async = require('async')

module.exports = class FollowbackWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'search'
    @modelName  = 'term'
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
    if @account.hits.follows >= @account.settings.maxFollowsPerDay
      @log 'warn', 'Limit for daily follows reached'
      return cb(null)

    @twit.post 'friendships/create', { screen_name: friend.info.screen_name }, (err, data, result) =>
      @account.update { $inc: { 'hits.follows': 1 }}, (error) =>
        if(error)
          @log('error', 'Updating follow hit', error)
        else
          @account.hits.follows++

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
