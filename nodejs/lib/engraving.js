const {Writeable} = require('./writeable.js');
const {Revelator} = require('./revelator.js');

class Engraving extends Writeable {
    constructor(options = {}) {
        super();
        let {title = "Flammarion"} = options;
        if (typeof options === 'string') {
            title = options;
        }

        this.pane_name = "default"
        this.engraving = this;
        this.sockets = []
        this.waitingConnectionResolves = []
        
        this.revelator = new Revelator();
        this.revelator.windowId = this.revelator.server.registerWindow(this)
        console.log("Registered window", this.revelator.windowId)
        // this.revelator.openWindow();
    }
    async send_json(val) {
        if (this.sockets.length === 0)
        {
            // await this.openWindow()
            // await this.waitForAConnection()
        }
        for (let ws of this.sockets)
        {
            ws.send(JSON.stringify(val))
        }
    }
    async openWindow(...args) {
        await this.revelator.openWindow(...args)
    }
    waitForAConnection() {
        return new Promise((r, e) => {
            this.waitingConnectionResolves.push(r)
        })
    }
    registerConnection(ws) {
        this.sockets.push(ws);
        for (let r of this.waitingConnectionResolves)
        {
            r()
        }
        this.waitingConnectionResolves.length = 0;
    }
}

module.exports = {Engraving}