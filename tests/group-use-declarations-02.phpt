--TEST--
PHP7 Group Use Declarations 02
--FILE--
<?php

use function Foo\{Bar, Baz};
use OtherFoo\{
	const Qux,
	function Xyzzy,
};

echo 'pass';
--EXPECT--
pass
