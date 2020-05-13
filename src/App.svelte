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
    import {Button, Modal, ModalBody, ModalFooter, ModalHeader} from 'sveltestrap';

    let trashIcon = faTrash;
    let checkCircleIcon = faCheckCircle;
    let checkIcon = faCheck;
    let selectedImage = '';
    let backgroundList = [];
    let confirmRestart = false;
    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';

    onMount(async () => {
        // Create app folder if it does not exist
        const createFolder = exec('cd ' + home + '&& mkdir -p ' + appFolderName, (error, stdout, stderr) => {
            if (error) {
                console.log(error.stack);
            }
        });
        createFolder.on('exit', () => getBackgroundList());
    });

    function checkSelected(image) {
        if (fs.existsSync(home + appFolder + 'selectedBackground')) {
            let selectedB = fs.readFileSync(home + appFolder + 'selectedBackground', 'utf-8');

            if (image.trim() === selectedB.trim()) {
                return true;
            }
        } else {
            createSelectedBackgroundFile()
        }
    }

    function restartGdm() {
        console.log('on restart')
    }
    function createSelectedBackgroundFile(content = '') {
        fs.writeFile(home + appFolder + 'selectedBackground', content, function (err) {
            if (err) throw err;
            console.log('File is created successfully.');
        });
    }

    function getBackgroundList() {
        fs.readdir(home + appFolder, (err, items) => {
            // console.log(items);
            if (items !== 'selectedBackground')
                backgroundList = items;
            backgroundList = backgroundList.filter(array => {
                console.log(array.trim() !== 'selectedBackground')
                return (array.trim() !== 'selectedBackground')
            })
        });
    }

    function deleteImage(image) {
        fs.unlinkSync(home + appFolder + image);
        getBackgroundList()
    }

    function executeBackgroundChange(image) {
        let script = __dirname + '/test.sh';
        let imagePath = home + appFolder + image;
        const options = { // Can't get it to work i think
            name: 'Electron',
            icns: '/Applications/Electron.app/Contents/Resources/Electron.icns', // (optional)
        };

        sudo.exec(script + ' ' + imagePath, options, (error, stdout, stderr) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);

            createSelectedBackgroundFile(image.trim());
            getBackgroundList();
            confirmRestart = true;
        });

        //TODO Sudo exec service gdm restart if successful
    }

    function reset() {
        //TODO Launch default script with --restore option
    }

    const toggle = () => (confirmRestart = !confirmRestart);

</script>

<main>
    <div>
        <Modal isOpen={confirmRestart} {toggle}>
            <ModalHeader {toggle}>Fond changé</ModalHeader>
            <ModalBody>
                Pour que le changement prenne effet il faut redémarrer le service GDM.
                <br>
                Cela vous déconnectera de votre session
            </ModalBody>
            <ModalFooter>
                <Button color="primary" on:click={restartGdm}>
                    OK
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
                <button class="btn btn-danger pull-right" on:click={reset}>Reset</button>
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
                            <a href="#" class="clickable pull-left" on:click={executeBackgroundChange(image)}
                               data-toggle="tooltip" data-placement="bottom"
                               title="Supprimer">
                                <Icon class="clickable" icon="{checkIcon}"/>
                            </a>
                            <a href="#" class="clickable pull-right" on:click={deleteImage(image)} data-toggle="tooltip"
                               data-placement="bottom"
                               title="Supprimer">
                                <Icon class="clickable" icon="{trashIcon}"/>
                            </a>
                        </div>
                    </div>
                </div>
            {/each}
        </div>
    </div>
</main>


<style>
    main {
        text-align: center;
        padding: 1em;
        max-width: 240px;
        margin: 0 auto;
    }

    li {
        list-style-type: none;
    }



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
        left: 50%;
        top: 90px;
        font-size: 14px !important;
    }


    .clickable {
        cursor: pointer !important;
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