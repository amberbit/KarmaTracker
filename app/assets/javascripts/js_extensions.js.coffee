String::endsWith = (suffix) ->
  @indexOf(suffix, @length - suffix.length) isnt -1

