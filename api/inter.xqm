module namespace int = "http://www.iro37.ru/stasova/api/interface";

declare
  %rest:path("/trac/api/interface/main")
  %rest:method('GET')
function int:nav-main (  )
{
  <div class="collapse navbar-collapse">
    <ul class="nav navbar-nav">
      <li class="nav-item"><a class="nav-link" href="/trac/domains">Домены</a></li>
    </ul>
</div>
};

declare
  %rest:path("/trac/api/interface/owner")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
function int:nav-owner ( $domain )
{
  <div class="collapse navbar-collapse">
    <ul class="nav navbar-nav">
      <li class="nav-item"><a class="nav-link" href="{'/trac/owner/' || $domain }">Ресурсы</a></li>
      <li class="nav-item"><a class="nav-link" href="#">Отчёты</a></li>
    </ul>
</div>
};