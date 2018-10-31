module namespace report = "http://www.iro37.ru/trac/api/report";

import module namespace docx = "docx.iroio.ru" at '../../../iro/module-docx.xqm';

declare
  %rest:path("/trac/api/output/Report/{$domain}/{$report}/trci")
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
     
   let $table :=
      <table>
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
            <row>
              <cell id="№ пп">{$n}</cell>
              <cell id="ФИО">
                {string-join ( $r/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")}
              </cell>
              <cell id="Должность, место работы">
                {
                  $school/cell[@id=( "city__type__full" )] || " " ||
                  $school/cell[@id=( "mo" )] || " " ||
                  $school/cell[@id=( "area__type__full" )] || ", " ||
                  $school/cell[@id=( "label" )] || ", " ||
                  $r/cell[@id="position"] 
                }
              </cell>
            </row>
        }
      </table>
    
    return 
        <table>
          <row id="tables" >
            <cell id="Слушатели_курса">
              { $table }
            </cell>
          </row>
        </table>
};