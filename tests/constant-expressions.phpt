--TEST--
Constant Values from Expressions
--FILE--
<?php // xhp

const GLOBAL_CONST = 'global'.' const';

class Foo {
  const REFERNECED_CONST = \GLOBAL_CONST;
  const CONCATENATED_CONST = 'pa'.'ss';
}

echo Foo::REFERNECED_CONST."\n";
echo Foo::CONCATENATED_CONST;
--EXPECT--
global const
pass
