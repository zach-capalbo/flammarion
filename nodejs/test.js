const {Engraving} = require('./lib/engraving.js');
;(async () => {
    f = new Engraving()
    await f.revelator.openWindow();
    f.puts("hi")
})();