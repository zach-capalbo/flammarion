const http = require('http');
const WebSocket = require('ws');
const fs = require('fs');
var finalhandler = require('finalhandler');
var serveStatic = require('serve-static');

const path = require('path');
const htmlDir = [
                // Installed node_module
                path.join(path.dirname(__filename), '/../html/source/'),
                // Development path
                path.join(path.dirname(__filename), '/../../lib/html/source/'), 
].find(p => fs.existsSync(p))
var serve = serveStatic(htmlDir);

class Server {
  constructor() {
    this.windows = {};
    this.socketPaths = {};
    this.started = false;
    this.start();
    this.newPath = 0;
  }

  wslPlatform() {
    return (
      fs.existsSync('/proc/version') &&
      fs
        .readFileSync('/proc/version', 'utf8')
        .toLowerCase()
        .includes('microsoft')
    );
  }

  start() {
    if (this.started) return;
    if (this._starting) return this._starting;
    return this._starting = this._start();
  }

  async startHttpServer() {
    let port;

    while (!port) {
      try {
        port = Math.floor(Math.random() * (65000 - 1024) + 1024);
        
          const webrick = http.createServer((req, res) => {
            try {
              var done = finalhandler(req, res);
              serve(req, res, done);
            } catch (e) {
              console.error("Could not serve", req.path, e)
            }
          });
          this.webrick_port = port;
          this.webrick = webrick;

          await new Promise((resolve, reject) => {
            webrick.listen(port, '127.0.0.1', (err) => {
              if (err) {
                if (err.code === 'EADDRINUSE') {
                  port = null;
                } else {
                  reject(err);
                }
              } else {
                resolve();
              }
            });
        });
      } catch (e) {
        console.error("Retring start", e)
        if (e.code === 'EADDRINUSE') {
          port = null;
        } else {
          throw e;
        }
      }
    }
  }

  async _start() {
    await this.startHttpServer();
    this.port = this.webrick_port;
    const wss = new WebSocket.Server({ server: this.webrick });
    wss.on('connection', (ws, req) => {
      if (this.windows[req.url]) {
        this.windows[req.url].registerConnection(ws);
        if (this.windows[req.url].onConnect) {
          this.windows[req.url].onConnect();
        }
        this.socketPaths[ws] = req.url;
      } else {
        console.error(`No such window: ${req.url}`);
      }
      ws.on('message', (msg) => {
        try {
          this.windows[this.socketPaths[ws]].processMessage(msg);
        } catch (e) {
          this.handleException(e);
        }
      });
      ws.on('close', () => {
        const window = this.windows[this.socketPaths[ws]];
        if (window) {
          window.disconnect(ws);
        }
        delete this.socketPaths[ws];
        if (Object.keys(this.socketPaths).length === 0)
        {
          wss.close();
          this.webrick.close();
        }
      });
    });

    this.started = true
  }
  registerWindow(window)
  {
    this.newPath += 1;
    this.windows[`/w${this.newPath}`] = window
    return `w${this.newPath}`
  }
  handleException(e) {
    console.error(e)
  }
}

module.exports = {Server}