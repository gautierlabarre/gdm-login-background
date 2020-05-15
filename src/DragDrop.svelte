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

        exec(mvToProperFolder + ' && cp ' + filename + ' ./' + date + ext, (error) => {
            if (error) console.log(error.stack);
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
        margin: 0 -15px 10px -25px;
        border-left: 0;
        border-right: 0;
        border-top: 0;
        border-style: dotted;
        background: #dddddd;
    }


    .normal {
        background: #dddddd;
    }

    .dropOver {
        background: #aaa;
    }
</style>