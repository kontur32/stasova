module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/user1/{$domain}")
  %output:method ('xhtml')
function view:user( $domain ) {
  let $template := serialize( doc("../src/main-tpl.html") )
  let $domain := 
    if ( empty($domain) ) 
    then ( $conf:db/domains/domain[1]/@id/data() ) 
    else ($domain)
  let $content :=
      if ( $conf:db/domains/domain[@id = $domain ])
      then ( 
      <html>
        <h2>Страница пользователя домена "{$conf:db/domains/domain[@id = $domain ]/@label/data()}"</h2>
        {Session:get('token'),
          Session:get('id'),
          Session:get('domain'),
        auth:validate-session ( Session:get('domain'), Session:get('token') ),
      let $session := $conf:db/domains/domain[@id = $domain]/sessions/session[@token/data() = Session:get('token')]
        where $session
        return   
           ( xs:dateTime ($session/@expires/data() ) - current-dateTime() )
    }
          <p><a href="{'/' || $conf:base || '/logout'}">Выйти</a></p>
      </html>
      )
      else (
        web:redirect( '/' || $conf:base )
      )
  let $sidebar := 
    <div >
      <h2>Домены:</h2>
      <ul>
      {
        for $i in $conf:db/domains/domain
        return
          <li><a href="{'/' || $conf:base || '/domains/?domain=' || $i/@id/data()} ">{$i/@label/data()}</a></li>
      }
      </ul>
    </div>
  
    return st:fill-html-template($template, map{"sidebar": $sidebar, "content":$content} )/child::*        
      
 };