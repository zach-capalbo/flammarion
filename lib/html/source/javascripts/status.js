/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
class StatusDisplay {
  static initClass() {
    this.prototype.status_history = [];
    this.prototype.waiting_statuses = [];
    this.prototype.max_statuses = 10;
  }
  constructor(ws, target) {
    this.ws = ws;
    this.target = target;
    this.target.click(() => {
      return this.show_history();
    });
  }

  show_status(data) {
    this.target.html(this.ws.escape(data.text, data));
    return this.status_history.push(data);
  }

  show_history() {
    console.log(this.status_history);
    const message = `<ul>${(Array.from(this.status_history).map((item) => `<li>${this.ws.escape(item.text, item)}</li>`)).join("\n")}</ul>`;
    $('#dialog > #content > #message').html(message);
    $('#dialog').show();
    return $('#dialog > #content > #ok').click(() => $('#dialog').hide());
  }
}
StatusDisplay.initClass();

window.StatusDisplay = StatusDisplay;
