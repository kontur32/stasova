module namespace int = "http://www.iro37.ru/stasova/api/interface";

declare
  %rest:path("/trac/api/interface/menu/main")
  %rest:method('GET')
function int:nav-main1 (  )
{
  <table>
    <row>
      <cell id="id">domains</cell>
      <cell id="label">Домены</cell>
      <cell id="href">/trac/domains</cell>
    </row>
  </table>
};

declare
  %rest:path("/trac/api/interface/menu/owner")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
function int:nav-owner ( $domain )
{
  <table>
    <row>
      <cell id="id">resource</cell>
      <cell id="label">Ресурсы</cell>
      <cell id="href">{$domain}?section=resourses</cell>
    </row>
    <row>
      <cell id="id">orders</cell>
      <cell id="label">Отчеты</cell>
      <cell id="href">{$domain}?section=orders</cell>
    </row>
  </table>
};