--TEST--
Class Constants with Visibility
--FILE--
<?php // xhp

class Foo {
  public const PUBLIC_CONST = 'pass';
}

echo Foo::PUBLIC_CONST;

--EXPECT--
pass
