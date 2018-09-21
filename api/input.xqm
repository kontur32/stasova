module namespace input = "http://www.iro37.ru/stasova/api/input";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse" at "../TRCI-parse.xqm";

declare
  %updating
  %rest:path("/trac/api/input/owner/data/users")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function input:users (  $file, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner" )
  then (
      let $data := parse:from-xlsx( xs:base64Binary($file(map:keys($file)[1] )) )
      let $model := $conf:domain ($domain)/data/owner/table[@type="Model" and @aboutType="users"]
      let $users-info := parse:data ( $data, $model )       
      
      return       
        replace node  $conf:domain ($domain)/data/owner/table[@type="Data" and @aboutType="users"] with $users-info,  
      db:output( web:redirect($conf:rootUrl || $callback , map {"group" : "users", "message" : "Файл загружен"})) 
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
  )
};

declare
  %updating
  %rest:path("/trac/api/input/owner/Model")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function input:model (  $file, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner" )
  then (
      let $data := parse:from-xlsx( xs:base64Binary($file(map:keys($file)[1] )) )
      let $newModel := parse:model ( $data )
      let $model :=  $conf:domain ($domain)/data/owner/table[@type="Model" and @aboutType = $newModel/@aboutType]
      return
        if( not ( $model ))
        then (
          insert node $newModel into  $conf:domain ($domain)/data/owner 
        )
        else (
          replace node  $model with $newModel
        ) ,  
      
      db:output( web:redirect($conf:rootUrl || $callback , map { "message" : "Файл загружен"})) 
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
  )
};