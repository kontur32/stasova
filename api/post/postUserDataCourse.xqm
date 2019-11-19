module namespace input = "http://www.iro37.ru/stasova/api/input";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../../permissions/auth.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse" at "../../TRCI-parse.xqm";

declare
  %updating
  %rest:path("/trac/api/input/user/student")
  %rest:method("POST")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
  %rest:form-param("group", "{$group}")
function input:user (  $file, $callback, $domain, $token, $group )
{
  if ( auth:get-session-scope ( $domain, $token ) = "user" and  $conf:userData ( $domain, auth:get-session-user ( $domain, $token ) ) ) 
  then (
      let $userID := auth:get-session-user ( $domain, $token )          
      let $newData := input:newData ( $file, $domain, $group )
      let $oldData := $conf:userData ( $domain, $userID )/table [ @aboutType = "student"  and @id = $group ]
      return
        if ( $oldData )
        then (
          replace node $oldData with $newData
        )
        else (        
          insert node $newData into $conf:userData ( $domain, $userID )
        ),  
      db:output( web:redirect( $callback , map { "group" : $group,"message" : "Файл загружен" } ) ) 
  )
  else (
    db:output(web:redirect( $callback, map{ "message":"Ошибка авторизации" } ) )
  )
};

declare
  %private
function input:newData ( $file, $domain, $group ) as element( table ) {
   let $newRows := 
        for $f in map:keys( $file )
        let $rawData := parse:from-xlsx( 
            xs:base64Binary( $file ( $f ) ) 
          )
        let $model := $conf:models ( $domain ) [ @id = $rawData/@model ]
        let $model := if ( $model ) then ( $model ) else ( <table/> )
        return
          parse:data ( $rawData, $model, $conf:parserUrl )/row 
            update replace value of node cell[ @id = "course" ] with $group
     
     let $newData :=
        element { "table" } {
          attribute { "type" } { "Data" },
          attribute { "id" } { $group },
          attribute { "aboutType" } { "student" },
          attribute { "label" } { "Слушатели курсов" },
          attribute { "updated" } { current-dateTime () },
          $newRows 
        }
      return
        $newData
};