/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require websocket.coffee
let __geosearch = null;
$.extend(WSClient.prototype.actions, {
  map(data) {
    const default_options = {
      latitude: 51.505,
      longitude: -0.09,
      zoom: 13,
      marker: true,
      replace: true
    };

    const options = $.extend(default_options, data);

    if (options.address) {
      if (!__geosearch) { __geosearch = new L.GeoSearch.Provider.OpenStreetMap(); }
      const url = __geosearch.GetServiceUrl(options.address);
      $.getJSON(url, json => {
        console.log(json);
        options.latitude = json[0].lat;
        options.longitude = json[0].lon;
        options.address = null;
        return this.map(options);
      });
      return;
    }

    const target = this.__parent.check_target(data);
    const mapDiv = $('<div id="map" class="map"></div>');
    this.__parent.add(mapDiv, target, data);
    mapDiv.height(target.height());
    $(window).resize(() => mapDiv.height(target.height()));

    const {
      latitude
    } = options;
    const {
      longitude
    } = options;

    const map = L.map('map', {center: [latitude, longitude], zoom: options.zoom});
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 19,
        subdomans: ["a.tile", "b.tile", "c.tile"]
    }).addTo(map);

    L.Icon.Default.imagePath = "/images";
    if (options.marker) { return L.marker([latitude, longitude]).addTo(map); }
  }
}
);
