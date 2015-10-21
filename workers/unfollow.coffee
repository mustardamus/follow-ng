async = require('async')

module.exports = class UnfollowWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'unfollow'
    funcsArr    = []

    findObj = # all friends that dont follow the account but the account follows them
      accountId:    @account._id
      userId:       @account.userId
      followed:     true
      backfollowed: false
      unfollowed:   false

    @models.friend.find findObj, (err, friends) =>
      return @log('error', 'finding friends for account', err) if(err)

      for friend in friends
        do (friend) =>
          # check if worker is update
          # check if setting allows to unfollow

          funcsArr.push (cb) =>
            @processFriend friend, cb

      async.series funcsArr

  processFriend: (friend, cb) ->
    if @account.hits.unfollows >= @account.settings.maxUnfollowsPerDay
      @log 'warn', 'Limit for daily unfollows reached'
      return cb(null)

    @twit.post 'friendships/destroy', { screen_name: friend.info.screen_name }, (err, data, response) =>
      @account.update { $inc: { 'hits.unfollows': 1 }}, (error) =>
        if(error)
          @log('error', 'Updating unfollow hit', error)
        else
          @account.hits.unfollows++

      if err
        @log('error', err.message, err)
        return cb(null)

      friend.update { unfollowed: true }, (error) =>
        if error
          @log 'error', 'Saving unfollowed to friend', error
        else
          @log 'info', "Unfollowed @#{friend.info.screen_name}"

        return cb(null)
