async = require('async')

module.exports = class BackfollowWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'backfollow'
    funcsArr    = []

    findObj = # all friends that follow the account but the account dont follow them
      accountId:    @account._id
      userId:       @account.userId
      followed:     false
      backfollowed: true
      unfollowed:   false

    @models.friend.find findObj, (err, friends) =>
      return @log('error', 'finding friends for account', err) if(err)

      for friend in friends
        do (friend) =>
          funcsArr.push (cb) =>
            @processFriend friend, cb

      async.series funcsArr

  processFriend: (friend, cb) ->
    @twit.post 'friendships/create', { screen_name: friend.info.screen_name }, (err, data, result) =>
      if err
        @log('error', err.message, err)

        unless err.code is 160 # already requested the follow to a private account, let thru
          return cb(null)

      friend.update { followed: true }, (error) =>
        if error
          @log 'error', 'updating friend model', error
        else
          @log 'info', "Backfollowed @#{friend.info.screen_name}"

        return cb(null)
