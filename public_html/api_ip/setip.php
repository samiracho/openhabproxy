<?php
  $fh = fopen("../../data/ip", 'w') or die("can't open file");
  fwrite($fh, $_SERVER['REMOTE_ADDR']);
  fclose($fh);
?>
