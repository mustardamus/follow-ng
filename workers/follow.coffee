async  = require('async')
moment = require('moment')
random = require('random-js')()

module.exports = class FollowWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'follow'
    funcsArr    = []

    findObj = # all friends that follow the account but the account dont follow them
      accountId:    @account._id
      userId:       @account.userId
      sourceWorker: 'search'
      followed:     false
      backfollowed: false
      unfollowed:   false

    @models.friend.find findObj, (err, friends) =>
      return @log('error', 'finding friends for account', err) if(err)

      for friend in friends
        continue if(random.integer(0, 10) is 5) # add a bit of randomness

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

      friend.update { followed: true, followedDate: moment() }, (error) =>
        if error
          @log 'error', 'updating friend model', error
        else
          @log 'info', "Followed @#{friend.info.screen_name}"

        return cb(null)
