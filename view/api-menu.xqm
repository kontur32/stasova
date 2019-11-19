module namespace int = "http://www.iro37.ru/stasova/api/interface";

import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

declare
  %rest:path("/trac/api/interface/menu/{$scope}")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
function int:nav-scope ( $scope, $domain )
{
  let $menu :=
  <menu>
    <table id = "main">
      <row>
        <cell id="id">domains</cell>
        <cell id="label">Организации</cell>
        <cell id="href">domains</cell>
      </row>
      <row>
        <cell id="id">OpenData</cell>
        <cell id="label">Открытые данные</cell>
        <cell id="href">OpenData</cell>
      </row>
    </table>
    <table id = "owner" domain="{$domain}">
      <row>
        <cell id="id">Model</cell>
        <cell id="label">Модели</cell>
        <cell id="href">owner/{$domain}/Model</cell>
      </row>
      <row>
        <cell id="id">Data</cell>
        <cell id="label">Данные</cell>
        <cell id="href">owner/{$domain}/Data</cell>
      </row>
      <row>
        <cell id="id">OpenData</cell>
        <cell id="label">Открытые данные</cell>
        <cell id="href">owner/{$domain}/OpenData</cell>
      </row>
    </table>
    <table id="user" domain="{$domain}">
      <row>
        <cell id="id">domain</cell>
        <cell id="label">Главная</cell>
        <cell id="href">user/{$domain}</cell>
      </row>
      <row>
        <cell id="id">course</cell>
        <cell id="label">Курсы</cell>
        <cell id="href">user/{$domain}/course</cell>
      </row>
      <row>
        <cell id="id">prof</cell>
        <cell id="label">Профпереподготовка</cell>
        <cell id="href">user/{$domain}/course</cell>
      </row>
      <row>
        <cell id="id">probl</cell>
        <cell id="label">Семинары</cell>
        <cell id="href">user/{$domain}/course</cell>
      </row>
   </table>
  </menu>
  
 return $menu/child::*[ @id = $scope ]
};

declare
  %rest:path("/trac/api/interface/menu/static")
  %rest:query-param("domain", "{$domain}")
  %rest:method('GET')
function int:nav-static ( $domain )
{
  let $menu :=
  <menu>
    <table id="ood" domain="{$domain}">
         <ul class="navbar-nav">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" id="navbardrop" data-toggle="dropdown">
                ЗаполниТитул
              </a>
              <div class="dropdown-menu">
              <a class="dropdown-item" target="_blanc" href="http://dbx.iro37.ru/zapolnititul/v/iroio?path=ood&amp;form=rp1">Благодарственное письмо</a>
                <a class="dropdown-item" target="_blanc" href="http://dbx.iro37.ru/zapolnititul/v/iroio?path=ood&amp;form=rp2">Сертификат</a>
                <a class="dropdown-item" target="_blanc" href="http://dbx.iro37.ru/zapolnititul/v/iroio?path=ood&amp;form=rp3">Деловое письмо</a>
              </div>
            </li>
          </ul>
    </table>
    <table id="lipers" domain="{$domain}">
         <ul class="navbar-nav">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" id="navbardrop" data-toggle="dropdown">
                ЗаполниТитул
              </a>
              <div class="dropdown-menu">
                <a class="dropdown-item" target="_blanc" href="http://dbx.iro37.ru/zapolnititul/v/lipers?path=edu&amp;form=rp">Рабочая программа</a>
              </div>
            </li>
          </ul>
    </table>
  </menu>
  
 return $menu/table[ @id = $domain ]
};