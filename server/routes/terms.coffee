module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

  @get '/terms', auth, (req, res, next) ->
    userId    = req.user._id
    accountId = req.query.accountId

    models.term.find { accountId: accountId, userId: userId }, (err, terms) ->
      return res.status(403).json({ message: 'Can not get terms' }) if(err)

      res.json(terms)

  @post '/terms', auth, (req, res, next) ->
    userId    = req.user._id
    accountId = req.body.accountId
    termStr   = req.body.term

    models.term.count { accountId: accountId, userId: userId, term: termStr }, (err, count) ->
      return next(err) if(err)
      return res.json(403).status({ message: 'Term already exists.' }) if(count isnt 0)

      term = new models.term
        userId:    userId
        accountId: accountId
        term:      termStr

      term.save (err) ->
        return next(err) if(err)
        res.json({ success: true })

  @delete '/terms', auth, (req, res, next) ->
    userId    = req.user._id
    accountId = req.body.accountId
    termStr   = req.body.term

    models.term.findOneAndRemove { userId: userId, accountId: accountId, term: termStr }, (err) ->
      return next(err) if(err)
      res.json({ success: true })
