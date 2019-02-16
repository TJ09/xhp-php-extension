--TEST--
PHP5.5 List in Foreach 03
--SKIPIF--
<?php 
if (version_compare(PHP_VERSION, '7.1', '<')) exit("Skip This test is for PHP 7.1 only.");
?>
--FILE--
<?php //xhp

$data = [
  ['p', 'a'],
  ['s', 's'],
];
foreach($data as [$v1, $v2]) {
  echo $v1.$v2;
}
--EXPECT--
pass
