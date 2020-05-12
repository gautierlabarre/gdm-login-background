<script>
	const fs = require("fs");
	const {app} = require('electron').remote;
	const home = app.getPath('home');

	export let name;
	import { onMount } from 'svelte';

	let backgroundFiles = [];

	onMount(async () => {
		fs.readdir(home + /background/, function(err, items) {
			backgroundFiles = items;

			backgroundFiles.forEach(image => {
				console.log(image.replace(/(\s+)/g, '\\$1') )
			});
		});
	});

	async function update(image) {
		console.log(image);
	}
</script>

<main>
	<h1>Hello {name}!</h1>
		{#each backgroundFiles as image}
			<li><img src="{home}/background/{image}" on:click={update(image)} width="200" alt="test"></li>
		{/each}


<!--	<button on:click={update}>update</button>-->

</main>


<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	h1 {
		color: #ff3e00;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>