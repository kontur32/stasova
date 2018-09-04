module namespace pm='tmp';
import module namespace Session = "http://basex.org/modules/session";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at 'auth.xqm';
import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";


declare
  %updating
  %rest:path("/trac/login-check")
  %output:method("html")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pass", "{$pass}")
  %rest:query-param("domain", "{$domain}")
  %rest:query-param("scope", "{$scope}")
function pm:login-check(  $name, $pass, $domain, $scope ) {
    
     if( auth:validate-grants ( $domain, $name, $pass, $scope ) )
    then(
      Session:set('token', auth:build-token ( ) ), 
      auth:set-session( $domain, $name, $scope, Session:get('token') ),
      Session:set('name', $name),
      Session:set('domain', $domain),
      Session:set('scope', $scope),
      
      db:output( web:redirect('/trac/' || $scope || '/' || $domain ))
    )
    else (
      db:output( web:redirect('/trac'))
    )
};

declare
  %rest:path("/trac/logout")
function pm:logout(  ) {
  session:close(),
  web:redirect( "/" || $conf:base )
};

(: --------- start API auth ------------------------------ :)

declare 
  %perm:check('/trac/user')
  %updating 
function pm:check-user() {
  let $domain := Session:get('domain')
  let $token := Session:get('token')
  let $user := Session:get('name')
  let $new-token := auth:build-token ( )
  return 
    if (  auth:validate-session ( $domain, $token ) and $conf:db/domains/domain[@id = $domain]/users/user[@name = $user ])
    then ( 
      Session:set('token', $new-token ), 
      auth:set-session($domain, $user, Session:get("scope"), $new-token ) 
    )
    else (
       db:output (web:redirect('/trac')  )
    )
};

declare 
  %perm:check('/trac/owner')
  %updating 
function pm:check-owner() {
  let $domain := Session:get('domain')
  let $token := Session:get('token')
  let $user := Session:get('name')
  let $new-token := auth:build-token ( )
  return 
    if (  auth:validate-session ( $domain, $token ) and $conf:db/domains/domain[@id/data()=$domain]/@owner = $user)
    then ( 
      Session:set('token', $new-token ), 
      auth:set-session($domain, $user, Session:get("scope"), $new-token ) 
    )
    else (
       db:output (web:redirect('/trac')  )
    )
};