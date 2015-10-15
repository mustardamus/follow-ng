module.exports =
  server:
    port         : 7799
    publicDir    : "#{__dirname}/../public"
    initializeDir: "#{__dirname}/initialize"
    helpersDir   : "#{__dirname}/helpers"
    routesDir    : "#{__dirname}/routes"
    modelsDir    : "#{__dirname}/models"

  database:
    url: 'mongodb://localhost/smartfollow'

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
