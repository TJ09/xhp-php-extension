--TEST--
XHP attributes Inheritance
--FILE--
<?php
class :foo {
  attribute
    string foo;
}
class :bar extends :foo {
  attribute
    string bar;

  public static function printAttributes() {
	$attribute_names = array_keys(self::__xhpAttributeDeclaration());
    echo implode("\n", $attribute_names);
  }
}

:bar::printAttributes();
--EXPECT--
bar
foo
