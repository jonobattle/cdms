class window.Account

  constructor: (account) ->

    @first_name   = if account.first_name then account.first_name
    @middle_name  = if account.middle_name then account.middle_name
    @last_name    = if account.last_name then account.last_name 

