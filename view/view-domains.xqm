module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/domains")
  %rest:query-param("domain", "{$domain}")
  %output:method ('xhtml')
function view:domain( $domain ) {
  let $template := serialize( doc("../src/main-tpl.html") )
  let $domain := 
    if ( empty($domain) ) 
    then ( $conf:db/domains/domain[1]/@id/data() ) 
    else ($domain)
  let $content :=
    if ( $conf:db/domains/domain[@id = $domain ])
    then (  
      <div>
        <p>Информационная среда организации:</p>
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
         <p>Организация <i><b>{$domain}</b></i> не зарегистрирована</p>
       </div>
     )
  let $sidebar := 
    <div >
      <h2>Организации:</h2>
      <ul>
      {
        for $i in $conf:db/domains/domain
        return
          <li><a href="{'/' || $conf:base || '/domains/?domain=' || $i/@id/data()} ">{$i/@label/data()}</a></li>
      }
      </ul>
    </div>
  
    return st:fill-html-template( $template, map{ "sidebar": $sidebar, "content":$content, "nav":"", "nav-login" : "" } )/child::*  
};