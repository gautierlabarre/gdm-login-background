<script>
    export let home;
    export let appFolder;
    export let image;

    const fs = require("fs");
    const dispatch = createEventDispatcher();

    import { createEventDispatcher } from 'svelte';
    import {faTrash} from '@fortawesome/free-solid-svg-icons'
    import {faCheckCircle} from '@fortawesome/free-solid-svg-icons'
    import {faCheck} from '@fortawesome/free-solid-svg-icons'
    import { FontAwesomeIcon } from 'fontawesome-svelte';

    function checkSelected(image) {
        if (fs.existsSync(home + appFolder + 'selectedBackground')) {
            const selectedB = fs.readFileSync(home + appFolder + 'selectedBackground', 'utf-8');
            if (image.trim() === selectedB.trim()) return true;
        }
    }

    function deleteImage(image) {
        fs.unlinkSync(home + appFolder + image);
        dispatch('delete');
    }

    function executeBackgroundChange(image) {
        dispatch('selected', {image: image});
    }

</script>

<div class="card">
    {#if checkSelected(image)}
        <div class="selectedImagePlaceholder"></div>
        <FontAwesomeIcon class="selectedImage" icon="{faCheckCircle}"/>
    {/if}

    <img src="{home}{appFolder}{image}" alt="test">

    <div class="card-body">
        {#if !checkSelected(image)}
            <b class="clickable text-primary pull-left" on:click={executeBackgroundChange(image)} title="Select this image">
                <FontAwesomeIcon class="clickable" icon="{faCheck}"/>
            </b>
        {/if}
        <b class="text-danger clickable pull-right" on:click={deleteImage(image)} title="Delete">
            <FontAwesomeIcon class="clickable" icon="{faTrash}"/>
        </b>
    </div>
</div>

<style>
    img {
        width: 100%;
        height: 200px;
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
        left: 45%;
        top: 75px;
        font-size: 50px !important;
    }

    .clickable {
        cursor: pointer !important;
    }
</style>