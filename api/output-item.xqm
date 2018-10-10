module namespace apioutput = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";

declare
  %rest:path("/trac/api/output/Data/{$domain}")
  %rest:method('GET')
  %rest:query-param( "class", "{$class}" )
  %rest:query-param( "container", "{$container}" )  
  %rest:query-param( "subject", "{$subject}" )    
  %rest:query-param( "token", "{$token}" )
  %rest:query-param( "output", "{$output}" )
  %output:method( "xhtml" )

function apioutput:open-data ( $domain, $class, $container, $subject, $token, $output )
{
  if ( auth:get-session-scope ( $domain, $token ) = ( "owner", "user" ) )
  then (
    let $userID := auth:get-session-user ( $domain, $token )
    let $model := $conf:models ( $domain ) [ @aboutType = $class ]
    let $item := $conf:userData ( $domain,  $userID )/table[ @aboutType = $class and @id=$container ]/row [ @id = $subject ]
    let $item-html := 
          let $content := inter:item-properties ( $model, $item )
          let $sidebar := 
            <div>
              <h2>{ $model/@label/data() }</h2>
              <p><b>Курсов </b> {$conf:domain("ood")/data/owner/table[@type="Data" and @aboutType="course"]/row [@id=$container]/cell[@id="label"]/text()} </p>
            </div>
          
          let $template := serialize( doc("../src/main-tpl.html") )
          let $map := map{ "nav": "", "nav-login" : "", "sidebar" :  $sidebar, "content" : $content }
          return st:fill-html-template( $template, $map )//html 

    return
      switch ( $output )
      case "xml" return $item
      case "html" return $item-html
      default return $item-html
   )
  else ( "Не достаточно прав" )
};