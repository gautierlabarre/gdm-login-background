<script>
    // Electron dependencies
    const fs = require("fs");
    const {exec} = require('child_process');
    const sudo = require('sudo-prompt');
    const {app} = require('electron').remote;
    const home = app.getPath('home');

    // Svelte code
    import {onMount} from 'svelte';

    import Icon from 'fa-svelte';
    import {faTrash} from '@fortawesome/free-solid-svg-icons/faTrash'
    import {faCheckCircle} from '@fortawesome/free-solid-svg-icons/faCheckCircle'
    import {faCheck} from '@fortawesome/free-solid-svg-icons/faCheck'
    import Dragdrop from './dragdrop.svelte';
    import {Button, Alert, Modal, ModalBody, ModalFooter, ModalHeader} from 'sveltestrap';

    let visible = true;
    let visibleAlert = false;
    let alertDependencies = false;
    let trashIcon = faTrash;
    let checkCircleIcon = faCheckCircle;
    let checkIcon = faCheck;
    let selectedImage = '';
    let backgroundList = [];
    let confirmRestart = false;
    const script = __dirname + '/change-gdm-background.sh';

    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';

    onMount(async () => {
        checkFolderExist();
        checkScriptExist();
        checkDependencies();
        getBackgroundList();
    });

    function checkDependencies() {
        alertDependencies = false;
        exec("dpkg -s libglib2.0-dev-bin | grep Status | cut -d ' ' -f 4", (error, stdout, stderr) => {
            if (error) {
                console.log(error.stack);
                console.log('Error code: ' + error.code);
                console.log('Signal received: ' + error.signal);
            }
            if(stdout.trim() !== "installed") {
                alertDependencies = true;
            }
        });
    }

    function installDependencies() {
        const options = { // Can't get it to work i think
            name: 'GDM Login background',
            icns: '/Applications/Electron.app/Contents/Resources/Electron.icns', // (optional)
        };

        sudo.exec('apt install libglib2.0-dev-bin', options, (error, stdout, stderr) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);
            checkDependencies()
        });
    }

    function checkFolderExist() {
        if (!fs.existsSync(home + appFolder)) {
            fs.mkdirSync(home + appFolder);
        }
    }

    function checkScriptExist() {
        if (!fs.existsSync(home + appFolder + 'script.sh')) {
            let scriptContent = fs.readFileSync(script);
            fs.writeFile(home + appFolder + 'script.sh', scriptContent, function (err) {
                if (err) throw err;
            });
        }
    }
    function checkSelected(image) {
        if (fs.existsSync(home + appFolder + 'selectedBackground')) {
            let selectedB = fs.readFileSync(home + appFolder + 'selectedBackground', 'utf-8');
            if (image.trim() === selectedB.trim()) {
                return true;
            }
        } else {
            createSelectedBackgroundFile();
        }
    }

    function createSelectedBackgroundFile(content = '') {
        fs.writeFile(home + appFolder + 'selectedBackground', content, function (err) {
            if (err) throw err;
        });
        let scriptContent = fs.readFileSync(script);
        console.log(scriptContent);
        fs.writeFile(home + appFolder + 'script.sh', scriptContent, function (err) {

        });
    }

    function getBackgroundList() {
        fs.readdir(home + appFolder, (err, items) => {
            if (items !== 'selectedBackground') {
                backgroundList = items;
            }
            backgroundList = backgroundList.filter(array => array.trim() !== 'selectedBackground');
            backgroundList = backgroundList.filter(array => array.trim() !== 'script.sh');
        });
    }

    function deleteImage(image) {
        fs.unlinkSync(home + appFolder + image);
        getBackgroundList();
    }

    function executeBackgroundChange(image) {
        visibleAlert = false;
        let imagePath = home + appFolder + image;
        let givePermissions = 'chmod +x ' + home + appFolder + 'script.sh'
        const options = { // Can't get it to work i think
            name: 'GDM Login background',
            icns: '/Applications/Electron.app/Contents/Resources/Electron.icns', // (optional)
        };

        sudo.exec(givePermissions + ' && ' + home + appFolder + 'script.sh ' + imagePath, options, (error, stdout, stderr) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);

            if(stdout.trim() === 'GDM background sucessfuly changed.') {
                createSelectedBackgroundFile(image.trim());
                getBackgroundList();
                confirmRestart = true;
            } else {
                visibleAlert = true;
            }
        });

    }

    function restartGdm() {
        const options = { // Can't get it to work i think
            name: 'Gdm login background',
        };

        sudo.exec('service gdm restart', options, (error, stdout, stderr) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);
        });
    }

    function reset() {
        const options = { // Can't get it to work i think
            name: 'Gdm login background',
        };

        sudo.exec(home + appFolder + 'script.sh  --restore', options, (error, stdout, stderr) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);
            confirmRestart = true;
        });
    }

    const toggle = () => (confirmRestart = !confirmRestart);


</script>

<main>
    <Alert class="text-center" color="danger" isOpen={alertDependencies} >
        This application might not work if you do not install "<b>libglib2.0-dev-bin</b>".
        <br><br>
        <button class="btn btn-success" on:click={installDependencies}>Install libglib2.0-dev-bin</button>
    </Alert>

    <Alert color="danger" isOpen={visibleAlert} toggle={() => (visibleAlert = false)}>
        There was an error. The backgroud has not been changed.
    </Alert>
    <div>
        <Modal isOpen={confirmRestart} {toggle}>
            <ModalHeader {toggle}>GDM background changed</ModalHeader>
            <ModalBody>
                For the change to take place, you have to restart GDM service.
                Careful, you will lose all your work and your session will be closed.
                If you click Cancel, the change will be visible after you restart your computer.
            </ModalBody>
            <ModalFooter>
                <Button color="primary" on:click={restartGdm}>
                    Restart GDM
                </Button>
                <Button color="secondary" on:click={toggle}>
                    Cancel
                </Button>
            </ModalFooter>
        </Modal>
    </div>
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
                    <div class="card" style="width: 18rem;">
                        {#if checkSelected(image)}
                            <div class="selectedImagePlaceholder"></div>
                            <Icon class="selectedImage" icon="{checkCircleIcon}"/>
                        {/if}
                        <img src="{home}{appFolder}{image}" width="100%"
                             height="200" alt="test">
                        <div class="card-body">
                            {#if !checkSelected(image)}
                                <b class="clickable text-primary pull-left" on:click={executeBackgroundChange(image)}
                                   data-toggle="tooltip" data-placement="bottom"
                                   title="Supprimer">
                                    <Icon class="clickable" icon="{checkIcon}"/>
                                </b>
                            {/if}
                            <b class="text-danger clickable pull-right" on:click={deleteImage(image)} data-toggle="tooltip"
                               data-placement="bottom"
                               title="Supprimer">
                                <Icon class="clickable" icon="{trashIcon}"/>
                            </b>
                        </div>
                    </div>
                </div>
            {/each}
        </div>
    </div>
</main>


<style>
    .card {
        margin-bottom: 5px;
    }

    .pull-left {
        float: left;
    }

    .pull-right {
        float: right;
    }

    .selectedImagePlaceholder {
        position: absolute !important;
        width: 100%;
        height: 200px;
        background: rgba(250, 250, 250, 0.5);
    }

    div :global(.selectedImage) {
        position: absolute !important;
        left: 45%;
        top: 75px;
        font-size: 50px !important;
    }

    .clickable {
        cursor: pointer !important;
    }
</style>