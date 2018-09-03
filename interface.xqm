module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at 'permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "functions.xqm";

declare 
  %rest:path("/trac")
  %rest:GET
  %output:method('xhtml')
  
function view:main()
{
  let $template := serialize( doc("src/main-tpl.html") )
  let $content := doc('src/intro.html')
  let $sidebar := 
    <div >
      <img class="img-fluid"  src="http://svptraining.info/wp-content/uploads/2018/02/large-puzzle-piece-template-puzzle-piece-clip-art-free-2-image-large-puzzle-pieces-template-free.jpg"/>
      <h2>Домены:</h2>
    <ul>
    {
      for $i in $auth:db/domains/domain
      return
        <li><a href="{'/' || $auth:base || '/' || $i/@alias/data()} ">{$i/@alias/data()}</a></li>
    }
    </ul>
    </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*  
};
