<script>
    // Electron dependencies
    const fs = require("fs");
    const {exec} = require('child_process');
    const sudo = require('sudo-prompt');
    const {app} = require('electron').remote;
    const home = app.getPath('home');

    // Svelte code
    import {onMount} from 'svelte';
    import Dragdrop from './DragDrop.svelte';
    import ConfirmRestart from './ConfirmRestart.svelte';
    import BackgroundCard from './BackgroundCard.svelte';
    import CheckDependencies from './CheckDependencies.svelte';
    import {Alert} from 'sveltestrap';

    let visible = true;
    let visibleAlert = false;
    let backgroundList = [];
    let confirmRestart = false;

    const script = __dirname + '/change-gdm-background.sh';
    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';

    onMount(async () => {
        checkFolderExist();
        checkScriptExist();
        // CheckDependencies done in component CheckDependencies
        getBackgroundList();
    });

    function checkFolderExist() {
        if (!fs.existsSync(home + appFolder)) fs.mkdirSync(home + appFolder);
    }

    function checkScriptExist() {
        if (!fs.existsSync(home + appFolder + 'script.sh')) {
            fs.writeFile(home + appFolder + 'script.sh', fs.readFileSync(script), (err) => {
                if (err) throw err;
            });
        }
    }

    function getBackgroundList() {
        fs.readdir(home + appFolder, (err, items) => {
            backgroundList = items.filter(array => array.trim() !== 'selectedBackground');
            backgroundList = backgroundList.filter(array => array.trim() !== 'script.sh');
        });
    }

    function executeBackgroundChange(event) {
        visibleAlert = false;

        const image = event.detail.image;
        const imagePath = home + appFolder + image;
        const scriptLocation = home + appFolder + 'script.sh'
        const givePermissions = 'chmod +x ' + scriptLocation;
        const options = {name: 'GDM Login background'};

        sudo.exec(givePermissions + ' && ' + scriptLocation + ' ' + imagePath, options, (error, stdout) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);

            if (stdout.trim() === 'GDM background sucessfuly changed.') {
                createSelectedBackgroundFile(image.trim());
                getBackgroundList();
                confirmRestart = true;
            } else {
                visibleAlert = true;
            }
        });
    }

    function createSelectedBackgroundFile(content = '') {
        fs.writeFile(home + appFolder + 'selectedBackground', content, (err) => {
            if (err) throw err;
        });
        checkScriptExist();
    }

    function reset() {
        const options = {name: 'Gdm login background'};

        sudo.exec(home + appFolder + 'script.sh  --restore', options, (error, stdout) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);
            confirmRestart = true;
        });
    }
</script>

<main>
    <CheckDependencies />

    <Alert color="danger" isOpen={visibleAlert} toggle={() => (visibleAlert = false)}>
        There was an error. The backgroud has not been changed.
    </Alert>

    <ConfirmRestart confirmRestart={confirmRestart}/>

    <div class="container-fluid">
        <div class="row">
            <div class="col">
                <button class="btn btn-outline-danger pull-right" on:click={reset}>Reset</button>
            </div>
        </div>

        <Dragdrop on:refresh={getBackgroundList}/>

        <div class="row">
            {#each backgroundList as image}
                <div class="col-md-4 col-sm-12">
                    <BackgroundCard {home} {appFolder} {image}
                                    on:delete={getBackgroundList}
                                    on:selected={executeBackgroundChange}/>
                </div>
            {/each}
        </div>
    </div>
</main>

<style>
    .pull-right {
        float:right;
    }
</style>