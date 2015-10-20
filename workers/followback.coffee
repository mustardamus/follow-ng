_ = require('lodash')

module.exports = class FollowbackWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'search'
    @modelName  = 'term'

    findObj = # all friends that follow the account but the account dont follow them
      accountId:    @account._id
      userId:       @account.userId
      followed:     false
      backfollowed: true

    @models.friend.find findObj, (err, friends) =>
      return @log('error finding friends for account', err) if(err)

      for friend in friends
        @processFriend friend

  processFriend: (friend) ->
    @twit.post 'friendships/create', { screen_name: friend.info.screen_name }, (err, data, result) =>
      return @log('error following friend', err) if(err)

      friend.update { followed: true }, (err) =>
        if err
          @log 'error updating friend model', err
        else
          @log "Backfolloweed #{friend.info.screen_name} for account #{@account.info.screen_name}..."
