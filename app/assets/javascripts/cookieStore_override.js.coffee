#=require jquery-2.0.3.min
#=require jquery.cookie

KarmaTracker.provider '$cookieStore', ->

  this.$get = ->
    return {
      get: (name) ->
        $.cookie name

      set: (name, value, options) ->
        if options? && options.expires?
          $.cookie name, value, { expires: options.expires }
        else
          $.cookie name, value

      remove: (name) ->
        $.removeCookie name
    }
