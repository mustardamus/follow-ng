_      = require('lodash')
moment = require('moment')

module.exports = class UnfollowWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName        = 'unfollow'
    @modelName         = null

    findObj = # all friends that dont follow the account but the account follows them
      accountId:    @account._id
      userId:       @account.userId
      followed:     true
      backfollowed: false

    @models.friend.find findObj, (err, friends) =>
      return @log('error', 'finding friends for account', err) if(err)

      for friend in friends
        @processFriend friend

  processFriend: (friend) ->
    @log 'info', friend.info.screen_name
