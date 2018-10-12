module namespace opendata = "http://www.iro37.ru/stasova/api/output";

import module namespace transform = "http://www.iro37.ru/trac/processing/transform"  at "../lib/transform.xqm";

declare
  %rest:path("/trac/opendata/schools")
  %rest:method('GET')
  %rest:query-param("path", "{$path}")
  %rest:query-param("class", "{$class}")
  %output:method("xhtml")
function opendata:schools ( $path, $class )
{
let $data := csv:parse(fetch:text( $path ))//record[ not (matches (entry[1]/text(), "федеральный округ") or matches (entry[1]/text(), "Федерация")) ][position()>1]
let $d := ("субъект", "школ", "школьников", "сотрудников", "среднее")

let $table :=
  element {"table"} {
    for $i in $data
    order by  $i/entry[5] descending
    return 
      element {"row"}{
        for $t in 1 to 5
        
        return 
          element {"cell"}{
            attribute {"id"} {$d[$t]},
            if ($d[$t]="среднее") then (round($i/entry[$t]/text(), 2)) else ($i/entry[$t]/text()) }
    }
  }
  return transform:trci-to-table ( $table, $class )
};