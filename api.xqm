module namespace api = "http://www.iro37.ru/stasova/api";
import module namespace model = "http://www.iro37.ru/stasova/model" at "model.xqm";


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
function api:template ($template)
{
  <a>{$template}</a>
};