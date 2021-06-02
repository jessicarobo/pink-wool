<?php include("/var/opt/minecraft/www/header.php"); ?>
	<title>Pink Wool - Performing action</title>
</head>
<body>
	<h1><?php htmlentities($_GET["do"]);
	echo("</h1><hr>");
		$action = htmlentities($_GET["do"]);
		if (!in_array($action, ['start','restart','stop'], true )) {
			exit(2);
		}
		exec("sudo /usr/sbin/service minecraft $action",$out,$err);
		if ($err == 0) {
			echo "<h2>$action command sent successfully...</h2>";
			echo "<p>This means the server is now attempting to $action Java and Minecraft. It could take a long time, depending on your system's speed. Check the admin panel to see the server's status.</p>";
			echo '<p><a href="index.php">Back to panel</a><p>';
		} 
		else {
			echo "<h2>Error</h2><p>Exit code: $err</p>";
		}
	include("/var/opt/minecraft/www/footer.php"); 
?>
