module namespace output = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';

declare
  %rest:path("/trac/api/parser/{$domain}/sha-256")
  %rest:method('GET')
  %rest:query-param("data", "{$data}")
function output:parser-hash ( $domain, $data )
{
 if ($data)
 then ( string(hash:hash( $data, 'sha-256' )) )
 else ()
};