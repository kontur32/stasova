module namespace view = 'http://www.iro37.ru/trac/interface';


import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare 
  %rest:path("/trac/{ $domain }/monitor")
  %rest:GET
  %output:method('xhtml')  
function view:main( $domain )
{
  let $template := serialize( doc("../src/main-tpl.html") )
  let $nav-items-data := fetch:xml ( $conf:menuUrl( "main" ) )/table
  let $nav := inter:build-menu-items ( $nav-items-data )
  
  let $domain := db:open("trac-dev")/domains/domain[ @id= $domain ]
  let $userData := $domain/data/user
  let $users := $domain/data/owner/table[ @type="Data" and @aboutType="users" ]/row
     
  let $content := 
      <table class="table table-striped">
        <tr>
          <th>№ пп</th>
          <th>Пользователь</th>
          <th>Групп</th>
          <th>Слушателей</th>
          <th>Групп за 7 дней</th>
          <th>Слушателей за 7 дней</th>
        </tr>
        {
         for $i in $userData
         count $n
         return 
           <tr class="text-center">
               <td>{ $n }</td>
               <td class="text-left">{ $users[@id = $i/@id]/cell[@id="label"]/text() }</td>
               <td>{ count($i/table) }</td>
               <td>{ count($i/table/row) }</td>
               <td>{ count($i/table[( ( ( current-dateTime() -  xs:dateTime (@dateTime/data() ) ) div  xs:dayTimeDuration('P1D') ) - 7 < 7 )]) }</td>
               <td>{ count($i/table[( ( ( current-dateTime() -  xs:dateTime (@dateTime/data() ) ) div  xs:dayTimeDuration('P1D') ) - 7 < 7 )]/row) }</td>
           </tr>  
        }
      </table>
  
  let $sidebar := 
    <div >
      <img class="img-fluid"  src="http://iro37.ru/res/trac-src/img/logo.jpg"/>
    </div>
  let $map := map{"sidebar": $sidebar, "content" : $content, "nav" : $nav, "nav-login" : ""}
    return st:fill-html-template( $template, $map )//html 
};

declare 
  %rest:path("/trac/{ $domain }/monitor2")
  %rest:query-param("year", "{$year}")
  %rest:query-param("row", "{$rowField}")
  %rest:query-param("col", "{$colField}")
  %rest:GET
  %output:method('text')  
function view:main2 ( $domain, $year, $rowField, $colField )
{
  let $courses := 
    fetch:xml("http://localhost:8984/trac/api/Data/public/"|| $domain ||"/course")/table/row[cell[@id="yearPK"]/text() = $year ]/cell[@id="id"]/text()
  let $students := 
    fetch:xml("http://localhost:8984/trac/api/Data/public/"|| $domain ||"/student")/table/row
  let $mo :=
    distinct-values ( $students/table/row/cell[@id=$rowField]/text())
  
  for $i in $students
  where $i[ cell[@id="course"]/text() = $courses ]
  group by $m := $i/cell[@id=$rowField]/text()
  return 
      ( "&#10;{" || $m || ": " || count($i),
       
         for $b in $i
         group by $sch := $b/cell[@id=$colField]/text()
         return 
           ( "&#10;      {" || $sch || ": " || count ($b) || "}" ),
       "&#10;}"
      
    )
};