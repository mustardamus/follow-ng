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
    console.log friend
