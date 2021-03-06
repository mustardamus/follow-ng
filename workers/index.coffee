fs       = require('fs')
mongoose = require('mongoose')
argv     = require('yargs').argv
Twit     = require('twit')
log      = require('npmlog')
moment   = require('moment')
config   = require('../server/config')

unless argv.worker
  console.log 'Please specify which worker to start with --worker=*'
  return

unless fs.existsSync("#{__dirname}/#{argv.worker}.coffee")
  console.log "Worker '#{argv.worker}.coffee' does not exist."
  return

unless config.workers.intervals[argv.worker]
  console.log "Please specify a interval for the worker '#{argv.worker}' in '../server/config.coffee'."
  return

initDir = (path) ->
  outObj = {}

  for fileName in fs.readdirSync(path)
    funcs = require("#{path}/#{fileName}")
    name  = fileName.split('.')[0]

    if funcs and name
      outObj[name] = funcs
      pathArr      = path.split('/')
      console.log "-> #{pathArr[pathArr.length - 1]}/#{fileName}"

  outObj

helpers = initDir(config.server.helpersDir)
models  = initDir(config.server.modelsDir)
db      = mongoose.connection

for resourceName, modelFunc of models
  models[resourceName] = modelFunc.call(mongoose, helpers)

db.on 'error', ->
  console.log "Can not connect to database #{config.database.url}! 'mongod' running?"

db.once 'open', ->
  console.log "Connected to database #{config.database.url}..."

  Worker     = require("./#{argv.worker}")
  workerCall = ->
    models.account.find {}, (err, accounts) ->
      return console.log('Error finding accounts', err) if(err)

      for account in accounts
        do (account) ->
          logFunc = (level, message, additional) ->
            time   = moment().format('HH:mm:ss')
            worker = argv.worker.toUpperCase()
            prefix = "#{time} - #{worker} (@#{account.info.screen_name}):"

            if additional
              log[level](prefix, message, additional)
            else
              log[level](prefix, message)

          twit = new Twit
            consumer_key:        config.twitter.consumerKey
            consumer_secret:     config.twitter.consumerSecret
            access_token:        account.accessToken
            access_token_secret: account.accessTokenSecret

          new Worker(config, models, helpers, account, logFunc, twit)

  setInterval ->
    workerCall()
  , 1000 * 60 * config.workers.intervals[argv.worker]

  workerCall()

mongoose.connect config.database.url
