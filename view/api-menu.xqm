module namespace int = "http://www.iro37.ru/stasova/api/interface";

import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

declare
  %rest:path("/trac/api/interface/menu/{$scope}")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
function int:nav-user ( $scope, $domain )
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
        <cell id="href">user/{$domain}/prof</cell>
      </row>
      <row>
        <cell id="id">probl</cell>
        <cell id="label">Семинары</cell>
        <cell id="href">user/{$domain}/probl</cell>
      </row>
   </table>
  </menu>
  
 return $menu/child::*[ @id = $scope ]
};