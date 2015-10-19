module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

  @get '/friends', auth, (req, res, next) ->
    console.log 'find friends', req.user
    models.friend
      .find({ userId: req.user._id })
      .skip(0).limit(10)
      .exec (err, friends) ->
        return next(err) if(err)
        res.json { friends: friends }

  @post '/friends', (req, res, next) ->
  @put '/friends', (req, res, next) ->
  @delete '/friends', (req, res, next) ->
