/*
 j_controls - part of AtariVCSGML and works directly with the o_ControllerController example in the Readme.md

 Normally you would call gamepad_* functions in GML but these will fall back to those only when j_server() reveals no active connection to the Atari Classic compatibility server.
 So, replace "gamepad_button_check" with "j_button_check" and everything should work fine if you've got your server running, and if it is not running, will attempt the gamepad_button_check function instead.

 Additionally, some control simplification functions toward the end of the file that create the NES style "UP DOWN LEFT RIGHT AB" simple controls (usually used as a fallback for menu systems)

For Atari controllers, the following signals or axis mappings for buttons:

Modern:                    Classic:
                           
X: 10                      Left: 132
Y: 9                       Right: 130
A: 6                       Up: 129
B: 7                       Down: 131
D-Left: 132                Red: 6
D-Right: 130               Side: 7
D-Up: 129                  Back: 9
D-Down: 131                Menu: 10
L-Shoulder: 16             Fuji: 16
L-Trigger: 17
R-Shoulder: RH axis[2]
R-Trigger: axis[5] 
Back: 14
Menu: 15
Fuji: 13

See j_axis_value for axis mappings for the modern.

I do not recommend supporting anything other than the Atari Modern and Atari Classic on the VCS if you are using this method,
even though it is possible to plug in other types of controllers.  Since we are routing everything through Inputcandy it is
technically possible, but you will have to create a cheat sheet for each controller as seen above.  The only stretch goal
would be to add support for xbox controllers.

 */
  
 function vcs_atari() {
	 return os_get_config() == "VCS"; // must be atari VCS 800 then..
 }
 
 function j_server() {
	 return ( global.pad_server != noone and global.pad_data != false );
 }
 
 function j_get_device_count() { return j_device_count(); }
 function j_device_count() {
	 if ( j_server() ) return array_length(global.pad_data.d);
	 return gamepad_get_device_count();
 }
 
 function j_is_connected(gp) { return j_connected(gp); }
 function j_connected(gp) {
	 return gp >= 0 and gp < j_device_count();
 }

 function j_type(gp) {
	var name=j_name(gp);
	var guid=j_guid(gp);
	if ( string_pos("xinput",name) >= 1 ) return "xinput";
	if (name == "Classic Controller"
	 or name == "Atari Classic Controller"
	 or guid == "03000000503200000110000000000000"
	 or guid == "03000000503200000110000011010000"
	 or guid == "05000000503200000110000000000000"
	 or guid == "05000000503200000110000044010000"
	 or guid == "05000000503200000110000046010000"
	 or ( vcs_atari() and j_button_count(gp) == 5 and j_hat_count(gp) == 1 and j_axis_count(gp) == 1 )
	 ) return "classic";
   if ( name == "Atari Game Controller" 
	 or name == "Atari Controller"
	 or name == "Atari VCS Modern Controller"
	 or guid == "03000000503200000210000000000000"
	 or guid == "03000000503200000210000011010000"
	 or guid == "05000000503200000210000000000000"
	 or guid == "05000000503200000210000045010000"
	 or guid == "05000000503200000210000046010000"
	 or guid == "05000000503200000210000047010000"
	 or (vcs_atari() and ( j_button_count(gp) == 11 and j_hat_count(gp) == 1 and j_axis_count(gp) == 6 ) )
	 ) return "modern";
	 return "other"; // or unknown :(
 } 
 
 function j_signal( gp, num ) {
 	 if ( j_connected(gp) ) {
		 if ( j_server() ) {
			 for ( var i=0; i<array_length(global.pad_data.s[gp].signals); i++ )
			  if ( global.pad_data.s[gp].signals[i].signal_index == num ) return true;
		 }
	 }
	 return false;
 }
 
 function j_get_description(gp) { return j_name(gp); }
 function j_name(gp) {
	 if ( j_connected(gp) ) {
		 if ( j_server() ) return global.pad_data.d[gp].desc;
		 return gamepad_get_description(gp);
	 }
	 return "";
 }

 function j_get_guid(gp) { return j_guid(gp); } 
 function j_guid(gp) {
	 if ( j_connected(gp) ) {
		 if ( j_server() ) return global.pad_data.d[gp].guid;
		 return gamepad_get_guid(gp);
	 }
	 return "";
 }
  
 function j_button_count(gp) {
	 if ( j_connected(gp) ) {
		 if ( j_server() ) return global.pad_data.d[gp].button_count;
		 return gamepad_button_count(gp);
	 }
	 return 0;
 }
 
 function j_button_check(gp,h) {
	 if ( j_connected(gp) ) {
		 var vcs_signum=h;
		 var buttons=j_button_count(gp);
		 if ( h > buttons ) {
			 var classic=buttons == 5;
			 switch ( h ) {
				 case gp_face1: vcs_signum=6; break;
				 case gp_face2: vcs_signum=7; break;
				 case gp_face3: vcs_signum=classic?6:10; break;
				 case gp_face4: vcs_signum=classic?7:9; break;
				 case gp_padl: vcs_signum=132; break;
				 case gp_padr: vcs_signum=130; break;
				 case gp_padu: vcs_signum=129; break;
				 case gp_padd: vcs_signum=131; break;
				 case gp_shoulderl: vcs_signum=classic?6:16; break;
				 case gp_shoulderlb: vcs_signum=17; break;
				 case gp_shoulderr: return ( j_axis_value(gp,2) > 0.7 ); break;
				 case gp_shoulderrb: return ( j_axis_value(gp,5) > 0.7 ); break;
				 case gp_select: vcs_signum=classic?9:14; break;
				 case gp_start: vcs_signum=classic?10:15; break;
				 default: vcs_signum=0; break;
			 }
		 }
		 return ( j_signal(gp,vcs_signum) );
	 }
	 return false;
 }
 
 function j_button_value(gp,h) {
	 if ( j_connected(gp) and h>=0 and h < j_button_count(gp) ) {
		 if ( j_server() ) return global.pad_data.s[gp].buttons[h];
		 return gamepad_button_value(gp,h);
	 }
	 return 0;
 }
 
 function j_button(gp,h) {
	 if ( j_connected(gp) and h>=0 and h < j_button_count(gp) ) {
		 if ( j_server() ) return global.pad_data.s[gp].buttons[h] > 0;
		 return gamepad_button_value(gp,h) > 0;
	 }
	 return 0;
 }
 
 function j_hat_count(gp) {
	 if ( j_connected(gp) ) {
		 if ( j_server() ) return global.pad_data.d[gp].hat_count;
		 return gamepad_hat_count(gp);
	 }
	 return 0;
 } 
 
 function j_hat_value(gp,h) {
	 if ( j_connected(gp) and h >= 0 and h < j_hat_count(gp) ) {
		 if ( j_server() ) return global.pad_data.s[gp].hats[h];
		 return gamepad_hat_value(gp,h);
	 }
	 return 0;
 }
 
 function j_axis_count(gp) {
	 if ( j_connected(gp) ) {
		 if ( j_server() ) return global.pad_data.d[gp].axis_count;
		 return gamepad_axis_count(gp);
	 }
	 return 0;
 }
 
 function j_axis_value(gp,h) {
	 static nal= (os_type == os_windows ? 0 : 0.5);
	 if ( j_connected(gp) ) {
		 if ( j_server() ) {
			 var classic = j_button_count(gp) == 5;
			 if ( classic ) return nal;
			 switch ( h ) {
				 case gp_axislh: return global.pad_data.s[gp].axis[0];
				 case gp_axisrh: return global.pad_data.s[gp].axis[3];
				 case gp_axislv: return global.pad_data.s[gp].LV;
				 case gp_axisrv: return global.pad_data.s[gp].axis[4];
				 default:
				    if ( h>=0 and h < global.pad_data.d[gp].axis_count ) return global.pad_data.s[gp].axis[h];
					else return nal;
				  break;
			 }
		 }
		 return nal;
	 }
	 return nal;
 }
 
 function j_keyboard_check(key) {
	 if ( j_server() ) {
	 }
	 return keyboard_check(key);
 }

 function j_keyboard_check_released(key) {
	 if ( j_server() ) {
	 }
	 return keyboard_check_released(key);
 }
