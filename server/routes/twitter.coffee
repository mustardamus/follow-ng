twitterAPI = require('node-twitter-api')
Twit       = require('twit')

module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers)

  twitter = new twitterAPI
    consumerKey:    config.twitter.consumerKey
    consumerSecret: config.twitter.consumerSecret
    callback:       config.twitter.callback

  @get '/twitter', auth, (req, res, next) ->
    twitter.getRequestToken (err, requestToken, requestTokenSecret, results) ->
      return next(err) if(err)

      req.session.userId             = req.user._id
      req.session.requestTokenSecret = requestTokenSecret
      req.session.requestToken       = requestToken

      res.json({ redirectUrl: twitter.getAuthUrl(requestToken) })

  @get '/twitter_callback', (req, res, next) ->
    models.user.findById req.session.userId, (err, user) ->
      return res.status(403).json({ message: 'No user provided. '}) if(err)

      token              = req.query.oauth_token
      verifier           = req.query.oauth_verifier
      requestToken       = req.session.requestToken
      requestTokenSecret = req.session.requestTokenSecret

      if !token or !verifier or !requestToken or !requestToken
        return res.status(403).json({ message: 'Not all information provided.' })

      twitter.getAccessToken requestToken, requestTokenSecret, verifier, (err, accessToken, accessTokenSecret, results) ->
        return res.status(403).json({ message: err }) if(err)

        user.requestToken       = null
        user.requestTokenSecret = null
        req.session.userId      = null
        isNewToken              = true

        for account in user.accounts
          if account.accessToken is accessToken
            isNewToken = false
            break

        if isNewToken
          T = new Twit
            consumer_key:        config.twitter.consumerKey
            consumer_secret:     config.twitter.consumerSecret
            access_token:        accessToken
            access_token_secret: accessTokenSecret

          T.get 'users/show', { screen_name: results.screen_name }, (err, data, response) ->
            return res.status(403).json({ message: 'Cant fetch user information.' }) if(err)

            user.accounts.push
              accessToken:       accessToken
              accessTokenSecret: accessTokenSecret
              info:              data

            user.save (err) ->
              return next(err) if(err)
              res.redirect '/#/accounts'
        else
          res.redirect '/#/accounts'
