module namespace pm='tmp';
import module namespace Session = "http://basex.org/modules/session";

(:~ Login page (visible to everyone). :)
declare
  %rest:path("stasova2")
  %output:method("html")
function pm:login() {
  <html>
    Please log in:
    <form action="stasova2/login-check" method="post">
      <input name="name"/>
      <input type="password" name="pass"/>
      <input type="submit"/>
    </form>
  </html>
};
 
(:~ Main page (restricted to logged in users). :)
declare
  %rest:path("stasova2/main")
  %output:method("html")
function pm:main() {
  <html>
  <p>Пользователь: {session:get('id')}</p>
  <p>{user:info()}</p>
    Welcome to the main page:
    <a href='main/admin'>admin area</a>,
    <a href='logout'>log out</a>.
  </html>
};
 
(:~ Admin page. :)
declare
  %rest:path("stasova2/main/admin")
  %output:method("html")
  %perm:allow("admin")
function pm:admin() {
  <html>
    Welcome to the admin page.
  </html>
};

(: -------------------------------------------------- :)
declare
  %rest:path("stasova2/login-check")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pass", "{$pass}")
function pm:login($name, $pass) {
  try {
    user:check($name, $pass),
    Session:set('id', $name),
    web:redirect("main")
  } catch user:* {
    web:redirect("stasova2")
  }
};
 
declare
  %rest:path("stasova2/logout")
function pm:logout() {
  Session:delete('id'),
  web:redirect("/stasova2")
};

(: -------------------------------------------------- :)
(:~
 : Permission check: Area for logged-in users.
 : Checks if a session id exists for the current user; if not, redirects to the login page.
 :)
declare %perm:check('stasova2/main') function pm:check-app() {
  let $user := Session:get('id')
  where empty($user)
  return web:redirect('/stasova2')
};
 
(:~
 : Permissions: Admin area.
 : Checks if the current user is admin; if not, redirects to the main page.
 : @param $perm  map with permission data
 :)
declare %perm:check('stasova2/main/admin', '{$perm}') function pm:check-admin($perm) {
  let $user := Session:get('id')
  where not( doc('../../../data/users.xml')//user[@name=$user]/@group/data() = $perm?allow )
  return web:redirect('/stasova2/main')
};