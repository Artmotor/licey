module namespace report = 'http://www.iro37.ru/stasova/order';
import module namespace st = 'http://www.iro37.ru/stasova/funct' at "functions.xqm";

declare 
  %rest:path("/stasova/api/reports/report1")
  %rest:method('GET')
  %rest:query-param("id", "{$id}", "id")
 
function report:report1( $id as xs:string )
{
  <table class="table table-striped">
  <caption>Кадровый состав ПДО</caption>
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
  return 
    <tr>
      <td>{count($r/preceding-sibling::*)+1}</td>
      <td>{$r/cell[@id ='фамилия'] || " "|| $r/cell[@id ='имя'] || " " || $r/cell[@id ='отчество']}</td>
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
  %rest:query-param("class", "{$class}", "class")
function report:report2( $class )
{
  <table class="table table-striped">
    <tr>
      <th>Всего,<br/>чел / %</th>
      <th>до 30</th>
      <th>31-40</th>
      <th>41-50</th>
      <th>51-60</th>
      <th>61-70</th>
      <th>старше 71</th>
    </tr>
  {
  let $r := db:open('stasova','data')//row[@class=$class]
  let $age := 
      for $i in $r
      return 
        years-from-duration(st:count-age(xs:date( $i/cell[@id ='Дата рождения']/text())))
  let $age-group :=
     <tr>
      <td>{count($age)}</td>
      <td>{count($age[ data()<=30])}</td>
      <td>{count($age[data()>=31 and data()<=40])}</td>
      <td>{count($age[data()>=41 and data()<=50])}</td>
      <td>{count($age[data()>=51 and data()<=60])}</td>
      <td>{count($age[data()>=61 and data()<=70])}</td>
      <td>{count($age[data()>=71])}</td>
    </tr>
  return
  <tbody> 
    <tr>
      {for $i in $age-group/td
      return 
        $i}
    </tr>
    <tr>
      {
        for $i in $age-group/td
        return 
          <td>{round ($i div $age-group/td[1] * 100)}</td>
      }
    </tr>
    </tbody>
   }</table>
};

declare 
  %rest:path("/stasova/api/reports/report3")
  %rest:method('GET')
  %rest:query-param("class", "{$class}", "class")
  %output:method('html')
function report:report3( $class )
{
  let $a := ('Доход семьи', "Жилищные условия", 'Форма обучения', "Группа здоровья", "Характер работы матери", "Характер работы отца", "Место работы матери", "Место работы отца")
  let $ch := db:open('stasova', 'data')//table[@type="data" and @class="http://iro37.ru/schema/children" ]/row
  let $result :=
    for $k in $a
    return
      <tbody>
        <tr style="border-bottom: 1px solid black;">
          <th colspan="2">{$k}</th>
        </tr>
      {        
          for $i in $ch
          group by $b := $i/cell[@id=$k][text()]/text()
          where $b
          return
            <tr> 
              <td>{$b}</td> <td><a href="api/reports/report4?group={$k}&amp;value={$b}">{count($i)}</a> {if ($k="Форма обучения" and $b="домашняя") then ( " (" || string-join(  $i/cell[@id=("Фамилия", "Имя")], " " ) || ")") else ()}</td>
            </tr>
     }
     </tbody>   
 return
   <table class="table table-striped">
     <tr>
       <th><b>Показатель</b></th>
       <th><b>Значение</b></th>
     </tr>
     {$result}
   </table>
};

declare 
  %rest:path("/stasova/api/reports/report4")
  %rest:method('GET')
  %rest:query-param("group", "{$group}", "group")
  %rest:query-param("value", "{$value}", "value")
function report:report4( $group, $value )
{
  <table>
    {db:open('stasova', 'data')//table[@type="data" and @class="http://iro37.ru/schema/children" ]/row[cell[@id=$group]/text()=$value]}
  </table>
};

declare 
  %rest:path("/stasova/api/reports/report5")
  %rest:method('GET')
  %output:method('html')
function report:report5( )
{
  let $data := db:open('stasova', 'data')//table[@type="data" and @class="http://iro37.ru/schema/teacher" ]/row
let $fields := ("Фамилия", "Имя", "Отчество", "Должность", "Стаж педагогический")
let $result := 
  for $r in $data
  return 
    <tr>
      {
        for $c in $r/cell[@id/data() = $fields]
        return 
          <td>{$c/text()}</td>
      }
    </tr>
    
    return 
      <table class="table table-striped">
        <tr>
          {for $c in $fields
          return <th>{$c}</th>}
        </tr>
        {$result}
      </table>
};