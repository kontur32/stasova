module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../../lib/inter.xqm";
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../../functions.xqm";

import module namespace docx = "docx.iroio.ru" at '../../../iro/module-docx.xqm';

declare variable $report:userData := function ( $domain, $token, $type, $query ) {
  try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/user/" || $domain || "/"|| $type,
            map { "q" :  $query,
                  "ACCESS_KEY" : $token
            }  )
        )
      }
      catch * {
      }
};

declare variable $report:openData := function ( $domain, $type, $query ) {
  try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| $type,
            map { "q" :  $query }  )
        )
      }
      catch * {
      }
};

declare
  %rest:path("/trac/api/output/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )
  %output:method( "xhtml" )

function report:report ( $report, $domain, $class, $container, $token )
{
    let $data := $report:userData ( $domain, $token, $class, "course:" || $container)
    let $content := 
        switch ( $report )
        case "1" return report:зачисление ( $data )
        case "2" return report:дистант ( $data )
        case "3" return report:бухгалтерия ( $data )
        case "4" return report:зачетная ( $data )
        case "5" return report:регистрационная ( $data )
        case "6" return report:зачисление ( $data )
        default return <table/>      
      
      let $sidebar := 
        <div>
          <h2>Приказ о зачислении</h2>
          <p>
            Слушателей курсов 
            <b>{
                
            } </b></p>
        </div>
          
      let $template := serialize( doc("../../src/main-tpl.html") )
      let $map := map{ "nav": "", "nav-login": "", "sidebar" :  $sidebar, "content" : $content }
      return st:fill-html-template( $template, $map )//html 
};

 declare
  %rest:path("/trac/api/download/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )

function report:зачисление-загрузка ( $domain, $report, $class, $container, $token )
{
      let $data := $report:userData ( $domain, $token, $class, "course:" || $container)
      let $content :=
      switch ( $report )
        case "1" return 
            map{ "data" : report:зачисление ( $data ),
                 "tpl" : "http://iro37.ru/res/tpl/%d0%bf%d1%80%d0%b8%d0%ba%d0%b0%d0%b7_%d0%b7%d0%b0%d1%87%d0%b8%d1%81%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5.docx" }
        case "2" return 
            map{ "data" : report:дистант ( $data ),
                 "tpl" : "http://iro37.ru/res/tpl/%d0%a1%d0%b2%d0%b5%d0%b4%d0%b5%d0%bd%d0%b8%d1%8f%20%d0%b4%d0%bb%d1%8f%20%d0%b4%d0%b8%d1%81%d1%82%d0%b0%d0%bd%d1%82%d0%b0.docx" }
        case "3" return 
            map{ "data" : report:бухгалтерия ( $data ),
                 "tpl" : "http://iro37.ru/res/tpl/%d0%91%d0%bb%d0%b0%d0%bd%d0%ba%202%20%d0%b4%d0%bb%d1%8f%20%d0%b1%d1%83%d1%85%d0%b3%d0%b0%d0%bb%d1%82%d0%b5%d1%80%d0%b8%d0%b8.docx" }
        case "4" return 
            map{ "data" : report:зачетная ( $data ),
                 "tpl" : "http://iro37.ru/res/tpl/%d0%97%d0%b0%d1%87%d0%b5%d1%82%d0%bd%d0%b0%d1%8f%20%d0%b2%d0%b5%d0%b4%d0%be%d0%bc%d0%be%d1%81%d1%82%d1%8c.docx" }
        case "5" return 
            map{ "data" : report:регистрационная ( $data ),
                 "tpl" : "http://iro37.ru/res/tpl/%d0%a0%d0%b5%d0%b3%d0%b8%d1%81%d1%82%d1%80%d0%b0%d1%86%d0%b8%d0%be%d0%bd%d0%bd%d1%8b%d0%b9_%d0%bb%d0%b8%d1%81%d1%82_%d0%9a%d0%9f%d0%9a.docx" }
        case "6" return 
            map{ "data" : report:зачисление ( $data ),
                 "tpl" : "http://iro37.ru/res/tpl/%d0%9f%d1%80%d0%b8%d0%ba%d0%b0%d0%b7%20%d0%be%d0%b1%20%d0%be%d0%ba%d0%be%d0%bd%d1%87%d0%b0%d0%bd%d0%b8%d0%b8.docx" }
        
        default return <table/> 

      let $template := fetch:binary(  $content?tpl )
      let $doc := parse-xml ( archive:extract-text( $template,  'word/document.xml' ) ) 
      
      let $rows := for $row in $content?data /child::*[ position()>1 ]
                    return docx:row($row)
      
      let $entry := docx:table-insert-rows ($doc, $rows)
      let $updated := archive:update ($template, 'word/document.xml', $entry)
      
      return $updated
};

declare %private function report:зачисление ( $data ) {
     <table class="table table-striped">
        <tr>
          <th>№ пп</th>
          <th>ФИО</th>
          <th>Должность, место работы</th>
        </tr>
        {
          for $r in $data/table/row
          let $inn := $r/cell[@id="inn"]/text() 
          let $school := $report:openData ( "ood", "school", "id:" || $inn )/table/row[1]
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
                  $school/cell[@id=( "city__type__full" )] || " " ||
                  $school/cell[@id=( "mo" )] || " " ||
                  $school/cell[@id=( "area__type__full" )] || ", " ||
                  $school/cell[@id=( "label" )] || ", " ||
                  $r/cell[@id="position"] 
                }
              </td>
            </tr>
        }
      </table>
};

declare %private function report:дистант ( $data ) {
     <table class="table table-striped">
       <tr>
          <th>курс</th>
          <th>почта</th>
          <th>пароль</th>
          <th>фамилия</th>
          <th>имя</th>
          <th>отчество</th>
          <th>телефон</th>
          <th>организация</th>
          <th>должность</th>
          <th>дата_пк</th>
        </tr>
        
        {
        for $r in $data/table/row
          let $inn := $r/cell[@id="inn"]/text() 
          let $school := $report:openData ( "ood", "school", "id:" || $inn )/table/row[1]
          order by $r/cell[@id="familyName"]
          count $n
        return
          <tr>
            <td></td>
            <td>{ $r/cell[@id="email"] }</td>
            <td></td>
            <td>{ $r/cell[@id="familyName"] }</td>
            <td>{ $r/cell[@id="givenName"] }</td>
            <td>{ $r/cell[@id="secondName"] }</td>
            <td>{ $r/cell[@id="telephone"] }</td>
            <td>{ $school/cell[@id="label"] }</td>
            <td>{ $r/cell[@id="position"] }</td>
            <td>{ $r/cell[@id="last_kpk_year"] }</td>
          </tr>
        } 
     </table>
};

declare %private function report:бухгалтерия ( $data ) {
     <table class="table table-striped">
       <tr>
        <th>номер</th>
        <th>муниципалитет</th>
        <th>организация</th>
        <th>руководитель</th>
        <th>ФИО_слушателя</th>
        <th>должность</th>
        <th>номер</th>
        <th>дата</th>
        <th>стоимость</th>
        <th>срок</th>
        <th>адрес_организации</th>
      </tr>
      {
        for $r in $data/table/row
          let $inn := $r/cell[@id="inn"]/text() 
          let $school := $report:openData ( "ood", "school", "id:" || $inn )/table/row[1]
          order by $r/cell[@id="familyName"]
          count $n
        return
          <tr>
            <td>{ $n }.</td>
            <td>
              {
                $school/cell[@id=( "city__type__full" )] || " " ||
                $school/cell[@id=( "mo" )] || " " ||
                $school/cell[@id=( "area__type__full" )]
              }
            </td>
            <td>{ $school/cell[@id=( "label" )] }</td>
            <td>{ $school/cell[@id=( "name" )] }</td>
            <td>
              {string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")}
            </td>
            <td>{  $r/cell[@id="position"] }</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td>
              { string-join( ($school/cell[@id= "postal__code" ], $school/cell[@id = "unrestricted__value" ], "ИНН", $school/cell[@id=( "id")], "КПП", $school/cell[@id=( "kpp")] ), ", " )}
            </td>
          </tr>
      }
     </table>
};

declare %private function report:зачетная ( $data ) {
     <table class="table table-striped">
       <tr>
          <th>номер</th>
          <th>фио</th>
          <th>отметка</th>
          <th>подпись преподавателя</th>
        </tr>
        {
        for $r in $data/table/row
        order by $r/cell[@id="familyName"]
        count $n
        return
        
        <tr>
          <td>{ $n }.</td>
          <td>
            {string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")}
          </td>
          <td></td>
          <td></td>
        </tr>
        }
     </table>
};

declare %private function report:регистрационная ( $data ) {
     <table class="table table-striped">
        <tr>
          <th>номер</th>
          <th>фио</th>
          <th>район</th>
          <th>должность</th>
          <th>подпись</th>
        </tr>
        {
          for $r in $data/table/row
            let $inn := $r/cell[@id="inn"]/text() 
            let $school := $report:openData ( "ood", "school", "id:" || $inn )/table/row[1]
            order by $r/cell[@id="familyName"]
            count $n
          return
            <tr>
              <td>{ $n }.</td>
              <td>
                {string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")}
              </td>
              <td>
              {
                $school/cell[@id=( "city__type__full" )] || " " ||
                $school/cell[@id=( "mo" )] || " " ||
                $school/cell[@id=( "area__type__full" )]
              }
            </td>
            <td>{ $school/cell[@id=( "label" )] || ", " || $r/cell[ @id = "position" ]}</td>
              <td></td>
            </tr>
        }
     </table>
};
