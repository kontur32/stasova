module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace docx = "docx.iroio.ru" at '../../../iro/module-docx.xqm';

declare
  %rest:path("/trac/api/output/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "type", "{$type}" )
  %rest:query-param( "group", "{$group}" )     
  %rest:query-param( "token", "{$token}" )
  %output:method ( "xml" )
function report:report ( $report, $domain, $type, $group, $token )
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
        case "1" return report:зачисление ( $data )
        case "2" return report:дистант ( $data )
        case "3" return report:бухгалтерия ( $data )
        case "4" return report:зачетная ( $data )
        case "5" return report:регистрационная ( $data )
        case "6" return report:зачисление ( $data )
        default return <table/>      
    return $content
};

 declare
  %rest:path("/trac/api/download/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )     
  %rest:query-param( "token", "{$token}" )
function report:выгрузка ( $domain, $report, $class, $container, $token )
{
  let $content := report:report ( $report, $domain, $class, $container, $token )

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

declare
  %rest:path("/trac/api/output/Report/kin18/school-subject")
  %rest:method('GET')
  %output:method ( "xml" )
function report:school-subject (  )
{
    let $data := 
      try {
        fetch:xml (
          web:create-url ( "http://localhost:8984/trac/api/Data/public/kin18/curriculum-5-8",
            map { }  )
        )
      }
      catch * {
      }
      
   let $subj := 
      for $a in  $data/table/row
      where $a [cell[@id="school_class_" || "5"]]/text()
      return 
        if( $a/cell [@id = "variative"]/table) 
        then (
          for $i in $a/cell [ @id = "variative" ]/table/row
          return <cell id="subject" parallel="5">{ $i/@id/data() }</cell>
        )
        else (
          <cell id="subject" parallel="5">{ $a/cell[@id="label"]/text() }</cell>
        )
   
   return <table><row>{$subj}</row></table>
};

(: --- собтственно отчеты ----------------------------------------------------:)
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
          
          let $school := 
            try {
              fetch:xml (
                web:create-url ( "http://localhost:8984/trac/api/Data/public/" || "ood" || "/"|| "school",
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
          let $school := 
            try {
              fetch:xml (
                web:create-url ( "http://localhost:8984/trac/api/Data/public/" || "ood" || "/"|| "school",
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
          let $school := 
            try {
              fetch:xml (
                web:create-url ( "http://localhost:8984/trac/api/Data/public/" || "ood" || "/"|| "school",
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
            let $inn := $r/cell[ @id="inn" ]/text() 
            let $school := 
              try {
                fetch:xml (
                  web:create-url ( "http://localhost:8984/trac/api/Data/public/" || "ood" || "/"|| "school",
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