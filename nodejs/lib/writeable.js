const {existsSync, readFileSync} = require('fs')

let Pane;

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
        if (callback)
        {
            this.engraving.callbacks[id] = callback
            return id
        }
        else
        {
            return new Promise((r, e) => {
                this.engraving.callbacks[id] = r
            });
        }
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
        let e = this.emoji[`:${name}:`]
        if (e) {
            return `<img class="emoji" alt="${name}" src="images/emoji/${e.unicode.last.downcase}.png">`
        }
        else {
            return `<i class="fa fa-${name} ${additionalClasses.map(c => `fa-${c}`).join(" ")}"></i>`
        }
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
        if (existsSync(text)) {
            return this.scriptSrc(text)
        }
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
    js(...args) { return this.script(...args); }
    scriptSrc(src) {
        if (existsSync(src)) {
            this.html(`<script>${readFileSync(src)}</script>`)
        } else {
            this.html(`<script src="${src}"></script>`)
        }
    }
    style(keyOrObject, valueOrNull)
    {
        if (valueOrNull)
        {
            this.send_json({action: 'style', attribute: keyOrObject, value:valueOrNull})
        }
        else
        {
            for (let [k,v] of Object.entries(keyOrObject))
            {
                this.send_json({action: 'style', attribute: k, value:v})
            }
        }
    }
    markdown(text, options = {}) {
        this.send_json(Object.assign({action: 'markdown', text, hard_wrap: false}, options))
    }
    hide() {
        this.send_json({action: 'hide'})
    }
    show() {
        this.send_json({action: 'show'})
    }
    subpane(name, options = {}) {
        if (!name) {
            name = this.engraving.makeId()
        }
        this.send_json(Object.assign({action: 'subpane', name}, options))
        return new Pane(this.engraving, name)
    }
    pane(name, options = {}) {
        if (!name) {
            name = this.engraving.makeId()
        }
        this.send_json(Object.assign({action: 'addpane', name}, options))
        return new Pane(this.engraving, name)
    }
    set orientation(orientation) {
        if (orientation != 'horizontal' && orientation != 'vertical') {
            throw new Error("Orientation must be 'horizontal' or 'vertical'")
        }
        this.send_json({action: 'reorient', orientation})
    }
    buttonBox(name = "buttonbox") {
        this.send_json({action: 'buttonbox', name})
        return new Pane(this.engraving, name)
    }
    status(str, options = {}) {
        if (typeof options === 'string') {
            options = {position: options}
        }
        this.engraving.send_json(Object.assign({action: 'status', text: str}, options))
    }
    table(rows, options = {}) {
        this.send_json(Object.assign({action: 'table', rows}, options))
    }
    async gets(prompt = "", options = {}) {
        return await new Promise((r, e) => {
            this.input(prompt, Object.assign({once: true, focus: true}, options), (m) => r(m.text))
        })
    }
    search(string) {
        this.send_json({action: 'search', text: string})
    }
    get emoji() {
        if (!this._emoji) {
            const emojioneFile = readFileSync(__dirname + '/../../lib/html/source/javascripts/vendor/emojione.js', 'utf8');
            const emojioneList = emojioneFile.split('\n').find(line => line.startsWith('    ns.emojioneList'));
            const emojiJson = JSON.parse(emojioneList.match(/= ({[^;]+);/)[1]);
            this._emoji = emojiJson;
        }
        return this._emoji;
    }
}

module.exports = {Writeable}
Pane = require('./pane').Pane
