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
  let $nav-items-data := fetch:xml ( $conf:menuUrl("main"))/table
  let $nav := inter:build-menu-items ($nav-items-data)
     
  let $content := doc('../src/intro.html')
  let $sidebar := 
    <div >
      <img class="img-fluid"  src="http://svptraining.info/wp-content/uploads/2018/02/large-puzzle-piece-template-puzzle-piece-clip-art-free-2-image-large-puzzle-pieces-template-free.jpg"/>
    </div>
  let $map := map{"sidebar": $sidebar, "content":$content, "nav":$nav}
    return st:fill-html-template( $template, $map )//html 
};