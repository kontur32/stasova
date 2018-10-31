module namespace pm='http://www.iro37.ru/trac/permissions';

import module namespace Session = "http://basex.org/modules/session";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at 'auth.xqm';
import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

(: ------------- session-module ------------------------------------------ :)
declare
  %updating
  %rest:path("/trac/login-check")
  %output:method("html")
  %rest:query-param("name", "{$user}")
  %rest:query-param("pass", "{$pass}")
  %rest:query-param("domain", "{$domain}")
  %rest:query-param("scope", "{$scope}")
function pm:login-check(  $user, $pass, $domain, $scope ) {
    
     if( auth:validate-grants ( $domain, $user, $pass, $scope ) )
    then(
      Session:set('token', auth:build-token ( ) ), 
      auth:set-session( $domain, $user, $scope, Session:get('token') ),
      Session:set('id', $user),
      Session:set('domain', $domain),
      Session:set('scope', $scope),
     
      db:output( web:redirect('/trac/' || $scope || '/' || $domain ))
    )
    else (
      db:output( web:redirect('/trac'))
    )
};

declare
  %updating
  %rest:path("/trac/logout")
function pm:logout(  ) {
  delete node $conf:db//domain[@id = Session:get('domain')]/sessions/session[@userid = Session:get('id')],
  session:close(),
  db:output (web:redirect( "/" || $conf:base ) )
};


(: ------------------ check-module ----------------------------- :)
declare 
  %perm:check('/trac/user')
  %updating 
function pm:check-user() {
  let $domain := Session:get('domain')
  let $token := Session:get('token')
  let $user := Session:get('id')
  let $new-token := auth:build-token ( )
  return 
    if ( auth:validate-session ( $domain, $token ) )
    then ( 
      if ( not ( $conf:userData ( $domain, $user ) ) and  $conf:getUser( $domain, $user )/cell[@id="status"]/text() = "active")
      then (
        insert node <user id="{$user}"/> into $conf:domain ( $domain )/data
      )
      else ( ),
      Session:set( 'token', $new-token ),
      auth:set-session( $domain, $user, Session:get("scope"), $new-token ) 
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
  let $user := Session:get('id')
  let $new-token := auth:build-token ( )
  return 
    if (  auth:validate-session ( $domain, $token ) and $conf:db/domains/domain[@id/data()=$domain]/@owner = $user)
    then ( 
      Session:set('token', $new-token ), 
      auth:set-session($domain, $user, Session:get("scope"), $new-token ) 
    )
    else (
       db:output (web:redirect('/trac/domains')  )
    )
};

declare function pm:current-session( $domain )
{
  Session:get('token'),
  Session:get('id'),
  Session:get('domain'),
  auth:validate-session ( Session:get('domain'), Session:get('token') ),
  let $session := $conf:db/domains/domain[@id = $domain]/sessions/session[@token/data() = Session:get('token')]
  where $session
  return   
    ( xs:dateTime ($session/@expires/data() ) - current-dateTime() )
};