_ = require('lodash')

module.exports = (config, helpers, io, models) ->
  auth = require('../middleware/auth')(config, helpers)

  @post '/terms', auth, (req, res, next) ->
    screen_name = req.body.screen_name
    term        = req.body.term

    if !screen_name or !term
      return res.status(403).json({ message: 'screen_name or term missing.' })

    models.user.findById req.user._id, (err, user) ->
      return next(err) if(err)

      account     = null
      index       = 0
      accountsArr = user.accounts

      for acc in accountsArr
        if acc.info.screen_name is screen_name
          account = acc
          break
        index++

      unless account
        return res.status(403).json({ message: 'Can not find account with screen_name.' })

      unless _.isArray(accountsArr[index].searchTerms)
        accountsArr[index].searchTerms = []

      if _.indexOf(accountsArr[index].searchTerms, term) is -1
        accountsArr[index].searchTerms.push term

      user.update { accounts: accountsArr }, (err) ->
        return next(err) if(err)
        res.json({ success: true })

  @delete '/terms', auth, (req, res, next) ->
    screen_name = req.body.screen_name
    term        = req.body.term

    if !screen_name or !term
      return res.status(403).json({ message: 'screen_name or term missing.' })

    models.user.findById req.user._id, (err, user) ->
      return next(err) if(err)

      account     = null
      index       = 0
      accountsArr = user.accounts
      outArr      = []

      for acc in accountsArr
        if acc.info.screen_name is screen_name
          account = acc
          break
        index++

      unless account
        return res.status(403).json({ message: 'Can not find account with screen_name.' })

      for searchTerm in accountsArr[index].searchTerms
        if searchTerm isnt term
          outArr.push searchTerm

      accountsArr[index].searchTerms = outArr

      user.update { accounts: accountsArr }, (err) ->
        return next(err) if(err)
        res.json({ success: true })
