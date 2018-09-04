module namespace output = "http://www.iro37.ru/stasova/api/input";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';

declare
  %updating
  %rest:path("/trac/api/input/admin/users")
  %rest:method("post")
  %rest:form-param("files", "{$files}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function output:users (  $files, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner")
  then (
    db:output(web:redirect("http://localhost:8984" ||$callback, map{"group":"users", "message":"Данные загружены"}))
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
  )
};