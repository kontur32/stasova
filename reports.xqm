module namespace report = 'http://www.iro37.ru/stasova/order';

import module namespace st = 'http://www.iro37.ru/stasova/funct' at "functions.xqm";


declare 
  %rest:path("/stasova/api/reports/report1")
  %rest:method('GET')
  %rest:query-param("id", "{$id}", "id")
 
function report:report1( $id as xs:string )
{
  <table class="table table-striped">
  <tr>
    <th>№</th>
    <th>Ф.И.О.</th>
     <th>Дата рожд.</th>
     <th>Возраст</th>
     <th>Образование</th>
     <th>Стаж общ.</th>
     <th>Стаж по спец.</th>
     <th>Стаж ИШИ</th>
     <th>Категория</th>
     <th>Награды</th>
     <th>Должность</th>
  </tr>
  {
  for $r in db:open('stasova','data')//row[@class="http://interdomivanovo.ru/schema/vospitatel"]
  count $c
  return 
    <tr>
      <td>{$c}</td>
      <td>{string-join($r/cell[@id = ('фамилия', 'имя', 'отчество') ]/text(), " " )}</td>
      <td>{ $r/cell[@id ='дата рождения']/text() }</td>
      <td>{ years-from-duration(st:count-age(xs:date( $r/cell[@id ='дата рождения']/text() ))) }</td>
      <td>{ $r/cell[@id ='образование']/text() || ", " || $r/cell[@id ='дата завершения образования']/text()}</td>
      <td>{ $r/cell[@id ='стаж общий']/text() }</td>
      <td>{ $r/cell[@id ='стаж педагогический']/text() }</td>
      <td>{ $r/cell[@id ='стаж ИШИ']/text() }</td>
      <td>{ $r/cell[@id ='категория']/text() }
          {
           if( $r/cell[@id ='дата аттестации']/text() )
           then
           (
             ", " || $r/cell[@id ='дата аттестации']/text() ||
             ", прошло лет: " || 
             years-from-duration( st:count-age(xs:date($r/cell[@id ='дата аттестации']/text())))
           )
           else()
          }
       </td>
      <td>{ $r/cell[@id ='награды']/text() }</td>
      <td>{ $r/cell[@id ='должность']/text() }</td>
    </tr>
  }
  </table>
};

declare 
  %rest:path("/stasova/api/reports/report2")
  %rest:method('GET')
function report:report2()
{
  let $head := 
          <tr>
            <th>Всего,<br/>чел / %</th>
            <th>до 30</th>
            <th>31-40</th>
            <th>41-50</th>
            <th>51-60</th>
            <th>61-70</th>
            <th>старше 71</th>
          </tr>
  let $r := db:open('stasova','data')//row[@class="http://interdomivanovo.ru/schema/vospitatel"]
  let $age := 
      for $i in $r
      return 
        years-from-duration(st:count-age(xs:date( $i/cell[@id ='дата рождения']/text())))        
          
  return
  <table class="table table-striped">
    {$head}
    <tr>
      <td>{count($age)}</td>
      <td>{count($age[ data()<=30])}</td>
      <td>{count($age[data()>=31 and data()<=40])}</td>
      <td>{count($age[data()>=41 and data()<=50])}</td>
      <td>{count($age[data()>=51 and data()<=60])}</td>
      <td>{count($age[data()>=61 and data()<=70])}</td>
      <td>{count($age[data()>=71])}</td>
    </tr>
    <tr>
      <td>100</td>
      <td>{round(count($age[data()<=30]) div count($age)*100)}</td>
      <td>{round(count($age[data()>=31 and data()<=40]) div count($age)*100)}</td>
      <td>{round(count($age[data()>=41 and data()<=50]) div count($age)*100)}</td>
      <td>{round(count($age[data()>=51 and data()<=60]) div count($age)*100)}</td>
      <td>{round(count($age[data()>=61 and data()<=70]) div count($age)*100)}</td>
      <td>{round(count($age[data()>=71]) div count($age) *100)}</td>
    </tr>
  </table>
};