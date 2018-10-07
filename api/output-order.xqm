module namespace order = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";

import module namespace docx = "docx.iroio.ru" at '../../iro/module-docx.xqm';

declare
  %rest:path("/trac/api/output/Report/{$domain}/1")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )
  %output:method( "xhtml" )

function order:order-a ( $domain, $class, $container, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = ( "owner", "user" ) or 1 )
  then (
    let $userID := auth:get-session-user ( $domain, $token )
    let $data := $conf:userData( $domain, $userID )/table[ @aboutType= $class and @id= $container ]
    let $content :=
      <table class="table table-striped">
        <tr>
          <th>№ пп</th>
          <th>ФИО</th>
          <th>Должность, место работы</th>
        </tr>
        {
          for $r in $data/row
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
                  $r/cell[@id="position"]
                }
              </td>
            </tr>
        }
      </table>
      let $nav := <div></div>
      let $sidebar := 
        <div>
          <h2>Приказ о зачислении</h2>
          <p>
            Слушателей курсов 
            { $conf:domain("ood")/data/owner/table[@type="Data" and @aboutType="course"]/row [@id=$container]/cell[@id="label"]/text()} </p>
        </div>
          
      let $template := serialize( doc("../src/main-tpl.html") )
      let $map := map{ "nav":$nav, "sidebar" :  $sidebar, "content" : $content }
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

function order:order-b ( $domain, $class, $container, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = ( "owner", "user" ) or 1 )
  then (
    let $userID := auth:get-session-user ( $domain, $token )
    let $data := $conf:userData( $domain, $userID )/table[ @aboutType= $class and @id= $container ]
    let $content :=
      <table class="table table-striped">
        <tr>
          <th>№ пп</th>
          <th>ФИО</th>
          <th>Должность, место работы</th>
        </tr>
        {
          for $r in $data/row
          order by $r/cell[@id="familyName"]
          count $n
          return
            <tr>
              <td>{$n}.</td>
              <td>
                {string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")}
              </td>
              <td>
                {
                  $r/cell[@id="position"]
                }
              </td>
            </tr>
        }
      </table>
      
      let $tpl := 'http://iro37.ru/res/tpl/%d0%bf%d1%80%d0%b8%d0%ba%d0%b0%d0%b7_%d0%b7%d0%b0%d1%87%d0%b8%d1%81%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5.docx'
      let $template := fetch:binary($tpl)
      let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
      
      let $rows := for $row in $content/child::*[ position()>1 ]
                    return docx:row($row)
      
      let $entry := docx:table-insert-rows ($doc, $rows)
      let $updated := archive:update ($template, 'word/document.xml', $entry)
  
      return $updated
  )
  else ( "Не достаточно прав" )
};