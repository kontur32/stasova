module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at 'permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "functions.xqm";
import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "config.xqm";

declare 
  %rest:path("/trac")
  %rest:GET
  %output:method('xhtml')  
function view:main()
{
  let $template := serialize( doc("src/main-tpl.html") )
  let $nav := fetch:xml ("http://localhost:8984/trac/api/interface/main")
  let $content := doc('src/intro.html')
  let $sidebar := 
    <div >
      <img class="img-fluid"  src="http://svptraining.info/wp-content/uploads/2018/02/large-puzzle-piece-template-puzzle-piece-clip-art-free-2-image-large-puzzle-pieces-template-free.jpg"/>
    </div>
  let $map := map{"sidebar": $sidebar, "content":$content, "nav":$nav}
    return st:fill-html-template( $template, $map )//html 
};

declare
  %rest:path("/trac/domains")
  %rest:query-param("domain", "{$domain}")
  %output:method ('xhtml')
function view:domain( $domain ) {
  let $template := serialize( doc("src/main-tpl.html") )
  let $domain := 
    if ( empty($domain) ) 
    then ( $conf:db/domains/domain[1]/@id/data() ) 
    else ($domain)
  let $content :=
    if ( $conf:db/domains/domain[@id = $domain ])
    then (  
      <div>
        <p>Информационная среда (домен):</p>
        <h2>{$conf:db/domains/domain[@id = $domain ]/@label/data()}</h2>
        <br/>
        <p>Введите логин и пароль</p>
        <form action=  "{ '/' || $conf:base || '/login-check'}" method="post">
            <input type="text" name="name"/>
            <input type="password" name="pass"/>
            <input type="text" name="domain" value="{$domain}" hidden="true"/>
            <br/>
            <input type="radio" name="scope" value="user" checked="true">Пользователь</input>
            <input type="radio" name="scope" value="owner">Администратор</input>
            <br/>
            <input type="submit" value="Войти"/>
        </form>
      </div>
     )
     else (
       <div>
         <p>Домент <i><b>{$domain}</b></i> не зарегистрирован</p>
       </div>
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


declare
  %rest:path("/trac/user/{$domain}")
  %output:method ('xhtml')
function view:user( $domain ) {
  let $template := serialize( doc("src/main-tpl.html") )
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
          Session:get('name'),
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
    let $nav := fetch:xml (web:create-url( $conf:rootUrl || "/" || $conf:base || "/api/interface/owner", map{"domain":$domain}))
    let $template := serialize( doc("src/main-tpl.html") )
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
              <p><i>{$message}</i></p>
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
                
          <p>Текущая сессия: <br/><i>{view:current-session( $domain )}</i></p>
         </div>
        
    let $sidebar := 
      <div >
        <h2>Ресурсы:</h2>
        <ul>
            <li><a href="?group=users">Пользователи домена</a></li>
            <li><a href="?group=ontology">Онтология домена</a></li>
        </ul>
      </div>
  let $map := map{"sidebar": $sidebar, "content":$content, "nav":$nav}
  return st:fill-html-template( $template, $map )//html 
   )
   else (
     web:redirect( '/' || $conf:base )
   )  
 };


declare function view:current-session( $domain )
{
  Session:get('token'),
  Session:get('name'),
  Session:get('domain'),
  auth:validate-session ( Session:get('domain'), Session:get('token') ),
  let $session := $conf:db/domains/domain[@id = $domain]/sessions/session[@token/data() = Session:get('token')]
  where $session
  return   
    ( xs:dateTime ($session/@expires/data() ) - current-dateTime() )
};