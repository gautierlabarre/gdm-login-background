<script>
    const fs = require("fs");
    const {exec} = require('child_process');
    const sudo = require('sudo-prompt');
    const {app} = require('electron').remote;
    const home = app.getPath('home');

    import {onMount} from 'svelte';
    import Dragdrop from '../components/DragDrop.svelte';
    import ConfirmRestart from '../components/ConfirmRestart.svelte';
    import BackgroundCard from '../components/BackgroundCard.svelte';
    import CheckDependencies from '../components/CheckDependencies.svelte';
    import {Alert} from 'sveltestrap';

    let visibleAlert = false;
    let confirmRestart = false;
    let backgroundList = [];
    const script = __dirname + '/change-gdm-background.sh';
    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';

    onMount(async () => {
        checkFolderExist();
        checkScriptExist();
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
        const scriptLocation = home + appFolder + 'script.sh';
        const givePermissions = 'chmod +x ' + scriptLocation;
        const options = {name: 'GDM Login background'};

        sudo.exec(givePermissions + ' && ' + scriptLocation + ' ' + imagePath, options, (error, stdout) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);
            if (stdout.trim() === 'GDM background successfully changed.') {
                createSelectedBackgroundFile(image.trim());
                getBackgroundList();
                confirmRestart = true;
                console.log('confirmRestart :>> ', confirmRestart);
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
</script>

<ConfirmRestart confirmRestart={confirmRestart}/>

<div class="container-fluid">
    <Dragdrop on:refresh={getBackgroundList}/>

    <div id="listItems">
        <CheckDependencies/>

        <Alert color="danger" isOpen={visibleAlert} toggle={() => (visibleAlert = false)}>
            There was an error. The background has not been changed.
        </Alert>

        <div class="row">
            {#if backgroundList.length === 0 }
                <p class="w100 m-20 text-center">You have no background image yet.</p>
            {/if}
            {#each backgroundList as image}
                <div class="col-md-4 col-sm-12">
                    <BackgroundCard
                            {home} {appFolder} {image}
                            on:delete={getBackgroundList}
                            on:selected={executeBackgroundChange}/>
                </div>
            {/each}
        </div>
    </div>
</div>

<style>
    .w100 {
        width: 100%;
    }

    #listItems {
        padding: 10px;
        height: 600px;
        overflow-x: hidden;
        overflow-y: auto;
    }
</style>