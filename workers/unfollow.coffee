async  = require('async')
moment = require('moment')
random = require('random-js')()

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
          if friend.sourceWorker is 'update' and !@account.settings.unfollowInitialFriends
            @log 'warn', "Not allowed to unfollow initital friends, @#{friend.info.screen_name}"
            return # dont unfollow initial/self-added friends

          now       = moment().unix()
          checkDate = moment(friend.followedDate).add(@account.settings.refollowPeriodDay, 'days').unix()

          if friend.followedDate and now < checkDate
            @log 'warn', "Still in refollow period, @#{friend.info.screen_name}"
            return # dont unfollow if still in refollow period

          funcsArr.push (cb) =>
            setTimeout =>
              @processFriend friend, cb
            , 1000 * 60 * random.integer(0, 10) # random 0-10 minutes in between follows

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
