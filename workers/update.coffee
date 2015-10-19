Twit = require('twit')
_    = require('lodash')

module.exports = class UpdateWorker
  constructor: (@config, @models, @helpers, @account, @log) ->
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
      return @log('Error receiving follower ids - ', err.message) if(err)
      @followerIds = data.ids

      @twit.get 'friends/ids', { screen_name: @account.info.screen_name }, (err, data, response) =>
        return @log('Error receiving friends ids - ', err.message) if(err)
        @friendIds = data.ids

        @processIds()

  processIds: ->
    @processFollowCompleteIds _.union(@followerIds, @friendIds)

  processFollowCompleteIds: (ids) ->
    for id in ids
      do (id) =>
        @insertFriend id, { followed: true, backfollowed: true }

  insertFriend: (userId, extendObj) ->
    @models.friend.findOne { accountId: @account._id, userId: @account.userId, 'info.id_str': "#{userId}" }, (err, friend) =>
      return @log('error finding friend') if(err)

      if friend and (friend.followed isnt true or friend.backfollowed isnt true)
        friend.update extendObj, (err) =>
          if err
            @log 'error updating friend', err
          else
            @log "Updated friend #{friend.info.screen_name} for account #{@account.info.screen_name}."
      else
        return if(@rateLimitExceeded)

        @twit.get 'users/show', { user_id: userId }, (err, data, response) =>
          if err
            @rateLimitExceeded = true if(err.code is 88)
            @log('error receiving user data - ', err.message) if(err)
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
              @log 'error saving friend', err
            else
              @log "Saved friend #{friend.info.screen_name} for account #{@account.info.screen_name}."
