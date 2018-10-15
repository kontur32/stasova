module namespace parse = "http://www.iro37.ru/trac/api/processing/parse" ;

declare 
  %public
  %rest:path("/trac/api/processing/parse/comma-separated/colon-separated/{$type}/{$subject}")
  %rest:method('GET')
  %rest:query-param("q", "{$queryString}" )
function parse:comma-colon-separated ( $type, $subject,  $queryString as xs:string ) as element ( table ) {
  if ( normalize-space ( $queryString ) )
  then ( 
  let $var := tokenize ( $queryString, ", "  )
  
  let $result := 
    for $e in $var
    let $id := substring-before ( $e, ":" )
    let $expr := substring-after ( $e, ":" )
    return 
    element { "row" } {
      attribute { "id"} { $id },
         element {"cell"} {
          attribute {"id"} {"id"},
          $id
        },
        element {"cell"} {
          attribute {"id"} {"expr"},
          $expr
        }
    }
  return 
    element { "table" } { 
       attribute { "id"} { $subject },
       attribute { "type"} { $type },
      $result
    }
  )
  else ()
};

declare 
  %public
  %rest:path("/trac/api/processing/parse/comma-separated/{$type}")
  %rest:method('GET')
  %rest:query-param("q", "{$queryString}" )
function parse:comma-separated ( $type,  $queryString as xs:string ) as element ( table ) {
  if ( normalize-space ( $queryString ) )
  then ( 
  let $var := tokenize ( $queryString, ", "  )
  
  let $result := 
    for $e in $var
    return 
    element { "row" } {
      attribute { "id"} { $e },
      attribute { "type"} { $type },
         element {"cell"} {
            attribute {"id"} {"expr"},
            $e
         }
   }
    
  return 
    element { "table" } { 
       attribute { "id"} { "variative"  },
       attribute { "type"} { $type  },
      $result
    }
  )
  else ()
};