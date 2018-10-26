module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace st = 'http://www.iro37.ru/trac/funct' at "../../functions.xqm";
import module namespace docx = "docx.iroio.ru" at '../../../iro/module-docx.xqm';

declare
  %rest:path("/trac/api/output/Report/kin18-dev/booksInstock")
  %rest:method('GET')
  %output:method ( "xml" )
function report:booksInstock ( )
{
  let $data := 
        try {
          fetch:xml ( "http://localhost:8984/trac/api/Data/public/kin18-dev/book" )/table
        }
        catch * {}

  let $subList :=   distinct-values ($data/row/cell[@id="subject"]/text() )
  
  let $result :=
      for $s in $subList
      let $posCount := count ($data/row[cell[@id="subject"]/text() = $s] )
      let $quant := sum ($data/row[cell[@id="subject"]/text() = $s]/cell[@id="quantity_lib"]/text() ) + 
          sum ($data/row[cell[@id="subject"]/text() = $s]/cell[@id="quantity_pers"]/text() )
      let $stud := sum ($data/row[cell[@id="subject"]/text() = $s]/cell[@id="students"]/text() )
      count $i
          return 
            element {"row" } {
              attribute { "id" } { $s },
               element {"cell"}  {
                attribute { "id" } { "№ пп" },
                "1." || $i || "."
              },
              element {"cell"}  {
                attribute { "id" } { "Ступень образования / Предмет" },
                $s
              },
              element {"cell"}  {
                attribute { "id" } { "Наименований" },
                $posCount
              },
               element {"cell"}  {
                attribute { "id" } { "Наименований среднее" },
                ""
              },
               element {"cell"}  {
                attribute { "id" } { "Экземпляров"  },
                $quant
              },
               element {"cell"}  {
                attribute { "id" } { "Экземлпяров среднее" },
                round ($quant div $posCount)
              },
              element {"cell"}  {
                attribute { "id" } { "Экземлпляров на учащегося" },
                round ($quant div $stud, 2)
              },
              element {"cell"}  {
                attribute { "id" } { "Страше 10 лет" },
                ""
              }
            }
  let $head := 
          element {"row" } {
              
              element {"cell"}  {
                attribute { "id" } { "№ пп" },
                "1." 
              },
              element {"cell"}  {
                attribute { "id" } { "Ступень образования / Предмет" },
                "Начальное общее"
              },
              element {"cell"}  {
                attribute { "id" } { "Наименований" },
                ""
              },
               element {"cell"}  {
                attribute { "id" } { "Наименований среднее" },
                ""
              },
               element {"cell"}  {
                attribute { "id" } { "Экземпляров"  },
                ""
              },
               element {"cell"}  {
                attribute { "id" } { "Экземлпяров среднее" },
                "" 
              },
              element {"cell"}  {
                attribute { "id" } { "Экземлпляров на учащегося" },
                ""
              },
              element {"cell"}  {
                attribute { "id" } { "Страше 10 лет" },
                ""
              }
            }  
  
  return 
    element { "table" } {
      $head,
      $head,
      $result
    }
};

declare
  %rest:path("/trac/api/output/Report/kin18-dev/booksInstock/html")
  %rest:method('GET')
  %output:method ( "xhtml" )
function report:books ( ) {
  
  let $result :=
    try {
      fetch:xml ( "http://localhost:8984/trac/api/output/Report/kin18-dev/booksInstock" )//row[position()>1]
    }
    catch * { }
      
  let $content := st:TRCI-to-html( <table>{ $result }</table> )
  
  let $downloadUrl := "http://localhost:8984/trac/api/download/Report/kin18-dev/booksInstock/download"
  
  let $sidebar :=
      <div>
        <b>ИНФОРМАЦИЯ <br/> о наличии учебной литературы необходимой для реализации образовательных программ</b>
       <a 
                  class="btn btn-info" 
                  role="button" 
                  target="_blank" download="Информация_об_обеспеченности.docx"  
                  href="{ $downloadUrl }">скачать</a> 
      </div>
  let $template := serialize( doc("../../src/main-tpl.html") )
    let $map := map{ "nav":"", "nav-login" : "" , "sidebar" :  $sidebar, "content" : $content }
    return st:fill-html-template( $template, $map )//html 
};

 declare
  %rest:path("/trac/api/download/Report/kin18-dev/booksInstock/download")
  %rest:method('GET')
 
function report:выгрузка ( )
{
  let $content := 
       try {
          fetch:xml ( "http://localhost:8984/trac/api/output/Report/kin18-dev/booksInstock" )/table
        }
        catch * { }


  let $tplPath := "http://iro37.ru/res/tpl/school/%D0%98%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F_%D0%BE%D0%B1_%D0%BE%D0%B1%D0%B5%D1%81%D0%BF%D0%B5%D1%87%D0%B5%D0%BD%D0%BD%D0%BE%D1%81%D1%82%D0%B8.docx"      
  let $template := 
    try {
      fetch:binary( iri-to-uri ( $tplPath ) )
    }
    catch *{}
  
  let $doc := parse-xml ( archive:extract-text( $template,  'word/document.xml' ) ) 
  
  let $rows := for $row in $content /child::*[ position()>1 ]
                return docx:row($row)
  
  let $entry := docx:table-insert-rows-last ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return $updated

};