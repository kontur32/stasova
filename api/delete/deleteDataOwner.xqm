module namespace delete = "http://www.iro37.ru/stasova/api/delete";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../../permissions/auth.xqm';
import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";
import module namespace conf = "http://www.iro37.ru/trac/api/conf" at "../conf.xqm";

declare
  %updating
  %rest:path( "/trac/api/delete/owner" )
  %rest:method( "GET" )
  %rest:query-param( "callback", "{ $callback }" )
  %rest:query-param( "domain", "{ $domain }" )
  %rest:query-param( "type", "{ $type }" )
  %rest:query-param( "class", "{ $class }" )
  %rest:query-param( "token", "{ $token }" )
function delete:owner ( $callback, $domain, $type, $class, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner" )
  then (
   delete node $data:domainData ( $domain )/owner/table[ @type = $type and @aboutType = $class ],
   db:output (  web:redirect ( $callback ) )
  )
  else (
    db:output (  web:redirect ( $callback ) ) 
  )
};