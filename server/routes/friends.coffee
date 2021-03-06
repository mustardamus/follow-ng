_ = require('lodash')

module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

  @get '/friends/numbers', auth, (req, res, next) ->
    retObj = {}
    toGo   = 4
    accObj = { userId: req.user._id, accountId: req.query.accountId }
    obj    =
      followback:       { followed: true, backfollowed: true }
      followers:        { followed: false, backfollowed: true }
      friends:          { followed: true, backfollowed: false }
      potentialfriends: { followed: false, backfollowed: false }

    for mode, findObj of obj
      do (mode, findObj) ->
        models.friend.count _.extend(accObj, findObj), (err, count) ->
          return next(err) if(err)
          retObj[mode] = count
          toGo--
          res.json(retObj) if(toGo is 0)

  @get '/friends', auth, (req, res, next) ->
    limit   = 80
    page    = ((req.query.page or 1) - 1) * limit # turn page 1 into 0 based
    findObj = { userId: req.user._id, accountId: req.query.accountId }
    retObj  =
      'info.profile_image_url': 1
      'info.screen_name': 1

    switch req.query.mode
      when 'followback'
        _.extend(findObj, { followed: true, backfollowed: true })
      when 'followers'
        _.extend(findObj, { followed: false, backfollowed: true })
      when 'friends'
        _.extend(findObj, { followed: true, backfollowed: false })
      when 'potentialfriends'
        _.extend(findObj, { followed: false, backfollowed: false })

    models.friend.count findObj, (err, count) ->
      return next(err) if(err)

      models.friend
        .find(findObj, retObj)
        .skip(page).limit(limit)
        .exec (err, friends) ->
          return next(err) if(err)

          pages = Math.floor(count / limit) + 1
          res.json { items: friends, pages: pages }

  @post '/friends', (req, res, next) ->
  @put '/friends', (req, res, next) ->
  @delete '/friends', (req, res, next) ->
