<?php 
	include("/var/opt/minecraft/www/header.php");
?>
	<title>Pink Wool Admin Panel</title>
</head>
<body><div id="helpr">
	<h1>Pink Wool Admin Panel</h1>
		<?php
			exec("sudo /usr/bin/pink-wool status",$out,$err);
			echo '<h2>Backend status:</h2><ol id="status">';
			foreach ($out as $o) {
				echo "<li>$o</li>";
			}
		?>
		</ol> <hr>
		<h2>Console</h2>
		<div id='consoleout'>
			<em>Loading Minecraft console...</em>
		</div>
		<form id="sendCommand" method="post" action="pwexec.php">
			<input id='pwexec' name='pwexec' size=120>
			<input type="submit" value="Send">
		</form>
		<hr>
		<div class='gridwrap'><div class='grid1'>
		<h2>Backups</h2>
		<?php
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
		<p><a href="backup.php">Run a backup</a></p></div><div class="grid1">
		<h2>Controls (Warning: slow!)</h2>
		<p><a href="service.php?do=start">Start Minecraft</a></p>
		<p><a href="service.php?do=stop">Stop Minecraft</a></p>
		<p><a href="service.php?do=restart">Restart Minecraft (stop then start)</a></p>
		<br></div></div></div>
<script src="/pink-wool.js"></script>
<?php include("/var/opt/minecraft/www/footer.php");
?>
