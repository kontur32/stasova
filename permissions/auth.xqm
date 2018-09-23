module namespace auth = 'http://iro37.ru/xq/modules/auth';

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
 
 declare
 function auth:build-token ( )
 {
    string(xs:hexBinary(hash:hash(string(random:double()) || string(current-dateTime()) , 'sha-256')))
 };
 
 declare
 function auth:build-session-record ( $user as xs:string, $scope, $token, $duration as xs:dayTimeDuration )
 {   
   element session {
     attribute { 'userid' } { $user },
     attribute { 'scope' } { $scope },
     attribute { 'expires' } { string(current-dateTime() + $duration ) },
     attribute { 'token' } { $token  }
   }
 };

declare
  function auth:build-user-record ( 
    $name as xs:string,
    $label as xs:string, 
    $password as xs:string, 
    $permission as xs:string
  )
  {
    element user {
      attribute {'id'} { $name },
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
   auth:set-session( $domain as xs:string, $user as xs:string, $scope, $token, $duration as xs:dayTimeDuration )
 {
   let $sessions := $conf:domain ($domain)/sessions
   let $session := auth:build-session-record ( $user, $scope , $token, $duration )  
   where 
     $conf:getUser ( $domain, $user ) or
     $conf:domain( $domain )/@owner = $user
   
   return
     if ($sessions/session[@userid= $user])
     then ( replace node $sessions//session[@userid= $user][last()] with $session )
     else ( insert node $session into $sessions)
 };
 
 declare 
   %updating 
 function auth:set-session($domain as xs:string, $user as xs:string, $scope, $token )
 {
   auth:set-session($domain, $user, $scope, $token, $conf:session-duration )
 };
  
  declare 
  function  
    auth:validate-session ( $domain, $token )
  {
    let $session := $conf:db/domains/domain[@id = $domain]/sessions/session[@token/data() = $token]
    where $session
    return   
      $session/@token/data() = $token and ( xs:dateTime ($session/@expires/data() ) - current-dateTime() ) div xs:dayTimeDuration('PT1S') > 0 
  }; 
  
    declare 
  function  
    auth:get-session-scope ( $domain, $token )
  {
    let $session := $conf:db/domains/domain[@id = $domain]/sessions/session[@token/data() = $token]
    where  auth:validate-session ( $domain, $token )
    return   
     $session/@scope/data() 
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
    let $userHash := $conf:getUser ( $domain, $name )/cell[@id="hash"]/text()
    let $userStatus := $conf:getUser ( $domain, $name )/cell[@id="status"]/text()
    let $hash := string(hash:hash($pass, 'sha-256'))
    return
      if ( $userHash = $hash and  $userStatus = "active")
      then ( true() )
      else ( false() )
  };  

declare function 
    auth:validate-owner ( $domain as xs:string , $name as xs:string, $pass as xs:string)
  {
    let $owner-name := $conf:db/domains/domain[@id= $domain ]/@owner
    let $owner-hash := $conf:db/domains/domain[@id= $domain ]/@owner-hash
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