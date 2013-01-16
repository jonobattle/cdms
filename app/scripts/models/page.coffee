class window.PageData

  constructor: (data) ->

    @name = if data.name then data.name else ""
    @value = if data.value then data.value else ""
    @prompt = if data.prompt then data.prompt else ""
    @type = if data.type then data.type else ""
    @options = data.options if data.options
    @values = data.values if data.values


class window.Page

  constructor: (item) ->

    @datas = []
    @template_datas = []

    # Get the page data
    if item.data 
      for data_object in item.data
        @datas.push new window.PageData(data_object)

  
    if item.template and item.template.data
      for data_object in item.template.data 
        @template_datas.push new window.PageData(data_object)


  data: (key) ->

    for d in @datas
      if d.name == key
        return d


  template_data: (key) ->

    for d in @template_datas
      if d.name == key
        return d


