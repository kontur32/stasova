module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/owner/{$domain}/{$section}")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:owner-dic( $domain, $section, $group,  $item, $pagination, $message ) {

  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "owner"  )
  then (
    
    let $data :=  $conf:domain ( $domain )/data/child::*[ name() = "owner" ]/table[ @type= $section ]
    let $group := if ( $group ) then ( $group ) else ( $data[ 1 ]/@aboutType )
    let $models := $conf:domain ( $domain )/data/owner/table[ @type = "Model" and @aboutType = $data/@aboutType ]
    let $model := $models[ @aboutType= $group ]
     
    let $pagination := 
      if ( $pagination ) 
      then (  number (tokenize ($pagination, "-")[1]), number (tokenize ($pagination, "-")[2]) ) 
      else ( (1, 10) )
      
    let $item := if ( $item ) then ( $item ) else ( $data[@aboutType = $group ]/row[ $pagination[1] ]/cell[@id="id"]/text() )
    
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl("owner"), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    
    let $sectionLabel := $nav-items-data/row[ cell[@id="id" ] = $section ]/cell[ @id="label" ]/text()
   
    let $callback := string-join (( "/trac", "owner" , $domain, $section), "/")
    let $action := string-join (("owner", $section), "/" )
    let $token := Session:get('token')
    let $inputForm := inter:form-update ( $callback , $action, $token, $domain )
    
    let $sidebar :=
      <div>
        <h2>{ $sectionLabel }</h2>
        { inter:section-groups ( $models ) }
        <div class="border-top">
          <p><i>{$message}</i></p>
          {$inputForm}
        </div>
      </div>    

    let $content :=
      <div class="row">
        <div class="col-md-6 border-right"> 
          <h2>{ $model/@label/data() }</h2>
          <p>Доступ к словарю по API: 
            <a href="{ '/trac/api/output/' || $domain || '/dictionaries/' || $group }">
              {'/trac/api/output/' || $domain || '/dictionaries/' || $group }
            </a>
          </p>
          <div>
            { inter:group-items ( $data[ @aboutType = $group ], $pagination  ) }
            { inter:pagination ( $group, $pagination, $data ) }
          </div>
        </div>
        <div class="col-md-6">
          <h2> { $data [@aboutType = $group ] /@label/data()  }</h2>
          {
            inter:item-properties ( $model, $data/row[ @id = $group || "/" || $item ] )
          }
        </div>
      </div>
    
    let $template := serialize( doc("../src/main-tpl.html") )
    let $map := map{ "nav":$nav, "sidebar" :  $sidebar, "content" : $content }
    return st:fill-html-template( $template, $map )//html 
  )
  else (
     web:redirect( '/' || $conf:base )
  )
};