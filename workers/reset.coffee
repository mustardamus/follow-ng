module.exports = class UnfollowWorker
  constructor: (@config, @models, @helpers, @account, @log, @twit) ->
    @workerName = 'reset'

    @account.update { hits: { follows: 0, unfollows: 0 }}, (err) =>
      if err
        @log 'error', 'Ressetting hits', err
      else
        @log 'info', 'Reset hits for account following and unfollowing'
