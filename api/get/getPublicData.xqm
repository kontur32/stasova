module namespace public = "http://www.iro37.ru/trac/api/Data/public";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";
import module namespace conf = "http://www.iro37.ru/trac/api/conf" at "../conf.xqm";

declare
  %rest:path("/trac/api/Data/public/{$domain}/{$type}")
  %rest:method('GET')
  %rest:query-param( "q", "{ $q }", "id:.*" )
  %rest:query-param( "f", "{ $f }" )
  %rest:query-param( "method", "{ $method }", "trci" )
function public:open-data ( $domain, $type, $q, $f, $method )
{
    let $query := public:parseQuery ( $domain, $q )        
    let $model := $data:model ( $domain, $type )
    let $fields := tokenize ( $f, "," )
    let $openCellID := $model/row[ cell[ @id = ("access", "open") ]/text() = ( "public", "true" ) ]/cell[ @id = "id" ]/text()
    let $openCellID := if ( $f ) then ( $openCellID[ . = $fields ] ) else ( $openCellID )
    let $data := $data:domainData ( $domain )/child::*[ name() = ( "owner", "user" ) ]/table[ @type != "Model" ]/row [ @type= $type ]
    
    let $result :=
      element { "table" } {        
        for $expr in $query?expr
        return 
            for $r in $data 
            where matches ( $r/ cell [ @id = $query?prop ]/text(),  $expr ) 
            return
              element { "row" } {
              $r/@id,
              attribute { "type" } { $type },
              for $c in $r/cell [ @id/data() =  $openCellID ]
              return 
                $c
                }
      }
      return 
      switch ( $method ) 
      case ( "xlsx" ) return public:trciCompact ( $result  )
      case ( "trci" ) return  $result 
      case ( "csv" ) return public:csvExport ( $result )
      default return $result 
};

declare 
  %private
function public:csvExport ( $data as element ( table ) ) {
  let $result := 
    <csv>{
      for $row in $data/row
      return
       <record>{
         for $c in $row/cell
         return 
           element { $c/@id } { $c/text() }
       }</record>  
    }</csv>
    
  return csv:serialize ( $result, map{ "header" : "yes" } )
};

declare 
  %private 
function public:trciCompact ( $data as element( table ) ) {
    element { "table" } {
      
      for $r in $data/row
      return 
        element { "row" } {
          for $c in $r/cell
          return 
            attribute { $c/@id/data() } { 
             $c }
        }
    }    
};

declare 
  %private 
function public:parseQuery ( $domain, $q ) {
        let $parse-query := 
      try {
          fetch:xml ( 
            web:create-url( $conf:url( $domain, "processing/parse") || "/data-query", 
                            map { "q" : $q }) 
             )
          }
      catch * {}
    
    let $result := 
          map {
            "prop" : $parse-query/table/row/@id/data(),
            "expr" : 
              for $e in $parse-query/table/row/cell/text()
              return $e
        }
   return $result 
};