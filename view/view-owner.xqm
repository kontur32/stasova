module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/{ $scope }/{$domain}")
  %output:method ('xhtml')
function view:owner-main( $scope, $domain ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = $scope  )
  then (
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl($scope), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    let $content := 
        <p>Добро пожаловать на страницу владельца домена <b>"{$conf:db//domain[@id=$domain]/@label/data()}"</b></p>
    let $template := serialize( doc("../src/main-tpl.html") )
    let $map := map{ "sidebar" : "", "content" :  $content, "nav":$nav }
    return st:fill-html-template( $template, $map )//html 
    
  )
  else (
     web:redirect( '/' || $conf:base )
  )

};

declare
  %rest:path("/trac/{$scope}/{$domain}/{$section}")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:owner-section ( $scope, $domain, $section, $group,  $item, $pagination, $message ) {

  if ( auth:get-session-scope ( $domain, Session:get('token') ) =  $scope )
  then (
    
    let $data :=  $conf:domain ( $domain )/data/child::*[ name() = $scope ]/table[ @type= $section ]
    let $group := if ( $group ) then ( $group ) else ( $data[ 1 ]/@aboutType )
    let $models := $conf:domain ( $domain )/data/owner/table[ @type = "Model" and @aboutType = $data/@aboutType ]
    let $model := $models[ @aboutType= $group ]
     
    let $pagination := 
      if ( $pagination ) 
      then (  number (tokenize ($pagination, "-")[1]), number (tokenize ($pagination, "-")[2]) ) 
      else ( (1, 10) )
      
    let $item := if ( $item ) then ( $item ) else ( $data[@aboutType = $group ]/row[ $pagination[1] ]/cell[@id="id"]/text() )
    
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl($scope), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    
    let $sectionLabel := $nav-items-data/row[ cell[@id="id" ] = $section ]/cell[ @id="label" ]/text()
   
    let $callback := string-join (( "/trac", $scope , $domain, $section), "/")
    let $action := $scope
    let $token := Session:get( 'token' )
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
                <a href="{ string-join ( ('/trac/api/output/Data', $domain, $scope, $group), '/') }">
                  (открытый доступ по API)
                </a>   
          <div>
            { inter:group-items ( $data[ @aboutType = $group ], $pagination  ) }
            { inter:pagination ( $group, $pagination, $data ) }
          </div>
        </div>
        <div class="col-md-6">
          <h2> { 
            let $itemLabel := $data [ @aboutType = $group ] /@label/data()
            return 
              concat (upper-case (substring ( $itemLabel, 1, 1)), substring ( $itemLabel, 2 ))
          }</h2>
          {
            inter:item-properties ( $model, $data/row[ @id =  $item ] )
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

declare
  %rest:path("/trac/{$scope}/{$domain}/OpenData")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:open-data ( $scope, $domain, $group,  $item, $pagination, $message ) {

  if ( auth:get-session-scope ( $domain, Session:get('token') ) =  $scope )
  then (
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl($scope), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
   
 
    let $sidebar :=
      <div>
        <h2> Открытые данные </h2>
        <a href="#">Школы</a>
      </div>    

    let $content :=
      <div class="row">
        <div class="col-md-12 border-right"> 
        <h2>Сведения о функционировании системы общего образования</h2>
        <p>Источник: 
          <a href="http://opendata.mon.gov.ru/opendata/7710539135-OO">портал открытых данных Минобрнауки России</a>
        </p>
          {
            fetch:xml( web:create-url ("http://localhost:8984/trac/opendata/schools", 
            map {
              "path":"http://opendata.mon.gov.ru/opendata/7710539135-OO/data-20160701T102009-structure-20150907.csv",
              "class" : "table table-striped"
            }
          ))
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