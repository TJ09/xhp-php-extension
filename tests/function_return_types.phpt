--TEST--
Function Return Types

--FILE--
<?php // xhp

function foo(bool $in): array {}

echo 'pass';
--EXPECT--
pass
