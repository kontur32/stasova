module namespace parse = "http://www.iro37.ru/trac/api/processing/parse" ;

declare 
  %public
  %rest:path("/trac/api/processing/parse/data-query")
  %rest:method('GET')
  %rest:query-param("q", "{$queryString}", "id:.*")
function parse:data-query ( $queryString as xs:string ) as element ( table ) {
  let $prop := substring-before ( $queryString, ":" )
  let $expr := tokenize ( substring-after ($queryString, ":" ), " " )
  let $result := 
    element { "row" } {
      attribute { "id"} { if (  $prop  ) then ( $prop ) else ( "id" ) },
      if ( not (empty ($expr ) ) )
      then (
        for $e in $expr 
        return 
          element { "cell" } {
            attribute { "id" } { "expr"}, 
            $e
          }
      )
      else (
        element { "cell" } {
          attribute { "id" } { "expr"},
          ".*"
        }
      )
    }
  return 
    <table> { $result } </table>
};

declare 
  %public
  %rest:path( "/trac/api/processing/parse/sha-256" )
  %rest:method('GET')
  %rest:query-param("q", "{$queryString}", "")
  %output:method ( "text" )
function parse:hash ( $queryString as xs:string ) as xs:string {
 if ( $queryString )
 then ( string( hash:hash( $queryString, 'sha-256' ) ) )
 else ( "" )
};