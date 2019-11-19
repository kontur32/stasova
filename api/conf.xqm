module namespace conf = "http://www.iro37.ru/trac/api/conf" ;

declare variable $conf:url := 
  function ( $group as xs:string , $funct as xs:string  ) as xs:string  {
    let $urls := 
      <table>
        <row id="default">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="ood">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="po">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="lipers">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="euf">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="kin18">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="kin18-dev">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
         <row id="saivpds">
          <cell id="processing">http://localhost:8984/trac/api/processing</cell>
          <cell id="processing/parse">http://localhost:8984/trac/api/processing/parse</cell>
        </row>
        <row id="auth">
          <cell id="user/scope">http://localhost:8984/trac/api/auth/user/scope</cell>
          <cell id="user/userID">http://localhost:8984/trac/api/auth/user/userID</cell>
        </row>
      </table>
<<<<<<< HEAD
    return "http://localhost:8984/trac/api/" || $funct
      (:$urls/row[ @id = $group ]/cell [ @id = $funct ]/text():)
=======
    let $row := 
      if (  $urls/row[ @id = $group ] )
      then ( $group )
      else ( "default" )
    return
      $urls/row[ @id = $row ]/cell [ @id = $funct ]/text()
>>>>>>> dev2
};