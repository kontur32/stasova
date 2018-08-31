 module namespace auth = 'http://iro37.ru/xq/modules/auth';

 declare variable $auth:db := db:open('stasova2');
 declare variable $auth:domain-alias := 'ood';
 declare variable $auth:domain-path := 'domains';
 declare variable $auth:domain := db:open( 'stasova2' , $auth:domain-path )/domains/domain[@alias= $auth:domain-alias];
 
 declare 
 function auth:build-session-record ( $user as xs:string, $duration as xs:dayTimeDuration )
 {
   element session {
     attribute { 'name' } { $user },
     attribute { 'expires' } { string(current-dateTime() + $duration ) },
     attribute { 'token' } { string(xs:hexBinary(hash:hash(string(random:double()) || string(current-dateTime()) , 'sha-256'))) }
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
   auth:set-session( $user as xs:string, $duration as xs:dayTimeDuration )
 {
   let $sessions := $auth:domain/sessions
   let $session := auth:build-session-record ( $user, $duration )
   where $auth:domain/users/user[@name = $user ]
   return
     if ($sessions/session[@name= $user])
     then ( replace node $sessions//session[@name= $user] with $session )
     else ( insert node $session into $sessions)
 };
 
 declare 
   %updating 
 function auth:set-session( $user as xs:string )
 {
   auth:set-session( $user, xs:dayTimeDuration('PT60S') )
 };
  
  declare 
  function 
    auth:validate-session ( $token as xs:string )
  {
    let $session := $auth:domain/sessions/session[@token/data() = $token]
    where $session
    return   
      $session/@token/data() = $token and ( xs:dateTime ($session/@expires/data() ) - current-dateTime() ) div xs:dayTimeDuration('PT1S') > 0
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