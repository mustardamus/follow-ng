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
    accounts:    []

  ready: ->
    if @$root.$data.loggedIn
      @startRequests()

    @$root.$watch 'loggedIn', (loggedIn) =>
      @startRequests() if(loggedIn)

    @$watch 'currentPage', ->
      @friendsRequest()

  methods:
    startRequests: ->
      @accountsRequest()
      @numbersRequest()
      @friendsRequest()

    accountsRequest: ->
      $.ajax
        url:      '/accounts'
        type:     'GET'
        dataType: 'json'
        success:  @onAccountsSuccess
        error:    @onAccountsError

    onAccountsSuccess: (accounts) ->
      @$data.accounts = accounts

    onAccountsError: (res) ->
      console.log 'error', res

    numbersRequest: ->
      $.ajax
        url:      '/friends/numbers'
        type:     'GET'
        dataType: 'json'
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
        data:     { page: @$data.currentPage, mode: @$data.mode }
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
      vm = e.targetVM
      id = vm.$data._id
      el = $(e.toElement)

      $('.menu.accounts .active.teal', @$el).removeClass 'active teal'
      el.addClass 'active teal'
