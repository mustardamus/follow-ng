module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

  @get '/accounts', auth, (req, res, next) ->
    retObj =
      'info.screen_name':       1
      'info.profile_image_url': 1
      'info.statuses_count':    1
      'info.friends_count':     1
      'followers_count':        1

    models.account.find { userId: req.user._id }, retObj, (err, accounts) ->
      return next(err) if(err)

  @get '/accounts/terms', auth, (req, res, next) ->
    retArr = []
    toGo   = 0

    models.account.find { userId: req.user._id }, (err, accounts) ->
      return next(err) if(err)

      for account in accounts
        toGo++

        do (account) ->
          models.term.find { userId: req.user._id, accountId: account._id }, { term: 1 }, (err, terms) ->
            return if(err)

            retArr.push
              _id:               account._id
              screen_name:       account.info.screen_name
              statuses_count:    account.info.statuses_count
              friends_count:     account.info.friends_count
              followers_count:   account.info.followers_count
              profile_image_url: account.info.profile_image_url
              terms:             terms

            toGo--
            res.json(retArr) if(toGo is 0)
