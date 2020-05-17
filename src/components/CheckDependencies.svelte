<script>
    import {Spinner, Alert} from 'sveltestrap';
    import {onMount} from 'svelte';

    const sudo = require('sudo-prompt');
    const {exec} = require('child_process');

    let showLoading = false;
    let alertDependencies = false;

    onMount(async () => checkDependencies());

    function checkDependencies() {
        alertDependencies = false;

        exec("dpkg -s libglib2.0-dev-bin | grep Status | cut -d ' ' -f 4", (error, stdout) => {
            if (error) console.log(error.stack);
            if (stdout.trim() !== "installed") alertDependencies = true;
        });
    }

    function installDependencies() {
        showLoading = true;
        const options = {name: 'GDM Login background'};

        sudo.exec('apt install -y libglib2.0-dev-bin', options, (error, stdout) => {
            if (error) throw error;
            console.log(stdout);
            checkDependencies();
        });
    }
</script>

<Alert class="text-center" color="danger" isOpen={alertDependencies}>
    <p>This application might not work if you do not install "<b>libglib2.0-dev-bin</b>".</p>

    {#if showLoading}
        <Spinner color="primary"/>
    {/if}

    {#if !showLoading}
        <button class="btn btn-success" on:click={installDependencies}>Install libglib2.0-dev-bin</button>
    {/if}
</Alert>