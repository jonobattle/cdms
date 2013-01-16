class window.App

  constructor: ->

    @site = []

    $("a").address ->
      $(this).attr("href").replace /^#/, ""


  clear: ->

    $(CONTAINER).html ""

  load: ->

    @load_site_object()


  load_site_object: ->

    $.ajax
      url: API_URL
      dataType: "json"
      type: "GET"

      success: (json) ->

        window.router = new Router

        $.address.change (event) ->
          router.route_to_current_hash event.value    


        # We are expecting a hypermedia api as well as certain page_objects
        if json and json.item and json.item.page_object == "site"

          if json.item.links
            
            for link in json.item.links

              # We're expecting navigation so look for that and create the controller
              if link.page_object == "navigation"
                window.navigations = new Navigations(link) 

              # We're also expecting session so create that controller when found
              if link.page_object == "session"
                window.session = new Session(link)


            window.pages = new Pages
            router.route_to_current_hash window.location.hash










