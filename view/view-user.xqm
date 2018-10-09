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
  %rest:path("/trac/user/{$domain}/{$section}")
  %rest:query-param("group", "{$group}")  
  %rest:query-param("item", "{$item}")
  %rest:query-param("pagination", "{$pagination}")
  %rest:query-param("message", "{$message}")
  %output:method ('xhtml')
function view:user-section (  $domain, $section, $group,  $item, $pagination, $message ) {

  if ( auth:get-session-scope ( $domain, Session:get('token') ) =  "user" )
  then (
   
    let $nav-items-data := fetch:xml ( web:create-url($conf:menuUrl( "user" ), map{"domain":$domain}))/table
    let $nav := inter:build-menu-items ($nav-items-data)
    let $userID := auth:get-session-user ( $domain, Session:get('token') )
    let $nav-login := inter:build-menu-login ( $conf:user ( $domain, $userID ) )
   
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
          for $c in $conf:domain("ood")/data/owner/table[ @type="Data" and @aboutType= $section ]/row
          return
            <li><a href="{'?group=' || $c/cell[@id='id']/text()}">{ $c/cell[@id="label"]/text() }</a></li>
        }</ul>
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
             let $link-label := string-join ( $s/cell[@id=("familyName", "givenName", "secondName")]/text() , " ")
             return 
              <li>
                <a target="_blank"  href= "{ $href }"  >
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
          <h2>Отчеты</h2>
          <table class="table table-striped">
            <tr></tr>
            <tr>
              <td>
                Приказ о зачислении<br/>
                <i><a href="http://iro37.ru/res/tpl/%d0%bf%d1%80%d0%b8%d0%ba%d0%b0%d0%b7_%d0%b7%d0%b0%d1%87%d0%b8%d1%81%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5.docx">(шаблон)</a></i>
              </td>
              <td><a target="_blank" href="{
              web:create-url (  '/trac/api/output/Report/' || $domain || '/1', 
                map {
                  'class' : 'student',
                  'container' : $group,
                  'token' : $token
                })
              }">просмотреть</a></td>
              <td>
                <a target="_blank" download="{'Приказ о зачислении ' || $group || '.docx'}"  href="{
                web:create-url (  '/trac/api/download/Report/' || $domain || '/1', 
                  map {
                    'class' : 'student',
                    'container' : $group,
                    'token' : $token
                  })
                }">скачать</a>                
              </td>
              
            </tr>
            <tr>
              <td>Для дистанта<br/>
                <i><a href="#">(шаблон)</a></i>
              </td>
              <td><a target="_blank" href="#">просмотреть</a></td>
              <td><a target="_blank" href="#">скачать</a></td>
            </tr>
            <tr>
              <td>Для бухгалетрии<br/>
                <i><a href="#">(шаблон)</a></i>
              </td>
              <td><a target="_blank" href="#">просмотреть</a></td>
              <td><a target="_blank" href="#">скачать</a></td>
            </tr>
            <tr>
              <td>Регистрационный лист<br/>
                <i><a href="#">(шаблон)</a></i>
              </td>
              <td><a target="_blank" href="#">просмотреть</a></td>
              <td><a target="_blank" href="#">скачать</a></td>
            </tr>
            <tr>
              <td>Приказ об отчислении<br/>
                <i><a href="#">(шаблон)</a></i>
              </td>
              <td><a target="_blank" href="#">просмотреть</a></td>
              <td><a target="_blank" href="#">скачать</a></td>
            </tr>
          </table>
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