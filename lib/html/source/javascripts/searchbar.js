/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
window.show_search_bar = function() {
  $('#searchbar').show();
  return $('#searchbar > input').focus();
};

$(document).ready(() => $('#searchbar > input').change(function() {
  const text = $('#searchbar > input')[0].value;
  $('#searchbar').hide();
  $('#searchbar > input')[0].value = "";
  console.log(`Searching ${text}`);
  if (window.find(text, 0, 0, 1)) {
    console.log(`Found ${text}`);
    let anchor = window.getSelection().anchorNode;
    if (anchor.nodeType !== 1) { anchor = anchor.parentNode; }
    anchor.focus();
    return anchor.scrollIntoView();
  } else {
    return alert(`Cannot find ${text}`);
  }
}));
    // $('#searchbar > input')[0].value = text
