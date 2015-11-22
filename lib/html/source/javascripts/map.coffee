#= require websocket.coffee
__geosearch = null
$.extend WSClient.prototype.actions,
  map: (data) ->
    default_options =
      latitude: 51.505
      longitude: -0.09
      zoom: 13
      marker: true
      replace: true

    options = $.extend default_options, data

    if options.address
      __geosearch ||= new L.GeoSearch.Provider.OpenStreetMap()
      url = __geosearch.GetServiceUrl(options.address)
      $.getJSON url, (json) =>
        console.log(json)
        options.latitude = json[0].lat
        options.longitude = json[0].lon
        options.address = null
        @map(options)
      return

    target = @__parent.check_target(data)
    mapDiv = $('<div id="map" class="map"></div>')
    @__parent.add(mapDiv, target, data)
    mapDiv.height target.height()
    $(window).resize ->
      mapDiv.height target.height()

    latitude = options.latitude
    longitude = options.longitude

    map = L.map('map', {center: [latitude, longitude], zoom: options.zoom})
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        maxZoom: 19,
        subdomans: ["a.tile", "b.tile", "c.tile"]
    }).addTo(map);

    L.Icon.Default.imagePath = "/images"
    L.marker([latitude, longitude]).addTo(map) if options.marker
