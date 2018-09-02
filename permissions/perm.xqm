module namespace pm='tmp';
import module namespace Session = "http://basex.org/modules/session";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at 'auth.xqm';

declare variable $pm:base := 'trac' ;
declare variable $pm:token := '';

declare
  %rest:path("/trac")
  %output:method ('xhtml')
function pm:start(  ) {
  <html>
    <h2>Домены:</h2>
    <ul>
    {
      for $i in $auth:db/domains/domain
      return
        <li><a href="{'/' || $pm:base || '/' || $i/@alias/data()} ">{$i/@alias/data()}</a></li>
    }
    </ul>
    <a href="{$pm:base || '/user'}">Для пользователя</a>
    <a href="{$pm:base || '/owner'}">Для администратора</a>
  </html>
};

declare
  %rest:path("/trac/{$domain}")
  %output:method ('xhtml')
function pm:domain( $domain ) {
  <html>
    <h2>Домен {$domain}</h2>
    <a href="{'/' || $pm:base || '/login/user/' || $domain}">Для пользователя</a>
    <a href="{'/' || $pm:base || '/login/owner/' || $domain}">Для администратора</a>
  </html>
};

declare
  %rest:path("/trac/user")
  %output:method ('xhtml')
function pm:user(  ) {
  <html>
    <h2>Вход пользователей:</h2>
    <ul>
    {
      for $i in $auth:db/domains/domain
      return
        <li><a href="{ '/' || $pm:base || '/login/user/' || $i/@alias/data() } ">{$i/@alias/data()}</a></li>
    }
    </ul>
  </html>
};

declare
  %rest:path("/trac/owner")
  %output:method ('xhtml')
function pm:owner(  ) {
  <html>
    <h2>Вход администраторов:</h2>
    <ul>
    {
      for $i in $auth:db/domains/domain
      return
        <li><a href="{ $pm:base || '/login/owner/' || $i/@alias/data() } ">{$i/@alias/data()}</a></li>
    }
    </ul>
  </html>
};

declare
  %rest:path("/trac/login/{$scope}/{$domain}")
  %output:method("html")
function pm:user-login( $scope, $domain ) {
  
  if ( $auth:db/domains/domain[@alias = $domain ])
  then ( 
  <html>
    Please log in:
    <form action=  "{ '/' || $pm:base || '/login-check'}" method="post">
      <input type="text" name="name"/>
      <input type="password" name="pass"/>
      <input type="text" name="domain" value="{$domain}" hidden="true"/>
      <input type="text" name="scope" value="{$scope}" hidden="true"/>
      <input type="submit"/>
    </form>
  </html>
  )
  else (
    web:redirect( $pm:base )
  )
};

declare
  %rest:path("/trac/user/{$domain}")
  %output:method("html")
function pm:user( $domain ) {
  
  if ( $auth:db/domains/domain[@alias = $domain ])
  then ( 
  <html>
    <h2>Страница пользователя домена {$domain}</h2>
    {Session:get('token'),
      Session:get('name'),
      Session:get('domain'),
    auth:validate-session ( Session:get('domain'), Session:get('token') ),
  let $session := $auth:db/domains/domain[@alias = $domain]/sessions/session[@token/data() = Session:get('token')]
    where $session
    return   
       ( xs:dateTime ($session/@expires/data() ) - current-dateTime() )
}
      <p><a href="{'/' || $pm:base || '/logout'}">Выйти</a></p>
  </html>
  )
  else (
    web:redirect( '/' || $pm:base )
  )
};

declare
  %rest:path("/trac/owner/{$domain}")
  %output:method("html")
function pm:owner( $domain ) {
  
  if ( $auth:db/domains/domain[@alias = $domain ])
  then ( 
  <html>
    <h2>Страница владельца домена {$domain}</h2>
  </html>
  )
  else (
    web:redirect( $pm:base )
  )
};

(: --------- start API auth ------------------------------ :)
declare
  %updating
  %rest:path("/trac/login-check")
  %output:method("html")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pass", "{$pass}")
  %rest:query-param("domain", "{$domain}")
  %rest:query-param("scope", "{$scope}")
function pm:login-check(  $name, $pass, $domain, $scope ) {
    
     if( auth:validate-user ( $domain, $name, $pass ) )
    then(
      Session:set('token', auth:build-token ( ) ), 
      auth:set-session($domain, $name, Session:get('token')),
      Session:set('name', $name),
      Session:set('domain', $domain),
      
      db:output( web:redirect('/trac/user/' || $domain ))
    )
    else (
      db:output( web:redirect('/trac'))
    )
};


declare
  %rest:path("/trac/logout")
function pm:logout(  ) {
  session:close()
  ,
  web:redirect( "/" || $pm:base )
};

(: --------- start API auth ------------------------------ :)

declare %perm:check('/trac/user') function pm:check-app() {
  let $domain := Session:get('domain')
  let $token := Session:get('token')
  where  not ( auth:validate-session ( $domain, $token ))
  return
    web:redirect('/trac')  
};

(: -------------------------------------------------------------------------- :)

 
 
(:~ Admin page. :)
declare
  %rest:path("stasova2/ood/admin")
  %output:method("html")
  %perm:allow("admin")
function pm:admin () {
  <html>
    Welcome to the admin page.<br/>
    User: { Session:get('id') } <br/>
    Token: { Session:get('token') } <br/>
    Domain: { Session:get('domain') }
  </html>
};

(: -------------------------------------------------- :)

declare 
  %rest:path ("stasova2/admin/{$domain}") 
  %perm:allow( 'owner' ) 
  %output:method('xhtml')
function pm:b ( $domain ){
  <html>
    <h2>Административная панель домена "{db:open('stasova2')//domain[users/user[@name=Session:get('id')]]/@alias/data()}"</h2>
    <p>Владелец: {Session:get('id')} </p>
  </html>
  
};

declare %perm:check ("stasova2/user") function pm:a ( ){
  let $user := Session:get('id')
  where not ( db:open('stasova2')//domain[@alias/data() = Session:get('domain')]/users/user[@name = $user] )
  return 
    web:redirect ('/stasova2')
};
 
(:~
 : Permissions: Admin area.
 : Checks if the current user is admin; if not, redirects to the main page.
 : @param $perm  map with permission data
 :)
declare %perm:check('stasova2/admin') function pm:check-admin( ) {
  let $user := Session:get('id')
  let $token := Session:get('token')
  where not( db:open('stasova2')//domain[@alias/data()= 'ood']/@owner/data() = $user  )
  return web:redirect('/stasova2/' || Session:get('domain') )
};