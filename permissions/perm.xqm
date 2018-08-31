module namespace pm='tmp';
import module namespace Session = "http://basex.org/modules/session";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at 'auth.xqm';

declare variable $pm:base := 'stasova2';

declare
  %rest:path("stasova2")
  %output:method ('xhtml')
function pm:start(  ) {
  <html>
    <ul>
    {
      for $i in db:open('stasova2')/domains/domain
      return
        <li><a href="{'/stasova2/' || $i/@alias/data()} ">{$i/@alias/data()}</a></li>
      
    }
    </ul>
  </html>
};
(:~ Login page (visible to everyone). :)
declare
  %rest:path("stasova2/{$domain}")
  %output:method("html")
function pm:login( $domain ) {
  
  if ( db:open('stasova2')//domain[@alias = $domain ])
  then ( 
  <html>
    Please log in:
    <form action=  "{'/stasova2/' || $domain || '/login-check'}" method="post">
      <input name="name"/>
      <input type="password" name="pass"/>
      <input type="submit"/>
    </form>
  </html>
  )
  else (
    web:redirect('/stasova2/')
  )
  
};
 
(:~ Main page (restricted to logged in users). :)
declare
  %rest:path("stasova2/user/{$domain}")
  %output:method("html")
function pm:main( $domain ) {
  <html>
  <p>Пользователь: {session:get('id')}</p>
  <p>{user:info()}</p>
  <p>{Session:get('domain')}</p>
    Welcome to the main page:
    <a href="{'/stasova2/admin/' || $domain}" >admin area</a>,
    <a href='logout'>log out</a>.
  </html>
};
 
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
  %rest:path("/stasova2/{$domain}/login-check")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pass", "{$pass}")
function pm:login( $name, $pass, $domain ) {
  
    if( db:open('stasova2', 'domains')/domains/domain[@alias= $domain ]/users/user[@name=$name]/password[@algorithm="sha-256"]/hash/text()=string(hash:hash($pass, 'sha-256')))
    then(
      Session:set('id', $name),
      Session:set('token', string (xs:hexBinary(hash:hash('', 'sha-256'))) ),
      Session:set('domain', $domain),
      web:redirect("/stasova2/user/" ||  $domain )
    )
    else (
      web:redirect("/stasova2/" || $domain)
    )
};
 
declare
  %rest:path("stasova2/user/logout")
function pm:logout(  ) {
  Session:delete('id'),
  web:redirect("/stasova2")
};

(: -------------------------------------------------- :)
(:~
 : Permission check: Area for logged-in users.
 : Checks if a session id exists for the current user; if not, redirects to the login page.
 :)
declare %perm:check('stasova2/ood/main') function pm:check-app() {
  let $user := Session:get('id')
  where empty($user) 
  return web:redirect('/stasova2')
};

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