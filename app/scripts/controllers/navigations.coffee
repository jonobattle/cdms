class window.Navigations

  navigations = []

  constructor: (link) ->

    @url = null    

    # We are expecting a link that contains information on obtainin the navigation
    if link and link.page_object == "navigation"
      @url = link.href
  
      @load()


  load: ->
    # Load the navigations content from the url

    $.ajax
      url: @url
      dataType: "json"
      type: "GET"

      success: (json) ->

        # We are expecting a hypermedia collection and a page_object of navigations
        if json and json.collection and json.collection.page_object == "navigations"

          # Load the navigation objects from the json
          for item in json.collection.items
            if item.page_object == "navigation"

              navigation = []
              for object in item.data 
                navigation[object.name] = object.value

              navigations.push new window.Navigation(navigation)

          window.navigations.render()


  clear: ->

    $(NAVIGATION_CONTAINER).html("")

  render: ->



    # Highlight the initial navigation link
    # Find the current nav link and add the active class
    current_hash = window.location.hash
    if !/#/.test current_hash
      current_hash = "#/"

    @clear()
    for navigation in navigations

      active = ""
      if current_hash == "#/" + navigation.friendly_url
        active = "class=active" 

      $(NAVIGATION_CONTAINER).mk("li[" + active + "]",
        $.mk("a[href=#/" + navigation.friendly_url + "]", navigation.name)
      )


