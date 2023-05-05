const {Engraving} = require('./lib/engraving.js');
;(async () => {
    f = new Engraving()
    await f.revelator.openWindow();
    // await new Promise(resolve => setTimeout(resolve, 1000))
    await f.waitForAConnection();
    f.puts("hi")
    f.highlight({test: 123, abc: ["EFG"]})
    var d, dd;
    f.button("abc", () => { f.puts(d.value); f.puts(dd.value)})
    d = f.input("Type:")
    dd = f.dropdown(["123", "456", "abc"])
    f.puts(await f.script(() => 1 + 1))
    f.puts(await f.script("1 + 1"))
})();