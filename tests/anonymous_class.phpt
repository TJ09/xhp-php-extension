--TEST--
Anonymous Classes
--FILE--
<?php
class :x {}

new class() extends :x {};

echo 'pass';
--EXPECT--
pass
