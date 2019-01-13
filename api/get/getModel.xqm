module namespace getModel = "http://www.iro37.ru/trac/api/Model";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";

declare
  %rest:path("/trac/api/Model/{$domain}")
  %rest:method('GET')
  %rest:query-param( "id", "{ $id }")
function getModel:getModel ( $domain, $id )
{  
    let $models :=  $data:models ( $domain )
    return 
      if ( $id )
      then (
         $models [ @id = $id ]
      )
      else (
        $models/@id
      )
};