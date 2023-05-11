const fs = require('fs');
const {execSync, spawnSync, spawn } = require('child_process');
const {Server} = require('./server.js');

class SetupError extends Error {}
const CHROME_PATH = process.env.FLAMMARION_REVELATOR_PATH || 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
class Revelator {
  

  constructor() {
    this.server = new Server();
    this.started = this.server.start();

    this.browsers = [
      function electron(options) {
        if (Revelator.#which('electron')) {
          const electronPath = `${__dirname}/../../electron`;
          if (process.platform === 'cygwin') {
            electronPath = require('child_process').execSync(`cygpath -w '${electronPath}'`).toString().trim();
          }
          require('child_process').spawn(`electron "${electronPath}" "${options.url}" ${options.width || ''} ${options.height || ''}`, { detached: true });
          return true;
        }
        return false;
      },
      function osx(options) {
        if (process.platform !== 'darwin') {
          return false;
        }
        const executable = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
        const [inStream, outStream, errStream, thread] = require('child_process').spawnSync(executable, [`--app=${options.url}`]);
        this.chrome = { inStream, outStream, errStream, thread };
        return !!this.chrome.inStream;
      },
      function chrome(options) {
        let chromePath = CHROME_PATH;
        // Convert to path in WSL
        if (this.wslPlatform()) {
          chromePath = execSync(`wslpath '${CHROME_PATH}'`).toString().trim();
        }
      
        if (!fs.existsSync(chromePath)) {
          console.log("NO CHROME", chromePath)
          return false;
        }
      
        let url = `http://localhost:${this.server.webrick_port}/index.html`;
        // url = "https://zachcapalbo.com"
        const title = options && options.title ? options.title : "Flammarion%20Engraving";
        // let args = [`--app=${url}?port=${this.server.port}&path=${this.windowId.replace('/', '')}&title=${title}`];
        let args = [`--app=${url}?port=${this.server.port}&path=${this.windowId }`];

        console.log("Starting chrome", chromePath, args)
      
        const proc = spawn(chromePath, args, {
          stdio: ["pipe", "pipe", "pipe"],
          shell: false,
        });

        console.log("Chrome spawned");
      
        return true;
      },
    ];
  }

  static #which(cmd) {
    try {
      const stdout = require('child_process').execSync(`which ${cmd}`);
      return String(stdout).trim();
    } catch (error) {
      return false;
    }
  }

  // Check for WSL, idea from https://github.com/hashicorp/vagrant/blob/master/lib/vagrant/util/platform.rb
  wslPlatform() {
    return (
      fs.existsSync('/proc/version') &&
      fs
        .readFileSync('/proc/version', 'utf8')
        .toLowerCase()
        .includes('microsoft')
    );
  }

  async openWindow(options = {}) {
    await this.started;
    const host = `http://localhost:${this.server.webrickPort}/`;
    this.expectedTitle = options.title || 'Flammarion';
    const url = `${host}?path=${this.windowId}&port=${this.server.port}&title=${this.expectedTitle}`;
    this.browserOptions = { ...options, url };
    this.requestedBrowser = process.env.FLAMMARION_BROWSER || options.browser;
    this.browser = this.browsers.find(browser => {
      console.log("Checking function", browser)
      if (this.requestedBrowser && browser.name !== this.requestedBrowser) {
        return false;
      }
      try {
        return browser.call(this, this.browserOptions);
      } catch (err) {
        console.error(err);
        return false;
      }
    });

    if (!this.browser) {
      throw new SetupError('You must have either electron or google-chrome installed and accessible via your path.');
    }
  }

  static waitForConnection() {
    let connected = false;
    const startTime = Date.now();
    const timeout = 20000;
    const interval = setInterval(() => {
      if (!connected && this.sockets.length > 0) {
        connected = true;
        clearInterval(interval);
      } else if (Date.now() - startTime > timeout) {
        clearInterval(interval);
        throw new SetupError(`Timed out while waiting for a connection using ${this.browser.name}.`);
      }
    }, 10);
  }
}

module.exports = {Revelator}