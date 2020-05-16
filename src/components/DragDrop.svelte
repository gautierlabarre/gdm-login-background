<script>
    import {createEventDispatcher} from 'svelte';
    import Dropzone from "../updatedLibrairies/SVDropzone.svelte";

    const dispatch = createEventDispatcher();
    const {app} = require('electron').remote;
    const {exec} = require('child_process');
    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';
    const home = app.getPath('home');

    function addedfile(file) {
        const filename = file.path.replace(/(\s+)/g, '\\$1');
        let ext
        if (file.type === 'image/png') {
            ext = '.png';
        }

        console.log(file.type)
        if (file.type === 'image/jpg' || file.type === 'image/jpeg' ) {
            ext = '.jpg';
        }

        if(ext === undefined) {
            console.log('rejected file')
        } else {
            addImageToAppFolder(filename, ext);
        }
    }

    function addImageToAppFolder(filename, ext) {
        const mvToProperFolder = 'cd ' + home + appFolder;
        const date = Date.now();

        exec(mvToProperFolder + ' && cp ' + filename + ' ./' + date + ext, (error) => {
            if (error) console.log(error.stack);
            dispatch('refresh')
        });
    }
</script>

<div class="row">
    <div class="col">
        <Dropzone
                dropzoneClass="dropzone"
                hooveringClass="dropOver"
                dropzoneEvents={{ addedfile }}
                options={{
                    clickable: true,
                    acceptedFiles: 'image/*',
                    maxFilesize: 256,
                     }}>
            <p class="text-center">
                Drag an image here to upload, or click to select one (only works with JPG or PNG file).
                <br><br>
                If you have a dual screen, take a background with huge dimensions.
            </p>
        </Dropzone>
    </div>
</div>

<style>
    div :global(.dropzone) {
        height: 100px !important;
        margin: 0 -15px 10px -25px;
        border-color: gray;
        border-left: 0;
        border-right: 0;
        border-top: 0;
        border-radius: 0;
        box-shadow: 1px 5px 5px #7f7f7f;
        /*border-style: dotted;*/
        background: #dddddd !important;
    }

    div :global(.dropOver) {
        background: #aaa !important;
    }
</style>