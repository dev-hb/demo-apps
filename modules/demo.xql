module namespace demo="http://exist-db.org/apps/demo";

import module namespace t="http://exist-db.org/apps/demo/shakespeare/tests" at "xmldb:exist:///db/demo/examples/tests/shakespeare-tests.xql";
import module namespace test="http://exist-db.org/xquery/xqsuite" at "xmldb:exist:///db/xqsuite.xql";

(:~
 : Simple templating function. A templating function needs to take two parameters at least.
 : It may return any sequence, which will be inserted into the output instead of $node.
 :
 : @param $node the HTML node which contained the class attribute which triggered this call.
 : @param $model an arbitrary sequence of items. Use this to pass required information between
 : tempate functions.
 :)
declare function demo:hello($node as node()*, $model as map(*)) as element(span) {
    <span>Hello World!</span>
};

(:~
 : A templating function taking two additional parameters. The templating framework inspects
 : the function signature and tries to fill in additional parameters automatically. The value
 : to use is determined as follows:
 :
 : <ol>
 :    <li>if there's a (non-empty) request parameter with the same name as the variable, use it</li>
 :    <li>check for a parameter with the same name in the parameters list given in the call to 
 :    the templating function.</li>
 :    <li>test if there's an annotation %templating:default(name, value) whose first parameter matches
 :    the name of the parameter variable. Use the second parameter as value if it does.</li>
 : </ol>
 :)
declare function demo:multiply($node as node()*, $model as map(*), $n1 as xs:int, $n2 as xs:int) {
    $n1 * $n2
};

declare function demo:error-handler-test($node as node(), $model as map(*), $number as xs:string?) {
    if (exists($number)) then
        xs:int($number)
    else
        ()
};

declare function demo:link-to-home($node as node(), $model as map(*)) {
    <a href="{request:get-context-path()}/">{ 
        $node/@* except $node/@href,
        $node/node() 
    }</a>
};

declare function demo:run-tests($node as node(), $model as map(*)) {
    let $results := test:suite(util:list-functions("http://exist-db.org/apps/demo/shakespeare/tests"))
    return
        test:to-html($results)
};

declare function demo:display-source($node as node(), $model as map(*), $lang as xs:string?, $type as xs:string?) {
    let $source := replace($node/string(), "^\s*(.*)\s*$", "$1")
    let $context := request:get-context-path()
    let $eXidePath := if (doc-available("/db/eXide/index.html")) then "apps/eXide" else "eXide"
    return
        <div xmlns="http://www.w3.org/1999/xhtml" class="source">
            <div class="code" data-language="{if ($lang) then $lang else 'xquery'}">{ $source }</div>
            <div class="toolbar">
                <a class="btn run" href="#" data-type="{if ($type) then $type else 'xml'}">Run</a>
                <a class="btn" href="{$context}/{$eXidePath}/index.html?snip={encode-for-uri($source)}" target="eXide"
                    title="Opens the code in eXide in new tab or existing tab if it is already open.">Edit</a>
                <div class="output"></div>
            </div>
        </div>
};