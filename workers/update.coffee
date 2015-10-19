Twit = require('twit')
_    = require('lodash')

class ProcessAccount
  constructor: (@config, @models, @account) ->
    @workerName        = 'update'
    @modelName         = null
    @followerIds       = []
    @friendIds         = []
    @rateLimitExceeded = false

    @twit = new Twit
      consumer_key:        @config.twitter.consumerKey
      consumer_secret:     @config.twitter.consumerSecret
      access_token:        @account.accessToken
      access_token_secret: @account.accessTokenSecret

    @twit.get 'followers/ids', { screen_name: @account.info.screen_name }, (err, data, response) =>
      return console.log('Error receiving follower ids - ', err.message) if(err)
      @followerIds = data.ids

      @twit.get 'friends/ids', { screen_name: @account.info.screen_name }, (err, data, response) =>
        return console.log('Error receiving friends ids - ', err.message) if(err)
        @friendIds = data.ids

        @processIds()

  processIds: ->
    @processFollowCompleteIds _.difference(@followerIds, @friendIds)

  processFollowCompleteIds: (ids) ->
    for id in ids
      do (id) =>
        @insertFriend id, { followed: true, backfollowed: true }

  insertFriend: (userId, extendObj) ->
    @models.friend.find { accountId: @account._id, userId: @account.userId, 'info.id': userId }, (err, friend) =>
      return console.log('error finding friend') if(err)

      if friend
        friend.update extendObj, (err) ->
          if err
            console.log 'error updating friend', err
          else
            console.log "Updated friend #{friend.info.screen_name} for account #{@account.info.screen_name}."
      else
        return if(@rateLimitExceeded)

        @twit.get 'users/show', { user_id: userId }, (err, data, response) =>
          if err
            @rateLimitExceeded = true if(err.code is 88)
            console.log('error receiving user data - ', err.message) if(err)
            return

          data =
            userId:       @account.userId
            accountId:    @account._id
            info:         data
            sourceWorker: @workerName
            sourceModel:  @modelName
            sourceId:     null
            unfollowed:   false

          friend = new @models.friend(_.extend(data, extendObj))

          friend.save (err) =>
            if err
              console.log 'error saving friend', err
            else
              console.log "Saved friend #{friend.info.screen_name} for account #{@account.info.screen_name}."


module.exports = (config, models, helpers) ->
  models.account.find {}, (err, accounts) ->
    return console.log('Error finding accounts', err) if(err)

    for account in accounts
      do (account) ->
        new ProcessAccount(config, models, account)
