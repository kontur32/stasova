module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/owner/{$domain}")
  %rest:query-param("section", "{$section}")
  %rest:query-param("group", "{$group}")
  %rest:query-param("item", "{$item}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:owner( $section, $domain, $group, $item, $message ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "owner"  )
  then (
    let $groups := map{"users" : "Пользователи домена", "ontology":"Онтология домена"}
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl("owner"), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
        
    let $template := serialize( doc("../src/main-tpl.html") )
    let $domain := 
      if ( empty($domain) ) 
      then ( $conf:db/domains/domain[1]/@id/data() ) 
      else ($domain)
    let $group := if (empty ($group)) then ("users") else ($group)
    let $content :=
         <div>
          <h2>Страница владельца домена: "{$conf:db/domains/domain[@id = $domain ]/@label/data()}"</h2>    
            <div>
            <h3>{map:get($groups, $group)}:</h3>
            <ul>
              {
                let $request-url := 
                    web:create-url 
                      ( $conf:rootUrl || "/" || $conf:base || "/api/output/" || $group,
                       map{ "domain": $domain, "token" : Session:get("token")}
                     )
                let $items-list := 
                      try {
                        fetch:xml( $request-url )//cell[@id="label"]/text()
                      }
                      catch * { }

                for $i in $items-list
                return
                  <li>{$i}</li>
              }
            </ul>
            </div>
            <div>
              <p style="color : green; background: yellow"><i>{$message}</i></p>
              <p>Загрузить:</p>
              <form action=  "{ '/' || $conf:base || '/api/input/admin/users'}" method="POST" enctype="multipart/form-data">
                <input type="file" name="file" multiple="multiple"/>
                <input type="text" name="callback" value="{ '/trac/owner/' || $domain }" hidden="true" />
                <input type="text" name="domain" value="{$domain}" hidden="true"/>
                <input type="text" name="token" value="{Session:get('token')}" hidden="true"/>
                <br/>
                <input type="submit" value="Загрузить"/>
            </form>
            </div>
         </div>
        
    let $sidebar := 
      <div >
        <h2>Ресурсы:</h2>
        <ul>
            <li><a href="?section=resources&amp;group=users">Пользователи домена</a></li>
            <li><a href="?section=resources&amp;group=ontology">Онтология домена</a></li>
        </ul>
      </div>
  let $map := map{"sidebar": $sidebar, "content":$content, "nav":$nav}
  return st:fill-html-template( $template, $map )//html 
   )
   else (
     web:redirect( '/' || $conf:base )
   )  
 };