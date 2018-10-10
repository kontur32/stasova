module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../../permissions/auth.xqm';
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../../lib/inter.xqm";
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../../functions.xqm";

import module namespace docx = "docx.iroio.ru" at '../../../iro/module-docx.xqm';

declare
  %rest:path("/trac/api/output/Report/{$domain}/1")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )
  %output:method( "xhtml" )

function report:зачисление-просмотр ( $domain, $class, $container, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = ( "owner", "user" ) )
  then (
    let $data := 
      try {
        fetch:xml ("http://localhost:8984/trac/api/Data/open/ood?type=student&amp;q=course:" || $container )/table  
      }
      catch * {
      }

      let $content := report:зачисление-данные ( $data )
      
      let $sidebar := 
        <div>
          <h2>Приказ о зачислении</h2>
          <p>
            Слушателей курсов 
            <b>{
               let $course := 
                  try {
                    fetch:xml ("http://localhost:8984/trac/api/Data/open/ood?type=course&amp;q=id:" || $container )/table  
                  }
                  catch * {
                  } 
               return $course/row [ @id = $container ]/cell [@id = "label"]/text()     
            } </b></p>
        </div>
          
      let $template := serialize( doc("../../src/main-tpl.html") )
      let $map := map{ "nav": "", "nav-login": "", "sidebar" :  $sidebar, "content" : $content }
      return st:fill-html-template( $template, $map )//html 
  )
  else ( "Не достаточно прав" )
};

declare
  %rest:path("/trac/api/download/Report/{$domain}/1")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )

function report:зачисление-загрузка ( $domain, $class, $container, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = ( "owner", "user" ) )
  then (
      let $data := 
        try {
          fetch:xml ("http://localhost:8984/trac/api/Data/open/ood?type=student&amp;q=course:" || $container )/table  
        }
        catch * {
        }
      let $content := report:зачисление-данные ( $data )
      let $tpl := 'http://iro37.ru/res/tpl/%d0%bf%d1%80%d0%b8%d0%ba%d0%b0%d0%b7_%d0%b7%d0%b0%d1%87%d0%b8%d1%81%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5.docx'
      let $template := fetch:binary($tpl)
      let $doc := parse-xml (archive:extract-text( $template,  'word/document.xml' ) ) 
      
      let $rows := for $row in $content/child::*[ position()>1 ]
                    return docx:row($row)
      
      let $entry := docx:table-insert-rows ($doc, $rows)
      let $updated := archive:update ($template, 'word/document.xml', $entry)
      
      return $updated
  )
  else ( "Не достаточно прав" )
};

declare %private function report:зачисление-данные ( $data ) {
     <table class="table table-striped">
        <tr>
          <th>№ пп</th>
          <th>ФИО</th>
          <th>Должность, место работы</th>
        </tr>
        {
          for $r in $data/row
          let $school := 
            try {
              fetch:xml ("http://localhost:8984/trac/api/Data/open/ood?type=school&amp;q=id:" || $r/cell[@id="inn"]/text() )/table/row[1]  
            }
            catch * {
            }
          order by $r/cell[@id="familyName"]
          count $n
          return
            <tr>
              <td>{$n}</td>
              <td>
                {string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")}
              </td>
              <td>
                {
                  $r/cell[@id="position"] || ", " ||
                  $school/cell[@id=("label")] || ", " ||
                  $school/cell[@id=( "city__type__full" )] || " " ||
                  $school/cell[@id=( "mo" )] || " " ||
                  $school/cell[@id=( "area__type__full" )]
                }
              </td>
            </tr>
        }
      </table>
};