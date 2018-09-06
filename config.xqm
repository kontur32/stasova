 module namespace conf = 'http://iro37.ru/xq/modules/config';


declare variable $conf:db := db:open('stasova2');

declare variable $conf:domain-path := 'domains';

declare variable $conf:session-duration := xs:dayTimeDuration('PT600S');
declare variable $conf:base := 'trac';
declare variable $conf:rootUrl := "http://localhost:8984" ;