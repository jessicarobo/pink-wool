const formElement = document.getElementById('sendCommand'); 
async function getConsole() {
	var response = await fetch('console.php');
	if (response.ok) {
		let pageOut = await response.text();
		document.getElementById('consoleout').innerText = pageOut;
	} else {
		console.log(response.status);
	}
}
formElement.addEventListener('submit', e => {
	e.preventDefault();  // <-- important! this keeps the page from refreshing when the form is submitted
	let formDat = new FormData(formElement);
	const execOut = fetch('pwexec.php', {
		method: 'POST',
		body: formDat
	});
	formElement.elements["pwexec"].value = null;
});
getConsole();
var maj3 = window.setInterval(getConsole, 3000);
