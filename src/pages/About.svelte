<script>
    const pjson = require('../package.json');
    const appVersion = pjson.version;
    const author = pjson.author;
    const { shell } = require('electron')

    function showWebsite() {
        shell.openExternal('https://labarre.me')
    }

</script>

<p class="mt-56">Gnome Login background v{appVersion}</p>
<p>Date de réalisation : mai 2020 par {author}</p>
<p>Site web : <a href="#/about" on:click={showWebsite}>GDM Login Background</a></p>

<style>
    p {
        text-align: center;
    }
</style>