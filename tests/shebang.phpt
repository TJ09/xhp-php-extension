--TEST--
Shebang (#!) with strict_types
--FILE--
#!/usr/bin/env php
<?php
declare(strict_types=1);
echo "pass";
--EXPECT--
pass
