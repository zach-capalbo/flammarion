/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require websocket.coffee
if (window.$remote) {
  $.extend(WSClient.prototype.actions, {
    snapshot(data) {
      return window.$remote.getCurrentWindow().capturePage(image => {
        return this.__parent.send({
          id:data.id,
          action:'callback',
          source:'snapshot',
          data: image.toPNG(),
          original_msg:data
          });
      });
    }
  }
  );
}
