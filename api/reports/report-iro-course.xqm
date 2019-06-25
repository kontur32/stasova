module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace docx = "docx.iroio.ru" at '../../../iro/module-docx.xqm';

import module namespace Report1 = "http://www.iro37.ru/trac/api/report/reportAge" at "../../../functionTRaC/reportAge.xqm";
import module namespace Report2 = "http://www.iro37.ru/trac/api/report/contactsStaffers" at "../../../functionTRaC/contactsStaffers.xqm";

declare
  %rest:path("/trac/api/output/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "type", "{$type}" )
  %rest:query-param( "group", "{$group}" )     
  %rest:query-param( "method", "{$method}", "html" )
  %rest:query-param( "token", "{$token}" )
  %output:method ( "xml" )
function report:report ( $report, $domain, $type, $group, $method, $token )
{
    let $data := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/user/" || $domain || "/"|| $type,
            map { "q" :  "course:" || $group,
                  "ACCESS_KEY" : $token
            }  )
        )
      }
      catch * {
      }
      
    let $content := 
        switch ( $report )
        case "1" return report:зачисление ( $domain, $data )
        case "2" return report:дистант ( $domain, $data )
        case "3" return report:бухгалтерия ( $domain, $data )
        case "4" return report:зачетная ( $data )
        case "5" return report:регистрационная ( $domain, $data )
        case "6" return report:зачисление ( $domain, $data )
        case "7" return report:цсРегистрация ( $data )
        case "8" return report:цсЖурналПосещения ( $data )
        case "9" return report:цсЗачетнаяВедомость ( $data )
        case "10" return report:Возраст( $data )
        case "11" return report:КонтактыСотрудников ( $data )
        case "20" return report:семинарияРейтингСтудентов ( $domain, $data )
        case "21" return report:семинарияРейтингПоКурсам ( $domain, $data )
        case "22" return  report:семинарияРейтингСводный ( $domain, $data )
        default return <table/>      
    return 
      if ( $method = "html" )
      then ( $content )
      else ( )
};

 declare
  %rest:path("/trac/api/download/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )
function report:выгрузка ( $domain, $report, $class, $container, $token )
{
  let $method := "html"
  let $content := report:report ( $report, $domain, $class, $container, $method, $token )

  let $tpl := 
      try {
        fetch:xml ( 
          "http://localhost:8984/trac/api/Data/public/" || $domain || "/report" )/table/row [@id= $report ]/cell[@id="template"]/text()
      }
      catch * {}
      
  let $template := 
    try {
      fetch:binary( iri-to-uri ( $tpl ) )
    }
    catch *{}
  
  let $doc := parse-xml ( archive:extract-text( $template,  'word/document.xml' ) ) 
  
  let $rows := for $row in $content /child::*[ position()>1 ]
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return $updated

};


(: --- собтственно отчеты ----------------------------------------------------:)
declare %private function report:зачисление ( $domain, $data ) {
     <table class="table table-striped">
        <tr>
          <th>№ пп</th>
          <th>ФИО</th>
          <th>Должность, место работы</th>
        </tr>
        {
          for $r in $data/table/row
          let $inn := $r/cell[@id="inn"]/text() 
          
          let $school := 
            try {
              fetch:xml (
                web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "eduOrg",
                  map { "q" :  "id:" || $inn }  )
              )/table/row[1]
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

declare %private function report:дистант ( $domain, $data ) {
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
          let $school := 
            try {
              fetch:xml (
                web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "eduOrg",
                  map { "q" :  "id:" || $inn }  )
              )/table/row[1]
            }
            catch * {
            }
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

declare %private function report:бухгалтерия ( $domain, $data ) {
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
          let $school := 
            try {
              fetch:xml (
                web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "eduOrg",
                  map { "q" :  "id:" || $inn }  )
              )/table/row[1]
            }
            catch * {
            }
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

declare %private function report:регистрационная ( $domain, $data ) {
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
            let $inn := $r/cell[ @id="inn" ]/text() 
            let $school := 
              try {
                fetch:xml (
                  web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "eduOrg",
                    map { "q" :  "id:" || $inn }  )
                )/table/row[1]
              }
              catch * {
              }
            order by $r/cell[ @id="familyName" ]
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

declare %private function report:цсРегистрация ( $data ) {
     <table class="table table-striped">
       <tr>
          <th>№ пп</th>
          <th>ФИО слушателя</th>
          <th>Контакные данные</th>
          <th>Подпись</th>
        </tr>
        
        {
        for $r in $data/table/row
          order by $r/cell[@id="familyName"]
          count $n
        return
          <tr>
            <td>{ $n }</td>
            <td>{ string-join ($r/cell[@id=("familyName", "givenName", "secondName") ], " ") }</td>
            <td>{ $r/cell[@id="telephone"] || ", " || $r/cell[@id="email"]  }</td>
            <td></td>
          </tr>
        } 
     </table>
};

declare %private function report:цсЖурналПосещения ( $data ) {
     <table class="table table-striped">
       <tr>
          <th>№ пп</th>
          <th>ФИО слушателя</th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
          <th></th>
        </tr>
        {
        for $r in $data/table/row
          order by $r/cell[@id="familyName"]
          count $n
        return
          <tr>
            <td>{ $n }</td>
            <td>{ string-join ($r/cell[@id=("familyName", "givenName", "secondName") ], " ") }</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        } 
     </table>
};

declare %private function report:цсЗачетнаяВедомость ( $data ) {
     <table class="table table-striped">
       <tr>
          <th>№ пп</th>
          <th>ФИО слушателя</th>
          <th>Отметка</th>
          <th>Подпись преподавателя</th>
        </tr>
        {
        for $r in $data/table/row
          order by $r/cell[@id="familyName"]
          count $n
        return
          <tr>
            <td>{ $n }</td>
            <td>{ string-join ($r/cell[@id=("familyName", "givenName", "secondName") ], " ") }</td>
            <td></td>
            <td></td>
          </tr>
        } 
     </table>
};

declare function report:Возраст ( $data ) {
  Report1:Возраст ( $data )
};

declare function report:КонтактыСотрудников ( $data ) {
  Report2:контакты ( $data )
};

declare %private function report:семинарияРейтингСтудентов ( $domain, $data ) {
  let $data := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "student",
            map { }  )
        )
      }
      catch * { }
   let $курсы := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "course",
            map { }  )
        )
      }
      catch * { }
   return  
     <table class="table table-striped">
       <tr>
          <th>место</th>
          <th>студент</th>
          <th>средний балл</th>
          <th>качество знаний, %</th>
          <th>рейтинг</th>
        </tr>
        {
        for $r in $data/table/row
        let $курс := $курсы//row[ @id = $r/cell[ @id = "course"] ]/cell[ @id = "label"]/text()
        let $notes := $r/cell[  matches( @id/data(), "^o[0-9]" ) ][ number(text()) > 0 ]/text()
        where count( $notes ) > 0 
        let $среднийБалл := sum($notes) div count($notes)
        let $качество := 
          if( $среднийБалл >= 4 )
          then( 100 )
          else(
             if( $среднийБалл < 3 )
             then( 0 )
             else( ( $среднийБалл - 3 ) * 100 )
          )
        let $рейтинг := $среднийБалл * $качество
        order by $рейтинг descending
        count $c
        return      
          <tr>
            <td>{ $c }</td>
            <td>
              { string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ") || ", " || $курс }
            </td>
            <td>{ $среднийБалл }</td>
            <td>{ $качество }</td>
            <td>{ $рейтинг }</td>
          </tr>
        }
     </table>
};

