<script>
    /**
     *                  THIS IS NOT FROM ME
     *
     *      SINCE THE CREATOR OF THIS LIBRAIRIE IS NOT MAINTAINING THIS CODE
     *      I COPIED THE COMPONENT HE CREATED AND FIXED IT ...
     *
     */
    import { onMount } from "svelte";
    export let dropzoneEvents = {};
    export let options = { previewTemplate: "<div/>" };
    export let dropzoneClass = "dropzone";
    export let hooveringClass = "dropzone-hoovering";
    export let id = "dropId";
    export let autoDiscover = false;

    onMount(() => {
        const dropzoneElement = document.getElementById(id);
        if (!options.previewTemplate) {
            options.previewTemplate = "<div/>";
        }
        if (!options.dictDefaultMessage) {
            options.dictDefaultMessage = "";
        }

        let svDropzone = new Dropzone(`div#${id}`, {
            ...options
        });
        if (autoDiscover !== true) {
            Dropzone.autoDiscover = false;
        }

        svDropzone.on("addedfile", f => {
            dropzoneElement.classList.remove(hooveringClass);
        });
        svDropzone.on("dragenter", e => {
            console.log(dropzoneElement);
            dropzoneElement.classList.toggle(hooveringClass);
        });
        svDropzone.on("dragleave", e => {
            dropzoneElement.classList.toggle(hooveringClass);
        });
        Object.entries(dropzoneEvents).map(([eventKey, eventFunc]) =>
                svDropzone.on(eventKey, eventFunc)
        );

        if (options.clickable !== false) {
            dropzoneElement.style.cursor = "pointer";
        }
        svDropzone.on("error", (file, errorMessage) => {
            console.error(`Error: ${errorMessage}`);
        });
    });
</script>

<style>
    .dropzone {
        border-radius: 5px;
        display: flex;
        justify-content: center;
        align-items: center;
        transition: all 300ms ease-out;
    }

</style>

<div action="#" class={dropzoneClass} {id}>
    <slot />
    <input hidden name="sites_data" type="file" />
</div>
