/*
 j_controls - part of AtariVCSGML and works directly with the o_ControllerController example in the Readme.md

 Normally you would call gamepad_* functions in GML but these will fall back to those only when j_server() reveals no active connection to the Atari Classic compatibility server.
 So, replace "gamepad_button_check" with "j_button_check" and everything should work fine if you've got your server running, and if it is not running, will attempt the gamepad_button_check function instead.

 Additionally, some control simplification functions toward the end of the file that create the NES style "UP DOWN LEFT RIGHT AB" simple controls (usually used as a fallback for menu systems)
 */
  
 function vcs_atari() {
	 return os_get_config() == "VCS" and os_type == os_linux; // must be atari VCS 800 then..
 }
 
 function j_server() {
	 return ( global.pad_server != noone and global.pad_data != false );
 }
 
 function j_get_device_count() { return j_device_count(); }
 function j_device_count() {
	 if ( j_server() ) return array_length(global.pad_data.d);
	 return gamepad_get_device_count();
 }
 
 function j_is_connected(pn) { return j_connected(pn); }
 function j_connected(pn) {
	 var dv=pn-1;
	 return dv >= 0 and dv < j_device_count();
 }

 function j_type(pn) {
	var name=j_name(pn);
	var guid=j_guid(pn);
	if ( string_pos("xinput",name) >= 1 ) return "xinput";
	if (name == "Classic Controller"
	 or name == "Atari Classic Controller"
	 or guid == "03000000503200000110000000000000"
	 or guid == "03000000503200000110000011010000"
	 or guid == "05000000503200000110000000000000"
	 or guid == "05000000503200000110000044010000"
	 or guid == "05000000503200000110000046010000"
	 or ( vcs_atari() and j_button_count(pn) == 5 and j_hat_count(pn) == 1 and j_axis_count(pn) == 1 )
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
	 or (vcs_atari() and ( j_button_count(pn) == 11 and j_hat_count(pn) == 1 and j_axis_count(pn) == 6 ) )
	 ) return "modern";
	 return "other"; // or unknown :(
 } 
 
 function j_get_description(pn) { return j_name(pn); }
 function j_name(pn) {
	 if ( j_connected(pn) ) {
		 if ( j_server() ) return global.pad_data.d[pn-1].desc;
		 return gamepad_get_description(pn-1);
	 }
	 return "";
 }

 function j_get_guid(pn) { return j_get_guid(pn); } 
 function j_guid(pn) {
	 if ( j_connected(pn) ) {
		 if ( j_server() ) return global.pad_data.d[pn-1].guid;
		 return gamepad_get_guid(pn-1);
	 }
	 return "";
 }
  
 function j_button_count(pn) {
	 if ( j_connected(pn) ) {
		 if ( j_server() ) return global.pad_data.d[pn-1].button_count;
		 return gamepad_button_count(pn-1);
	 }
	 return 0;
 }
 
 function j_button_check(pn,h) {
	 if ( j_connected(pn) and h>=0 and h < j_button_count(pn) ) {
		 if ( j_server() ) return global.pad_data.s[pn-1].buttons[h];
		 return gamepad_button_check(pn-1,h);
	 }
	 return 0;
 }
 
 function j_button_value(pn,h) {
	 if ( j_connected(pn) and h>=0 and h < j_button_count(pn) ) {
		 if ( j_server() ) return global.pad_data.s[pn-1].buttons[h];
		 return gamepad_button_value(pn-1,h);
	 }
	 return 0;
 }
 
 function j_button(pn,h) {
	 if ( j_connected(pn) and h>=0 and h < j_button_count(pn) ) {
		 if ( j_server() ) return global.pad_data.s[pn-1].buttons[h] > 0;
		 return gamepad_button_value(pn-1,h) > 0;
	 }
	 return 0;
 }
 
 function j_hat_count(pn) {
	 if ( j_connected(pn) ) {
		 if ( j_server() ) return global.pad_data.d[pn-1].hat_count;
		 return gamepad_hat_count(pn-1);
	 }
	 return 0;
 } 
 
 function j_hat_value(pn,h) {
	 if ( j_connected(pn) and h >= 0 and h < j_hat_count(pn) ) {
		 if ( j_server() ) return global.pad_data.s[pn-1].hats[h];
		 return gamepad_hat_value(pn-1,h);
	 }
	 return 0;
 }
 
 function j_axis_count(pn) {
	 if ( j_connected(pn) ) {
		 if ( j_server() ) return global.pad_data.d[pn-1].axis_count;
		 return gamepad_axis_count(pn-1);
	 }
	 return 0;
 }
 
 function j_axis_value(pn,h) {
	 if ( j_connected(pn) and h < j_axis_count(pn) ) {
		 if ( j_server() ) return global.pad_data.s[pn-1].axis[h];
		 return gamepad_axis_value(pn-1,h);
	 }
	 return 0;
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

function j_pressing_left(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return (j_hat_value(pn,0) & 8);
		} else if ( t == "modern" ) {
			return (j_hat_value(pn,0) & 8)
				or (j_axis_value(pn,0) < 0.3)
				or (j_axis_value(pn,3) < 0.3);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else return ControlsGetLeft(pn);
}

function j_pressing_right(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return (j_hat_value(pn,0) & 2);
		} else if ( t == "modern" ) {
			return (j_hat_value(pn,0) & 2)
				or (j_axis_value(pn,0) > 0.7)
				or (j_axis_value(pn,3) > 0.7);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else return ControlsGetRight(pn);
}
function j_pressing_up(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return (j_hat_value(pn,0) & 1);
		} else if ( t == "modern" ) {
			return (j_hat_value(pn,0) & 1)
				or (j_axis_value(pn,1) < 0.3)
				or (j_axis_value(pn,4) < 0.3);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else return ControlsGetUp(pn);
}
 
function j_pressing_down(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return (j_hat_value(pn,0) & 4);
		} else if ( t == "modern" ) {
			return (j_hat_value(pn,0) & 4)
				or (j_axis_value(pn,1) > 0.7)
				or (j_axis_value(pn,4) > 0.7);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else return ControlsGetDown(pn);
}

function j_pressing_fuji(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return j_button(pn,4);
		} else if ( t == "modern" ) {
			return j_button(pn,8);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else {
		// No equivalent, let's pick Select
		return gamepad_button_check(pn-1,gp_select);
	}
}

function j_pressing_start(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return j_button(pn,3);
		} else if ( t == "modern" ) {
			return j_button(pn,7);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else {
		// No equivalent, let's pick Select
		return gamepad_button_check(pn-1,gp_start);
	}
}


function j_pressing_select(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return j_button(pn,2);
		} else if ( t == "modern" ) {
			return j_button(pn,6);
		} else if ( t == "xinput" ) {
		} else {
		}
	} else {
		// No equivalent, let's pick Select
		return gamepad_button_check(pn-1,gp_select);
	}
}

