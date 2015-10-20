module.exports =
  replace:  true
  template: require('./template')

  data: ->
    friends:     []
    currentPage: 1
    totalPages:  1
    loading:     false
    mode:        'followback' # followers | friends | potentialfriends
    numbers:     { followback: 0, followers: 0, friends: 0, potentialfriends: 0 }
    accounts:    @$root.$data.accounts
    accountId:   if @$root.$data.accounts[0] then @$root.$data.accounts[0].id else ''

  ready: ->
    if @$root.$data.loggedIn
      if @$data.accounts.length is 0
        @accountsRequest()
      else
        @numbersRequest()
        @friendsRequest()

    @$root.$watch 'loggedIn', (loggedIn) =>
      if loggedIn and @$data.accounts.length is 0
        @accountsRequest()

    @$root.$watch 'accounts', (accounts) =>
      @$data.accounts = accounts

    @$watch 'currentPage', ->
      @friendsRequest()

    @$watch 'accountId', ->
      @numbersRequest()
      @friendsRequest()

  methods:
    accountsRequest: ->
      $.ajax
        url:      '/accounts'
        type:     'GET'
        dataType: 'json'
        success:  @onAccountsSuccess
        error:    @onAccountsError

    onAccountsSuccess: (accounts) ->
      @$root.$data.accounts = accounts
      @$data.accountId      = accounts[0]._id

      @numbersRequest()
      @friendsRequest()

    onAccountsError: (res) ->
      console.log 'error', res

    numbersRequest: ->
      $.ajax
        url:      '/friends/numbers'
        type:     'GET'
        dataType: 'json'
        data:     { accountId: @$data.accountId }
        success:  @onNumbersSuccess
        error:    @onNumbersError

    onNumbersSuccess: (numbers) ->
      @$data.numbers = numbers

    onNumbersError: (res) ->
      console.log 'error', res

    friendsRequest: ->
      @$data.loading = true

      $.ajax
        url:      '/friends'
        type:     'GET'
        dataType: 'json'
        data:     { page: @$data.currentPage, mode: @$data.mode, accountId: @$data.accountId }
        success:  @onFriendsSuccess
        error:    @onFriendsError

    onFriendsSuccess: (res) ->
      @$data.totalPages = res.pages
      @$data.friends    = res.items
      @$data.loading    = false

      setTimeout =>
        $('img', @$el).popup()
      , 200

    onFriendsError: (res) ->
      @$data.loading = false
      console.log 'error', res

    onPrevPageClick: ->
      if @$data.currentPage - 1 > 0
        @$data.currentPage--

    onNextPageClick: ->
      if @$data.currentPage + 1 <= @$data.totalPages
        @$data.currentPage++

    onMenuItemClick: (e) ->
      @$data.mode        = $(e.toElement).data('mode')
      @$data.currentPage = 1
      @friendsRequest()

    onAccountClick: (e) ->
      @$data.accountId = e.targetVM.$data._id