// Everything under here is specific to the actions of my game, which basically only has UP DOWN LEFT RIGHT A B SELECT START

function j_pressing_fuji(gp) {
	if ( j_server() ) {
		var t=j_type(gp);
		if ( t == "classic" ) {
			return j_signal(gp,16);
		} else if ( t == "modern" ) {
			return j_signal(gp,13);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else {
		// No equivalent, let's pick Select
		return gamepad_button_check(gp,gp_select);
	}
}

function j_pressing_start(gp) {
	if ( j_server() ) {
		var t=j_type(gp);
		if ( t == "classic" ) {
			return j_button(gp,3);
		} else if ( t == "modern" ) {
			return j_button(gp,7);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else {
		// No equivalent, let's pick Select
		return gamepad_button_check(gp,gp_start);
	}
}


function j_pressing_select(gp) {
	if ( j_server() ) {
		var t=j_type(gp);
		if ( t == "classic" ) {
			return j_button(gp,2);
		} else if ( t == "modern" ) {
			return j_button(gp,6);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else {
		// No equivalent, let's pick Select
		return gamepad_button_check(gp,gp_select);
	}
}

function j_pressing_A(gp) {
	if ( j_server() ) {
		var t=j_type(gp);
		if ( t == "classic" ) {
			return j_button(gp,0);
		} else if ( t == "modern" ) {
			return j_button(gp,0) or j_button(gp,2) or (j_axis_value(gp,2) > 0.7);
		} else if ( t == "xinput" ) {
			return j_button(gp,0) or j_button(gp,2);
		} else {
			return j_button(gp,0);
		}
	} 
}

function j_pressing_B(gp) {
	if ( j_server() ) { // on the VCS...
		var t=j_type(gp);
		if ( t == "classic" ) {
			return j_button(gp,1);
		} else if ( t == "modern" ) {
			return j_button(gp,1) or j_button(gp,3) or (j_axis_value(gp,5) > 0.7);
		} else if ( t == "xinput" ) {
			return j_button(gp,1) or j_button(gp,3);
		} else {
			return j_button(gp,1);
		}
	} else { // on windows...
		var gamepad_count=j_get_device_count();
		if ( gp+1 == 1 ) {
			  return keyboard_check(vk_lshift)
			   or keyboard_check(ord("X"))
			   or keyboard_check(ord("C"))
			   or (0 < gamepad_count
			    and (gamepad_button_check(0, gp_face2)
				  or gamepad_button_check(0, gp_face4)));
		} else if ( gp+1 == 2 ) {
			  return keyboard_check(vk_rshift)
			   or keyboard_check(vk_pageup)
			   or keyboard_check(vk_numpad5)
			   or (1 < gamepad_count
			    and (gamepad_button_check(1, gp_face2)
				  or gamepad_button_check(1, gp_face4)));
		} else {
			  return (gp < gamepad_count
			    and (gamepad_button_check(gp,gp_face2)
			      or gamepad_button_check(gp,gp_face4)));
		}		
	}
}
