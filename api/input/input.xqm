module namespace input = "http://www.iro37.ru/stasova/api/input";

import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../../permissions/auth.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse" at "../../TRCI-parse.xqm";
import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";
import module namespace conf = "http://www.iro37.ru/trac/api/conf" at "../conf.xqm";

declare
  %updating
  %rest:path("/trac/api/input/owner")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function input:owner (  $file, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner" )
  then (
      let $rawData := parse:from-xlsx( xs:base64Binary( $file ( map:keys( $file ) [ 1 ] ) ) )
      
      let $model := $data:model ( $domain, $rawData/@aboutType ) 
      
      let $newData := parse:data ( $rawData, $model, $conf:url ( $domain, "processing/parse" ) || "/" )
             
      let $oldData := $data:ownerData ( $domain )[ @type= $rawData/@type and @aboutType= $rawData/@aboutType ]
      
      return
        if ( $oldData )
        then (
          replace node $oldData with $newData
        )
        else (
          insert node $newData into  $data:domainData ( $domain )/owner
        ),  
      db:output( web:redirect( $callback , map { "message" : "Файл загружен" } ) ) 
  )
  else (
    db:output( web:redirect( $callback, map{"message":"Ошибка авторизации"} ) )
  )
};