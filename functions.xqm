module namespace st = 'http://www.iro37.ru/trac/funct';

import module namespace functx = "http://www.functx.com";
 
declare 
  %public
function st:generate-form(
    $data-model as node()
  ) as node()*
{
  for $field in $data-model//row
  return
  <div class="form-group">
    <label for="{$field/cell[@id='id']/text()}">{ upper-case($field/cell[@id='alias']/text()) || ": "}</label>
    <input 
      id="{$field/cell[@id='id']/text()}" 
      type="{$field/cell[@id='input']/text()}"
      class="form-control"
      />
  </div>
};

declare function st:TRCI-to-html( $data as element() )
{
  <table class="table table-striped">
    <head>
     <tr>
       {
         for $i in $data//row[1]/cell/@id/data()
         return <th>{$i}</th>
       }
     </tr>
    </head>
         {
           for $i in $data//row
           return
             <tr>
               {
                 for $k in $i/cell
                 return 
                   <td>{$k/text()}</td>
               }
             </tr>
       }
   </table>
};

declare function st:fill-html-template($template, $content )
{
let $changeFrom := 
    for $i in map:keys($content)
    return "\{\{" || $i || "\}\}"
let $changeTo := map:for-each($content, function($key, $value) {serialize($value)})
return 
   parse-xml ("<node>" || functx:replace-multi ($template, $changeFrom, $changeTo) || "</node>")
};

declare function st:count-age( $birthDay as xs:dateTime ) 
{
  ( current-date() - $birthDay ) div xs:dayTimeDuration('P1D') idiv 365.242199 * xs:yearMonthDuration('P1Y')
};