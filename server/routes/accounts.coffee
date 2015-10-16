module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers)

  @get '/accounts', auth, (req, res, next) ->
    retArr = []
    toGo   = 0

    models.account.find { userId: req.user._id }, (err, accounts) ->
      return next(err) if(err)

      for account in accounts
        toGo++

        do (account) ->
          models.term.find { userId: req.user._id, accountId: account._id }, (err, terms) ->
            return if(err)

            termsArr = []

            for term in terms
              termsArr.push term.term

            retArr.push
              screen_name:       account.info.screen_name
              statuses_count:    account.info.statuses_count
              friends_count:     account.info.friends_count
              followers_count:   account.info.followers_count
              profile_image_url: account.info.profile_image_url
              terms:             termsArr

            toGo--
            res.json(retArr) if(toGo is 0)
