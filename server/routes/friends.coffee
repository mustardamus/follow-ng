module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

  @get '/friends', auth, (req, res, next) ->
    limit  = 40
    page   = ((req.query.page or 1) - 1) * limit # turn page 1 into 0 based
    retObj =
      'info.profile_image_url': 1
      'info.screen_name': 1

    models.friend.count (err, count) ->
      return next(err) if(err)

      models.friend
        .find({ userId: req.user._id }, retObj)
        .skip(page).limit(limit)
        .exec (err, friends) ->
          return next(err) if(err)

          pages = Math.floor(count / limit) + 1
          res.json { items: friends, pages: pages }

  @post '/friends', (req, res, next) ->
  @put '/friends', (req, res, next) ->
  @delete '/friends', (req, res, next) ->
