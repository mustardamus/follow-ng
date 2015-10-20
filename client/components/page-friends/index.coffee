module.exports =
  replace:  true
  template: require('./template')

  data: ->
    friends:     []
    currentPage: 1
    totalPages:  1
    loading:     false
    mode:        'followback' # followers | friends | potentialfriends

  ready: ->
    if @$root.$data.loggedIn
      @friendsRequest()

    @$root.$watch 'loggedIn', (loggedIn) =>
      @friendsRequest() if(loggedIn)

    @$watch 'currentPage', ->
      @friendsRequest()

  methods:
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
