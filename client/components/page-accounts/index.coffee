module.exports =
  replace:  true
  template: require('./template')

  data: ->
    accounts:  @$root.$data.accounts
    accountId: if @$root.$data.accounts[0] then @$root.$data.accounts[0].id else ''
    settingsDefault:
      unfollowInitialFriends: false
      maxFollowsPerDay:       500
      maxUnfollowsPerDay:     500
      refollowPeriodDay:      5
    settings: if @$root.$data.accounts[0] then @$root.$data.accounts[0].settings else @$data.settingsDefault
    term    : ''
    terms   : []

  ready: ->
    if @$root.$data.loggedIn and @$data.accounts.length is 0
      @accountsRequest()

    @$root.$watch 'loggedIn', (loggedIn) =>
      if loggedIn and @$data.accounts.length is 0
        @accountsRequest()

    @$root.$watch 'accounts', (accounts) =>
      @$data.accounts = accounts

    @$watch 'accountId', (id) ->
      $('.form.settings', @$el).removeClass 'success error'

      for account in @$root.accounts
        if account.id is @$data.accountId
          @$data.settings = account.settings
          break

      @termsRequest()

    @$watch 'settings', (settings) ->
      for account in @$root.accounts
        if account.id is @$data.accountId
          account.settings = settings
          break

    $('.ui.checkbox', @$el).checkbox()

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

    onAccountsSuccess: (accounts) ->
      @$root.$data.accounts = accounts
      @$data.accountId      = accounts[0]._id

    onAccountsError: (res) ->
      console.log 'get accounts error', res

    onAccountClick: (e) ->
      @$data.accountId = e.targetVM.$data._id

    onSaveSettingsClick: (e) ->
      @saveSettingsRequest()
      e.preventDefault()

    saveSettingsRequest: ->
      return unless @validateSettingsForm()

      $('.form.settings', @$el).addClass 'loading'

      @$data.settings =
        accountId:              @$data.accountId
        unfollowInitialFriends: $('#unfollowInitialFriends', @$el).is(':checked')
        maxFollowsPerDay:       $('#maxFollowsPerDay', @$el).val()
        maxUnfollowsPerDay:     $('#maxUnfollowsPerDay', @$el).val()
        refollowPeriodDay:      $('#refollowPeriodDay', @$el).val()

      $.ajax
        url:      '/accounts/settings'
        type:     'POST'
        dataType: 'json'
        data:     @$data.settings
        success:  @onSaveSettingsSuccess
        error:    @onSaveSettingsError

    onSaveSettingsSuccess: (res) ->
      $('.form.settings', @$el)
        .addClass('success')
        .removeClass('loading')

    onSaveSettingsError: (res) ->
      $('.form.settings', @$el)
        .addClass('error')
        .removeClass('loading')

    validateSettingsForm: ->
      valid           = true
      maxFollowsEl    = $('#maxFollowsPerDay', @$el)
      maxFollowsVal   = maxFollowsEl.val()
      maxUnfollowsEl  = $('#maxUnfollowsPerDay', @$el)
      maxUnfollowsVal = maxUnfollowsEl.val()
      refollowEl      = $('#refollowPeriodDay', @$el)
      refollowVal     = refollowEl.val()

      if maxFollowsVal.length is 0 or isNaN(maxFollowsVal) or +maxFollowsVal < 0 or +maxFollowsVal > @$data.settingsDefault.maxFollowsPerDay
        maxFollowsEl.parent().addClass 'error'
        valid = false

      if maxUnfollowsVal.length is 0 or isNaN(maxUnfollowsVal) or +maxUnfollowsVal < 0 or +maxUnfollowsVal > @$data.settingsDefault.maxUnfollowsPerDay
        maxUnfollowsEl.parent().addClass 'error'
        valid = false

      if refollowVal.length is 0 or isNaN(refollowVal) or +refollowVal < 0
        refollowEl.parent().addClass 'error'
        valid = false

      if valid
        $('.form.settings .field.error', @$el).removeClass 'error'

      valid

    termsRequest: ->
      $.ajax
        url:      '/terms'
        type:     'GET'
        dataType: 'json'
        data: { accountId: @$data.accountId }
        success:  @onTermsSuccess
        error:    @onTermsError

    onTermsSuccess: (terms) ->
      @$data.terms = terms

    onTermsError: (res) ->
      console.log 'error', res

    onSearchTermAdd: (e) ->
      return if(@$data.term.length is 0)

      $.ajax
        url:      '/terms'
        type:     'POST'
        dataType: 'json'
        data: { accountId: @$data.accountId, term: @$data.term }
        success:  @onTermAddSuccess
        error:    @onTermAddError

      e.preventDefault()

    onTermAddSuccess: ->
      @$data.terms.push { term: @$data.term }
      @$data.term = ''

    onTermAddError: (res) ->
      console.log 'error', res

    onDeleteTermClick: (e) ->
      $.ajax
        url:      '/terms'
        type:     'DELETE'
        dataType: 'json'
        data: { accountId: @$data.accountId, term: e.targetVM.$data.term }
        success:  @onTermDeleteSuccess
        error:    @onTermDeleteError

    onTermDeleteSuccess: ->
      @termsRequest() # eazy way

    onTermDeleteError: (res) ->
      console.log 'error', res
