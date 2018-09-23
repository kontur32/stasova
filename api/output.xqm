module namespace output = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';

declare
  %rest:path("/trac/api/output/{$aboutType}")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
  %rest:query-param("token", "{$token}")
function output:users ( $domain, $token, $aboutType )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner")
  then (
    $conf:db//domain[@id = $domain ]/data/owner/table[@type="Data" and @aboutType= $aboutType ]
  )
  else (
    <error>Ошибка авторизации</error>
  )
};

declare
  %rest:path("/trac/api/parser/sha-256")
  %rest:method('GET')
  %rest:query-param("data", "{$data}")
function output:parser-password ( $data )
{
 if ($data)
 then ( string(hash:hash( $data, 'sha-256' )) )
 else ()
};

declare
  %rest:path("/trac/api/output/{$domain}/dictionaries/{$aboutType}")
  %rest:method('GET')
function output:dictionaries ( $domain, $aboutType )
{
  let $dic := $conf:domain ( $domain )//table[ @type="Model" and @aboutType= $aboutType ]/@label
  return 
    element { $dic } {
      let $data := $conf:domain ( $domain )//table[ @type="Dictionaries" and @aboutType=$aboutType ]
      for $r in $data/row
      return 
        element { $data/@label } {
          for $c in $r/cell
          return 
            element {$c/@id} {
              $c/text()
            }
        }    
  }
};