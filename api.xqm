module namespace api = "http://www.iro37.ru/stasova/api";

import module namespace model = "http://www.iro37.ru/stasova/model" at "model.xqm";
import module namespace docx = "http://iro37.ru.ru/xq/modules/docx" at "module-docx.xqm";


declare
  %updating
  %rest:path("/stasova/api/save-model")
  %rest:method('POST')
  %rest:form-param("files", "{$files}")
function api:save-model ($files)
{
  for $file-name in map:keys($files)[1]
  return 
      model:save-model(model:make-model(map:get($files, $file-name))),
      db:output(web:redirect('/stasova/models', map {"message":"Новая модель успешно сохранена"}))
};

declare
  %updating
  %rest:path("/stasova/api/save-data")
  %rest:method('POST')
  %rest:form-param("files", "{$files}")
  %rest:form-param("order", "{$order}", "row")
function api:save-dataset ($files, $order)
{

     for $file-name in map:keys($files)[1]
     return 
          model:save-data( model:make-data(map:get($files, $file-name), $order) ),
    let $id := model:make-data(map:get($files, map:keys($files)[1]), $order)/@class/data()
    return 
      db:output(web:redirect('/stasova/data', map {"id":$id,"message":"Данные успешно сохранены"}))
     
};

declare
  %rest:path("/stasova/api/templates")
  %rest:method('GET')
  %rest:query-param("template", "{$template}")
  %rest:query-param("title", "{$title}")
function api:template ($template, $title)
{
  let $tpl-path := 
              map{
                  "report1": "C:\Users\Пользователь\Desktop\Шаблоны\шаблон-кадры-ПДО.docx", 
                  "report2": "C:\Users\Пользователь\Desktop\Шаблоны\шаблон-педсостав-МЦО.docx"
                }
  let $file := docx:insert-tab-into-template(
                     map:get($tpl-path, $template),
                    'http://localhost:8984/stasova/api/reports/' || $template
               )
  let $file-path := "C:\Users\Пользователь\Desktop\Шаблоны\сохранить-" || random:uuid() || ".docx"
  return
      file:write-binary( $file-path , $file ),
  
  let $params := map {
                  "report" : $template,
                  "message" :"Отчет записан" ,
                  "title" : $title}
  return
      web:redirect('/stasova/reports', $params)
};