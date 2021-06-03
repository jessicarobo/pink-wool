<?php
	include("/var/opt/minecraft/www/header.php");
?>
	<title>Pink Wool control panel - backup</title>
</head>
<body>
	<h1>Backup</h1>
	<?php
		exec("sudo /usr/sbin/pink-wool backup",$out,$err);
		if ($err >= 2) {
			echo "<h2>Zip error (exit status $err)</h2>";
		}
		else {
			echo '<h2>Backup complete!</h2><p><a href="index.php">Back to panel</a><p>';
		}
		include("/var/opt/minecraft/www/footer.php"); 
?>
