class window.Router

  constructor: ->

    $("#navigation>li>a").live "click", (e) ->
      $("li").removeClass "active"
      $(e.currentTarget).parent().addClass "active"


  route_to_current_hash: (hash) ->

    if hash.split("/").length > 0 && hash.length > 0
      route = hash.split("/")
    else 
      route = ("/").split("/")
      
    if route

      if route.length < 1
        route[1] = ""

      auth_token = window.session.auth_token

      $(document).ajaxSend (e, xhr, options) ->
        xhr.setRequestHeader "Authorization", auth_token

      # Hit the api with the supplied friendly url, then route based on the result
      $.ajax
        url: API_URL + "/" + route[1]
        dataType: "json"
        type: "GET"

        success: (json) ->

          # We don't know yet if its a collection or an item
          if json.item

            switch json.item.page_object
              when "page"
                window.pages.load_page json.item.data, json.item.page_object
                
              when "site"
                window.pages.load_page json.item.data, json.item.page_object
                

          else

            alert json.item.page_object
