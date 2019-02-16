--TEST--
PHP5.5 List in Foreach 01
--SKIPIF--
<?php 
if (version_compare(PHP_VERSION, '5.5', '<')) exit("Skip This test is for PHP 5.5 only.");
?>
--FILE--
<?php //xhp

$data = [
  ['p', 'a'],
  ['s', 's'],
];
foreach($data as list($v1, $v2)) {
  echo $v1.$v2;
}
--EXPECT--
pass
