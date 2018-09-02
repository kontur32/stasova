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
        for $attr in $meta//row[1]/cell
        return 
          attribute {$attr/@label/data()} {$attr/text()},
              $fields/row
      }
};


(: ----------------------------------------------------------- :)
declare 
  %public
function parse:construct-TRCI( $dbname as xs:string, $data as element(table) )
{
  if ($data/@type="Model")
  then ( parse:construct-MODEL($data) )
  else (
    let $model:= db:open($dbname, 'root')//table[@type='Model' and @aboutType=$data/@aboutType]
    return parse:construct-DATA($data, $model)
  )
};

declare 
  %private
function parse:construct-MODEL($model as element(table) )
{
 element {QName('', 'table')}
 {
   $model/attribute::*,
   for $row in $model/row
   return
     element {QName('', 'row')}
       {  
         attribute {'id'} {$model/@xml:base || "/schema/"|| $model/@aboutType/data() || "/" || $row/cell[@label='id']/text()},
         for $c in $row/cell
         return
           $c update rename node ./@label as 'id'
       }
  }
};

declare 
  %private
function parse:construct-DATA( $data as element(table), $model as element (table))
{
  element {QName('', 'table')}
   {
     $data/attribute::*,   
     for $row in $data/row
     return
      element {QName('', 'row')}
        {
         attribute {'type'} {$model/@xml:base || "/schema/" || $data/@aboutType/data()},
         attribute {'id'}{$model/@xml:base || "/resource/"|| $data/@aboutType/data() || "/" || $row/cell[@label='id']/text()},
         for $cell in $row/cell
         let $id := $model//row[cell[@id='label']/text()= $cell/@label/data()]/cell[@id='id']/text()
         return 
           $cell update insert node attribute id {$id} into .
         }
    }
};

