 module namespace conf = 'http://iro37.ru/xq/modules/config';


declare variable $conf:db := db:open('stasova2');
declare variable $conf:domain-alias := 'ood';
declare variable $conf:domain-path := 'domains';
declare variable $conf:domain := db:open( 'stasova2' , $conf:domain-path )/domains/domain[@id = $conf:domain-alias];
declare variable $conf:session-duration := xs:dayTimeDuration('PT600S');
declare variable $conf:base := 'trac';