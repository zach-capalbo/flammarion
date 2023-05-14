const {Engraving} = require('./lib/engraving.js');
;(async () => {
    f = new Engraving()
    f.puts("hi")
    f.highlight({test: 123, abc: ["EFG"]})
    var d, dd;
    let subpane;
    f.button("abc", () => { 
        subpane.clear()
        subpane.puts(d.value); 
        subpane.puts(dd.value)
    })
    d = f.input("Type:")
    dd = f.dropdown(["123", "456", "abc"])
    subpane = f.subpane("abcd")
    f.puts(await f.script(() => 1 + 1))
    f.puts(await f.script("1 + 1"))
    f.highlight(f.emoji)
})();