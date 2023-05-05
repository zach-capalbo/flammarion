const { Writeable } = require("./writeable");

class Pane extends Writeable
{
    constructor(engraving, name, options = {})
    {
        super()
        this.engraving = engraving
        this.pane_name = name
        this.options = options;
    }
}

module.exports = {Pane}