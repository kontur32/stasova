module namespace domain = "http://www.iro37.ru/trac/api/Data/open/domain";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../../config.xqm";

declare
  %rest:path("/trac/api/Data/open/{$domain}")
  %rest:method('GET')
  %rest:query-param("type", "{$type}")
  %rest:query-param("q", "{$q}", ".*")
function domain:open-data ( $domain, $type, $q )
{
    let $q-field := substring-before ( $q, ":")
    let $q-expr := tokenize ( substring-after ($q, ":" ), " ")
    let $model := $conf:models ( $domain )[ @aboutType = $type or @id= $type ]
    let $data := 
      $conf:domain( $domain )/data/child::*[ name()= ("owner", "user") ]/table[@type="Data" and @aboutType= $type ]/row
    let $openCellID := $model/row[cell[@id="open"]/text() = "true" ]/cell[@id="id"]/text()
    return
      element { "table" } {
        
        for $q in $q-expr
        return 
            for $r in $data [ cell [ @id= $openCellID ] ] [matches ( cell[ @id= $q-field ]/text(), $q ) ]
            return
              element { "row" } {
              $r/@id,
              attribute { "type" } { $type },
              for $c in $r/cell [ @id=$openCellID ]
              return 
                $c
            }
      }
};