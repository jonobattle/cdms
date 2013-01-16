class window.Pages

  constructor: ->
    @current_page = null


  get_object_data: (data) ->
    page = []

    for object in data
      page[object.name] = object.value

    return page


  clear: ->
    $(CONTAINER).html("")


  load_page: (data, page_object) ->

    if data 
      page = @get_object_data(data)

      @current_page = new window.Page(page)
      @render(page_object)



  render: (page_object) ->

    if @current_page

      # Render using mkay
      @clear()

      switch page_object
        
        when "page"
          $(CONTAINER).mk(".page-header", 
            $.mk("h1", @current_page.name)
          )
          
          $(CONTAINER).mk("p", @current_page.body)
          
          return

        when "site"

          $(CONTAINER).mk(".row",
            $.mk(".span4", "Yo!")
            $.mk(".span4", "Yo!")
            $.mk(".span4", "Yo!")
          )          

          return
