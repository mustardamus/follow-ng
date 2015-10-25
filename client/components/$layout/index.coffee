module.exports =
  replace:  true
  template: require('./template')

  components:
    'page-home':     require('../page-home')
    'page-login':    require('../page-login')
    'page-user':     require('../page-user')
    'page-register': require('../page-register')
    'page-accounts': require('../page-accounts')
    'page-friends':  require('../page-friends')

  data: ->
    currentPage: ''
    loggedIn   : @$root.$data.loggedIn
    currentUser: { username: 'you' }

  compiled: ->
    @$root.$watch 'currentPage', (page) =>
      @$data.currentPage = page

    @$root.$watch 'loggedIn', (val) =>
      @$data.loggedIn = val

    @$root.$watch 'currentUser', (val) =>
      @$data.currentUser = val

  ready: ->
