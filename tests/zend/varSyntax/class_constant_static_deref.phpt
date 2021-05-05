--TEST--
[Zend] Class constants can be used as a class name
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

class Test {
    const NAME = 'Test2';
}

class Test2 {
    const FOO = 42;
    public static $foo = 42;

    public static function foo() {
        return 42;
    }
}

var_dump(Test::NAME::FOO);
var_dump(Test::NAME::$foo);
var_dump(Test::NAME::foo());

?>
--EXPECT--
int(42)
int(42)
int(42)
