class window.Pages

  constructor: ->
    @current_page = null
    @current_template = null


  clear: ->
    $(CONTAINER).html("")


  load_page: (item) ->

    if item and item.data
      @current_page = new window.Page(item)
      @render(item.page_object)


  render: (page_object) ->

    if @current_page

      # Render using mkay
      @clear()

      switch page_object
        
        when "page"

          # Add template classes if available
          $(CONTAINER).mk(".page-header", 
            $.mk("h1#name.data", @current_page.data("name").value)
          )
          
          $(CONTAINER).mk("p#body.data", @current_page.data("body").value)
          
        when "site"

          $(CONTAINER).mk(".row",
            $.mk(".span4", "Yo!")
            $.mk(".span4", "Yo!")
            $.mk(".span4", "Yo!")
          )          

        else

          $(CONTAINER).mk(".page-header",
            $.mk("h1", "Page Not Found")
          )


      # Now that the content is on the screen, see if we need to add template functionality
      # Grab the template if we have one and then match up the ids with the names in the template
      
      if @current_page.template_datas
        for template in @current_page.template_datas
          $("#" + template.name + ".data").addClass "editable"
          $("#" + template.name + ".data").attr "data-type", template.type




      # Add the editing controls

      $(".editable").die "hover"
      $(".editable").live "hover", (e) ->
        $(e.currentTarget).toggleClass "hover"

      $(".editable").die "click"
      $(".editable").live "click", (e) ->
        
        $("body").mk("#shroud")
        $("body").mk("#editor")

        $("#editor").ckeditor()

        # Determine the data type and add the appropriate input
        input = ""
        switch $(e.currentTarget).attr "data-type"
          when "string"
            input = $.mk("input[type=text]")

        $("#editor").append input

        # Get the location of the clicked element and match the editor to it
        position = $(e.currentTarget).position()

        height = $(e.currentTarget).outerHeight()
        width = $(e.currentTarget).outerWidth()
        
        $("#editor").css {top: position.top - 10 + parseInt($(e.currentTarget).css('margin-top')), left: position.left - 10, height: height + 20, width: width + 20 }

        $("#shroud").die "click"
        $("#shroud").live "click", (e) ->
          $(e.currentTarget).remove()
          $("#editor").remove()
















