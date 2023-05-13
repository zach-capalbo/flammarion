const {Engraving} = require('./engraving')

class Plot {
    constructor(...args) {
        if (args.length === 0) {
            this.engraving = new Engraving();
            this.id = this.engraving.makeId();
            this.target = "default"
        } else {
            const [id, target, engraving] = args;
            this.id = id
            this.target = target
            this.engraving = engraving
        }
    }
    plot(data, options = {}) {
        if (Object.getPrototypeOf({}) == Object.getPrototypeOf(data))
        {
            options = Object.assign({}, options, data)
            if ("xy" in data) {
                data = Object.assign({}, data)
                data.x = data.xy.map((a) => a[0])
                data.y = data.xy.map((a) => a[1])
                delete data.xy
            }
            data = [data]
        }
        else if (Object.getPrototypeOf({}) != Object.getPrototypeOf(data[0]))
        {
            data = [{y: data, x: Array.from({ length: data.length }, (_, i) => i + 1), ...options}]
        }
        this.engraving.send_json({action: 'plot', id: this.id, target: this.target, data, ...options})
    }
    layout(options = {}) {
        this.send_json({action: 'plot', id: this.id, target: this.target, layout: options})
    }
    save(options = {}, callback = undefined) {
        let id = this.engraving.makeId()
        if (callback) {
            this.engraving.callbacks[id] = callback;
            this.engraving.send_json({action: 'savePlot', id: this.id, target: this.target, callback_id: id, format: options})
        } else {
            return new Promise((r, e) => {
                this.engraving.callbacks[id] = r;
                this.engraving.send_json({action: 'savePlot', id: this.id, target: this.target, callback_id: id, format: options})
            })
        }
    }
    async toPNG(options = {}) {
        return await this.save(Object.assign({}, options, {format: 'png'}))
    }
    async toSVG(options = {}) {
        let d = await this.save(Object.assign({}, options, {format: 'svg'}))
        d = d.data
        return decodeURIComponent(d.slice(d.indexOf(',') + 1))
    }
}

module.exports = {Plot}
    