declare %private function report:семинарияРейтингПоКурсам ( $domain, $data ) {
  let $data := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "student",
            map { }  )
        )/table/row
      }
      catch * { }
   let $курсы := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "course",
            map { }  )
        )
      }
      catch * { }
   return  
     <table class="table table-striped">
       <tr>
          <th>место</th>
          <th>курс</th>
          <th>средний балл</th>
          <th>качество знаний, %</th>
          <th>рейтинг</th>
        </tr>
        {
        for $c in distinct-values( $data/cell[@id="course"]/text() )
        let $r := $data[ cell[@id="course"] = $c ]
        let $курс := $курсы//row[ @id = $c ]/cell[ @id = "label"]/text()
        let $notes := $r/cell[  matches( @id/data(), "^o[0-9]" ) ][ number(text()) > 0 ]/text()
        where count( $notes ) > 0
        let $среднийБалл := sum( $notes ) div count( $notes )
        let $качество := 
          if( $среднийБалл >= 4 )
          then( 100 )
          else(
             if( $среднийБалл < 3 )
             then( 0 )
             else( ( $среднийБалл - 3 ) * 100 )
          )
        let $рейтинг := $среднийБалл * $качество
        order by $рейтинг descending
        count $c
        return      
          <tr>
            <td>{ $c }</td>
            <td>
              { $курс }
            </td>
            <td>{ $среднийБалл }</td>
            <td>{ $качество }</td>
            <td>{ $рейтинг }</td>
          </tr>
        }
     </table>
};

declare %private function report:семинарияРейтингСводный ( $domain, $data ) {
  let $data := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "student",
            map { }  )
        )/table/row
      }
      catch * { }
   let $курсы := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "course",
            map { }  )
        )
      }
      catch * { }
   return  
     <table class="table table-striped">
       <tr>
          <th>средний балл</th>
          <th>качество знаний, %</th>
          <th>рейтинг</th>
        </tr>
        {
        let $notes := $data/cell[  matches( @id/data(), "^o[0-9]" ) ][ number(text()) > 0 ]/text()
        let $среднийБалл := sum( $notes ) div count( $notes )
        let $качество := 
          if( $среднийБалл >= 4 )
          then( 100 )
          else(
             if( $среднийБалл < 3 )
             then( 0 )
             else( ( $среднийБалл - 3 ) * 100 )
          )
        let $рейтинг := $среднийБалл * $качество
        order by $рейтинг descending
        count $c
        return      
          <tr>
            <td>{ round( $среднийБалл, 1 ) }</td>
            <td>{ round( $качество, 1 ) }</td>
            <td>{ round( $рейтинг, 1 ) }</td>
          </tr>
        }
     </table>
};