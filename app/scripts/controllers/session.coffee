class window.Session

  session_page = null
  account = null

  interval = null
  ping_url = null
  logout_url = null

  constructor: (link) ->

    @url = null
    
    if link and link.page_object == "session"
      @url = link.href
      @load()


  auth_token: ->
    $.cookie "authorization_token"


  set_auth_token: (auth_token) ->
    $.cookie "authorization_token", auth_token,
      expires: 7
      path: "/"

  kill_auth_token: ->
    $.removeCookie "authorization_token",
      path: "/"


  ping: ->

    auth_token = window.session.auth_token()

    $(document).ajaxSend (e, xhr, options) ->
      xhr.setRequestHeader "Authorization", auth_token

    $.ajax
      url: ping_url
      dataType: "json"
      type: "GET"

      success: (json) ->

        if json and json.item and json.item.page_object == "session_ping"
          if json.item.flash
            for flash in json.item.flash
              if flash.type == "error"
                # If its an error then we need to log the user out
                window.session.stop_ping()
                window.session.kill_auth_token()
                window.session.load()


  start_ping: ->
    interval = setInterval @ping, 10000


  stop_ping: ->
    clearInterval interval


  load: ->

    auth_token = @auth_token()

    $(document).ajaxSend (e, xhr, options) ->
      xhr.setRequestHeader "Authorization", auth_token

    $.ajax
      url: @url
      dataType: "json"
      type: "GET"

      success: (json) ->

        # We are expecting a hypermedia item for the session page
        if json and json.item and json.item.page_object == "session"
          session_page = json.item

          # Check if the response has a data item
          if json.item.data 
            # Build the account 

            account_data = []
            for object in json.item.data
              account_data[object.name] = object.value

            account = new Account(account_data)

            # We expect a url that lets us ping the session 
            for link in json.item.links
              if link.page_object == "ping"
                ping_url = link.href

              if link.page_object == "logout"
                logout_url = link.href

            window.session.start_ping()

          else
            # Kill any remnants of the session
            window.session.kill_auth_token()


          window.session.render()


  clear: ->

    $(SESSION_CONTAINER).html("")



  attempt_login: (email, password) ->

    if email and password

      $(document).ajaxSend (e, xhr, options) ->
        xhr.setRequestHeader "Authorization", ""      

      $.ajax
        url: @url
        dataType: "json"
        type: "POST"
        data:
          email: email
          password: password
          device_slug: "web"


        success: (json) ->

          # Check the json for the result
          if json and json.item and json.item.page_object == "session_attempt"
            
            # We expect data and a succesful flash message if logged in
            if json.item.data

              for flash in json.item.flash
                if flash.type == "success"
                  
                  # Grab the auth_token
                  for object in json.item.data
                    if object.name == "authorization_token"
                      window.session.set_auth_token object.value 

                  # We've got the auth token, so now hit the api again and grab the session details
                  window.session.load()


            else

              # There was an issue, so check for a flash message and display that
              for flash in json.item.flash
                if flash.type == "error"
                  alert flash.message
                  window.session.render()

          else

            alert "There was an error when trying to log in"
            window.session.render()


  logout: ->

    if logout_url

      $(".session-bar").fadeOut "fast", ->

        $(document).ajaxSend (e, xhr, options) ->
          xhr.setRequestHeader "Authorization", ""      

        $.ajax
          url: logout_url
          dataType: "json"
          type: "GET"
          
          success: (json) ->

            if json and json.item and json.item.page_object == "session"
              window.session.stop_ping()
              window.session.kill_auth_token()
              window.session.load()




  render: ->

    if window.session.auth_token() != null and account != null
      @render_logged_in()
    else
      @render_not_logged_in()



  render_logged_in: ->

    # Add padding to the page to allow for the session bar
    $(".navbar-wrapper").animate {paddingTop: 70}

    if session_page

      if $(".session-bar").length < 1
        $(SESSION_CONTAINER).mk(".navbar",
          $(SESSION_CONTAINER).mk(".navbar-inner.session-bar")
        )
        $(".session-bar").hide()

      $(".session-bar").fadeOut "fast", ->
        $(".session-form").remove()

        $(SESSION_CONTAINER).html ""
        $(SESSION_CONTAINER).mk(".navbar",
          $(SESSION_CONTAINER).mk(".navbar-inner.navbar-inverse.session-bar",
            $.mk("ul.nav",
              $.mk("li.dropdown",
                $.mk("a.dropdown-toggle[href=#][data-toggle=dropdown]","Pages")
                $.mk("ul.dropdown-menu",
                  $.mk("li.divider")
                  $.mk("li",
                    $.mk("a", "New Page")
                  )
                )
              )
            )
            $.mk("form.navbar-form.pull-right",
              $.mk('button#session_logout.btn.btn-info', "Logout")
            )
          )
        )

        $(".session-bar").fadeIn "fast"


        window.navigations.load()
        window.router.route_to_current_hash window.location.hash

        # Build logged in interactions
        $("button#session_logout").die "click"
        $("button#session_logout").live "click", (e) ->

          # Log out of the session on the api, and then prompt the front end to reload
          event.preventDefault()
          window.session.logout()



  render_not_logged_in: ->

    $(".navbar-wrapper").animate {paddingTop: 0}

    if session_page
      @clear()

    if session_page.template

      
      $(SESSION_CONTAINER).mk(".navbar",
        $(SESSION_CONTAINER).mk(".navbar-inner.session-bar",
          $.mk(".brand", "CDMS")
          $.mk("form.navbar-form.session-form.pull-right")
        )
      )

      $(".session-bar").hide()

      # Expected values
      email_name = null
      password_name = null

      for object in session_page.template.data

        switch object.type
          when "text"
            $(".session-form").mk('input[type=text][name=' + object.name + '][placeholder=' + object.prompt + '][value=jono.battle@gmail.com]')
            email_name = object.name

          when "password"
            $(".session-form").mk('input[type=password][name=' + object.name + '][placeholder=' + object.prompt + '][value=P0pul4t3!]')
            password_name = object.name


      $(".session-form").mk('button[name=login].btn.btn-info', "Go")
      $(".session-bar").fadeIn "fast"

      window.navigations.load()
      window.router.route_to_current_hash window.location.hash
      
      # Create the interactions for the session controls

      # Prepare login form on focus
      $(".session.form>input").die "focus"
      $(".session-form>input").live "focus", (e) ->
        $(e.currentTarget).removeClass "alert"

      # Validate input and attemp login on click
      $(".session-form>button").die "click"
      $(".session-form>button").live "click", (e) ->

        event.preventDefault()

        # Check if we have the values we need
        if $("input[name=" + email_name + "]").val() and $("input[name=" + password_name + "]").val()
          
          email = $("input[name=" + email_name + "]").val()
          password = $("input[name=" + password_name + "]").val()

          $(".session-bar").fadeOut "fast", ->
            $(".session-bar").html("")
            $(".session-bar").mk(".brand", "loading...")
            $(".session-bar").fadeIn "fast", ->

              window.session.attempt_login email, password

        else

          $("input[name=" + email_name + "]").addClass "alert" if !$("input[name=" + email_name + "]").val()
          $("input[name=" + password_name + "]").addClass "alert" if !$("input[name=" + password_name + "]").val()
