class DeferredValue {
    constructor() {}
    get value() {
        return this._value
    }
    _set(value) {
        this._value = value
    }
    toString() {
        return `#R${this._value}`
    }
    checked() {
        return Boolean(this._value)
    }
}

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
    raw(data) {
        return this.send(data, {raw: true})
    }
    replace(str, options = {}) {
        return this.send_json(Object.assign({action: 'replace', text: str}, options))
    }
    clear() {
        return this.send_json({action: 'clear'})
    }
    close() {
        return this.send_json({action: 'closepane'})
    }
    plot(data, options = {}) {
        let id = this.engraving.makeId()
        let p = new Plot(id, this.pane_name, this.engraving);
        p.plot(data, options)
        return p
    }
    highlight(text, options)
    {
        if (typeof text === 'string')
        {
            return this.send_json(Object.assign({action: 'highlight', text}, options))
        }
        else
        {
            return this.send_json(Object.assign({action: 'highlight', text: JSON.stringify(text, 2)}, options))
        }
    }
    button(label, options, callback) {
        let id = this.engraving.makeId()
        if (typeof options === 'function' && callback == undefined)
        {
            callback = options;
            options = {}
        }
        this.send_json(Object.assign({action: 'button', label, id}, options))
        this.engraving.callbacks[id] = callback
        return id
    }
    embeddedButton(label, options, callback)  {
        let id = this.engraving.makeId()
        if (typeof options === 'function' && callback == undefined)
        {
            callback = options;
            options = {}
        }
        this.engraving.callbacks[id] = callback
        return `<a class="floating-button" href="#" onClick="$ws.send({id:'${id}', action:'callback', source:'embedded_button'})">${label}</a>`
    }
    callbackLink(label, options, callback) {
        let id = this.engraving.makeId()
        if (typeof options === 'function' && callback == undefined)
        {
            callback = options;
            options = {}
        }
        this.engraving.callbacks[id] = callback
        return `<a href="#" onClick="$ws.send({id:'${id}', action:'callback', source:'link'})">${label}</a>`
    }
    icon(name, additionalClasses = []) {
        
    }
    input(label, options = {}, callback) {
        let id = this.engraving.makeId()
        if (typeof options === 'function' && callback == undefined)
        {
            callback = options;
            options = {}
        }

        this.send_json(Object.assign({action: 'input', label, id}, options))
        if (callback)
        {
            this.engraving.callbacks[id] = callback
        }
        else
        {
            let d = new DeferredValue;
            d._set(options.value)
            this.engraving.callbacks[id] = (m) => d._set(m.text)
            return d
        }
    }
    dropdown(items, options = {}, callback) {
        let id = this.engraving.makeId()
        if (typeof options === 'function' && callback == undefined)
        {
            callback = options;
            options = {}
        }
        this.send_json(Object.assign({action: 'dropdown', id, options: items}, options))
        if (callback) {
            this.engraving.callbacks[id] = callback;
        }
        else {
            let d = new DeferredValue;
            if (Array.isArray(items)) 
            {
                d._set(items[0])
            }
            else
            {
                d._set(items[Object.keys(items)[0]])
            }
            this.engraving.callbacks[id] = (m) => {d._set(m["value"])}
            return d;
        }
    }
    checkbox(label, options = {}, callback) {
        let id = this.engraving.makeId()
        if (typeof options === 'function' && callback == undefined)
        {
            callback = options;
            options = {}
        }

        this.send_json(Object.assign({action: 'checkbox', label, id}, options))
        if (callback)
        {
            this.engraving.callbacks[id] = callback
        }
        else
        {
            let d = new DeferredValue;
            d._set(options.value)
            this.engraving.callbacks[id] = (m) => d._set(m.checked)
            return d
        }
    }
    break(options = {}) {
        this.send_json(Object.assign({action: 'break'}, options))
    }
    html(data) {
        this.raw(data)
    }
    script(text, options = {}) {
        let id = this.engraving.makeId();
        if (typeof text === 'function') {
            text = `(${text.toString()})()`;
        }
        return new Promise((r, e) => {
            this.engraving.callbacks[id] = (m) => {
                r(m.result)
            }
            this.send_json(Object.assign({action: 'script', data: text, id}, options))
        })
    }
}

module.exports = {Writeable}