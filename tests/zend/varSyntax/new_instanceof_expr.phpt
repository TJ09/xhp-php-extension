--TEST--
[Zend] new with an arbitrary expression
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

$class = 'class';
var_dump(new ('std'.$class));
var_dump(new ('std'.$class)());
$obj = new stdClass;
var_dump($obj instanceof ('std'.$class));

?>
--EXPECT--
object(stdClass)#1 (0) {
}
object(stdClass)#1 (0) {
}
bool(true)
