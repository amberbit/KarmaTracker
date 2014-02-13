KarmaTracker.factory 'PasswordReset', ['$resource', ($resource) ->
  class PasswordReset
    constructor: ->
      @service = $resource("/api/v1/password_reset", {}, {
        update:
          method: 'PUT'
      })

    create: (email) =>
      @service.save(email: email)

    update: (token, password, password_confirmation) =>
      @service.update(token: token, password: password, confirmation: password_confirmation)

]
