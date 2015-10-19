module.exports =
  server:
    port         : 7799
    publicDir    : "#{__dirname}/../public"
    initializeDir: "#{__dirname}/initialize"
    helpersDir   : "#{__dirname}/helpers"
    routesDir    : "#{__dirname}/routes"
    modelsDir    : "#{__dirname}/models"

  session:
    secret: 'HuDfoF7bFyU1nVe6$a$0$21SWS1Vu'

  database:
    url: 'mongodb://localhost/followNG'

  auth:
    loginPath   : '/login'
    registerPath: '/register'
    secret      : '$2a$16$0S1VuSWHuDfoF7bFyU1nVe'
    saltLength  : 10
    messages    :
      userNotFound   : 'Can not find user.'
      wrongPassword  : 'Wrong password.'
      usernameMissing: 'Username missing.'
      passwordMissing: 'Password missing.'
      usernameExists : 'Username already exists.'
      emailExists    : 'E-Mail already exists.'
      invalidEmail   : 'Invalid E-Mail address.'
      noToken        : 'No token provided.'
      invalidToken   : 'Invalid token.'
      userFindError  : 'Can not find user.'

  twitter:
    consumerKey:    'SccAMm9AQEWgC5CI8yAG1QzYa'
    consumerSecret: '4s7ddqa7g49o48k0aFHjZD3rHzrBJi4SG0LHyUz9vfjDWFspZF'
    callback:       'http://127.0.0.1:7799/twitter_callback'

  workers:
    intervals: # in minutes
      search: 15
      update: 15
