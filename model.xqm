 module namespace model = "http://www.iro37.ru/stasova/model";

import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at 'module-xlsx.xqm';
import module namespace st = 'http://www.iro37.ru/stasova/funct' at "functions.xqm";
  

declare 
  %public
function model:make-model($file as xs:base64Binary)
{
  let $meta := xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet2.xml')
  let $fields := xlsx:binary-row-to-TRCI ($file, 'xl/worksheets/sheet1.xml')
  return
  <model modelId="{$meta//cell[@id='namespace']/text()|| '/' || $meta//cell[@id='id']/text()}">
    <meta>
      {$meta//cell}
    </meta>
    <fields>
      {$fields//row}
    </fields>
  </model>
};

declare 
  %public
function model:make-data($file as xs:base64Binary, $order as xs:string)
{
  
  let $meta := xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet2.xml')
  let $fields := 
      if ($order='col')
      then ( xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
      else ( xlsx:binary-row-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
  let $modelId := $meta//cell[@id='namespace']/text()
  return
      <table type="data" class="{$meta//cell[@id='class']/text()}" >
        {for $r in $fields//row
          return 
            <row class="{$meta//cell[@id='class']/text()}" alias="{$meta//cell[@id='alias']/text()}">
              {
                for $c in $r//cell
                return $c
              }
            </row>
        }
      </table>
};
 
declare
  %public
  %updating
function model:save-model($model as element(model))
{
  let $models := db:open('stasova', 'models')/child::*
  return 
    if ($models/model[@modelId=$model/@modelId])
    then (replace node $models/model[@modelId=$model/@modelId] with $model)
    else (insert node $model into $models)
};

declare
  %public
  %updating
function model:save-data($data as element(table))
{
  let $datasets := db:open('stasova', 'data')/child::*
  return 
    if ($datasets/table[@class=$data/@class])
    then (replace node $datasets/table[@class=$data/@class] with $data)
    else (insert node $data into $datasets)
};

declare function model:take-modelList ()
{
  for $i in db:open('stasova', 'models')//model
  let $alias := $i/meta/cell[@id='alias']/text()
  let $id := $i/meta/cell[@id='id']/text()
  let $namespace := $i/meta/cell[@id='namespace']/text()
  return 
    <li><a href="/stasova/models?id={$namespace || '/' || $id}">{$alias}</a></li>
};

declare function model:model-view ($modelId)
{
  let $models := db:open('stasova', 'models')//model
  let $model := 
      if ($models[@modelId = $modelId])
      then ($models[@modelId = $modelId])
      else ($models[1])
  let $content :=
      if($model)
      then (
          <div class="col"> 
            <h3>Модель данных</h3>
              <h4>Мета</h4>
                {st:TRCI-to-html(<table><row>{$model/meta/cell}</row></table>)}
              <h4>Состав</h4>
                {st:TRCI-to-html($model/fields)}
            <hr/>
            <h3>Форма для ввода</h3>
              <form  method="GET">
                {st:generate-form($model/fields)}
                <input type="submit" class="btn btn-primary"/>
              </form>
          </div>
      )
      else (<h4>Еще ни одной модели не загружено :( </h4>)
          return $content
};