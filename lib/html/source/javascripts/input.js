/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require websocket.coffee
$.extend(WSClient.prototype.actions, {
  button(data) {
    const target = this.__parent.check_target(data);
    const class_name = data.inline ? 'inline-button' : 'full-button';
    let left_icon = "";
    if (!data.right_icon) { data.right_icon = data.icon; }
    if (data.left_icon) {
      if (`:${data.left_icon}:` in emojione.emojioneList) {
        left_icon = "<i class='label-icon-left'>" + this.__parent.parse_emoji(`:${data.left_icon}:`) + "</i>";
      } else {
        left_icon = `<i class='fa fa-${data.left_icon} label-icon-left'></i>`;
      }
    }

    let right_icon = "";
    if (data.right_icon) {
      if (`:${data.right_icon}:` in emojione.emojioneList) {
        left_icon = "<i class='label-icon-right'>" + this.__parent.parse_emoji(`:${data.right_icon}:`) + "</i>";
      } else {
        right_icon = `<i class='fa fa-${data.right_icon} label-icon-right'></i>`;
      }
    }

    const element = $(`<a href='#' class='${class_name}'>${left_icon}${this.__parent.escape(data.label, data)}${right_icon}</a>`);
    element.click(() => {
      return this.__parent.send({
        id:data.id,
        action:'callback',
        source:'button',
        original_msg:data
        });
    });
    return target.append(element);
  },

  buttonbox(data) {
    const target = this.__parent.check_target(data);

    const element = target.find(`#console-${data.name}`);
    if (element.size() === 0) {
      return target.prepend(`<pre class='button-box' id='console-${data.name}'></pre>`);
    } else {
      return element.addClass('button-box');
    }
  },

  input(data) {
    let element;
    const target = this.__parent.check_target(data);
    if (data.multiline) {
      element = $(`<textarea placeholder='${data.label}' class='inline-text-input'></textarea>`);
    } else {
      const input_type = data.password ? 'password' : 'text';
      element = $(`<input type='${input_type}' placeholder='${data.label}' class='inline-text-input'>`);
    }
    if (data.value) {
      element[0].value = data.value;
    }

    const accept = data => {
      this.__parent.send({
        id:data.id,
        action:'callback',
        source:'input',
        text: element[0].value,
        original_msg:data
        });
      if (data.once) {
        let replaceText = this.__parent.escape(`${element[0].value}\n`);
        if (data.keep_label) { replaceText = `${data.label}${replaceText}`; }
        element.replaceWith(replaceText);
      }
      if (data.history) {
        const history = element.data('history') || [];
        history.push(element[0].value);
        element.data('history', history);
        element.data('history-index', history.length);
      }
      if (data.autoclear) {
        return element[0].value = "";
      }
    };

    element.change(() => {
      if (!element.hasClass("unclicked") && !data.enter_only) {
        return accept(data);
      }
    });

    const offset_history = (e, amt) => {
      const history = element.data('history') || [];
      const i = element.data('history-index') + amt;
      e.preventDefault();
      if ((i >= 0) && (i < history.length)) {
        element[0].value = history[i];
        return element.data('history-index', i);
      }
    };

    element.keydown(e => {
      if ((e.which === 38) && data.history) { offset_history(e, -1); }
      if ((e.which === 40) && data.history) { offset_history(e, +1); }
      if ((e.which === 13) && data.enter_only) {
        return accept(data);
      }
    });

    target.append(element);

    if (data.focus) {
      return element.focus();
    }
  },

  checkbox(data) {
    const target = this.__parent.check_target(data);
    const element = $(`<label class='inline-checkbox'><input type='checkbox'><span>${this.__parent.escape(data.label,data)}</span></label>'`);
    if (data.value) {
      element.find('input').attr("checked", true);
      element.addClass("checked");
    }
    element.change(e => {
      element.toggleClass("checked",  element.find('input').prop('checked'));
      return this.__parent.send({
        id:data.id,
        action:'callback',
        source:'input',
        checked: element.find('input').prop('checked'),
        original_msg:data
        });
    });
    element.click(e => {
      if (e.shiftKey && this.__lastChecked) {
        const all_boxes = $('.inline-checkbox');
        const start = all_boxes.index(this.__lastChecked);
        const stop = all_boxes.index(element);

        all_boxes.slice(Math.min(start, stop), Math.max(start, stop) + 1).find('input').prop("checked", this.__lastChecked.find('input').prop("checked"));
        return all_boxes.change();
      } else {
        return this.__lastChecked = element;
      }
    });
    return target.append(element);
  },

  dropdown(data) {
    const target = this.__parent.check_target(data);
    const element = $(`<select class='inline-dropdown' name='${data.id}'></select>`);
    if (data.options instanceof Array) {
      for (var item of Array.from(data.options)) { element.append($(`<option>${item}</option>`)); }
    } else {
      for (var k in data.options) {
        var v = data.options[k];
        var option = $(`<option>${k}</option>`);
        option.val(JSON.stringify(v));
        element.append(option);
      }
    }
    if (data.value) { element.val(data.value); }
    element.change(e => {
      let val = element.find('option:selected').text();
      if (element.find('option:selected')[0].value) {
        try {
          val = $.parseJSON(element.find('option:selected')[0].value);
        } catch (error) {
          val = element.find('option:selected')[0].value;
        }
      }
      return this.__parent.send({
        id:data.id,
        action:'callback',
        source:'dropdown',
        value: val,
        text: element.find('option:selected').text()
        });
    });
    return this.__parent.add(element, target, data);
  }
}
);
