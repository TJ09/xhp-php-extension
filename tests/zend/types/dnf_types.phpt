--TEST--
[Zend] Disjunctive Normal Form types in reflection
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.2', '<')) exit("Skip This test is for PHP 8.2+ only.");
?>
--FILE--
<?php // xhp

function dumpType(ReflectionType $rt, int $indent = 0) {
    $str_indent = str_repeat(' ', 2 * $indent);
    echo $str_indent . "Type $rt is " . $rt::class . ":\n";
    foreach ($rt->getTypes() as $type) {
        if ($type instanceof ReflectionNamedType) {
            echo $str_indent . "  Name: " . $type->getName() . "\n";
            echo $str_indent . "  String: " . (string) $type . "\n";
            echo $str_indent . "  Allows Null: " . json_encode($type->allowsNull()) . "\n";
        } else {
            dumpType($type, $indent+1);
        }
    }
}

function test1(): (X&Y)|(Z&Traversable)|Countable { }

class Test {
    public (X&Y)|Countable $prop;
}

dumpType((new ReflectionFunction('test1'))->getReturnType());

$rc = new ReflectionClass(Test::class);
$rp = $rc->getProperty('prop');
dumpType($rp->getType());

/* Force CE resolution of the property type */

interface y {}
class x implements Y, Countable {
    public function count(): int { return 0; }
}
$test = new Test;
$test->prop = new x;

$rp = $rc->getProperty('prop');
dumpType($rp->getType());

?>
--EXPECT--
Type (X&Y)|(Z&Traversable)|Countable is ReflectionUnionType:
  Type X&Y is ReflectionIntersectionType:
    Name: X
    String: X
    Allows Null: false
    Name: Y
    String: Y
    Allows Null: false
  Type Z&Traversable is ReflectionIntersectionType:
    Name: Z
    String: Z
    Allows Null: false
    Name: Traversable
    String: Traversable
    Allows Null: false
  Name: Countable
  String: Countable
  Allows Null: false
Type (X&Y)|Countable is ReflectionUnionType:
  Type X&Y is ReflectionIntersectionType:
    Name: X
    String: X
    Allows Null: false
    Name: Y
    String: Y
    Allows Null: false
  Name: Countable
  String: Countable
  Allows Null: false
Type (X&Y)|Countable is ReflectionUnionType:
  Type X&Y is ReflectionIntersectionType:
    Name: X
    String: X
    Allows Null: false
    Name: Y
    String: Y
    Allows Null: false
  Name: Countable
  String: Countable
  Allows Null: false
