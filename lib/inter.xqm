module namespace inter = 'http://www.iro37.ru/trac/lib/interface';

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

declare function inter:build-menu-items ( $data as element(table) )
{
  <div class="collapse navbar-collapse">
    <ul class="nav navbar-nav">
    {
      for $i in $data//row
      return 
        <li class="nav-item"><a class="nav-link" href="{$i/cell[@id='href']/text()}">{$i/cell[@id="label"]/text()}</a></li>
    }
    </ul>
  </div>
};