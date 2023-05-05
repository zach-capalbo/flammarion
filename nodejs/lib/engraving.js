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
        this.id = 0
        this.callbacks = {}
        
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
    openWindow() {
        if (this._windowOpening) return this._windowOpening;
        return this._windowOpening = this._openWindow();
    }
    async _openWindow(...args) {
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
    processMessage(msg) {
        this.lastMsg = msg
        let m = {}
        try {
            m = JSON.parse(msg)
        } catch (e) {
            console.error("Invalid JSON", e)
            return
        }

        switch (m.action) {
            case 'callback':
                let callback = this.callbacks[m.id]
                if (callback) {
                    callback(m)
                }
            break;
        }
    }
    makeId() {
        this.id += 1
        return `i${this.id}`
    }
}

module.exports = {Engraving}