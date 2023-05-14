<?php // xhp
// Extremely simple implementation of XHP client library useful primarily for
// unit tests.
class :x {

  protected $attrs;
  protected $children;
  protected $tagName;

  public function __construct($attrs, $children) {
    $this->attrs = $attrs;
    $this->children = $children;
    $this->tagName = static::class2element(get_class($this));
  }

  final public function __toString() {
    try {
      return $this->toString();
    } catch (\Exception $error) {
      trigger_error($error->getMessage(), E_USER_ERROR);
    }
  }

  public function toString() {
    $head = '<'.$this->tagName;
    foreach ($this->attrs as $key => $val) {
      $head .= ' '.htmlspecialchars($key, ENT_COMPAT).'="'.htmlspecialchars($val, ENT_QUOTES).'"';
    }
    return $head.'>'.implode('',
        array_map(function($child) { return is_string($child) ? htmlspecialchars($child, ENT_COMPAT) : $child; }, $this->children)
    ) . '</' . $this->tagName . '>';
  }

  public static function class2element($class) {
    return str_replace(array('__', '_'), array(':', '-'), preg_replace('#^xhp_#i', '', $class));
  }
}
