class window.Page

  constructor: (page) ->
    @name = if page.name then page.name else ""
    @description = if page.description then page.description else ""
    @body = if page.body then page.body else ""
