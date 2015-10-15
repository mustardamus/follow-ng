module.exports =
  replace:  true
  template: require('./template')

  components: {}

  data: ->

  ready: ->

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
      console.log 'error', res
