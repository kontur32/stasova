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
  
function docx:row (
  $row as element(row)
)
  {
      <w:tr w:rsidR="00512FB0" w:rsidTr="00512FB0">
        {
          for $a in $row/child::*
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
  %private 
function docx:table-insert-rows (
  $doc as element(w:document), (:шаблон в виде дерева:)
  $tr as element(w:tr)* (:строки для вставки в таблицу:)
)  as xs:string
  { 
    copy $c := $doc
    modify insert node $tr after $c//w:tbl/w:tr[1]      
    return serialize($c)
  };