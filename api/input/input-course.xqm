module namespace input = "http://www.iro37.ru/stasova/api/input";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../../permissions/auth.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse" at "../../TRCI-parse.xqm";

declare
  %updating
  %rest:path("/trac/api/input/user/student")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
  %rest:form-param("group", "{$group}")
function input:user (  $file, $callback, $domain, $token, $group )
{
  if ( auth:get-session-scope ( $domain, $token ) = "user" and $conf:userData ( $domain, auth:get-session-user ( $domain, $token ) ))
  then (
      let $userID := auth:get-session-user ( $domain, $token )
      let $rawData := parse:from-xlsx( xs:base64Binary($file(map:keys($file)[1] )) )
      let $model := $conf:models ( $domain ) [ @id = $rawData/@model ]
      let $model := if ( $model ) then ( $model ) else ( <table/> )
      let $newData := parse:data ( $rawData, $model, $conf:parserUrl ) update replace node ./@id with attribute { "id" } { $group }
      let $oldData := $conf:userData ( $domain, $userID )/table [ @aboutType= $rawData/@aboutType and @id=$group ]
      return
        if ( $oldData )
        then (
          replace node $oldData with $newData
        )
        else (
          insert node $newData into $conf:userData ( $domain, $userID )
        ),  
      db:output( web:redirect($conf:rootUrl || $callback , map { "group": $group,"message" : "Файл загружен" })) 
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
  )
};