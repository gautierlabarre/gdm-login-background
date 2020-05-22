<script>
    const pjson = require('../package.json');
    const appVersion = pjson.version;
    const author = pjson.author;
    const { shell } = require('electron')

    function showWebsite() {
        shell.openExternal('https://github.com/gautierlabarre/gdm-login-background');
    }
</script>

<p class="mt-56">Gnome Login background v{appVersion}</p>
<p>Creation date : May 2020 by {author}</p>
<p>Website : <a href="#/about" on:click={showWebsite}>GDM Login Background</a></p>

<style>
    p {
        text-align: center;
    }
</style>