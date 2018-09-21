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
function parse:model ($data as element(table))
{
  element { "table" } {
    $data/attribute::*,
    for $r in $data/row
    return 
      element {"row"} {
        attribute {"id"} { $data/@aboutType || "/" || $r/cell[@label="id"]/text()},
        for $c in $r/cell
        return
          $c 
           update replace node ./@label with attribute {"id"} {fn:encode-for-uri ($c/@label/data() )}
      } 
  }
};

declare 
  %public
function parse:data ($data as element(table), $model as element(table))
{
  element { "table" } {
    $data/attribute::*,
    for $r in $data/row
    return 
      element {"row"} {
        attribute {"id"} { $data/@aboutType || "/" || $r/cell[@label="id"]/text()},
        
        for $c in $r/cell
        let $modelCell := $model/row[ cell[@id="label"]/text()= $c/@label/data()]
        let $cellId := 
          if ($modelCell/cell[@id="id"]/text())
          then ( $modelCell/cell[@id="id"]/text() )
          else ( fn:encode-for-uri ($c/@label/data()) )
        let $cellData :=
          if ($modelCell/cell[@id="parser"])
          then ( 
            try {
              fetch:text( 
                web:create-url(
                  "http://localhost:8984/trac/api/parser/" || $modelCell/cell[@id="parser"]/text(),
                   map { "data" : $c/text()} )
              )
            }
            catch * {
              ""
            }
          )
          else ( $c/text() )  
        
        return
          element {"cell"} {
            attribute {"id"} { $cellId },
            $cellData
          }            
      } 
  }
};