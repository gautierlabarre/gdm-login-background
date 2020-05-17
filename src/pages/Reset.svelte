<script>
    const sudo = require('sudo-prompt');
    const fs = require("fs");
    const {app} = require('electron').remote;
    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';
    const home = app.getPath('home');
    import ConfirmRestart from '../components/ConfirmRestart.svelte';

    let confirmRestart = false;
    function reset() {
        const options = {name: 'Gdm login background'};

        sudo.exec(home + appFolder + 'script.sh  --restore', options, (error, stdout) => {
            if (error) throw error;
            emptyBackgroundFile();
            confirmRestart = true;
        });

    }

    function emptyBackgroundFile() {
        fs.writeFile(home + appFolder + 'selectedBackground', 'reset', (err) => {
            if (err) throw err;
        });
    }
</script>

<ConfirmRestart confirmRestart={confirmRestart}/>

<div class="jumbotron">
    <h1 class="display-4">Reset default login background</h1>
    <p class="lead">
        Not satisfied by your backgrounds ? Issue with this software ? Reset to default background with the button below.
    </p>
    <hr class="my-4">
    <p>It will set the background supplied with your gnome version.</p>
    <p class="lead text-center mt-10">
        <button class="btn btn-primary btn-lg" href="#" role="button" on:click={reset}>Reset</button>
    </p>
</div>

<style>
    .jumbotron {
        margin-top: 10px;
        margin-right: 10px;
    }

    .display-4 {
        font-size: 2.5rem;
    }
</style>