module namespace public = "http://www.iro37.ru/trac/api/Data/public";

import module namespace data = "http://www.iro37.ru/trac/api/lib/get-data" at "../data.xqm";
import module namespace conf = "http://www.iro37.ru/trac/api/conf" at "../conf.xqm";

declare
  %rest:path("/trac/api/Data/public/{$domain}/{$type}")
  %rest:method('GET')
  %rest:query-param("q", "{$q}", "id:.*")
  %rest:query-param("method", "{$method}", "trci")
function public:open-data ( $domain, $type, $q, $method )
{
    let $query := public:parseQuery ( $domain, $q )        
    let $model := $data:model ( $domain, $type )
    let $data := $data:domainData ( $domain )/child::*[ name() = ( "owner", "user" ) ]/table[ @type != "Model" ]/row [ @type= $type ]
    let $openCellID := $model/row[ cell[ @id = ("access", "open") ]/text() = ("public", "true" ) ]/cell[ @id = "id" ]/text()
    let $result :=
      element { "table" } {        
        for $expr in $query?expr
        return 
            for $r in $data [ cell [ @id = $openCellID ] ] [matches ( cell[ @id = $query?prop], $expr ) ]
            return
              element { "row" } {
              $r/@id,
              attribute { "type" } { $type },
              for $c in $r/cell [ @id = $openCellID ]
              return 
                $c
            }
      }
      return 
      if ( $method = "xlsx" )
      then (
        public:trciCompact ( $data )
      )
      else ( $result )    
};

declare 
  %private 
function public:trciCompact ( $data ) {
    element { "table" } {
      for $r in $data
      return 
        element { "row" } {
          for $c in $r/cell
          return 
            attribute { $c/@id/data() } { 
              if ($c/table) then ( normalize-space ($c/data() ) ) else ( web:decode-url( $c/text() )  ) }
        }
    }    
};

declare 
  %private 
function public:parseQuery ( $domain, $q ) {
        let $parse-query := 
      try {
          fetch:xml ( 
            web:create-url( $conf:url( $domain, "processing/parse") || "/data-query", 
                            map { "q" : $q }) 
             )
          }
      catch * {}
    
    let $result := 
          map {
            "prop" : $parse-query/table/row/@id/data(),
            "expr" : 
              for $e in $parse-query/table/row/cell/text()
              return $e
        }
   return $result 
};