module namespace view = 'http://www.iro37.ru/trac/interface';


import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare 
  %rest:path("/trac")
  %rest:GET
  %output:method('xhtml')  
function view:main()
{
  let $template := serialize( doc("../src/main-tpl.html") )
  let $nav-items-data := fetch:xml ( $conf:menuUrl( "main" ) )/table
  let $nav := inter:build-menu-items ( $nav-items-data )
     
  let $content := doc('../src/intro.html')
  let $sidebar := 
    <div >
      <img class="img-fluid"  src="http://iro37.ru/res/trac-src/img/logo.jpg"/>
    </div>
  let $map := map{"sidebar": $sidebar, "content":$content, "nav":$nav, "nav-login" : ""}
    return st:fill-html-template( $template, $map )//html 
};

declare
  %rest:path("/trac/OpenData")
  %output:method ('xhtml')
function view:open-data (  ) {

  let $nav-items-data := fetch:xml ( $conf:menuUrl("main"))/table
  let $nav := inter:build-menu-items ($nav-items-data)
   
 
    let $sidebar :=
      <div>
        <h2> Открытые данные </h2>
        <a href="#">Школы</a>
      </div>    

    let $content :=
      <div class="row">
        <div class="col-md-12 border-right"> 
        <h2>Сведения о функционировании системы общего образования</h2>
        <p>Источник: 
          <a href="http://opendata.mon.gov.ru/opendata/7710539135-OO">портал открытых данных Минобрнауки России</a>
        </p>
          {
            fetch:xml( web:create-url ("http://localhost:8984/trac/opendata/schools", 
            map {
              "path":"http://opendata.mon.gov.ru/opendata/7710539135-OO/data-20160701T102009-structure-20150907.csv",
              "class" : "table table-striped"
            }
          ))
          }
        </div>
        
      </div>
    
    let $template := serialize( doc("../src/main-tpl.html") )
    let $map := map{ "nav":$nav, "sidebar" :  $sidebar, "content" : $content }
    return st:fill-html-template( $template, $map )//html 
  
};