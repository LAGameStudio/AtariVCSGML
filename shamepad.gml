/* this file contains GML code that wraps InputCandy + AtariVCS Gamepad Server 
 so that you can call these functions 1:1 with gamepad_* functions in GML.
 It was written by Lost Astronaut Studios for Shiphaven Games (thus SH-amepad)
 InputCandy must be initialized before calling any of these functions.
 */

function pad_server_active(idx=none) {
  if ( !variable_global_exists("pad_server") ) return false;
  if ( !is_struct(global.pad_server) ) return false;
  if ( idx == none ) return true;
  if ( idx < array_length(global.pad_server.d) ) return true;
}

function ic_active(idx=none) {
  if ( idx < array_length(__INPUTCANDY.devices) ) return true;
  return false;
}

//gamepad_is_supported
function shamepad_is_supported() { return true; }
//gamepad_is_connected
function shamepad_is_connected(pn) {
 var pi=pn-1;
 if ( pad_server_active(pi) ) return true;
 if ( ic_active(pi) ) return true;
 return false;
} 
//gamepad_get_guid
function shamepad_get_guid(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].guid;
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].guid;
  return "none";
}
//gamepad_get_device_count
function shamepad_get_device_count() {
   if ( pad_server_active() ) return array_length(global.pad_server.d);
   return array_length(__INPUTCANDY.devices);   
}
//gamepad_get_description
function shamepad_get_description(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].desc;
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].desc;
  return "none";
}
//gamepad_get_button_threshold 
function shamepad_get_button_threshold(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].button_thresholds[0];
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].button_thresholds[0];
  return 0.5;
}
//gamepad_get_axis_deadzone
function shamepad_get_axis_deadzone(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].axis_deadzones[0];
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].axis_deadzones[0];
  return 0.1;
}
//gamepad_get_option - not supported because its for iOS only
//gamepad_set_button_threshold - cannot be supported over network
//gamepad_set_axis_deadzone - cannot be supported over network
//gamepad_set_vibration - cannot be supported over network
//gamepad_set_colour - cannot be supported over network
//gamepad_set_option - cannot be supported over network
//gamepad_axis_count
function shamepad_get_axis_count(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].axis_count;
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].axis_count;
  return 0.1;
}
//gamepad_axis_value
function shamepad_axis_value(pn,a) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) {
    if ( a == gp_axislh ) {
    } else if ( a == gp_axislv ) {
    } else if ( a == gp_axisrh ) {
    } else if ( a == gp_axisrv ) {
    } else if ( a>=0 and a < global.pad_server.d[pi].axis_count ) {
      return global.pad_server.s[pi].axis[a];
    } else return 0;
  }
  if ( !ic_active(pi) ) return 0;
  if ( a == gp_axislh ) {
  } else if ( a == gp_axislv ) {
  } else if ( a == gp_axisrh ) {
  } else if ( a == gp_axisrv ) {
  } else if ( a>=0 and a < global.pad_server.d[pi].axis_count ) {
    return __INPUTCANDY.states[pi].axis[a];
  } else return 0;
}
//gamepad_button_check
function shamepad_button_check(pn,b,threshold=0.5) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) {
    if ( global.pad_server.s[pi].button
  }
  if ( !ic_active(pi) ) return 0;
}
//gamepad_button_check_pressed
//gamepad_button_check_released
//gamepad_button_count
function shamepad_get_button_count(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].button_count;
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].button_count;
  return 0.1;
}
//gamepad_button_value
//gamepad_hat_count
function shamepad_get_hat_count(pn) {
  var pi=pn-1;
  if ( pad_server_active(pi) ) return global.pad_server.d[pi].hat_count;
  if ( ic_active(pi) ) return __INPUTCANDY.devices[pi].hat_count;
  return 0.1;
}
//gamepad_hat_value
 
