module namespace auth = "http://www.iro37.ru/trac/api/auth";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";

declare
  %rest:path( "/trac/api/auth/user/scope" )
  %rest:method( "GET" )
  %rest:query-param( "domain", "{$domain}" )
  %rest:query-param( "token", "{$token}" )
  %output:method ("text")
function auth:userScope ( $domain as xs:string, $token as xs:string ) 
{
  let $session := db:open ( $data:dbName, "sessions")/sessions/session [ @token = $token ]
  return
    $session [ xs:dateTime ( @expires/data() ) > current-dateTime () ]/@scope/data()
};

declare
  %rest:path( "/trac/api/auth/user/userID" )
  %rest:method( "GET" )
  %rest:query-param( "domain", "{$domain}" )
  %rest:query-param( "token", "{$token}" )
  %output:method ("text")
function auth:userID ( $domain as xs:string, $token as xs:string ) 
{
  $data:domainSessions ( $domain )/session [ @token = $token ] [ xs:dateTime (@expires/data() ) > current-dateTime () ]/@userid/data()
};