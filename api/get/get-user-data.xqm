module namespace domain = "http://www.iro37.ru/trac/api/Data/domain";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../lib/data-from-db.xqm";
import module namespace auth = "http://www.iro37.ru/trac/api/lib/auth"  at '../lib/auth.xqm';

declare
  %rest:path( "/trac/api/Data/user/{$domain}" )
  %rest:method("GET")
  %rest:query-param("ACCESS_KEY", "{$token}")
  %rest:query-param("type", "{$type}")
  %rest:query-param("q", "{$q}", ".*")
function domain:user-data ( $domain, $token, $type, $q )
{
  if ( auth:get-session-scope ( $domain, $token ) = "user" )
  then (
    let $qField := substring-before ( $q, ":")
    let $qExpr := tokenize ( substring-after ($q, ":" ), " ")
    let $userID := auth:get-session-user ( $domain, $token )
    let $userData := $data:userData ( $domain, $token )/row[ @type = $type ]
    
    return
      <table> {
        for $e in $qExpr
        return  $userData [ matches ( cell [ @id = $qField ]/text() , $e ) ]
      }</table> 
  )
  else (
    "Не достаточно прав" 
  )
};