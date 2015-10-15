module.exports =
  replace:  true
  template: require('./template')

  components: {}

  data: ->
    accounts: []

  ready: ->
    if @$root.$data.loggedIn
      @accountsRequest()

    @$root.$watch 'loggedIn', (loggedIn) =>
      @accountsRequest() if(loggedIn)

  methods:
    onAddAccountClick: ->
      $('#add.button', @$el).addClass 'loading'

      $.ajax
        url:      '/twitter'
        type:     'GET'
        dataType: 'json'
        success:  @onRedirectSuccess
        error:    @onRedirectError

    onRedirectSuccess: (obj) ->
      location.href = obj.redirectUrl

    onRedirectError: (res) ->
      console.log 'redirect obtain error', res

    accountsRequest: ->
      $.ajax
        url:      '/accounts'
        type:     'GET'
        dataType: 'json'
        success:  @onAccountsSuccess
        error:    @onAccountsError

    onAccountsSuccess: (accountsArr) ->
      @$data.accounts = accountsArr

    onAccountsError: (res) ->
      console.log 'get accounts error', res

    onRemoveSearchTermClick: (e) ->
      vm       = e.targetVM
      term     = vm.$value
      parentVm = vm.$parent
      outArr = []

      for searchTerm in parentVm.$data.searchTerms
        outArr.push(searchTerm) if(searchTerm isnt term)

      @removeSearchTermRequest vm.$parent.$data.screen_name, term
      vm.$parent.$data.searchTerms = outArr

    removeSearchTermRequest: (screen_name, term) ->
      console.log 'request remove', term, 'from', screen_name

    onSearchTermAdd: (e) ->
      vm   = e.targetVM
      term = $.trim(vm.$data.searchTerm)

      if term.length isnt 0
        @addSearchTermRequest vm.$data.screen_name, term
        vm.$data.searchTerms.push term
        vm.$data.searchTerm = ''

    addSearchTermRequest: (screen_name, term) ->
      console.log 'request add', term, 'to', screen_name
