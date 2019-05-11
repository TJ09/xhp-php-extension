--TEST--
PHP7 Group Use Declarations 02
--FILE--
<?php //xhp

use function Foo\{Bar, Baz};
use OtherFoo\{
	const Qux,
	function Xyzzy,
};

echo 'pass';
--EXPECT--
pass
