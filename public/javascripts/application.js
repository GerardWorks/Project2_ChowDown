$(window).ready(function(){
  initiate_geolocation();
});

function initiate_geolocation() {
  navigator.geolocation.getCurrentPosition(handle_geolocation_query);
}

function handle_geolocation_query(position){
  var a = position.coords.latitude;
  var b = position.coords.longitude;
    $("#longlat").attr('value',a+" "+b);
    $("#button_ready").removeClass("btn-warning").addClass("btn-danger").text("I'm ready to Chow Down");
}
