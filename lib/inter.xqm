module namespace inter = 'http://www.iro37.ru/trac/lib/interface';

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

declare function inter:build-menu-items ( $data as element(table) )
{
  <div class="collapse navbar-collapse">
    <ul class="nav navbar-nav">
    {
      for $i in $data//row
      return 
        <li class="nav-item">
          <a class="nav-link" href="{'/' || $conf:base || '/' || $i/cell[@id='href']/text()}">{$i/cell[@id="label"]/text()}</a>
        </li>
    }
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
                  <br/>
                  <input type="submit" value="Обновить данные"/>
              </form>
};