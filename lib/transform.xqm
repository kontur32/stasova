module namespace transform = "http://www.iro37.ru/trac/processing/transform" ;

declare 
  %public
function transform:trci-to-table ( 
    $data as element(table), 
    $class as xs:string 
  ) as element (table) {
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