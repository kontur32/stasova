module namespace apiget = "http://www.iro37.ru/stasova/api/output";

declare
  %rest:path("/{$root}/ресурс")
  %rest:method('GET') 
function apiget:recource-list ( $root )
{
  <ресурсы>
    {
      for $res in db:open($root, 'root')/root/table[@type = "Data"]
      return <ресурс>{$res/@aboutType/data()}</ресурс>
    }
  </ресурсы>
};

declare
  %rest:path("/{$root}/ресурс/{$type}")
  %rest:method('GET')
function apiget:recource ( $root, $type )
{
  <table>
    {
      db:open($root, 'root')/root/table[@type = "Data" and @aboutType =  $type ]/row
    }
  </table>
};

declare
  %rest:path("/{$root}/словарь")
  %rest:GET
function apiget:dictionary-list ($root)
{
  <словари>
    {
      for $dic in db:open($root, 'root')/root/table[@type="Data"]/@aboutType/data()
      return 
        <словарь>{$dic}</словарь>
    }
  </словари>
};

declare
  %rest:path("/{$root}/словарь/{$type}")
  %rest:method('GET')
function apiget:dictionary ($root, $type)
{
   let $rows := db:open($root, 'root')/root/table[@type="Data"]/row[@type="http://interdomivanovo.ru/schema/" || $type ]

return 
  element {QName('', 'table')}
    { 
     for $i in $rows 
     return 
       element {QName('', $type)}
         {
           $i/@id,
           $i/cell[@label='label']/text()
         }
    }
};

declare
  %rest:path("/{$root}/онтология/{$class}")
  %output:method('xhtml')
  
function apiget:ontology ($root, $class)
{
  let $ontology := db:open( $root, 'root')/root/table[@type="Classes"]
  let $subclasses := $ontology/row[cell[@label="subClassOf"]/text()= $class  ]/cell[@label="id"]/text()
  let $label := function ($class) 
    { 
      let $label := $ontology/row[cell[@label='id']/text()=$class]/cell[@label='label']/text()
      return
        if($label)then($label)else($class)
    }
    
    return
    <html>
      <div>
        <h2>{$label($class)}</h2>
        <div>
          <p>Влкючает подклассы:</p>
          <div>{
            for $i in $subclasses
            return 
              apiget:subclasses($root, $i)}
          </div>
        </div>
        <p>Является подклассом: </p>
        <ul>{
          for $i in  $ontology/row[cell[@label='id']/text()=$class]/cell[@label='subClassOf']/text()
          return 
            <li><a href="{$i}">{$label($i)}</a></li>
        }</ul>    
      </div>
    </html> 
};

declare %private function apiget:subclasses ( $root, $class )
{
  let $ontology := db:open( $root, 'root')/root/table[@type="Classes"]
  let $subclasses := $ontology/row[cell[@label="subClassOf"]/text()= $class  ]/cell[@label="id"]/text()
  let $label := function ($class) 
    { 
      $ontology/row[cell[@label='id']/text()=$class]/cell[@label='label']/text()
    }
    
  return 
   if ($subclasses)
   then (
    <li>{
         <a href="{$class}">{$label($class) || ":"}</a>,
         for $a in $subclasses
         return 
         <ul>{apiget:subclasses($root, $a)}</ul>
     }</li>
     )
   else ( <li><a href="{ $class}">{$label($class)}</a></li> ) 
};

declare
  %rest:path("/{$root}/пользователи")
  %rest:method('GET')
 
function apiget:users-list ($root )
{
  user:list()
};