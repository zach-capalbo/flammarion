const {Engraving} = require('./lib/engraving.js');
;(async () => {
    f = new Engraving()
    await f.revelator.openWindow();
    // await new Promise(resolve => setTimeout(resolve, 1000))
    await f.waitForAConnection();
    f.puts("hi")
})();