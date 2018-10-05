module namespace input = "http://www.iro37.ru/stasova/api/input";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse" at "../TRCI-parse.xqm";

declare
  %updating
  %rest:path("/trac/api/input/owner")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function input:owner (  $file, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner" )
  then (
      let $rawData := parse:from-xlsx( xs:base64Binary($file(map:keys($file)[1] )) )
      let $model := $conf:domain ($domain)/data/owner/table[@type="Model" and @id= $rawData/@model ]
      let $model := if ( $model ) then ( $model ) else ( <table/> )
      let $newData := parse:data ( $rawData, $model, $conf:parserUrl || $domain || "/")       
      let $oldData := $conf:domain ($domain)/data/owner/table[@type= $rawData/@type and @aboutType= $rawData/@aboutType ]
      return
        if ( $oldData )
        then (
          replace node $oldData with $newData
        )
        else (
          insert node $newData into $conf:domain ($domain)/data/owner
        ),  
      db:output( web:redirect($conf:rootUrl || $callback , map { "message" : "Файл загружен" })) 
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
  )
};

declare
  %updating
  %rest:path("/trac/api/input/user")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function input:user (  $file, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "user" )
  then (
      let $userID := auth:get-session-user ( $domain, $token )
      let $rawData := parse:from-xlsx( xs:base64Binary($file(map:keys($file)[1] )) )
      let $model := $conf:models ( $domain ) [ @aboutType = $rawData/@aboutType ]
      let $model := if ( $model ) then ( $model ) else ( <table/> )
      let $newData := parse:data ( $rawData, $model, $conf:parserUrl )       
      let $oldData := $conf:userData ( $domain, $userID ) [ @type= $rawData/@type and @aboutType= $rawData/@aboutType ]
      return
        if ( $oldData )
        then (
          replace node $oldData with $newData
        )
        else (
          insert node $newData into $conf:userData ($domain, $userID )
        ),  
      db:output( web:redirect($conf:rootUrl || $callback , map { "message" : "Файл загружен" })) 
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
  )
};