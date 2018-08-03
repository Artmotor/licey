declare namespace model = "http://www.iro37.ru/stasova/model";

import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at 'module-xlsx.xqm';

declare 
  %public
function model:parse-raw-data($file as xs:base64Binary, $order as xs:string)
{
  let $meta := xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet2.xml')
  let $fields := 
      if ($order='col')
      then ( xlsx:binary-col-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
      else ( xlsx:binary-row-to-TRCI ($file, 'xl/worksheets/sheet1.xml') )
  return
      <table>
        {$meta}
        {$fields}
      </table>
      
};

let $file := file:read-binary("C:\Users\Пользователь\Documents\DATA-vospitatel 2.0.xlsx")

let $sheet_data := parse-xml(
            archive:extract-text($file, 'xl/worksheets/sheet2.xml'))
 let $strings := parse-xml(
              archive:extract-text($file, 'xl/sharedStrings.xml'))              
 let $data := xlsx:index-to-text($sheet_data, $strings)
              
 return
   xlsx:binary-col-to-TRCI($file, 'xl/worksheets/sheet2.xml')