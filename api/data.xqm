module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" ;

declare variable $data:dbName := "trac-dev";

declare variable $data:rootPermissions := function ( $ACCESS_TOKEN ) {

};

declare variable $data:domains := 
    function ( ) as element( domains ) {
      db:open( $data:dbName )/domains
    };

declare variable $data:domainData := 
    function ( $domain as xs:string ) as element( data ) {
      db:open( $data:dbName )/domains/domain[ @id = $domain ]/data
    };

declare variable $data:domainSessions := 
    function ( $domain as xs:string ) as element( sessions ) {
      db:open( $data:dbName )/domains/domain[ @id = $domain ]/sessions
    };

declare variable $data:models := 
    function ( $domain as xs:string ) as element( table )* {
      $data:domainData( $domain )/owner/table[ @type = "Model" ]
    };

declare variable $data:model := 
    function ( $domain as xs:string, $modelID as xs:string) as element( table ) {
      let $result := $data:models( $domain )[ @aboutType = $modelID ]
      return 
        if ( $result ) then ( $result ) else ( <table/> )
    };
    
declare variable $data:ownerData := 
    function (
      $domain as xs:string
    ) as element( table )* {
      $data:domainData ( $domain )/owner/table[ @type != "Model" ]
    };

declare variable $data:userData := 
    function ( $domain as xs:string, $userID as xs:string ) as element(table)* {
      $data:domainData ( $domain )/user[ @id = $userID ]/table
    };