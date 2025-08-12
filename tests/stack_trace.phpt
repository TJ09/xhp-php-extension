--TEST--
Stack trace should give correct source
--FILE--
<?php // xhp

function exception_error_handler($errno, $errstr, $errfile, $errline )
{
  $trace = debug_backtrace();
  $caller = $trace[1];

  echo $errfile.':'.$errline,PHP_EOL;
  echo $caller['file'].':'.$caller['line'].' '.$caller['function'].PHP_EOL;

  echo 'Fatal error';
  die();
}
set_error_handler("exception_error_handler", E_WARNING);

spl_autoload_register();

echo
  <p>
    Follow these <a href="http://www.examples.com">link</a>.
  </p>;

--EXPECTF--
%s/xhp_b.php:3
%s/xhp_a.php:7 spl_autoload
Fatal error
