module namespace apiget = "http://www.iro37.ru/stasova/api/output";

declare
  %rest:path("/{$root}/ontology/{$class}")
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