 module namespace conf = 'http://iro37.ru/xq/modules/config';

declare variable $conf:db := db:open('trac-dev');

declare variable $conf:domain :=
       function ($domain) { 
        $conf:db/domains/domain[ @id= $domain ]
       };

declare variable $conf:models :=
       function ( $domain ) { 
         $conf:domain ( $domain )/data/owner/table [ @type = "Model" ]
       };
       
declare variable $conf:user :=
       function ( $domain, $userID ) {
         <table>{
           $conf:domain ( $domain )/data/owner/table/row[ @type = "users" and @id = $userID ]
         }</table> 
       };       

declare variable $conf:userData :=
       function ($domain, $userID) { 
        $conf:domain( $domain )/data/user[ @id = $userID ]
       };

declare variable $conf:ownerData :=
       function ($domain) { 
        $conf:db/domains/domain[ @id= $domain ]/data/owner/table
       };


declare variable $conf:domain-path := 'domains';

declare variable $conf:getUser := 
    function ( $domain, $name) {
      $conf:domain ( $domain )/data/owner/table[@type="Data" and @aboutType="users"]/row[cell[@id="id"] = $name]
    };

declare variable $conf:session-duration := xs:dayTimeDuration('PT3600S');
declare variable $conf:base := 'trac';
declare variable $conf:rootUrl := "http://localhost:8984" ;
declare variable $conf:parserUrl := "http://localhost:8984/trac/api/parser/" ;
declare variable $conf:menuUrl := 
      function ($level) {
        $conf:rootUrl || "/" || $conf:base || "/api/interface/menu/" || $level
      };
declare variable $conf:sectionUrl := 
      function ($domain, $userType) {
        $conf:rootUrl || "/" || $conf:base || "/" || $userType || "/" || $domain
      };