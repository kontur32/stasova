 module namespace auth = 'http://iro37.ru/xq/modules/auth';

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

 declare variable $auth:db := db:open('stasova2');
 declare variable $auth:domain-alias := 'ood';
 declare variable $auth:domain-path := 'domains';
 declare variable $auth:domain := db:open( 'stasova2' , $auth:domain-path )/domains/domain[@alias= $auth:domain-alias];
declare variable $auth:session-duration := xs:dayTimeDuration('PT60S');
declare variable $auth:base := 'trac';
 
 declare
 function auth:build-token ( )
 {
    string(xs:hexBinary(hash:hash(string(random:double()) || string(current-dateTime()) , 'sha-256')))
 };
 
 declare
 function auth:build-session-record ( $user as xs:string, $token, $duration as xs:dayTimeDuration )
 {
   
   element session {
     attribute { 'name' } { $user },
     attribute { 'expires' } { string(current-dateTime() + $duration ) },
     attribute { 'token' } { $token  }
   }
 };

declare
  function auth:build-user-record ( 
    $name as xs:string, 
    $password as xs:string, 
    $permission as xs:string
  )
  {
    element user {
      attribute {'name'} { $name },
      attribute {'permission'} { $permission },
        element password {
          attribute { "algorithm" } { "sha-256" },
          element hash {
            string(hash:hash( $password, 'sha-256' )) 
          }
        }
    }
  };
 
 declare 
   %updating 
 function 
   auth:set-session( $domain as xs:string, $user as xs:string, $token, $duration as xs:dayTimeDuration )
 {
   let $sessions := $auth:domain/sessions
   let $session := auth:build-session-record ( $user, $token, $duration )
   where $auth:db/domains/domain[@alias = $domain]/users/user[@name = $user ]
     or $auth:db/domains/domain/@owner = $user
   return
     if ($sessions/session[@name= $user])
     then ( replace node $sessions//session[@name= $user] with $session )
     else ( insert node $session into $sessions)
     
 };
 
 declare 
   %updating 
 function auth:set-session($domain as xs:string, $user as xs:string, $token )
 {
   auth:set-session($domain, $user, $token, $auth:session-duration )
 };
  
  declare 
  function  
    auth:validate-session ( $domain, $token )
  {
    let $session := $auth:db/domains/domain[@alias = $domain]/sessions/session[@token/data() = $token]
    where $session
    return   
      $session/@token/data() = $token and ( xs:dateTime ($session/@expires/data() ) - current-dateTime() ) div xs:dayTimeDuration('PT1S') > 0
  }; 
  
   declare function 
    auth:validate-grants ( $domain as xs:string , $name as xs:string, $pass as xs:string,  $scope as xs:string)
  {
    if ($scope = 'user')
    then ( 
      auth:validate-user ( $domain , $name , $pass )
    )
    else (
       auth:validate-owner ( $domain , $name , $pass )
    )
  };

  declare function 
    auth:validate-user ( $domain as xs:string , $name as xs:string, $pass as xs:string)
  {
    let $user := $auth:db/domains/domain[@alias= $domain ]/users/user[@name=$name]
    let $hash := string(hash:hash($pass, 'sha-256'))
    return
    if (
      $user/password[@algorithm="sha-256"]/hash/text()= $hash 
    )
    then (
      true()
    )
    else (
      false()
    )
  };  

declare function 
    auth:validate-owner ( $domain as xs:string , $name as xs:string, $pass as xs:string)
  {
    let $owner-name := $auth:db/domains/domain[@alias= $domain ]/@owner
    let $owner-hash := $auth:db/domains/domain[@alias= $domain ]/@owner-hash
    let $hash := string(hash:hash($pass, 'sha-256'))
    return
    if (
      $owner-name = $name and $owner-hash = $hash 
    )
    then (
      true()
    )
    else (
      false()
    )
  };

  declare 
    %updating
  function 
    auth:set-user ( 
      $name as xs:string, 
      $password as xs:string, 
      $permission as xs:string
  )
  {
    let $users := $auth:domain/users
    let $new-user := auth:build-user-record($name, $password, $permission)
        
    return 
      if ( $users/user[@name = $name] )
      then 
      (
        replace node $users/user[@name = $name] with $new-user
      )
      else
      (
        insert node $new-user into $users
      )
  };