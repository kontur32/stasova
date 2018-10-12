module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse";

import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at 'module-xlsx.xqm';

declare 
  %public
function parse:from-xlsx($file as xs:base64Binary)
{
  let $meta := xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet2.xml')
  let $fields := 
      if ($meta//row[1]/cell[@label="direction"]/text()='col')
      then ( xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
      else ( xlsx:binary-row-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
  return
    element {QName('', 'table') } 
      {
        for $attr in $meta/row[1]/cell
        return 
          attribute {$attr/@label/data()} {$attr/text()},
        $fields/row
      }
}; 

declare 
  %public
function parse:data ( 
  $data as element( table ),
  $model as element( table ),
  $parserUrl as item()*
  )
{
  element { "table" } {
    $data/attribute::*,
    attribute { "updated" } { current-dateTime() },
    for $r in $data/row
    let $idLabel := $model/row [ @id =  "id" ]/cell[ @id = "label" ]/text()
    let $rowID := $r/cell[ @label= $idLabel ]/text()
    let $rowID := if ( $rowID ) then ( $rowID ) else ( $r/cell[ @label="id"]/text() )
    return 
      element { "row" } {
        attribute { "id" } { $rowID },
        attribute { "type" } { $data/@aboutType },
        
        for $c in $r/cell
        let $modelCell := $model/row[ cell[@id="label"]/text() = $c/@label/data() ]
        let $cellId := 
          if ($modelCell/cell[@id="id"]/text())
          then ( $modelCell/cell[@id="id"]/text() )
          else ( encode-for-uri ($c/@label/data()) )
        
        let $cellData := 
           if ( $modelCell/cell[@id="parser"]/text() )
          then (
            parse:parse-fetch ( 
              $c/text(),
              $parserUrl || $modelCell/cell[@id="parser"]/text() ) 
          )
          else ( $c/text() ) 
        
        return
          element {"cell"} {
            attribute {"id"} { $cellId },
            if ( $cellId = "id" ) then ( iri-to-uri ( $cellData ) ) else ( $cellData )
          }            
      } 
  }
};

declare 
  %public
function parse:parse-fetch ( 
   $q as xs:string,
   $path as xs:string
  ) as item()*
{
  try {
  let $result := fetch:text( 
    web:create-url(
      $path,
       map { "q" : $q } )
    )
    return 
      try { parse-xml( $result ) }
      catch * { $result }
  }
  catch * {
    ""
  }
};