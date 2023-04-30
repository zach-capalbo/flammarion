/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require vendor/jquery.js
//= require status.coffee
//= require fontawesome.js
//= require vendor/twemoji.min.js
//= require vendor/emojione.min.js

// emojione.imagePathPNG = 'images/emoji/'

class WSClient {
  static initClass() {
  
    this.prototype.actions =
      {__parent: null};
  }
  constructor() {
    const host = $qs.get("host") || "localhost";
    console.log(`Path: ${$qs.get("path")}, Port: ${$qs.get("port")}, Host: ${host}`);
    this.ws = new WebSocket(`ws://${host}:${$qs.get("port")}/${$qs.get("path")}`);
    this.actions["__parent"] = this;
    document.title = decodeURIComponent($qs.get("title")) || "Flammarion";
    this.ws.onopen = msg => $('body').addClass("connected");

    this.ws.onclose = msg => $('body').removeClass("connected");

    this.ws.onmessage = msg => {
      // Just keeping this around for debug purposes
      this.lastMessage = msg;
      try {
        const data = $.parseJSON(msg.data);
        if (this.actions[data.action]) {
          return this.actions[data.action](data);
        } else {
          console.log(msg);
          return console.error(`No such action: ${data.action}`);
        }
      } catch (error) {
        console.log(msg);
        console.error(error);
        return console.error(error.stack);
      }
    };

    this.status = new StatusDisplay(this, $('#status > .right'));
  }

  send(data) {
    return this.ws.send(JSON.stringify(data));
  }

  check_target(data) {
    if (data.target_element) { return data.target_element; }
    if (!data.target) { data.target = "default"; }
    if ($(`#console-${data.target}`).size() === 0) { this.actions.addpane({name:data.target}); }
    this.resize_panes;
    return $(`#console-${data.target}`);
  }

  resize_panes(data) {
    let orientation, target;
    if (data.target) {
      target = this.check_target(data);
    } else {
      target = $('#panes');
    }

    const allPanes =  target.find('> .pane');
    if (target.hasClass('horizontal')) {
      orientation = 'horizontal';
    } else {
      orientation = 'vertical';
    }

    const total_weight = (Array.from(allPanes).map((i) => (parseFloat($(i).attr('pane-weight') || 1.0)))).reduce((t, s) => t + s);
    // total_weight = (allPanes.map((i) -> parseFloat(i[].attr('pane-weight')))).reduce (t, s) -> t + s

    const p_height = pane => ((parseFloat($(pane).attr('pane-weight') || 1.0) / total_weight) * 100).toFixed(0) + "%";
    console.log(target, allPanes.size(), 100.0 / allPanes.size(), total_weight, orientation);
    return (() => {
      const result = [];
      for (var pane of Array.from(allPanes)) {
        if (orientation === 'horizontal') {
          $(pane).css("width", p_height(pane));
          result.push($(pane).css("height", '100%'));
        } else {
          $(pane).css("height", p_height(pane));
          result.push($(pane).css("width", '100%'));
        }
      }
      return result;
    })();
  }

  relink(text) {
    return text.replace(/\<a href=['"](https?:\/\/[^\s]+)["']>/gm, (str, l) => `<a href=\"${l}\" target='_blank'>`);
  }

  parse_emoji(text) {
    return twemoji.parse(emojione.shortnameToUnicode(text), i => `images/emoji/${i}.png`);
  }

  escape(text, input_options) {
    const options = {
      raw: false,
      colorize: true,
      escape_html: true,
      escape_icons: false
    };
    $.extend(options, input_options);
    if (options.raw) { return text; }
    text = `${text}`;
    if (options.escape_html) { text = ansi_up.escape_for_html(text); }
    if (options.colorize) { text = ansi_up.ansi_to_html(text, {use_classes:true}); }
    if (options.escape_icons) {
      text = text.replace(/:[\w-]+:/g, function(match) {
        if (font_awesome_list.includes(match.slice(1, +-2 + 1 || undefined))) { return `<i class='fa fa-${match.slice(1, +-2 + 1 || undefined)}'></i>`; } else { return match; }
      });
    }

    if (options.escape_icons || options.escape_emoji) { text = this.parse_emoji(text); }
    text = $(`<div>${text}</div>`);
    text.find("a[href^='http']").attr('target','_blank');
    return text.html();
  }

  add(object, target, data) {
    object.find("a[href^='http']").attr('target','_blank');
    if (data.style) {
      for (var key of Object.keys(data.style || {})) { var val = data.style[key]; object.css(key, val); }
    }
    if (data.replace) {
      return target.html(object);
    } else {
      return target.append(object);
    }
  }
}
WSClient.initClass();

$(document).ready(() => window.$ws = new WSClient);

window.WSClient = WSClient;
