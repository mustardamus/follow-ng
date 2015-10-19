module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers, models)

  @post '/terms', auth, (req, res, next) ->
    userId      = req.user._id
    screen_name = req.body.screen_name
    termStr     = req.body.term

    if !screen_name or !termStr
      return res.status(403).json({ message: 'screen_name or term missing.' })

    models.term.findOne { userId: userId, term: termStr }, (err, term) ->
      return next(err) if(err)
      return res.json(403).status({ message: 'Term already exists.' }) if(term)

      models.account.findOne { userId: userId, 'info.screen_name': screen_name }, (err, account) ->
        return next(err) if(err)

        term = new models.term
          userId:    userId
          accountId: account._id
          term:      termStr

        term.save (err) ->
          return next(err) if(err)
          res.json({ success: true })

  @delete '/terms', auth, (req, res, next) ->
    userId      = req.user._id
    screen_name = req.body.screen_name
    term        = req.body.term

    if !screen_name or !term
      return res.status(403).json({ message: 'screen_name or term missing.' })

    models.account.findOne { userId: userId, 'info.screen_name': screen_name }, (err, account) ->
      return next(err) if(err)

      models.term.findOneAndRemove { userId: userId, accountId: account._id, term: term }, (err) ->
        return next(err) if(err)
        res.json({ success: true })
