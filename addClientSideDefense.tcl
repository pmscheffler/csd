when HTTP_REQUEST {
  # Disable the stream filter for all requests
  STREAM::disable

  # LTM does not uncompress response content, so if the webserver has compression enabled
  # we must prevent the server from send us a compressed response by changing the request
  # header that indicates client support for compression (on our LTM client-side we can re-
  # apply compression before the response goes across the Internet)
  # Check if response type is text
  HTTP::header remove "Accept-Encoding"
  log local0. "Removed Accept-Encoding"

  set httppath [HTTP::path]
  set httphost [HTTP::host]

}

when HTTP_RESPONSE {
  # Check if response type is text
  if {[HTTP::header value Content-Type] starts_with "text"} {

    set protectedDomain $httphost

    if { $protectedDomain contains "access.udf.f5.com" } {
      set protectedDomain "access.udf.f5.com"
    }

    log local0.info "For $httppath protectedDomain: $protectedDomain"

    # get the JS from the Datagroup
    set csdjs [class match -value $protectedDomain equals client_side_defense_js]
    if {$csdjs equals "<REPLACEME>"} {
      log local0.err "Please update your Data Group with the correct JS"
    } else {
      log local0. "Searching for <head>"
      STREAM::expression "@<head>@<head>$csdjs@"
    }
    # Enable the stream filter for this response only
    STREAM::enable
  }
}


when STREAM_MATCHED {
  log local0.info "We got a hit!"
}