--TEST--
[Zend] catch without capturing a variable
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

try {
    throw new Exception();
} catch (Exception) {
    echo "Exception\n";
}

try {
    throw new Exception();
} catch (Exception) {
    echo "Exception\n";
} catch (Error) {
    echo "FAIL\n";
}

try {
    throw new Exception();
} catch (Exception|Error) {
    echo "Exception\n";
} catch (Throwable) {
    echo "FAIL\n";
}

?>
--EXPECT--
Exception
Exception
Exception
