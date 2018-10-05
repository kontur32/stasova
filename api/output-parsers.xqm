module namespace output = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';


declare
  %rest:path("/trac/api/parser/{$domain}/sha-256")
  %rest:method('GET')
  %rest:query-param("data", "{$data}")
function output:parser-hash ( $domain, $data )
{
 if ($data)
 then ( string(hash:hash( $data, 'sha-256' )) )
 else ()
};

declare
  %rest:path("/trac/api/parser/{$domain}/psw")
  %rest:method('GET')
  %rest:query-param("data", "{$data}")
  %rest:query-param("id", "{$id}")
function output:parser-psw ( $domain, $data, $id )
{
 if ($data)
 then ( 
   element {"table"} {
     attribute { "type" } { "Data" },
     element {"row"} {
        attribute { "type" } { "pswRecord" },
        attribute { "id" } { $id },
       element {"cell"} {
         attribute {"id"} { "password" },
         $data
       },
       element { "cell" } {
         attribute {"id"} { "hash" },
         string(hash:hash( $data, 'sha-256' )) 
       }
     }
   }
 )
 else ()
};

declare
  %rest:path("/trac/api/parser/{$domain}/coursePerson")
  %rest:method('GET')
  %rest:query-param("data", "{$data}")
function output:parser-personPK ( $domain, $data )
{
 if ($data)
 then ( 
   $conf:domain( $domain )/data/owner/table[@type="Data" and @aboutType="users"]/row[ cell[@id="label"]/text() = $data ]/cell[@id="id"]/text()
 )
 else ()
};
