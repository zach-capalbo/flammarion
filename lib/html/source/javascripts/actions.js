/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require websocket.coffee
$.extend(WSClient.prototype.actions, {
  append(data) {
    let atBottom;
    this.__parent.check_target(data);
    let element = $(`#console-${data.target}`);
    const marginSize = 16;

    const atBottomStack = [];
    while (element.hasClass("pane")) {
      atBottom = (element.scrollTop() >= (element[0].scrollHeight - element.height() - marginSize - 2)) || ((element[0].scrollHeight - marginSize) < element.height());
      atBottomStack.push(atBottom);
      element = element.parent();
    }

    element = $(`#console-${data.target}`);
    element.append(this.__parent.escape(data.text, data));

    if (data.auto_scroll !== false) {
      return (() => {
        const result = [];
        while (element.hasClass("pane")) {
          atBottom = atBottomStack.shift();
          if (atBottom) { element.scrollTop(element[0].scrollHeight - element.height() - marginSize); }
          result.push(element = element.parent());
        }
        return result;
      })();
    }
  },

  replace(data) {
    this.__parent.check_target(data);
    return $(`#console-${data.target}`).html(this.__parent.escape(data.text, data));
  },

  clear(data) {
    this.__parent.check_target(data);
    return $(`#console-${data.target}`).html("");
  }, // empty() is really slow for some reason

  addpane(data) {
    let target;
    if (data.target) {
      target = this.__parent.check_target(data);
    } else {
      target = $('#panes');
    }

    if (target.find(`#console-${data.name}`).size() === 0) {
      const element = $(`<pre class='pane full-pane' id='console-${data.name}'><pre>`);
      element.attr('pane-weight', data.weight || 1);
      target.append(element);
    }
    return this.__parent.resize_panes(data);
  },

  closepane(data) {
    const target = $(`#console-${data.target}`);
    if (target.size() !== 0) {
      target.remove();
      return this.__parent.resize_panes(data);
    }
  },

  hidepane(data) {
    const target = this.__parent.check_target(data);
    target.addClass("hidden");
    target.removeClass("pane");
    return this.__parent.resize_panes({target_element:target.parent()});
  },

  showpane(data) {
    const target = this.__parent.check_target(data);
    target.addClass("pane");
    target.removeClass("hidden");
    return this.__parent.resize_panes(data);
  },

  reorient(data) {
    let target;
    if (data.target) {
      target = this.__parent.check_target(data);
    } else {
      target = $('#panes');
    }

    if (data.orientation === "horizontal") {
      target.addClass("horizontal");
    } else {
      target.removeClass("horizontal");
    }
    return this.__parent.resize_panes(data);
  },

  highlight(data) {
    const target = this.__parent.check_target(data);
    const code = $(`<code>${ansi_up.escape_for_html(data.text)}</code>`);
    if (data.language) { code.addClass(data.language); }
    this.__parent.add(code, target, data);
    return hljs.highlightBlock(code[0]);
  },

  markdown(data) {
    const target = this.__parent.check_target(data);
    const newblock = $("<div class='markdown'></div>");
    newblock.html(this.__parent.escape(data.text, $.extend({escape_html:false, escape_icons:true}, data)));
    this.__parent.add(newblock, target, data);
    return Array.from(newblock.find('code')).map((code) => hljs.highlightBlock(code));
  },

  break(data) {
    const target = this.__parent.check_target(data);
    const code = $("<hr>");
    return this.__parent.add(code, target, data);
  },

  subpane(data) {
    const target = this.__parent.check_target(data);
    const element = target.find(`#console-${data.name}`);
    if (element.size() === 0) {
      let other_classes;
      if (data.fill) { other_classes = "subpane-fill"; }
      return target.append(`<pre id='console-${data.name}' class='subpane pane ${other_classes}'></pre>`);
    }
  },

  alert(data) {
    return alert(data.text);
  },

  title(data) {
    return document.title = data.title;
  },

  status(data) {
    return this.__parent.status.show_status(data);
  },

  layout(data) {
    return $("body").html(data.data);
  },

  script(data) {
    const r = eval(data.data);
    return this.__parent.send({
      id:data.id,
      action:'callback',
      source:'script',
      original_msg:data,
      result: r
      });
  },

  style(data) {
    const target = this.__parent.check_target(data);
    return target.css(data.attribute, data.value);
  },

  table(data) {
    const target = this.__parent.check_target(data);
    let html = "<table>";
    if (data.headers) {
      html += "<tr>";
      for (var header of Array.from(data.headers)) { html += `<th>${this.__parent.escape(header, data)}</th>`; }
      html += "<tr>";
    }
    for (var row of Array.from(data.rows)) {
      html += "<tr>";
      for (var cell of Array.from(row)) { html += `<td>${this.__parent.escape(cell, data)}</td>`; }
      html += "</tr>";
    }
    html += "</table>";
    html = $(html);
    if (data.interactive !== false) {
      html.delegate('td', 'mouseover mouseout', function() {
        const pos = $(this).index();
        return html.find(`td:nth-child(${(pos+1)})`).toggleClass("hover");
      });
    }
    return this.__parent.add(html, target, data);
  },

  focus(data) {
    return window.show();
  },

  close(data) {
    return window.close();
  },

  search(data) {
    if (window.find(data.text, 0, 0, 1)) {
      let anchor = window.getSelection().anchorNode;
      if (anchor.nodeType !== 1) { anchor = anchor.parentNode; }
      return anchor.scrollIntoView();
    }
  }
}
);
