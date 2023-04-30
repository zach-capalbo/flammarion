/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
class QueryString {

	constructor(queryString) {
		let key, ref, value;
		this.queryString = queryString;
		if (!this.queryString) { this.queryString = window.document.location.search != null ? window.document.location.search.substr(1) : undefined; }
		this.variables = this.queryString.split('&');
		this.pairs = (Array.from(this.variables).map((pair) => ([key, value] = Array.from(ref = pair.split('=')), ref)));
	}

	get(name) {
		for (var [key, value] of Array.from(this.pairs)) {
			if (key === name) { return value; }
		}
	}
}

window.$qs = new QueryString;
