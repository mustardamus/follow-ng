module.exports =
  replace:  true
  template: require('./template')

  data: ->
    friends: []

  ready: ->
    if @$root.$data.loggedIn
      @friendsRequest()

    @$root.$watch 'loggedIn', (loggedIn) =>
      @friendsRequest() if(loggedIn)

  methods:
    friendsRequest: ->
      $.ajax
        url:      '/friends'
        type:     'GET'
        dataType: 'json'
        success:  @onFriendsSuccess
        error:    @onFriendsError

    onFriendsSuccess: (friends) ->
      @$data.friends = friends

    onFriendsError: (res) ->
      console.log 'error', res
