module namespace od = "http://www.iro37.ru/stasova/api/output";


declare 
  %output:method ("html")
function od:trci-to-table ( $data as element(table), $class as xs:string ) {
  element {"table"} {
    attribute { "class" } { $class },
    element {"tr"} {
      for $i in $data/row[1]/cell
      return 
        element {"th"} {$i/@id/data()}
    },
    for $r in $data/row
    return 
      element {"tr"} {
        for $c in $r/cell
        return
          element {"td"} { $c/text()}
      } 
  }
};

declare
  %rest:path("/trac/opendata/schools")
  %rest:method('GET')
  %rest:query-param("path", "{$path}")
  %rest:query-param("class", "{$class}")
  %output:method("xhtml")
function od:opendata ( $path, $class )
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
  return od:trci-to-table ( $table, $class )
};