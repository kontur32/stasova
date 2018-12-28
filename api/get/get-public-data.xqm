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
    let $openCellID := $model/row[ cell[ @id = ("access", "open") ]/text() = ("public", "true" ) ]/cell[ @id = "id" ]/text()
    let $fields := if ( not ( $f ) ) then ( $openCellID ) else ( tokenize ($f, ",") )
    
    let $data := $data:domainData ( $domain )/child::*[ name() = ( "owner", "user" ) ]/table[ @type != "Model" ]/row [ @type= $type ]
    
    let $result :=
      element { "table" } {        
        for $expr in $query?expr
        return 
            for $row in $data 
            where matches ( $row/ cell [ @id = $query?prop ]/text(),  $expr ) 
            return
              element { "row" } {
                $row/@id,
                attribute { "type" } { $type },
                for $c in $row/cell [ @id/data() =  $openCellID and @id/data()= $fields ]
                return 
                  $c
              }
      }
      return 
        switch ( $method )
        case "xlsx" 
          return public:trciCompact ( $result  )
        case "csv" 
          return 
             csv:serialize( 
                public:csvExport ( $result ), 
                map {"header": "yes", "separator" : "comma"}
              ) 
        case "trci" 
          return $result 
        default 
          return $result 
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
function public:csvExport ( $data as element( table ) ) {
  let $result :=
    <csv>{
      for $row in $data/row
      return
        <record>{
          for $attr in $row/cell
          return 
            element {$attr/@id/data()} {$attr/text()}
        }</record>
    }</csv>
      
  return
    $result
};

declare 
  %private 
function public:parseQuery ( $domain, $q ) {
        let $parse-query := 
      try {
          fetch:xml ( 
            web:create-url( $conf:url( $domain, "processing/parse" ) || "/data-query", 
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