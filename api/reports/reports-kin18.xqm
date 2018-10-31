module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace st = 'http://www.iro37.ru/trac/funct' at "../../functions.xqm";

declare
  %rest:path("/trac/api/output/Report/kin18/schoolSubjects/{$parallel}")
  %rest:method('GET')
  %output:method ( "xml" )
function report:school-subject ( $parallel )
{
    let $data := 
      try {
        fetch:xml (
           "http://localhost:8984/trac/api/Data/public/kin18/schoolSubject"
        )/table/row[ cell / @id = "parallel_" || $parallel ]
      }
      catch * {
      }
   let $rows :=    
          for $a in  $data
          return 
            if ( $a/cell [ @id = "variative" ]/table ) 
            then (
              for $i in $a/cell [ @id = "variative" ]/table/row
              return 
                <row id= "{$i/@id/data()}" type="schoolSubject">
                   <cell id="label">{$i/@id/data()}</cell>
                </row>
            )
            else (
              <row id= "{$a/@id/data()}" type="schoolSubject">
                  <cell id="label">{ $a/cell[@id="label"]/text() }</cell>
              </row>
            )
   return <table>{ $rows }</table>
};

declare
  %rest:path("/trac/api/output/Report/kin18/books-request/{$parallel}")
  %rest:method('GET')
  %output:method ( "xhtml" )
function report:books ( $parallel as xs:integer ) {
  
  let $subjList :=
    try {
      fetch:xml ( "http://localhost:8984/trac/api/output/Report/kin18/schoolSubjects/" || $parallel )/table/row/cell[ @id = "label" ]/text()
    }
    catch * { }
    
  let $count := fetch:xml ( "http://localhost:8984/trac/api/Data/public/kin18/contingent" )/table/row[ cell[ @id = "parallel" ] = $parallel ]
  let $books := fetch:xml ( "http://localhost:8984/trac/api/Data/public/kin18/book" )/table/row[ cell [ @id ="parallel" ] = $parallel ]
  let $totalContingent := sum ( $count / cell[ @id = "contingent" ]/text() )
      
  let $result := 
    for $s in $subjList
    where $books [ cell[ @id = "subject" ] = $s ]
    let $bookQ := sum ($books [ cell[ @id = "subject" ] = $s ] / cell [ @id = "quantity" ]/number() )
    let $c := 
        if ( $count / cell[ table/@type = "variative" ] / table/row [ @id = $s ])
        then ( sum( $count / cell[ table/@type = "variative" ] / table/row [ @id = $s ]/cell[ @id = "expr" ]/text() ) )
        else ( $totalContingent )
    return 
      element { "row" }{
          element { "cell" } {
            attribute { "id" } { "Предмет" },
            $s
          },
          element { "cell" } {
            attribute { "id" } { "Название" },
            $books [ cell[ @id = "subject" ] = $s ] / cell [ @id = "label" ]/text()
          },
          element { "cell" } {
            attribute { "id" } { "Автор" },
            $books [ cell[ @id = "subject" ] = $s ] / cell [ @id = "author" ]/text()
          },
           element { "cell" } {
            attribute { "id" } { "Учеников" },
            $c
          },
          element { "cell" } {
            attribute { "id" } { "В наличии" },
            $bookQ
          },
          element { "cell" } {
            attribute { "id" } { "Потребность" },
            if ( ($c - $bookQ) >= 1 ) then ( $c - $bookQ ) else ( "-" )
          }
        }    
      
  let $content := st:TRCI-to-html( <table>{ $result }</table> )
   let $sidebar :=
      <div>
        <h3>Наличие и потребность в учебниках для {$parallel}-х классов</h3>
      </div>
  let $template := serialize( doc("../../src/main-tpl.html") )
    let $map := map{ "nav":"", "nav-login" : "" , "sidebar" :  $sidebar, "content" : $content }
    return st:fill-html-template( $template, $map )//html 
};