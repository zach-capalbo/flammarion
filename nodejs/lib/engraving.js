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
        
        this.revelator = new Revelator();
        // this.revelator.openWindow();
    }
    send_json(...args) {
        console.log("Should send", args)
    }
}

module.exports = {Engraving}