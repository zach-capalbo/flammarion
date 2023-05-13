const {Engraving} = require('../lib/engraving.js')

let sampleFuncs = []
function sample(name, func) {
    sampleFuncs.push([name, func])
}

sample("Message Sender With Contacts", (f) => {
    f.orientation = 'horizontal'
    f.subpane('number').input("Phone Number")
    f.checkbox("Request Read Receipt")
    f.input("Body", {multiline: true})
    f.button("Send", () => f.status("Error: 123"))
    f.pane("contacts", {weight: 0.7}).puts("Contacts", {replace: true})
    icons = ["thumbs-up", "meh-o", "bicycle", "gears", "star", "cow", "cat", "cactus", null, null, null, null]
    for (let i = 0; i < 30; ++i) {
        let rightIcon = icons[Math.floor(Math.random() * icons.length)]
        let name = "123 ABC"
        f.pane("contacts").button(name, {right_icon: rightIcon}, () => {
            f.subpane("number").replace(`To: ${name}`)
        })
    }
})

sample("Table with side panes", (f) => {
    f.orientation = 'horizontal'
    let data = []
    for (let i = 0; i < 20; ++i)
    {
        data.push([i, "ABC", "123"])
    }
    f.table(data, {headers: ["Id", "Name", "Address"]})
})

sample("Plots", (f) => {
    let p1 = f.plot([1,2,5,6,77])
    let p2 = f.plot([{x: [5,6, 7], y: [100, 110, 300]}])
    f.button("to SVG", async () => {
        f.highlight(await p1.toSVG())
    })
})

;(async () => {
    for (let [name, func] of sampleFuncs)
    {
        console.log("Running", name)
        let f = new Engraving()
        func(f)
        await f.waitUntilClosed();
    }
    console.log("All done");
})();