--TEST--
[Zend] Constants can be dereferenced as objects (even though they can't be objects)
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

const FOO = "foo";
class Bar { const FOO = "foo"; }

try {
    FOO->length();
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}

try {
    Bar::FOO->length();
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}

?>
--EXPECT--
Call to a member function length() on string
Call to a member function length() on string
