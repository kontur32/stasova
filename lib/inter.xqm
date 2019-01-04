module namespace inter = 'http://www.iro37.ru/trac/lib/interface';

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

declare function inter:build-menu-items ( $data as element(table) )
{
  <div class="collapse navbar-collapse">
    <ul class="nav navbar-nav">
    {
      for $i in $data/row
      return 
        <li class="nav-item">
          <a class="nav-link" href="{'/' || $conf:base || '/' || $i/cell[@id='href']/text()}">{$i/cell[@id="label"]/text()}</a>
        </li>
    }
    </ul>
  </div>
};

declare function inter:build-menu-login ( $user as element ( table ) )
{
  <div class="collapse navbar-collapse justify-content-end">
    <ul class="nav navbar-nav">
      <li class="nav-item"><a class="nav-link" href="#"><span>{$user//cell[@id = "label"]/text()}</span><img class="img .img-fluid" style="max-height: 70px;" src="{$user//cell[@id = 'photo']/text()}"/></a></li>
      <li class="nav-item"><a class="nav-link" href="/trac/logout">Выйти</a></li>
    </ul>
</div>
};

declare
function inter:form-update ( $callback, $action, $token, $domain )
{
  <form action=  "{ '/trac/api/input/' || $action }" method="POST" enctype="multipart/form-data">
      <input type="file" name="file" multiple="multiple"/>
      <input type="text" name="callback" value="{ $callback }" hidden="true" />
      <input type="text" name="domain" value="{ $domain }" hidden="true"/>
      <input type="text" name="token" value="{ $token }" hidden="true"/>
      <input class="btn btn-info" type="submit" value="Обновить/загрузить данные"/>
  </form>
};

declare
function inter:form-update ( $callback, $action, $token, $domain, $group )
{
  <form action=  "{ '/trac/api/input/' || $action }" method="POST" enctype="multipart/form-data">
                  <input type="file" role = "button" name="file" multiple="multiple"/>
                  <input type="text" name="group" value="{ $group }" hidden="true" />
                  <input type="text" name="callback" value="{ $callback }" hidden="true" />
                  <input type="text" name="domain" value="{ $domain }" hidden="true"/>
                  <input type="text" name="token" value="{ $token }" hidden="true"/>
                  <br/>
                  <input class="btn btn-info" type="submit" value="Обновить/загрузить данные"/>
              </form>
};

declare
function inter:section-groups (
      $data as element(table)*, $domain, $type, $callback, $token
       )
{
  <table>
    <form method="GET" action="/trac/api/delete/owner">
    <input type="text" name="token" value="{ $token }" hidden="true"/>
    <input type="text" name="domain" value="{ $domain }" hidden="true"/>
    <input type="text" name="type" value="{ $type }" hidden="true"/>
    <input type="text" name="callback" value="{ $callback }" hidden="true" />
    <button onclick="return confirm('Удалить?');" >Удалить…</button>
    {
      for $i in $data
      return 
        <tr>
          <td>
            <input type="checkbox" name="class" value="{$i/@aboutType/data()}" onclick="buttons(this)"/>
            <a href="?group={$i/@aboutType/data()}">{$i/@label/data()}</a>
          </td>
        </tr>
    }
    </form>
  </table> 
};

declare
function inter:group-items (
      $data as element()*,
      $pagination 
       )
{
  <ul>{
            for $i in $data/row [ 
                position() >= $pagination[1] and
                position() <= $pagination[2]  
              ]
            let $param := web:create-url ("", map{ 
                              "group" : $data/@aboutType, 
                              "item" : $i/cell[@id='id'],
                              "pagination" :  string-join ($pagination, '-')
                              })
            return
              <li>
                <a href=" { $param } ">
                  {$i/cell[@id="label"]}
                </a>
              </li>
          }</ul>
};

declare
function inter:item-properties ( 
      $model as element(table)*, 
      $data as element(row)* )
{
    <table class="table table-striped">{
      for $i in $data/cell
      let $cellLabel := $model/row [@id=  $i/@id ]/cell[@id="label"]/text()
      return
        <tr>
          <th>{ if ( $cellLabel ) then ( $cellLabel) else ( $i/@id/data() ) }</th>
          <td>{$i/text()}</td>
        </tr>
    }</table>
};

declare
function inter:pagination ( $group, $pagination, $data )
{
   <span>
    <span style="float: left">
      <a href = "{ web:create-url ('', map { 'pagination': '1-10', 'group': $group } ) }"><b><u>&lt;&lt;</u></b> </a>
      <a href="{
        let $first := $pagination[1] - 10
        let $first := if ( $first < 1 ) then ( 1 ) else ( $first )
        let $last  := $first + 9
        return 
          web:create-url ('', map { 'pagination': $first || '-' || $last, 'group': $group } ) }"> &lt;</a>
    </span>
    <span style="float: right" >
     <a href="{              
        let $last  := if ( $pagination[2] +10 > count ( $data[ @aboutType = $group]/row ) ) then ( count ( $data[ @aboutType = $group]/row ) ) else ( $pagination[2] + 10 )
        let $first := if ($last < 10) then ( 1 ) else ( $last - 9 )
        return 
         web:create-url ('', map { 'pagination': $first || '-' || $last, 'group': $group } ) 
       }">&gt; </a>
     <a href = "{ 
       let $count := count ( $data[ @aboutType = $group]/row )
       let $first := if ( $count < 10 ) then ( 1 ) else ( $count - 9 )
       return
         web:create-url ('', map { 'pagination': $first || "-" || $first + 9 , 'group': $group } ) }"> <b><u>&gt;&gt;</u></b></a>
    </span>
  </span>
};