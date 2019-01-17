--TEST--
Ternary without whitespace

--FILE--
<?php

define('bar', 1);

function foo(int $in): int {
	return $in?:bar;
}

echo foo(0);
echo foo(2);
echo 'pass';
--EXPECT--
12pass
