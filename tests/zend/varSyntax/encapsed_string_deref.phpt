--TEST--
[Zend] Dereferencing operations on an encapsed string
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

$bar = "bar";
var_dump("foo$bar"[0]);
var_dump("foo$bar"->prop);
try {
    var_dump("foo$bar"->method());
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}

class FooBar { public static $prop = 42; }
var_dump("foo$bar"::$prop);

function foobar() { return 42; }
var_dump("foo$bar"());

?>
--EXPECTF--
string(1) "f"

Warning: Attempt to read property "prop" on string in %s on line %d
NULL
Call to a member function method() on string
int(42)
int(42)
