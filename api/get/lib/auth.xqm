module namespace auth = "http://www.iro37.ru/trac/api/lib/auth";

import module namespace conf = "http://www.iro37.ru/trac/api/conf"  at "../../conf.xqm";

declare 
  %public 
function 
  auth:get-session-scope ( $domain, $token ) 
{
  try {
    fetch:text( web:create-url ( $conf:url ( "auth", "user/scope" ), map { "domain": $domain, "token" : $token } ) )
  }
  catch * {
  }
};

declare 
  %public 
function 
  auth:get-session-user ( $domain, $token ) 
{
  try {
    fetch:text( web:create-url ( $conf:url ( "auth", "user/userID" ), map { "domain": $domain, "token" : $token } ) )
  }
  catch * {
  }
};