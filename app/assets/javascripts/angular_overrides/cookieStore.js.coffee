#=require jquery.cookie

KarmaTracker.factory '$cookieStore', ->
  get: (name) ->
    $.cookie name

  set: (name, value, options) ->
    if options? && options.expires?
      $.cookie name, value, { expires: options.expires }
    else
      $.cookie name, value

  remove: (name) ->
    $.removeCookie name
