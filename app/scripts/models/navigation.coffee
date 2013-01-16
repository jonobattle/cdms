class window.Navigation

  constructor: (navigation) ->

    @name = if navigation.name then navigation.name else ""
    @description = if navigation.description then navigation.description else ""
    @url = if navigation.url then navigation.url else ""
    @friendly_url = if navigation.friendly_url then navigation.friendly_url else ""