function j_pressing_A(pn) {
	if ( j_server() ) {
		var t=j_type(pn);
		if ( t == "classic" ) {
			return j_button(pn,0);
		} else if ( t == "modern" ) {
			return j_button(pn,0) or j_button(pn,2) or (j_axis_value(pn,2) > 0.7);
		} else if ( t == "xinput" ) {
			return j_button(pn,0) or j_button(pn,2);
		} else {
			return j_button(pn,0);
		}
	} else {
		if ( pn == 1 ) {			
			return keyboard_check(vk_lcontrol)
			 or keyboard_check(vk_space)
			 or keyboard_check(vk_lalt)
			 or (gamepad_get_device_count() > 0
			  and (gamepad_button_check(0,gp_face1)
			    or gamepad_button_check(0,gp_shoulderlb)
			    or gamepad_button_check(0,gp_shoulderrb)
			    or gamepad_button_check(0,gp_shoulderl)
			    or gamepad_button_check(0,gp_shoulderr)
			    or gamepad_button_check(0,gp_face3)));
		} else if ( pn == 2 ) {
			return keyboard_check(vk_rcontrol)
			 or keyboard_check(vk_ralt)
			 or keyboard_check(vk_pagedown)
			 or keyboard_check(vk_enter)
			 or (gamepad_get_device_count() > 1
			  and (gamepad_button_check(1,gp_face1)
			    or gamepad_button_check(1,gp_shoulderlb)
			    or gamepad_button_check(1,gp_shoulderrb)
			    or gamepad_button_check(1,gp_shoulderl)
			    or gamepad_button_check(1,gp_shoulderr)
			    or gamepad_button_check(1,gp_face3)));
		} else {
			return (gamepad_get_device_count() > pn-1
			  and (gamepad_button_check(pn-1,gp_face1)
			    or gamepad_button_check(pn-1,gp_shoulderlb)
			    or gamepad_button_check(pn-1,gp_shoulderrb)
			    or gamepad_button_check(pn-1,gp_shoulderl)
			    or gamepad_button_check(pn-1,gp_shoulderr)
			    or gamepad_button_check(pn-1,gp_face3)));
		}
	}
}

