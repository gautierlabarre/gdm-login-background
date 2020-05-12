<script>
    // Electron dependencies
    const fs = require("fs");
    const {exec} = require('child_process');
    const sudo = require('sudo-prompt');
    const {app} = require('electron').remote;
    const home = app.getPath('home');

    // Svelte code
    import {onMount} from 'svelte';

    let backgroundList = [];
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

    function getBackgroundList() {
        fs.readdir(home + appFolder, (err, items) => backgroundList = items);
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
        });
    }

    function reset() {
        //TODO Launch default script with --restore option
    }

    function addImageToAppFolder(filename, ext) {
        const mvToProperFolder = 'cd ' + home + appFolder;
        const date = Date.now();

        exec(mvToProperFolder + ' && cp ' + filename + ' ./' + date + ext, (error, stdout, stderr) => {
            if (error) {
                console.log(error.stack);
                console.log('Error code: ' + error.code);
                console.log('Signal received: ' + error.signal);
            }
            console.log(stdout);
            console.log(stderr);
        });
    }

    Dropzone.options.uploadWidget = {
        paramName: 'file',
        maxFilesize: 100, // MB
        maxFiles: 1,
        dictDefaultMessage: 'Drag an image here to upload, or click to select one (only works with JPG or PNG file)',
        acceptedFiles: 'image/*',
        init: function() {
            this.on('addedfile', (file) => {
                const filename = file.path.replace(/(\s+)/g, '\\$1');
                let ext = '.jpg';
                if (file.type === 'image/png') {
                    ext = '.png';
                }

                addImageToAppFolder(filename, ext);
            });
        },
        accept: function() {
            this.removeAllFiles();
            setTimeout(() => getBackgroundList(), 1500);
        }
    };
</script>

<main>
    <form id="upload-widget" method="post" action="/" class="dropzone">
        <div class="fallback">
            <input name="file" type="file" multiple/>
        </div>
    </form>

    <button on:click={reset}>update</button>
    {#each backgroundList as image}
        <li>
            <span on:click={deleteImage(image)}>DELETE</span>
            <img src="{home}{appFolder}{image}" on:click={executeBackgroundChange(image)} width="800" alt="test">
        </li>
    {/each}
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