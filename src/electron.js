const { app, BrowserWindow } = require('electron');
const path = require('path')

let mainWindow;
let watcher;
if (process.env.NODE_ENV === 'development') {
    watcher = require('chokidar').watch(path.join(__dirname, '../public/build'), { ignoreInitial: true });
    watcher.on('change', () => {
        mainWindow.reload();
    });
}
function createWindow() {
    mainWindow = new BrowserWindow({
        icon: path.join(__dirname, '../public/icon.png'),
        width: 1024,
        height: 800,
        resizable: false,
        autoHideMenuBar: true,
        webPreferences: {
            nodeIntegration: true,
        }
    });

    mainWindow.loadURL(`file://${path.join(__dirname, '../public/index.html')}`).then();
    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
    if (watcher) {
        watcher.close();
    }
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (mainWindow === null) {
        createWindow();
    }
});