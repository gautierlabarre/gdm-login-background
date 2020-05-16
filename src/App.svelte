<script>
    import Icon from 'fa-svelte';
    import {faEraser} from '@fortawesome/free-solid-svg-icons/faEraser'
    import {faInfo} from '@fortawesome/free-solid-svg-icons/faInfo'

    import {link} from 'svelte-spa-router';
    import Home from './pages/Home.svelte'
    import About from './pages/About.svelte'
    import Reset from './pages/Reset.svelte'
    import Router from 'svelte-spa-router'

    const infoIcon = faInfo;
    const eraserIcon = faEraser;
    const routes = {
        '/': Home,
        '/reset': Reset,
        '/about': About,
    }
</script>

<main>
    <div id="left-menu">
        <a href="/" use:link><img src="../public/icon.png" alt=""></a>

        <a href="/reset" use:link>
            <button class="btn btn-dark pull-right"  title="Reset default background"> <!--on:click={reset}-->
            <Icon class="clickable" icon="{eraserIcon}"/>
        </button></a>

        <a href="/about" use:link>
            <button class="btn btn-dark pull-right" title="Information">
            <Icon class="clickable" icon="{infoIcon}"/>
        </button></a>
    </div>

    <div id="content">
        <Router {routes}/>
    </div>
</main>

<style>
    #left-menu {
        display: inline-block;
        float: left;
        background: #1b1e21;
        width: 80px;
        height: 800px;
    }

    #left-menu img {
        margin-top: 20px;
        margin-bottom: 30px;
    }
    #left-menu  button {
        margin-top: 20px;
        float: left;
        margin-left: 15px;
        height: 50px;
        width: 50px;
    }

    #content {
        display: inline-block;
        width: calc(100% - 90px);
        margin-left: 10px;
        float: left;
    }
</style>