function j_pressing_B(pn) {
	if ( j_server() ) { // on the VCS...
		var t=j_type(pn);
		if ( t == "classic" ) {
			return j_button(pn,1);
		} else if ( t == "modern" ) {
			return j_button(pn,1) or j_button(pn,3) or (j_axis_value(pn,5) > 0.7);
		} else if ( t == "xinput" ) {
			return j_button(pn,1) or j_button(pn,3);
		} else {
			return j_button(pn,1);
		}
	} else { // on windows...
		var gamepad_count=gamepad_get_device_count();
		if ( pn == 1 ) {
			  return keyboard_check(vk_lshift)
			   or keyboard_check(ord("X"))
			   or keyboard_check(ord("C"))
			   or (0 < gamepad_count
			    and (gamepad_button_check(0, gp_face2)
				  or gamepad_button_check(0, gp_face4)));
		} else if ( pn == 2 ) {
			  return keyboard_check(vk_rshift)
			   or keyboard_check(vk_pageup)
			   or keyboard_check(vk_numpad5)
			   or (1 < gamepad_count
			    and (gamepad_button_check(1, gp_face2)
				  or gamepad_button_check(1, gp_face4)));
		} else {
			  return (pn-1 < gamepad_count
			    and (gamepad_button_check(pn-1,gp_face2)
			      or gamepad_button_check(pn-1,gp_face4)));
		}		
	}
}


 
function ControlsGetLeft( player_number ) {
	var gamepad_count=gamepad_get_device_count();
	var gamepads=[];
	var j=0;
	for ( var i=0; i<gamepad_count; i++ ) {
		if ( gamepad_is_connected(i) ) {
			gamepads[j]=i;
			j++;
		}
	}
	gamepad_count = array_length(gamepads);
	if ( player_number == 1 ) {
		  return keyboard_check(vk_left)
		   or keyboard_check(ord("A"))
		   or (0 < gamepad_count and ((gamepad_axis_value(gamepads[0], gp_axislh) < -0.5)
		       or gamepad_button_check(gamepads[0], gp_padl)
			   or (gamepad_hat_count(gamepads[0])>0 and (gamepad_hat_value(gamepads[0],0)&8))
			   or (gamepad_hat_count(gamepads[0])>1 and gamepad_hat_value(gamepads[0],1)&8)));
	} else if ( player_number == 2 ) {
		  return keyboard_check(vk_numpad4)
		   or keyboard_check(ord("J"))
		   or (1 < gamepad_count and ((gamepad_axis_value(gamepads[1], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[1], gp_padl)
			   or (gamepad_hat_count(gamepads[1])>0 and gamepad_hat_value(gamepads[1],0)&8)
			   or (gamepad_hat_count(gamepads[1])>1 and gamepad_hat_value(gamepads[1],1)&8)));
	} else if ( player_number == 3 ) {
		  return (2 < gamepad_count and ((gamepad_axis_value(gamepads[2], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[2], gp_padl)
			   or (gamepad_hat_count(gamepads[2])>0 and gamepad_hat_value(gamepads[2],0)&8)
			   or (gamepad_hat_count(gamepads[2])>1 and gamepad_hat_value(gamepads[2],1)&8)));
	} else if ( player_number == 4 ) {
		  return (3 < gamepad_count and ((gamepad_axis_value(gamepads[3], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[3], gp_padl)
			   or (gamepad_hat_count(gamepads[3])>0 and gamepad_hat_value(gamepads[3],0)&8)
			   or (gamepad_hat_count(gamepads[3])>1 and gamepad_hat_value(gamepads[3],1)&8)));
	} else if ( player_number == 5 ) {
		  return (4 < gamepad_count and ((gamepad_axis_value(gamepads[4], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[4], gp_padl)
			   or (gamepad_hat_count(gamepads[4])>0 and gamepad_hat_value(gamepads[4],0)&8)
			   or (gamepad_hat_count(gamepads[4])>1 and gamepad_hat_value(gamepads[4],1)&8)));
	} else if ( player_number == 6 ) {
		  return (5 < gamepad_count and ((gamepad_axis_value(gamepads[5], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[5], gp_padl)
			   or (gamepad_hat_count(gamepads[5])>0 and gamepad_hat_value(gamepads[5],0)&8)
			   or (gamepad_hat_count(gamepads[5])>1 and gamepad_hat_value(gamepads[5],1)&8)));
	} else if ( player_number == 7 ) {
		  return (6 < gamepad_count and ((gamepad_axis_value(gamepads[6], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[6], gp_padl)
			   or (gamepad_hat_count(gamepads[6])>0 and gamepad_hat_value(gamepads[6],0)&8)
			   or (gamepad_hat_count(gamepads[6])>1 and gamepad_hat_value(gamepads[6],1)&8)));
	} else if ( player_number == 8 ) {
		  return (7 < gamepad_count and ((gamepad_axis_value(gamepads[7], gp_axislh) < -0.5)
			   or gamepad_button_check(gamepads[7], gp_padl)
			   or (gamepad_hat_count(gamepads[7])>0 and gamepad_hat_value(gamepads[7],0)&8)
			   or (gamepad_hat_count(gamepads[7])>1 and gamepad_hat_value(gamepads[7],1)&8)));
	}
}

function ControlsGetRight( player_number ) {
	var gamepad_count=gamepad_get_device_count();
	var gamepads=[];
	var j=0;
	for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
	gamepad_count = array_length(gamepads);
	if ( player_number == 1 ) {
		  return keyboard_check(vk_right)
		   or keyboard_check(ord("D"))
		   or (0 < gamepad_count and ((gamepad_axis_value(gamepads[0], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[0], gp_padr)
			   or (gamepad_hat_count(gamepads[0])>0 and gamepad_hat_value(gamepads[0],0)&2)
			   or (gamepad_hat_count(gamepads[0])>1 and gamepad_hat_value(gamepads[0],1)&2)));
	} else if ( player_number == 2 ) {
		  return keyboard_check(vk_numpad6)
		   or keyboard_check(ord("L"))
		   or (1 < gamepad_count and ((gamepad_axis_value(gamepads[1], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[1], gp_padr)
			   or (gamepad_hat_count(gamepads[1])>0 and gamepad_hat_value(gamepads[1],0)&2)
			   or (gamepad_hat_count(gamepads[1])>1 and gamepad_hat_value(gamepads[1],1)&2)));
	} else if ( player_number == 3 ) {
		return (2 < gamepad_count and ((gamepad_axis_value(gamepads[2], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[2], gp_padr)
			   or (gamepad_hat_count(gamepads[2])>0 and gamepad_hat_value(gamepads[2],0)&2)
			   or (gamepad_hat_count(gamepads[2])>1 and gamepad_hat_value(gamepads[2],1)&2)));
	} else if ( player_number == 4 ) {
		return (3 < gamepad_count and ((gamepad_axis_value(gamepads[3], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[3], gp_padr)
			   or (gamepad_hat_count(gamepads[3])>0 and gamepad_hat_value(gamepads[3],0)&2)
			   or (gamepad_hat_count(gamepads[3])>1 and gamepad_hat_value(gamepads[3],1)&2)));
	} else if ( player_number == 5 ) {
		return (4 < gamepad_count and ((gamepad_axis_value(gamepads[4], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[4], gp_padr)
			   or (gamepad_hat_count(gamepads[4])>0 and gamepad_hat_value(gamepads[4],0)&2)
			   or (gamepad_hat_count(gamepads[4])>1 and gamepad_hat_value(gamepads[4],1)&2)));
	} else if ( player_number == 6 ) {
		return (5 < gamepad_count and ((gamepad_axis_value(gamepads[5], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[5], gp_padr)
			   or (gamepad_hat_count(gamepads[5])>0 and gamepad_hat_value(gamepads[5],0)&2)
			   or (gamepad_hat_count(gamepads[5])>1 and gamepad_hat_value(gamepads[5],1)&2)));
	} else if ( player_number == 7 ) {
		return (6 < gamepad_count and ((gamepad_axis_value(gamepads[6], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[6], gp_padr)
			   or (gamepad_hat_count(gamepads[6])>0 and gamepad_hat_value(gamepads[6],0)&2)
			   or (gamepad_hat_count(gamepads[6])>1 and gamepad_hat_value(gamepads[6],1)&2)));
	} else if ( player_number == 8 ) {
		return (7 < gamepad_count and ((gamepad_axis_value(gamepads[7], gp_axislh) > 0.5)
			   or gamepad_button_check(gamepads[7], gp_padr)
			   or (gamepad_hat_count(gamepads[7])>0 and gamepad_hat_value(gamepads[7],0)&2)
			   or (gamepad_hat_count(gamepads[7])>1 and gamepad_hat_value(gamepads[7],1)&2)));
	}
}

function ControlsGetUp( player_number ) {
	var gamepad_count=gamepad_get_device_count();
	var gamepads=[];
	var j=0;
	for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
	gamepad_count = array_length(gamepads);
	if ( player_number == 1 ) {
		  return keyboard_check(vk_up)
		   or keyboard_check(ord("W"))
		   or (0 < gamepad_count and ((gamepad_axis_value(gamepads[0], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[0], gp_padu)
			   or (gamepad_hat_count(gamepads[0])>0 and gamepad_hat_value(gamepads[0],0)&1)
			   or (gamepad_hat_count(gamepads[0])>1 and gamepad_hat_value(gamepads[0],1)&1)));
	} else if ( player_number == 2 ) {
		  return keyboard_check(vk_numpad8)
		   or keyboard_check(ord("I"))
		   or (1 < gamepad_count and ((gamepad_axis_value(gamepads[1], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[1], gp_padu)
			   or (gamepad_hat_count(gamepads[1])>0 and gamepad_hat_value(gamepads[1],0)&1)
			   or (gamepad_hat_count(gamepads[1])>1 and gamepad_hat_value(gamepads[1],1)&1)));
	} else if ( player_number == 3 ) {
		   return (2 < gamepad_count and ((gamepad_axis_value(gamepads[2], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[2], gp_padu)
			   or (gamepad_hat_count(gamepads[2])>0 and gamepad_hat_value(gamepads[2],0)&1)
			   or (gamepad_hat_count(gamepads[2])>1 and gamepad_hat_value(gamepads[2],1)&1)));
	} else if ( player_number == 4 ) {
		   return (3 < gamepad_count and ((gamepad_axis_value(gamepads[3], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[3], gp_padu)
			   or (gamepad_hat_count(gamepads[3])>0 and gamepad_hat_value(gamepads[3],0)&1)
			   or (gamepad_hat_count(gamepads[3])>1 and gamepad_hat_value(gamepads[3],1)&1)));
	} else if ( player_number == 5 ) {
		   return (4 < gamepad_count and ((gamepad_axis_value(gamepads[4], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[4], gp_padu)
			   or (gamepad_hat_count(gamepads[4])>0 and gamepad_hat_value(gamepads[4],0)&1)
			   or (gamepad_hat_count(gamepads[4])>1 and gamepad_hat_value(gamepads[4],1)&1)));
	} else if ( player_number == 6 ) {
		   return (5 < gamepad_count and ((gamepad_axis_value(gamepads[5], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[5], gp_padu)
			   or (gamepad_hat_count(gamepads[5])>0 and gamepad_hat_value(gamepads[5],0)&1)
			   or (gamepad_hat_count(gamepads[5])>1 and gamepad_hat_value(gamepads[5],1)&1)));
	} else if ( player_number == 7 ) {
		   return (6 < gamepad_count and ((gamepad_axis_value(gamepads[6], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[6], gp_padu)
			   or (gamepad_hat_count(gamepads[6])>0 and gamepad_hat_value(gamepads[6],0)&1)
			   or (gamepad_hat_count(gamepads[6])>1 and gamepad_hat_value(gamepads[6],1)&1)));
	} else if ( player_number == 8 ) {
		   return (7 < gamepad_count and ((gamepad_axis_value(gamepads[7], gp_axislv) > 0.5)
			   or gamepad_button_check(gamepads[7], gp_padu)
			   or (gamepad_hat_count(gamepads[7])>0 and gamepad_hat_value(gamepads[7],0)&1)
			   or (gamepad_hat_count(gamepads[7])>1 and gamepad_hat_value(gamepads[7],1)&1)));
	}
}

function ControlsGetDown( player_number ) {
	var gamepad_count=gamepad_get_device_count();
	var gamepads=[];
	var j=0;
	for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
	gamepad_count = array_length(gamepads);
	if ( player_number == 1 ) {
		  return keyboard_check(vk_down)
		   or keyboard_check(ord("S"))
		   or (0 < gamepad_count and ((gamepad_axis_value(gamepads[0], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[0], gp_padd)
			   or (gamepad_hat_count(gamepads[0])>0 and gamepad_hat_value(gamepads[0],0)&4)
			   or (gamepad_hat_count(gamepads[0])>1 and gamepad_hat_value(gamepads[0],1)&4)));
	} else if ( player_number == 2 ) {
		  return keyboard_check(vk_numpad2)
		   or keyboard_check(ord("K"))
		   or (1 < gamepad_count and ((gamepad_axis_value(gamepads[1], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[1], gp_padd)
			   or (gamepad_hat_count(gamepads[1])>0 and gamepad_hat_value(gamepads[1],0)&4)
			   or (gamepad_hat_count(gamepads[1])>1 and gamepad_hat_value(gamepads[1],1)&4)));
	} else if ( player_number == 3 ) {
		   return (2 < gamepad_count and ((gamepad_axis_value(gamepads[2], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[2], gp_padd)
			   or (gamepad_hat_count(gamepads[2])>0 and gamepad_hat_value(gamepads[2],0)&4)
			   or (gamepad_hat_count(gamepads[2])>1 and gamepad_hat_value(gamepads[2],1)&4)));
	} else if ( player_number == 4 ) {
		   return (3 < gamepad_count and ((gamepad_axis_value(gamepads[3], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[3], gp_padd)
			   or (gamepad_hat_count(gamepads[3])>0 and gamepad_hat_value(gamepads[3],0)&4)
			   or (gamepad_hat_count(gamepads[3])>1 and gamepad_hat_value(gamepads[3],1)&4)));
	} else if ( player_number == 5 ) {
		   return (4 < gamepad_count and ((gamepad_axis_value(gamepads[4], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[4], gp_padd)
			   or (gamepad_hat_count(gamepads[4])>0 and gamepad_hat_value(gamepads[4],0)&4)
			   or (gamepad_hat_count(gamepads[4])>1 and gamepad_hat_value(gamepads[4],1)&4)));
	} else if ( player_number == 6 ) {
		   return (5 < gamepad_count and ((gamepad_axis_value(gamepads[5], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[5], gp_padd)
			   or (gamepad_hat_count(gamepads[5])>0 and gamepad_hat_value(gamepads[5],0)&4)
			   or (gamepad_hat_count(gamepads[5])>1 and gamepad_hat_value(gamepads[5],1)&4)));
	} else if ( player_number == 7 ) {
		   return (6 < gamepad_count and ((gamepad_axis_value(gamepads[6], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[6], gp_padd)
			   or (gamepad_hat_count(gamepads[6])>0 and gamepad_hat_value(gamepads[6],0)&4)
			   or (gamepad_hat_count(gamepads[6])>1 and gamepad_hat_value(gamepads[6],1)&4)));
	} else if ( player_number == 8 ) {
		   return (7 < gamepad_count and ((gamepad_axis_value(gamepads[7], gp_axislv) < -0.5)
			   or gamepad_button_check(gamepads[7], gp_padd)
			   or (gamepad_hat_count(gamepads[7])>0 and gamepad_hat_value(gamepads[7],0)&4)
			   or (gamepad_hat_count(gamepads[7])>1 and gamepad_hat_value(gamepads[7],1)&4)));
	}
}
