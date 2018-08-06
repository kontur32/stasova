module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse";

import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at 'module-xlsx.xqm';

declare 
  %public
function parse:from-xlsx($file as xs:base64Binary)
{
  let $meta := xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet2.xml')
  let $fields := 
      if ($meta//row[1]/cell[@alias="direction"]/text()='col')
      then ( xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
      else ( xlsx:binary-row-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
  return
    element {QName('', 'table') } 
      {
        for $attr in $meta//row[1]/cell
        return 
          attribute {$attr/@alias/data()} {$attr/text()},
              $fields/row
      }
};

declare 
  %public
function parse:construct-MODEL($model )
{
 element {QName('', 'table')}
 {
   $model/attribute::*,
   for $r in $model/row
   return
     element {QName('', 'row')}
       {  
         for $c in $r/cell
         return
           $c update rename node ./@alias as 'id'
       }
  }
};

declare 
  %public
function parse:construct-DATA($data as element(), $model as element())
{
  element {QName('', 'table')}
   {
     $data/attribute::*,
     $model/@id,
     $model/@alias,
     $model/@xml:base,
     for $r in $data/row
     return
      element {QName('', 'row')}
        {
         attribute {'type'} {$data/@aboutType/data()},
         attribute {'id'}{$r/cell[@alias='id']/text()},
         $model/@xml:base,
         for $c in $r/cell
         let $id := $model//row[cell[@id='alias']/text() = $c/@alias/data()]/cell[@id='id']/text()
         return 
           $c update insert node attribute {'id'} {$id} into .
         }
    }
};