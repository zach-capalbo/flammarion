class Writeable {
    constructor() {

    }
    send_json(hash) {
        return this.engraving.send_json(Object.assign({target: this.pane_name}, hash));
    }
    send(str, options = {}) {
        return this.engraving.send_json(Object.assign({action: 'append', text: str, target: this.pane_name}, options));
    }
    print(...args) {
        return this.send(...args);
    }
    puts(str, options = {}) {
        this.send(str, options);
        this.send("\n");
    }
}

module.exports = {Writeable}