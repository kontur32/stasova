module namespace view = 'http://www.iro37.ru/stasova/view';

import module namespace st = 'http://www.iro37.ru/stasova/funct' at "functions.xqm";
import module namespace model = 'http://www.iro37.ru/stasova/model' at "model.xqm";
import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at "module-xlsx.xqm";

import module namespace request = "http://exquery.org/ns/request";

declare variable $view:db-name := 'stasova';

declare 
  %rest:path("/stasova")
  %rest:GET
  %output:method('xhtml')
function view:main()
{
  let $template := serialize( doc("main-tpl.html") )
  let $content := doc('intro.html')
  let $sidebar := 
    <div >
      <img class="img-fluid"  src="http://svptraining.info/wp-content/uploads/2018/02/large-puzzle-piece-template-puzzle-piece-clip-art-free-2-image-large-puzzle-pieces-template-free.jpg"/>
    </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*  
};

declare 
  %rest:path("/stasova/models")
  %rest:query-param("id", "{$id}")
  %rest:query-param("message", "{$message}", "")
  %rest:GET
  %output:method('xhtml')
function view:models( $id, $message )
{
  let $template := serialize( doc("main-tpl.html") )
  let $content := model:model-view($id)
  let $sidebar := <div>
                    <h4>Модели</h4>
                    <ul>{model:take-modelList ()}</ul>
                    <div class="border-top">
                      <p><i>{$message}</i></p>
                      <form enctype="multipart/form-data" action = '/stasova/api/save-model' method="post">
                          <div class="form-group">
                            <h4><lable for="model">Загрузить модель</lable></h4>
                            <input type = "file" name="files" id="files" multiple="multiple"/>
                          </div>
                          <input type="submit" class="btn btn-primary"/>
                      </form>
                    </div>
                  </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*  
};

declare 
  %rest:path("/stasova/data")
  %rest:query-param("id", "{$id}", "http://interdomivanovo.ru/schema/teacher")
  %rest:query-param("recid", "{$recid}")
  %rest:query-param("message", "{$message}")
  %rest:GET
  %output:method('xhtml')
function view:data( $id, $recid, $message )
{
 let $template := serialize( doc("main-tpl.html") )
  let $content :=
       <div class="row"> 
        <div class="col-md-6 border-right" >
          <h4>{db:open('stasova', 'models')//model[@modelId=$id]/meta/cell[@id='alias']/text()}</h4>
          <ul>
            {
              for $i in db:open('stasova','data')/data/table[@class=$id]/row
              return 
                <li>
                  <a href="{ '/stasova/data?recid=' || 
                             $i/cell[@id='id']/text() ||
                             '&amp;id=' || $i/@class }" >
                    {$i/cell[@id="id"]}
                  </a>
                </li>
            }
          </ul>
          <hr/>
          <p><i>{$message}</i></p>
          <form enctype="multipart/form-data" action = '/stasova/api/save-data' method="post">
              <div class="form-group">
                <h5><lable for="files">Загрузить данные</lable></h5>
                <input type = "file" name="files" id="files" multiple="multiple"/>
              </div>
              <div class="form-group">
                <lable for="order"><i>Расположение данных:</i></lable>
                <input type = "radio" name="order" id="order" value="row" checked="true">в строках</input>
                <input type = "radio" name="order" id="order" value="col">в столбцах</input>
              </div>
              <input type="submit" class="btn btn-primary"/>
          </form>
        </div>
        <div class="col-md-6 border-right" >
          {
            let $rec := db:open('stasova', 'data')//row[@class=$id and cell[@id='id']/text()=$recid]
            return 
             <div>
               <h4>{$rec/@alias/data()}</h4>
               <table class="table table-striped">
                 {for $cell in $rec/cell
                   return 
                     <tr>
                       <th>{$cell/@id/data()}</th>
                       <td>{if ($cell/@id/data() = "Фото") then(<a href="{$cell/text()}">фото</a>) else ($cell/text())}</td>
                     </tr>
                 }
               </table>
             </div>
          }
        </div>
       </div>
      
  let $sidebar := <div>
                    <h4>Сотрудники</h4>
                    <ul>
                      {
                        for $i in db:open('stasova', 'models')//model
                        return 
                          <li><a href="/stasova/data?id={$i/@modelId}">{$i/meta/cell[@id='alias']/text()}</a></li>
                      }
                    </ul>
                  </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*  
}; 

declare 
  %rest:path("/stasova/reports")
  %rest:query-param("report", "{$report}", "report1")
  %rest:query-param("title", "{$title}", "Кадровый состав ПДО")
  %rest:GET
  %output:method('xhtml')
function view:reports( $report, $title )
{
 let $template := serialize( doc("main-tpl.html") )
  let $content :=
       <div class="row">
         <div class="col">
           <h4>{$title}</h4>
           <form action="/stasova/api/templates" method="GET">
             <div class="input-group" >
               <input type="hidden" name="template" value="{$report}" />
               <input type="submit" class="btn btn-success" value="Сохранить"/>
             </div>
           </form>
           <div style="overflow: scroll; " > 
             {fetch:xml('http://localhost:8984/stasova/api/reports/' || $report || "?class=" || "http://iro37.ru/schema/teacher")}
           </div>
         </div>
       </div>
      
  let $sidebar := <div>
                    <h4>Список отчетов:</h4>
                    <ul>
                      <li>
                        <a href="/stasova/reports?report=report2&amp;title=OO-1: Педагогический состав по возрасту" >OO-1: Педагогический состав по возрасту</a>
                      </li>
                      <li>
                        <a href="/stasova/reports?report=report3&amp;title=Социальный паспорт класса" >Социальный паспорт класса</a>
                      </li>
                      <li>
                        <a href="/stasova/reports?report=report5&amp;title=Сведения о педагогах" >Сведения о педагогах</a>
                      </li>
                    </ul>
                  </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*  
}; 

declare 
  %rest:path("/stasova/templates")
  %rest:query-param("id", "{$id}")
  %rest:query-param("recId", "{$recId}")
  %rest:query-param("message", "{$message}")
  %rest:GET
  %output:method('xhtml')
function view:temlates( $id, $recId, $message )
{
 let $template := serialize( doc("main-tpl.html") )
  let $content :=
       <div class="row">
         <div class="col"> 
           <h4>Здесь будут шаблоны</h4>
         </div>
       </div>
      
  let $sidebar := <div>
                    <h4>Список шаблонов:</h4>
                    <ul>
                      <li>Шаблон 1</li>
                      <li>Шаблон 2</li>
                    </ul>
                  </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*  
}; 