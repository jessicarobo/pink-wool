<?php 
	include("/var/opt/minecraft/www/header.php");
?>
	<title>Pink Wool Admin Panel</title>
</head>
<body>
  <h1>Pink Wool Admin Panel</h1>
	<?php
		exec("sudo /usr/sbin/pink-wool status",$out,$err);
		echo '<h2>Backend status:</h2><ol>';
		foreach ($out as $o) {
			echo "<li>$o</li>";
		}
		echo("</ol> <hr> <h2>Backups</h2>");
		$zipfiles = glob('/var/opt/minecraft/www/admin/backups/*.zip');
		if (isset($zipfiles)) {
			echo '<ul>';
			foreach ($zipfiles as $zip) {
				$z=basename($zip);
				echo "<li><a href='/admin/backups/$z'>$z</a></li>";
			}
		}
	?>
	</ul>
	<p><a href="backup.php">Run a backup</a></p>
	<hr>
	<h2>Controls (Warning: These are slow!)</h2>
	<p><a href="service.php?do=start">Start Minecraft</a></p>
	<p><a href="service.php?do=stop">Stop Minecraft</a></p>
	<p><a href="service.php?do=restart">Restart Minecraft (stop then start)</a></p>
		<br>
<?php include("/var/opt/minecraft/www/footer.php");
?>
