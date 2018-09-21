module namespace int = "http://www.iro37.ru/stasova/api/interface";

import module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";

declare
  %rest:path("/trac/api/interface/menu/main")
  %rest:method('GET')
function int:nav-main1 (  )
{
  <table>
    <row>
      <cell id="id">domains</cell>
      <cell id="label">Домены</cell>
      <cell id="href">domains</cell>
    </row>
  </table>
};

declare
  %rest:path("/trac/api/interface/menu/owner")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
function int:nav-owner ( $domain )
{
  <table domain="{$domain}">
    <row>
      <cell id="id">model</cell>
      <cell id="label">Модели</cell>
      <cell id="href">owner/{$domain}/Model</cell>
    </row>
    <row>
      <cell id="id">resource</cell>
      <cell id="label">Данные</cell>
      <cell id="href">owner/{$domain}/Data</cell>
    </row>
    <row>
      <cell id="id">dictionaries</cell>
      <cell id="label">Словари</cell>
      <cell id="href">owner/{$domain}/Dictionaries</cell>
    </row>
    <row>
      <cell id="id">orders</cell>
      <cell id="label">Отчеты</cell>
      <cell id="href">owner/{$domain}/Orders</cell>
    </row>
  </table>
};