module namespace report = "http://www.iro37.ru/trac/Report";

import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";

declare
  %rest:path("/trac/Report/{$domain}/{$report}")
  %rest:method('GET')
  %rest:query-param( "type", "{$type}" )
  %rest:query-param( "group", "{$group}" )     
  %rest:query-param( "token", "{$token}" )
  %output:method( "xhtml" )

function report:report ( $report, $domain, $type, $group, $token )
{
    let $content :=  
         try {
           fetch:xml ( web:create-url ("http://localhost:8984/trac/api/output/Report/" || $domain || "/" || $report, 
                       map{ "type" : $type,
                             "group" : $group, 
                             "token" : $token }
                           )  )
         }
         catch * {}    
          
      let $template := serialize( doc("../src/main-tpl.html") )
      let $map := map{ "nav": "", "nav-login": "", "sidebar" :  "", "content" : $content }
      return st:fill-html-template( $template, $map )//html 
};