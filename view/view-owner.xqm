module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/owner/{$domain}")
  %output:method ('xhtml')
function view:owner-main( $domain ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "owner"  )
  then (
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl("owner"), map{"domain":$domain}))/table
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
  %rest:path("/trac/owner/{$domain}/Data")
  %rest:query-param("group", "{$group}")
  %rest:query-param("item", "{$item}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:owner-data( $domain, $group, $item, $message ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "owner"  )
  then (
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl("owner"), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    let $models :=  $conf:domain ( $domain )/data/owner/table[@type="Model"]
    let $data :=  $conf:domain ( $domain )/data/owner/table[@type="Data"]
    let $group := if ($group) then ($group) else ( $data[1]/@aboutType/data())
    let $item := if ($item) then ($item) else ( $data[@aboutType/data() = $group]/row[1]/cell[@id="id"] )
    let $callback := '/trac/owner/' || $domain || "/Data"
    let $action := 'owner/data/' || $group
    let $token := Session:get('token')
    let $inputForm := inter:form-update ( $callback , $action, $token, $domain )
    
    let $sidebar :=
      <div>
        <h2>Данные</h2>
        <ul>
        {
          for $i in $models
          return 
            <li><a href="?group={$i/@aboutType/data()}">{$i/@label/data()}</a></li>
        }
        </ul>
        <div class="border-top">
          <p><i>{$message}</i></p>
          {$inputForm}
        </div>
      </div>    
    
    let $content :=
      <div class="row">
        <div class="col-md-6 border-right"> 
          <h2>{$models[@aboutType= $group ]/@label/data()}</h2>
          <ul>{
            for $i in $data[@aboutType= $group ]/row
            return
              <li>
                <a href="?group={$group}&amp;item={$i/cell[@id='id']}">
                  {$i/cell[@id="label"]}
                </a>
              </li>
          }</ul>
        </div>
        
        <div class="col-md-6">
          <h2>{  $data[@aboutType = $group ]/@label/data() }</h2>
          <table class="table table-striped">{
            for $i in $data/row[ @id = $group || "/" || $item ]/cell
            let $cellLabel := $models[@aboutType= $group ]/row [@id = $group || "/" || $i/@id ] /cell [@id="label"]
            return
              <tr>
                <th>{ $cellLabel }</th>
                <td>{$i/text()}</td>
              </tr>
          }</table>
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
  %rest:path("/trac/owner/{$domain}/Model")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:owner-model( $domain, $group,  $item, $pagination, $message ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "owner"  )
  then (
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl("owner"), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    let $data :=  $conf:domain ( $domain )/data/owner/table[@type="Model"]
    
    let $group := if ( $group ) then ( $group ) else ( $data[ 1 ]/@aboutType )    
    let $pagination := 
      if ( $pagination ) 
      then ( 
          map{ 
            "first" : number(substring-before ( $pagination, "-" )),
            "last" : number(substring-after ( $pagination, "-" )) }
      ) 
      else ( map{ "first" : 1, "last" : 10 } )
    let $item := if ( $item ) then ( $item ) else ( $data[@aboutType = $group ]/row[ $pagination?first ]/cell[@id="id"]/text() )
    
    let $callback := '/trac/owner/' || $domain || "/Model"
    let $action := 'owner/Model'
    let $token := Session:get('token')
    let $inputForm := inter:form-update ( $callback , $action, $token, $domain )
    
    let $sidebar :=
      <div>
        <h2>Модели</h2>
        <ul>
        {
          for $i in $data
          return 
            <li><a href="?group={$i/@aboutType/data()}">{$i/@label/data()}</a></li>
        }
        </ul>
        <div class="border-top">
          <p><i>{$message}</i></p>
          {$inputForm}
        </div>
      </div>    

    let $content :=
      <div class="row">
        <div class="col-md-6 border-right"> 
          <h2>{$data[@aboutType= $group ]/@label/data()}</h2>
          <ul>{
            for $i in $data[@aboutType= $group ]/row
            return
              <li>
                <a href="?group={$group}&amp;item={$i/cell[@id='id']}">
                  {$i/cell[@id="label"]}
                </a>
              </li>
          }</ul>
        </div>
        
        <div class="col-md-6">
          <h2>{ $data/row[ @id = $group || "/" || $item ]/cell[@id="label"] }</h2>
          <table class="table table-striped">{
            for $i in $data/row[ @id = $group || "/" || $item ]/cell
            return
              <tr>
                <th>{$i/@id/data()}</th>
                <td>{$i/text()}</td>
              </tr>
          }</table>
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
  %rest:path("/trac/owner/{$domain}/Dictionaries")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:owner-dic( $domain, $group,  $item, $pagination, $message ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "owner"  )
  then (
    let $data :=  $conf:domain ( $domain )/data/owner/table[@type="Dictionaries"]
    let $group := if ( $group ) then ( $group ) else ( $data[ 1 ]/@aboutType )    
    let $pagination := 
      if ( $pagination ) 
      then ( 
          map{ 
            "first" : number(substring-before ( $pagination, "-" )),
            "last" : number(substring-after ( $pagination, "-" )) }
      ) 
      else ( map{ "first" : 1, "last" : 10 } )
    let $item := if ( $item ) then ( $item ) else ( $data[@aboutType = $group ]/row[ $pagination?first ]/cell[@id="id"]/text() )
    
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl("owner"), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
   
    let $callback := '/trac/owner/' || $domain || "/Dictionaries"
    let $action := 'owner/Dictionaries'
    let $token := Session:get('token')
    let $inputForm := inter:form-update ( $callback , $action, $token, $domain )
    
    let $sidebar :=
      <div>
        <h2>Словари</h2>
        <ul>
        {
          for $i in $conf:domain ( $domain )/data/owner/table[ @type = "Model" and @aboutType = $data/@aboutType ]
          return 
            <li><a href="?group={$i/@aboutType/data()}">{$i/@label/data()}</a></li>
        }
        </ul>
        <div class="border-top">
          <p><i>{$message}</i></p>
          {$inputForm}
        </div>
      </div>    

    let $content :=
      let $model := $conf:domain ( $domain )/data/owner/table[@type="Model" and @aboutType= $group ]
      return
      <div class="row">
        <div class="col-md-6 border-right"> 
          <h2>{ $model[ @aboutType= $group ]/@label/data() }</h2>
          <p>Доступ к словарю по API: 
            <a href="{ '/trac/api/output/' || $domain || '/dictionaries/' || $group }">
              {'/trac/api/output/' || $domain || '/dictionaries/' || $group }
            </a>
          </p>
          <ul>{
            for $i in $data[ @aboutType= $group ]/row [ 
                position() >= $pagination?first and
                position() <= $pagination?last  
              ]
            return
              <li>
                <a href="?group={$group}&amp;item={$i/cell[@id='id']}&amp;pagination={ $pagination?first || '-' || $pagination?last }">
                  {$i/cell[@id="label"]}
                </a>
              </li>
          }</ul>
          <p>
            <span style="float: left">
              <a href = "{ web:create-url ('', map { 'pagination': '1-10', 'group': $group } ) }">&lt;&lt; </a>
              <a href="{
                let $first := $pagination?first - 10
                let $first := if ( $first < 1 ) then ( 1 ) else ( $first )
                let $last  := $first + 9
                return 
                  web:create-url ('', map { 'pagination': $first || '-' || $last, 'group': $group } ) }"> предыдущие</a>
            </span>
            <span style="float: right" >
             <a href="{              
                let $last  := if ( $pagination?last +10 > count ( $data[ @aboutType = $group]/row ) ) then ( count ( $data[ @aboutType = $group]/row ) ) else ( $pagination?last + 10 )
                let $first := if ($last < 10) then ( 1 ) else ( $last - 9 )
                return 
                 web:create-url ('', map { 'pagination': $first || '-' || $last, 'group': $group } ) 
               }">следующие </a>
             <a href = "{ 
               let $count := count ( $data[ @aboutType = $group]/row )
               let $first := if ( $count < 10 ) then ( 1 ) else ( $count - 9 )
               return
                 web:create-url ('', map { 'pagination': $first || "-" || $first + 9 , 'group': $group } ) }"> &gt;&gt;</a>
            </span>
          </p>
        </div>
        
        <div class="col-md-6">
          <h2> { $data[ @aboutType = $group ]/@label/data()  }</h2>
          <table class="table table-striped">{
            for $i in $data/row[ cell[ @id = "id" ]/text() = $item ]/cell
            let $cellLabel := $model/row [@id= $group || "/" || $i/@id ]/cell[@id="label"]/text()
            return
              <tr>
                <th>{ $cellLabel }</th>
                <td>{$i/text()}</td>
              </tr>
          }</table>
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