module.exports = (config, models, helpers) ->
  models.account.find {}, (err, accounts) ->
    console.log 'found accounts', accounts.length
