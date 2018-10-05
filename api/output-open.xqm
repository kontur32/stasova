module namespace output = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';

declare
  %rest:path("/trac/api/output/Data/{$domain}/owner/{$aboutType}")
  %rest:method('GET')
  %rest:query-param("query", "{$query}", ".*")
function output:open-data ( $domain, $aboutType, $query )
{
    let $model := $conf:models ( $domain )[ @aboutType = $aboutType ]
    let $data := 
      $conf:domain( $domain )/data/child::*[name()= "owner" ]/table[@type="Data" and @aboutType= $aboutType ]
    let $openCell := $model/row[cell[@id="open"]/text() = "true" ]/cell[@id="id"]/text() 
    return
      element { "table" } {
        attribute {"query"} {$query},
        for $r in $data/row[cell [@id=$openCell]] [matches (cell[@id="label"]/text(), $query )]
        return 
          element { "row" } {
            for $c in $r/cell [@id=$openCell]
            return 
              attribute { $c/@id/data() } {$c/text()}
          }
      }
};