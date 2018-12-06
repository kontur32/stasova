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
          <th>Контейнеров</th>
          <th>Записей</th>
          <th>Контейнеров за 7 дней</th>
          <th>Записей за 7 дней</th>
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