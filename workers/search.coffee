Twit = require('twit')
_    = require('lodash')

module.exports = class SearchWorker
  constructor: (@config, @models, @helpers, @account, @log) ->
    @workerName = 'search'
    @modelName  = 'term'

    @twit = new Twit
      consumer_key:        @config.twitter.consumerKey
      consumer_secret:     @config.twitter.consumerSecret
      access_token:        @account.accessToken
      access_token_secret: @account.accessTokenSecret

    @models.term.find { accountId: @account._id }, (err, terms) =>
      return @log("Error finding terms for account #{@account.info.screen_name}", err) if err

      for term in terms
        @processTerm term

  processTerm: (term) ->
    searchObj = { q: term.term, count: 100, since_id: term.since_id_str }

    @twit.get 'search/tweets', searchObj, (err, data, response) =>
      return @log("Error searching Twitter", { screen_name: @account.info.screen_name, term: term.term }) if(err)

      term.update { since_id_str: data.search_metadata.max_id_str }, (err) ->
        @log('Error saving since_id') if(err)

      usernamesArr    = []
      uniqueStatusArr = []

      for status in data.statuses
        screen_name = status.user.screen_name

        if _.indexOf(usernamesArr, screen_name) is -1
          usernamesArr.push screen_name
          uniqueStatusArr.push status

      for status in uniqueStatusArr
        @processStatus status, term

  processStatus: (status, term) ->
    userInfo = status.user
    findObj  = { userId: @account.userId, accountId: @account._id, 'info.screen_name': userInfo.screen_name }

    @models.friend.count findObj, (err, count) =>
      return @log("Error counting friend models") if(err)
      return if(count isnt 0) # already in db

      friend = new @models.friend
        userId:       @account.userId
        accountId:    @account._id
        info:         userInfo
        sourceWorker: @workerName
        sourceModel:  @modelName
        sourceId:     term._id
        followed:     false
        unfollowed:   false
        backfollowed: false

      friend.save (err) =>
        if(err)
          @log 'Error saving friend', friend.info.screen_name
        else
          @log 'Saved potential friend', friend.info.screen_name, 'for account', @account.info.screen_name, 'with term', term.term
