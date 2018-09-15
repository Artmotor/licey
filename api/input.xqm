module namespace output = "http://www.iro37.ru/stasova/api/input";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/TRCI-parse" at "../TRCI-parse.xqm";


declare
  %updating
  %rest:path("/trac/api/input/admin/users")
  %rest:method("post")
  %rest:form-param("file", "{$file}")
  %rest:form-param("callback", "{$callback}")
  %rest:form-param("domain", "{$domain}")
  %rest:form-param("token", "{$token}")
function output:users (  $file, $callback, $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner")
  then (
    let $users-data := parse:from-xlsx( xs:base64Binary($file(map:keys($file)[1] )) )
    let $users := 
      for $i in  $users-data//row
      return  
        auth:build-user-record ( $i/cell[@label="id"]/text(), $i/cell[@label="label"]/text(), $i/cell[@label="password"]/text(), "user" ) 
     let $users-info := 
       element {'table'} {
         $users-data/attribute::*,
       for $r in $users-data/row
       return
         element {"row"}{
           for $c in $r/cell[@label !=  "password"]
           return
             element {"cell"} {
               attribute {'id'} {$c/@label},
               $c/text()
             }
         } 
       }
    return
      replace node $conf:db//domain[@id=$domain]/users with <users>{$users, $users-info}</users>,  
      db:output( web:redirect($conf:rootUrl || $callback, map{"section":"resource", "group":"users", "message":"Данные загружены"})) 
  )
  else (
    db:output(web:redirect($callback, map{"message":"Ошибка авторизации"}))
    
  )
};