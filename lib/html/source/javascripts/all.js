//= require vendor/jquery.js
//= require_tree ./vendor
//= require websocket.js
//= require_tree .
import './vendor/ansi_up.js'
import {emojione} from './vendor/emojione.js'
globalThis.emojione = emojione;
// import './vendor/emojione.min.js'
import './vendor/highlight.pack.js'
// import './vendor/jquery.js'
// import './vendor/jquery.transit.min.js'
// import './vendor/l.control.geosearch.js'
// import './vendor/l.geosearch.provider.openstreetmap.js'
// import './vendor/leaflet.js'
import './vendor/plotly.min.js'
// import './vendor/term.js'
import {twemoji} from './vendor/twemoji.min.js'
globalThis.twemoji = twemoji;

import './websocket.js'
import './actions.js'
import './electron_extensions.js'
import './fontawesome.js'
import './input.js'
import './map.js'
import './plot.js'
import './querystring.js'
import './searchbar.js'
import './status.js'

console.log("Flammarion UI Started")