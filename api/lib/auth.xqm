module namespace auth = "http://www.iro37.ru/trac/api/lib/auth";

import module namespace auth1 = 'http://iro37.ru/xq/modules/auth' at '../../permissions/auth.xqm';

declare 
  %public 
function 
  auth:get-session-scope ( $domain, $token ) 
{
  "user"
};

declare 
  %public 
function 
  auth:get-session-user ( $domain, $token ) 
{
  "poa"
};
