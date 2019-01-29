module namespace domain = "http://www.iro37.ru/trac/api/domain";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";

declare
  %updating
  %rest:path("/trac/api/domain/create")
  %rest:method("POST")
  %rest:form-param("domainID", "{ $domainID }", "")
  %rest:form-param("domainLabel", "{ $domainLabel }", "")
  %rest:form-param("domainURI", "{ $domainURI }", "")
  %rest:form-param("ownerName", "{ $ownerName }", "")
  %rest:form-param("ownerPassword", "{ $ownerPassword }", "")
  %rest:form-param( "ACCESS_TOKEN", "{ $ACCESS_TOKEN }", "")
function domain:new (  $domainID, $domainLabel, $domainURI, $ownerName, $ownerPassword, $ACCESS_TOKEN ) {
  let $scope := try {
    fetch:text( "http://localhost:8984/trac/api/auth/get/scope?ACCESS_TOKEN=" || $ACCESS_TOKEN )
  }
  catch * {
    "Сервер аутентификации не отвечает"
  }
  return 
  if ( $scope = "root" )
  then (
    if ( $domainID != "" and $domainLabel != "" and  $domainURI != "" and  $ownerName != "" )
    then (
      let $hash := string( hash:sha256( $ownerPassword ) )
      let $newDomain :=
        element { "domain" } {
          attribute { "id" } { $domainID },
          attribute { "label" } { $domainLabel },
          attribute { "uri" } { $domainURI },
          attribute { "owner" } { $ownerName },
          attribute { "owner-hash" } { $hash },
          element { "sessions"} {},
          element { "data" } {
            element { "owner" } {}
          }
        }
      return 
        let $domains := $data:domains ()
        return
          if ( $domains/domain[ @id = $domainID ] )
          then (
            db:output ( "Ошибка: " || "домен " || $domainID || " уже существует" )
          )
          else (
             insert node $newDomain into $domains,
             db:output ( $domainID || " успешно создан" )
          )  
        
    )
    else (
       db:output ("Не полные аргументы:  domainID, domainLabel, domainURI, ownerName, ownerPassword")
    )
    
  )
  else (
     db:output ( $scope || $ACCESS_TOKEN )
  )
};