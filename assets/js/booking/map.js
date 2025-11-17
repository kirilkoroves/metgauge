function initMap() {
  // [START maps_add_map_instantiate_map]
  // The location of Uluru
  // The map, centered at Uluru
  const map = new google.maps.Map(document.getElementById("map"), {
    zoom: 16,
    center: window.google_location,
  });
  // [END maps_add_map_instantiate_map]
  // [START maps_add_map_instantiate_marker]
  // The marker, positioned at Uluru
  const marker = new google.maps.Marker({
    position: window.google_location,
    map: map,
  });
  // [END maps_add_map_instantiate_marker]
}

window.initMap = initMap;