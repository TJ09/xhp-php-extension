--TEST--
Quotes in attribute
--FILE--
<?php
require 'xhp_x.php';
$quote = '"';
echo <x b={$quote}>c</x>;
--EXPECT--
<x b="&quot;">c</x>
