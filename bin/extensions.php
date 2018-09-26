<?php
$a = get_loaded_extensions();
natcasesort($a);
foreach ( $a as $v ) {
	$ext = new ReflectionExtension($v);
	print $ext->getName() . " " . $ext->getVersion() . "\n";
}
