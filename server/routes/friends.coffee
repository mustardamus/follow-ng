module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers)

  @get '/friends', auth, (req, res, next) ->
    models.friend.find { userId: req.user._id }, (err, friends) ->
      return next(err) if(err)
      res.json friends

  @post '/friends', (req, res, next) ->
  @put '/friends', (req, res, next) ->
  @delete '/friends', (req, res, next) ->
