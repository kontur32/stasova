(:~ 
 : Модуль является частью проекта iro
 : содержит функции для обработки файлов docx
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/stasova/blob/dev/README.md
 : @version  2.0.1
 :)

module namespace docx = "http://iro37.ru.ru/xq/modules/docx";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare 
  
function docx:rows (
  $rows as element()*
)
  {
      for $r in $rows
      return
      <w:tr w:rsidR="00512FB0" w:rsidTr="00512FB0">
        {
          for $a in $r/child::*
          return 
                <w:tc>
                <w:tcPr>
                  <w:tcW />
                </w:tcPr>
                <w:p w:rsidR="00512FB0" w:rsidRDefault="00512FB0">
                  <w:r>
                    <w:t>{$a/data()}</w:t>
                  </w:r>
                </w:p>
              </w:tc>
        }
     </w:tr>    
  };

(:возвращает в виде сериализованной строки таблицу документе Word, в которую начиная со второй строки
вставлены строки $tr:)
declare

function docx:insert-rows-into-table (
  $doc as document-node(), (:шаблон в виде дерева:)
  $tr as element(w:tr)*, (:строки для вставки в таблицу:)
  $position
)  as document-node()
  { 
      $doc update insert node $tr after .//w:tbl/w:tr[$position] 
  };
  
 declare function docx:insert-tab-into-template($template-path, $data-path)
 {
  let $file := docx:get-binary ($template-path)
  let $doc := parse-xml (archive:extract-text($file, 'word/document.xml'))
  let $data := parse-xml(fetch:text($data-path))
  let $contents := docx:insert-rows-into-table ($doc, docx:rows($data/child::*/child::*[position()>=2]), 1 )
    
  return
      archive:update($file, "word/document.xml", serialize ($contents))
     
 };
 
 (: -------- внутренние сервисные функции ------------------ :)
 declare function docx:get-binary ($res_path) {
  if ( try {file:exists($res_path)} catch * {} ) 
  then ( try {file:read-binary($res_path)} catch * {'локальный файл ' || $res_path || ' не доступен'}) 
  else ( try {fetch:binary( escape-html-uri($res_path))} catch * {'ресурс ' || $res_path  || ' с ошибкой'} )
};