<script>
    export let confirmRestart;
    const sudo = require('sudo-prompt');
    import {Button, Modal, ModalBody, ModalFooter, ModalHeader} from 'sveltestrap';

    function restartGdm() {
        const options = {name: 'Gdm login background'};

        sudo.exec('service gdm restart', options, (error, stdout) => {
            if (error) throw error;
            console.log('stdout: ' + stdout);
        });
    }

    const toggle = () => (confirmRestart = !confirmRestart);

</script>
<Modal isOpen={confirmRestart} {toggle}>
    <ModalHeader {toggle}>GDM background changed</ModalHeader>
    <ModalBody>
        For the change to take place, you have to restart GDM service.
        Careful, you will lose all your work and your session will be closed.
        If you click Cancel, the change will be visible after you restart your computer.
    </ModalBody>
    <ModalFooter>
        <Button color="primary" on:click={restartGdm}>Restart GDM</Button>
        <Button color="secondary" on:click={toggle}>Cancel</Button>
    </ModalFooter>
</Modal>