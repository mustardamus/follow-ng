module.exports =
  replace:  true
  template: require('./template')

  data: ->
    accounts: @$root.$data.accounts

  ready: ->
    if @$root.$data.loggedIn and @$data.accounts.length is 0
      @accountsRequest()

    @$root.$watch 'loggedIn', (loggedIn) =>
      if loggedIn and @$data.accounts.length is 0
        @accountsRequest()

    @$root.$watch 'accounts', (accounts) =>
      @$data.accounts = accounts

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
      @$root.$data.accounts = accountsArr

    onAccountsError: (res) ->
      console.log 'get accounts error', res

    onRemoveSearchTermClick: (e) ->
      vm       = e.targetVM
      term     = vm.$value
      parentVm = vm.$parent
      outArr = []

      for searchTerm in parentVm.$data.terms
        outArr.push(searchTerm) if(searchTerm isnt term)

      @removeSearchTermRequest vm.$parent.$data.screen_name, term
      vm.$parent.$data.terms = outArr

    removeSearchTermRequest: (screen_name, term) ->
      $.ajax
        url:      '/terms'
        type:     'DELETE'
        dataType: 'json'
        data: { screen_name: screen_name, term: term }

    onSearchTermAdd: (e) ->
      vm   = e.targetVM
      term = $.trim(vm.$data.term)

      if term.length isnt 0
        @addSearchTermRequest vm.$data.screen_name, term
        vm.$data.terms.push term
        vm.$data.term = ''

    addSearchTermRequest: (screen_name, term) ->
      $.ajax
        url:      '/terms'
        type:     'POST'
        dataType: 'json'
        data: { screen_name: screen_name, term: term }
