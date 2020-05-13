<script>
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();
    const {app} = require('electron').remote;
    const {exec} = require('child_process');
    const appFolderName = '.gdm-background';
    const appFolder = '/' + appFolderName + '/';
    const home = app.getPath('home');

    let dropzoneClass = 'normal';

    Dropzone.options.uploadWidget = {
        paramName: 'file',
        maxFilesize: 100, // MB
        maxFiles: 1,
        dictDefaultMessage: 'Drag an image here to upload, or click to select one (only works with JPG or PNG file). <br><br> If you have a dual screen, take a background with huge dimensions.',
        acceptedFiles: 'image/*',
        init: function () {
            this.on('dragover', () => {
                dropzoneClass = "dropOver";
            });
            this.on('dragleave', () => {
                dropzoneClass = "normal";
            });
            this.on('addedfile', (file) => {
                const filename = file.path.replace(/(\s+)/g, '\\$1');
                let ext = '.jpg';
                if (file.type === 'image/png') {
                    ext = '.png';
                }

                addImageToAppFolder(filename, ext);
            });
        },
        accept: function () {
            dropzoneClass = "normal";
            this.removeAllFiles();
            setTimeout(() => dispatch('refresh'), 1500);
        }
    };

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
</script>
<div class="row">
    <div class="col">
        <form id="upload-widget" method="post" action="/" class="dropzone {dropzoneClass}">
            <div class="fallback">
                <input name="file" type="file" multiple/>
            </div>
        </form>
    </div>
</div>

<style>
    .dropzone {
        border-radius: 10px;
        border-style: dashed;
        margin-bottom: 10px;
        margin-top: 10px;
    }

    .normal {
        background: white;
    }

    .dropOver {
        background: #ccc;
    }
</style>