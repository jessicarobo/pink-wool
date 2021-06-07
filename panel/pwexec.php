<?php
	if(isset($_POST['pwexec'])) {
		$inp = escapeshellarg($_POST['pwexec']);
		exec("sudo /usr/bin/pink-wool do $inp");
	} else {
	echo 'hii';
	}
?>
