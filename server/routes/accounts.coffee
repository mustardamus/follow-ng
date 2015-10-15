module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers)

  @get '/accounts', auth, (req, res, next) ->
    retArr = []

    models.user.findById req.user._id, (err, user) ->
      return next(err) if(err)

      for account in user.accounts
        ai = account.info

        retArr.push
          screen_name:       ai.screen_name
          statuses_count:    ai.statuses_count
          friends_count:     ai.friends_count
          followers_count:   ai.followers_count
          profile_image_url: ai.profile_image_url
          searchTerms:       account.searchTerms or []

      res.json retArr
