module namespace output = "http://www.iro37.ru/stasova/api/output";

import  module namespace conf = 'http://iro37.ru/xq/modules/config' at "../config.xqm";
import module namespace auth = 'http://iro37.ru/xq/modules/auth' at '../permissions/auth.xqm';

declare
  %rest:path("/trac/api/output/users")
  %rest:method('GET')
  %rest:query-param("domain", "{$domain}")
  %rest:query-param("token", "{$token}")
function output:users ( $domain, $token )
{
  if ( auth:get-session-scope ( $domain, $token ) = "owner")
  then (
    <table>
      {
        for $i in $conf:db//domains/domain[@id=$domain]/users/user
        return
          <row>
            <cell id="id">{$i/@name/data()}</cell>
            <cell id="label">{$i/@name/data()}</cell>
          </row>
      }
    </table>
  )
  else (
    <error>Ошибка авторизации</error>
  )
  
};