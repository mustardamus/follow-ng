module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers)

  @get '/accounts', auth, (req, res, next) ->
    models.account.find { userId: req.user._id }, (err, accounts) ->
      return next(err) if(err)

      retArr = []

      for account in accounts
        ai = account.info

        retArr.push
          screen_name:       ai.screen_name
          statuses_count:    ai.statuses_count
          friends_count:     ai.friends_count
          followers_count:   ai.followers_count
          profile_image_url: ai.profile_image_url

      res.json retArr
