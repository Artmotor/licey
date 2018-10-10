module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" ;

declare variable $data:dbName := "trac-dev";

declare variable $data:domainData := 
    function ( $domain as xs:string ) as element( data ) {
      db:open( $data:dbName )/domains/domain[ @id = $domain ]/data
    };

declare variable $data:models := 
    function ( $domain as xs:string ) as element( table )* {
      $data:domainData( $domain )/owner/table[ @type = "Model" ]
    };

declare variable $data:model := 
    function (
      $domain as xs:string, 
      $modelID as xs:string
    ) as element( table ) {
      $data:models( $domain )[ @id = $modelID ]
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