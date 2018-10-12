module namespace user = "http://www.iro37.ru/trac/api/Data/domain";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";
import module namespace conf = "http://www.iro37.ru/trac/api/conf" at "../conf.xqm";
import module namespace auth = "http://www.iro37.ru/trac/api/lib/auth"  at 'lib/auth.xqm';

declare
  %rest:path( "/trac/api/Data/user/{$domain}/{$type}" )
  %rest:method("GET")
  %rest:query-param("ACCESS_KEY", "{$token}")
  %rest:query-param("q", "{$queryString}", ".*")
function user:data ( $domain, $token, $type, $queryString )
{
  if ( auth:get-session-scope ( $domain, $token ) = "user" )
  then (
    let $query := 
        try {
          fetch:xml ( 
            web:create-url( $conf:url( $domain, "processing/parse") || "/data-query", 
                            map { "q" : $queryString }) 
             )
          }
      catch * {}
      
    let $userID := auth:get-session-user ( $domain, $token )
    let $userData := $data:userData ( $domain, $userID )/row[ @type = $type ]
    let $result := 
      <table> {
        for $expr in $query/table/row/cell/text()
        return  $userData [ matches ( cell [ @id = $query/table/row/@id/data() ], $expr ) ]
      }</table>
    return 
      $result
  )
  else (
    <error>Не достаточно прав</error> 
  )
};