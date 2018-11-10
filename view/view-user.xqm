module namespace view = 'http://www.iro37.ru/trac/interface';

import module namespace Session = "http://basex.org/modules/session";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace st = 'http://www.iro37.ru/trac/funct' at "../functions.xqm";
import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace inter = 'http://www.iro37.ru/trac/lib/interface' at "../lib/inter.xqm";

declare
  %rest:path("/trac/user/{$domain}")
  %output:method ('xhtml')
function view:owner-main( $domain ) {
  if ( auth:get-session-scope ( $domain, Session:get('token') ) = "user"  )
  then (
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl( "user" ), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    let $userID := auth:get-session-user ( $domain, Session:get('token') )
    let $nav-login := inter:build-menu-login ( $conf:user ( $domain, $userID ) )
       
    let $content := 
        <p>Добро пожаловать на страницу руководителя КПК <b>"{$conf:domain ( $domain )/@label/data()}"</b></p>
    let $template := serialize( doc("../src/main-tpl.html") )
    let $map := map{ "nav":$nav, "nav-login" : $nav-login, "sidebar" :  "", "content" : $content }
    return st:fill-html-template( $template, $map )//html 
  )
  else (
     web:redirect( '/' || $conf:base )
  )
};

declare
  %rest:path("/trac/user/{$domain}/course")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:user-section (  $domain, $group,  $item, $pagination, $message ) {

  if ( auth:get-session-scope ( $domain, Session:get('token') ) =  "user" )
  then (
    let $section := "course"
    let $userID := auth:get-session-user ( $domain, Session:get('token') )
    let $userLabel := $conf:domain( $domain )/data/owner/table[ @type="Data" and @aboutType= "users" ]/row[ @id= $userID ]/cell[ @id="label" ]/text()
    
    let $nav-items-data := fetch:xml ( web:create-url( $conf:menuUrl( "user" ), map{ "domain":$domain } ) )/table
    let $nav := inter:build-menu-items ( $nav-items-data )
    let $nav-login := inter:build-menu-login ( $conf:user ( $domain, $userID ) )
   
    let $group := if ( $group ) then ( $group ) else (
      $conf:domain( $domain )/data/owner/table[ @type ="Data" and @aboutType = "course" ]/row[1]/@id/data()
    )
   
    let $callback := string-join (( "/trac", "user" , $domain, $section), "/")
    let $action :=  "user/student"
    let $token := Session:get( 'token' )
    let $inputForm := inter:form-update ( $callback , $action, $token, $domain, $group )   
    
    let $sidebar :=
      <div>
        <h2>Курсы</h2>
        <hr/>
        <ul>
        {
          for $c in $conf:domain( $domain )/data/owner/table[ @type="Data" and @aboutType= $section ]/row [ cell[ @id="person" ] = $userLabel ]
          let $cl := 
            if ( $c/@id/data() = $group ) 
            then ("marked") 
            else ( "" )
          return
            <li class="{$cl}"><a href="{'?group=' || $c/cell[@id='id']/text()}">{ $c/cell[@id="label"]/text() }</a></li>
        }</ul>
        <hr/>
        <p>шаблон анкеты слушателя
            <a href="http://iro37.ru/res/tpl/xlsx/%d0%90%d0%9d%d0%9a%d0%95%d0%a2%d0%90-%d1%81%d0%bb%d1%83%d1%88%d0%b0%d1%82%d0%b5%d0%bb%d0%b8%d0%9a%d0%9f%d0%9a-10112018.xlsx">(скачать)</a>
        </p>
      </div>    

    let $content :=
      <div class="row">
        <div class="col-md-6 border-right"> 
          <h2>Слушатели курса</h2>
          <hr/>
          <ul>
          {
            for $s in $conf:userData( $domain , $userID )/table[ @id= $group ]/row
            order by $s/cell[ @id="familyName" ]
            let $href := 
              web:create-url ( "/trac/api/output/Data/" || $domain, 
                map {
                  "class" : "student",
                  "subject" : $s/@id/data(),
                  "container" : $group,
                  "token" : $token
                }
              )
             let $link-label := string-join ( $s/cell[@id=( "familyName", "givenName", "secondName" )]/text() , " ")
             return 
              <li>
                <a target="_self"  href= "{ $href }"  >
                  { $link-label }
                 </a>
              </li>
          }
          </ul>
          <div class="border-top">
            <p><b>Загрузить (обновить)</b></p>
            <p><i>{$message}</i></p>
            {$inputForm}
          </div>
         </div>
        <div class="col-md-6">
          <h2>Готовые документы</h2>
          {view:build-reports-list ( $domain, $group, $token )}
        </div>
      </div>
    
    let $template := serialize( doc("../src/main-tpl.html") )
    let $map := map{ "nav":$nav, "nav-login" : $nav-login, "sidebar" :  $sidebar, "content" : $content }
    return st:fill-html-template( $template, $map )//html 
  )
  else (
     web:redirect( '/' || $conf:base )
  )
};

(: -------------------------------------------------------------------- :)

declare function view:build-reports-list ( $domain, $group, $token ) {
          <table class="table table-striped">
           {let $reports := 
             try {
              fetch:xml (
                 "http://localhost:8984/trac/api/Data/public/" || $domain || "/"|| "report"
                  )
            }
            catch * { }
           for $r in $reports/table/row
           let $viewUrl := 
               web:create-url (  '/trac/Report/' || $domain || '/' || $r/cell[ @id = 'id' ], 
                map {
                  'type' : 'student',
                  'group' : $group,
                  'token' : $token
                } )
            let $downloadUrl :=
              web:create-url (  '/trac/api/download/Report/' || $domain || '/' || $r/cell[ @id = 'id' ] , 
                  map {
                    'class' : 'student',
                    'container' : $group,
                    'token' : $token
                  })
            let $fileName := 
                $r/cell[ @id = 'label' ]|| '-' || $group || '.docx'
           return
            <tr>
              <td>
                { $r/cell[ @id = 'label' ] }<br/>
                <i><a href="{ $r/cell[ @id = 'template' ] }">(шаблон)</a></i>
              </td>
              <td>
                <a class="btn btn-info" role="button" target="_self" 
                      href="{ $viewUrl }">просмотреть</a>
              </td>
              <td>
                <a 
                  class="btn btn-info" 
                  role="button" 
                  target="_blank" download="{ $fileName }"  
                  href="{ $downloadUrl }">скачать</a>                
              </td>
            </tr>
          }
    </table>
};