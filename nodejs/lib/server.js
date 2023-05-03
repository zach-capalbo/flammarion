const http = require('http');
const WebSocket = require('ws');
const fs = require('fs');
var finalhandler = require('finalhandler');
var serveStatic = require('serve-static');

const path = require('path');
const htmlDir = path.join(path.dirname(__filename), '/../../lib/html/source/');
var serve = serveStatic(htmlDir);

let globalServer;

class Server {
  constructor() {
    this.windows = {};
    this.socketPaths = {};
    this.started = false;
    this.serverThread = null;
    // this.launchThread = Thread.current;
    this.start();
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

  async _start() {
    // globalServer = http.createServer((r, rr) => console.log(r)).listen(4567, '0.0.0.0');
    this.webrick_port = 4567
    let webrickPort;

    while (!webrickPort) {
      try {
        webrickPort = Math.floor(Math.random() * (65000 - 1024) + 1024);
        
          const webrick = http.createServer((req, res) => {
            console.log("Handling http", req.path, htmlDir)
            var done = finalhandler(req, res);
            serve(req, res, done);
          });
          this.webrick_port = webrickPort;
          this.webrick = webrick;

          await new Promise((resolve, reject) => {
            webrick.listen(webrickPort, '127.0.0.1', (err) => {
              if (err) {
                if (err.code === 'EADDRINUSE') {
                  webrickPort = null;
                } else {
                  reject(err);
                }
              } else {
                console.log("Http server running on", webrickPort)
                console.log(webrick);
                resolve();
              }
            });
        });


        const wss = new WebSocket.Server({ server: webrick });
        wss.on('connection', (ws, req) => {
          if (this.windows[req.url]) {
            this.windows[req.url].sockets.push(ws);
            if (this.windows[req.url].onConnect) {
              this.windows[req.url].onConnect();
            }
            this.socketPaths[ws] = req.url;
          } else {
            console.log(`No such window: ${req.url}`);
          }
          ws.on('message', (msg) => {
            try {
              this.windows[this.socketPaths[ws]].processMessage(msg);
            } catch (e) {
              this.handleException(e);
            }
          });
          ws.on('close', () => {
            console.log('Connection closed');
            const window = this.windows[this.socketPaths[ws]];
            if (window) {
              window.disconnect(ws);
            }
          });
        });

        console.log(`HTTP server started on port ${webrickPort}`);
      } catch (e) {
        console.error("Retring start", e)
        if (e.code === 'EADDRINUSE') {
          webrickPort = null;
        } else {
          throw e;
        }
      }
    }

    let port = 7870;
    if (process.platform === 'win32' || this.wslPlatform()) {
      port = Math.floor(Math.random() * (65000 - 1024) + 1024);
    }

    // await new Promise((resolve, err) => {
    //   try {
    //     const server = http.createServer();
    //     const wsServer = new WebSocket.Server({ server });

    //     server.listen(port, '127.0.0.1', () => {
    //       console.log(`WebSocket server started on port ${port}`);
    //       this.port = port;
    //       this.started = true;
    //       resolve();
    //     });

    //     wsServer.on('connection', (ws) => {
    //       ws.on('message', (msg) => {
    //         try {
    //           this.windows[this.socketPaths[ws]].processMessage(msg);
    //         } catch (e) {
    //           this.handleException(e);
    //         }
    //       });
    //       ws.on('close', () => {
    //         console.log('Connection closed');
    //         const window = this.windows[this.socketPaths[ws]];
    //         if (window) {
    //           window.disconnect(ws);
    //         }
    //       });
    //     });

    //     console.log(`Web server started on port ${port}`);
    //   }
    //   catch (e) {
    //     console.error(e)
    //     err(e);
    //   }
    // });
  }
}

module.exports = {Server}