_ = require('lodash')

module.exports = class SearchWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'search'
    @modelName  = 'term'

    @models.term.find { accountId: @account._id }, (err, terms) =>
      return @log('error', "finding terms for account #{@account.info.screen_name}", err) if(err)

      for term in terms
        @processTerm term

  processTerm: (term) ->
    searchObj = { q: term.term, count: 100, since_id: term.since_id_str }

    @twit.get 'search/tweets', searchObj, (err, data, response) =>
      return @log('error', err.message) if(err)

      term.update { since_id_str: data.search_metadata.max_id_str }, (err) ->
        @log('error', 'saving since_id', err) if(err)

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
      return @log('error', 'counting friend models', err) if(err)
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
          @log 'error', 'saving friend', err
        else
          @log 'info', "Saved potential friend @#{friend.info.screen_name} with term '#{term.term}'"
