#= require websocket.coffee
if window.$remote
  $.extend WSClient.prototype.actions,
    snapshot: (data) ->
      window.$remote.getCurrentWindow().capturePage (image) =>
        @__parent.send({
          id:data.id
          action:'callback'
          source:'snapshot'
          data: image.toPNG()
          original_msg:data
          })
