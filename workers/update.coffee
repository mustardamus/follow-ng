_ = require('lodash')

module.exports = class UpdateWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName        = 'update'
    @modelName         = null
    @followerIds       = []
    @friendIds         = []
    @rateLimitExceeded = false

    @twit.get 'followers/ids', { screen_name: @account.info.screen_name }, (err, data, response) =>
      return @log('Error receiving follower ids - ', err.message) if(err)
      @followerIds = data.ids

      @twit.get 'friends/ids', { screen_name: @account.info.screen_name }, (err, data, response) =>
        return @log('Error receiving friends ids - ', err.message) if(err)
        @friendIds = data.ids

        @processIds()

  processIds: ->
    followbackIds = []
    followerIds   = []
    friendIds     = []

    for followerId in @followerIds
      if _.indexOf(@friendIds, followerId) isnt -1
        followbackIds.push followerId
      else
        followerIds.push followerId

    for friendId in @friendIds
      if _.indexOf(followbackIds, friendId) is -1
        friendIds.push friendId

    @processFollowbackIds followbackIds
    @processFollowerIds followerIds
    @processFriendIds friendIds

  processFollowbackIds: (ids) ->
    for id in ids
      @insertFriend id, { followed: true, backfollowed: true }

  processFollowerIds: (ids) ->
    for id in ids
      @insertFriend id, { followed: false, backfollowed: true }

  processFriendIds: (ids) ->
    for id in ids
      @insertFriend id, { followed: true, backfollowed: false }

  insertFriend: (userId, extendObj) ->
    @models.friend.findOne { accountId: @account._id, userId: @account.userId, 'info.id': userId }, (err, friend) =>
      return @log('error finding friend') if(err)

      if friend
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
