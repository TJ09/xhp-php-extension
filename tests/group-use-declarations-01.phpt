--TEST--
PHP7 Group Use Declarations 01
--FILE--
<?php //xhp

use Foo\{Bar, Baz};
use OtherFoo\{
	Qux,
	Xyzzy,
};

echo 'pass';
--EXPECT--
pass
