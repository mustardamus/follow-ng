twitterAPI = require('node-twitter-api')
Twit       = require('twit')

module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

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
    token              = req.query.oauth_token
    verifier           = req.query.oauth_verifier
    userId             = req.session.userId
    requestToken       = req.session.requestToken
    requestTokenSecret = req.session.requestTokenSecret

    if !userId or !token or !verifier or !requestToken or !requestToken
      return res.status(403).json({ message: 'Not all information provided.' })

    twitter.getAccessToken requestToken, requestTokenSecret, verifier, (err, accessToken, accessTokenSecret, results) ->
      return res.status(403).json({ message: err }) if(err)

      req.session.requestToken       = null
      req.session.requestTokenSecret = null
      req.session.userId             = null

      models.account.findOne { userId: userId, accessToken: accessToken }, (err, account) ->
        return next(err) if(err)

        if account
          return res.status(403).json({ message: 'Access Token already exists.' })

        T = new Twit
          consumer_key:        config.twitter.consumerKey
          consumer_secret:     config.twitter.consumerSecret
          access_token:        accessToken
          access_token_secret: accessTokenSecret

        T.get 'users/show', { screen_name: results.screen_name }, (err, data, response) ->
          return res.status(403).json({ message: 'Cant fetch user information.' }) if(err)

          account = new models.account
            userId:            userId
            accessToken:       accessToken
            accessTokenSecret: accessTokenSecret
            info:              data
            settings:
              unfollowInitialFriends: false

          account.save (err) ->
            return next(err) if(err)
            res.redirect '/#/accounts'
