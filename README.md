# AtariVCS GML
Contains code to help GameMaker developers write code for Atari VCS controllers on the Atari VCS

For reference only, Lost Astronaut Studios is providing its player code, based on the InputCandy library, which is a GML language library written by Lost Astronaut Studios for GameMaker 2.3.x and beyond, for all platforms that use a physical controller, keyboard and/or mouse: https://github.com/LAGameStudio/InputCandy

The following code is used for “Apolune 2” player controls.  Apolune 2, available in the VCS Store, supports up to 8 players, tested by attaching a hub and many third-party generic controllers.  A great way to thank Lost Astronaut Studios is to buy a copy of this game.

Example for Multiplayer, One Player's Step
==========================================

Apolune 2 controller code for o_PlayerX object (called in Step, one object per active player):

```
if ( global.game_is_paused ) return;

heartbeat+=global.dt;

var devices = controls.devices();
var player_using_classic = false;
var player_using_modern = false;
var isPressingA=false;
var isPressingB=false;
var isReleasedPause=false;
var pressingLeft=false, pressingRight=false;

var dn=player_number-1;
var dv=dn;

if ( dn < devices.count ) {
 dv=devices.gamepads[dn];
}

if ( dn < devices.count ) {
	if ( devices.gamepad_names[dn] == "Classic Controller"
	 || devices.gamepad_names[dn] == "Atari Classic Controller"
	 || devices.gamepad_guids[dn] == "03000000503200000110000000000000"
	 || devices.gamepad_guids[dn] == "03000000503200000110000011010000"
	 || devices.gamepad_guids[dn] == "05000000503200000110000000000000"
	 || devices.gamepad_guids[dn] == "05000000503200000110000044010000"
	 || devices.gamepad_guids[dn] == "05000000503200000110000046010000"
	 || ( gamepad_button_count(dv) == 5 && gamepad_hat_count(dv) == 1 && gamepad_axis_count(dv) == 1 ) ) player_using_classic = true;
	else if ( devices.gamepad_names[dn] == "Atari Game Controller" 
	 || devices.gamepad_names[dn] == "Atari Controller"
	 || devices.gamepad_names[dn] == "Atari VCS Modern Controller"
	 || devices.gamepad_guids[dn] == "03000000503200000210000000000000"
	 || devices.gamepad_guids[dn] == "03000000503200000210000011010000"
	 || devices.gamepad_guids[dn] == "05000000503200000210000000000000"
	 || devices.gamepad_guids[dn] == "05000000503200000210000045010000"
	 || devices.gamepad_guids[dn] == "05000000503200000210000046010000"
	 || devices.gamepad_guids[dn] == "05000000503200000210000047010000"
	 ||  (os_type == os_linux && ( gamepad_button_count(dv) == 11 && gamepad_hat_count(dv) == 1 && gamepad_axis_count(dv) == 6 ) )
	 ) player_using_modern = true;
}

if ( player_using_classic ) {
	if ( debug_mode ) {
		draw_text(64,64,"CLASSIC P"+int(player_number));
		show_debug_message("CLASSIC P"+int(player_number));
	}
	var twister_now = gamepad_axis_value(dv,0); // floor(gamepad_axis_value(dv,0) * 10)/10.0;
	if ( !variable_instance_exists(id,"twister") ) twister=twister_now;
	else {
		var diff=twister_now-twister;
		if ( abs(diff) > 0.02 and ( (twister < 0 and twister_now < 0) or (twister > 0 and twister_now > 0) ) ) {
			if ( diff > 0 ) {
				phy_angular_velocity = min(phy_angular_velocity + turn_accel, max_turn_spd + (has_jetbelt?max_turn_spd:0) );
				if ( using_directional_stabilizer ) phy_angular_velocity = 300;
			} else if ( diff < 0 ) {
				phy_angular_velocity = max(phy_angular_velocity - turn_accel, -max_turn_spd - (has_jetbelt?max_turn_spd:0) );
				if ( using_directional_stabilizer ) phy_angular_velocity = -300;
			}
		}
		twister=twister_now;
	}	
	
	// turn clockwise
	if ( gamepad_hat_value(dv,0)&2 ) {
		if ( using_directional_stabilizer ) phy_angular_velocity = 300;
		else phy_angular_velocity = min(phy_angular_velocity + turn_accel, max_turn_spd + (has_jetbelt?max_turn_spd:0) );
		pressingLeft=true;
	}
	// turn counterclockwise
	if ( gamepad_hat_value(dv,0)&8 ) {
		if ( using_directional_stabilizer ) phy_angular_velocity = -300;
		else phy_angular_velocity = max(phy_angular_velocity - turn_accel, -max_turn_spd - (has_jetbelt?max_turn_spd:0) );
		pressingRight=true;
	}
	
	// forward
	if ( gamepad_hat_value(dv,0)&1 ) {
		event_user(11);
		if ( phy_speed < 30 * (has_jetpack?2:1) ) {
	     phy_speed_x += lengthdir_x(accel * (has_jetpack?2:1), -phy_rotation);
	     phy_speed_y += lengthdir_y(accel * (has_jetpack?2:1), -phy_rotation);
		}
	}
	// backward
	if ( gamepad_hat_value(dv,0)&4 ) {
		event_user(11);
		if ( phy_speed > -30 * (has_jetpack?2:1) ) {
	     phy_speed_x -= lengthdir_x(decel * (has_jetpack?2:1), -phy_rotation);
	     phy_speed_y -= lengthdir_y(decel * (has_jetpack?2:1), -phy_rotation);
		}
	}
} else if ( player_using_modern ) {

	if ( debug_mode ) {
		draw_text(128,64,"MODERN P"+int(player_number));
		show_debug_message("MODERN P"+int(player_number));
	}	
	// DPAD is "Hat0"
	// turn clockwise
	if ( gamepad_hat_value(dv,0)&2 || (os_type == os_linux && (gamepad_axis_value(dv,0) > 0.6 || gamepad_axis_value(dv,3) > 0.6))
	      || (os_type == os_windows && (gamepad_axis_value(dv,0) > 0.5 || gamepad_axis_value(dv,3) > 0.5)) ) {
	    phy_angular_velocity = min(phy_angular_velocity + turn_accel, max_turn_spd + (has_jetbelt?max_turn_spd:0) );
		if ( using_directional_stabilizer ) phy_angular_velocity = 300;
		pressingLeft=true;
	}
	// turn counterclockwise
	if ( gamepad_hat_value(dv,0)&8 || (os_type == os_linux && (gamepad_axis_value(dv,0) < 0.4 || gamepad_axis_value(dv,3) < 0.4))
	      || (os_type == os_windows && (gamepad_axis_value(dv,0) < -0.5 || gamepad_axis_value(dv,3) < -0.5)) ) {
	    phy_angular_velocity = max(phy_angular_velocity - turn_accel, -max_turn_spd - (has_jetbelt?max_turn_spd:0) );
		if ( using_directional_stabilizer ) phy_angular_velocity = -300;
		pressingRight=true;
	}
	
	// forward
	if ( gamepad_hat_value(dv,0)&1 || (os_type == os_linux && (gamepad_axis_value(dv,1) < 0.4 || gamepad_axis_value(dv,4) < 0.4)) 
	      || (os_type == os_windows && (gamepad_axis_value(dv,1) < -0.5 || gamepad_axis_value(dv,4) > 0.5)) ) {
		event_user(11);
		if ( phy_speed < 30 * (has_jetpack?2:1) ) {
	     phy_speed_x += lengthdir_x(accel * (has_jetpack?2:1), -phy_rotation);
	     phy_speed_y += lengthdir_y(accel * (has_jetpack?2:1), -phy_rotation);
		}
	}
	// backward
	if ( gamepad_hat_value(dv,0)&4 || (os_type == os_linux && (gamepad_axis_value(dv,1) > 0.6 || gamepad_axis_value(dv,4) > 0.6))
	      || (os_type == os_windows && (gamepad_axis_value(dv,1) > 0.5 || gamepad_axis_value(dv,4) < -0.5)) ) {
		event_user(11);
		if ( phy_speed > -30 * (has_jetpack?2:1) ) {
	     phy_speed_x -= lengthdir_x(decel * (has_jetpack?2:1), -phy_rotation);
	     phy_speed_y -= lengthdir_y(decel * (has_jetpack?2:1), -phy_rotation);
		}
	}
	
} else {
	
	// turn clockwise
	if ( controls.right(player_number)
	 or (gamepad_axis_value(dv, gp_axisrh) > 0.5) ) {
	    phy_angular_velocity = min(phy_angular_velocity + turn_accel, max_turn_spd + (has_jetbelt?max_turn_spd:0) );
		if ( using_directional_stabilizer ) phy_angular_velocity = 300;
		pressingRight=true;
	}
	// turn counterclockwise
	if ( controls.left(player_number) 
	 or (gamepad_axis_value(dv, gp_axisrh) < -0.5) ) {
	    phy_angular_velocity = max(phy_angular_velocity - turn_accel, -max_turn_spd - (has_jetbelt?max_turn_spd:0) );
		if ( using_directional_stabilizer ) phy_angular_velocity = -300;
		pressingLeft=true;
	}
	
	// forward
	if ( controls.up(player_number)
	 or ( gamepad_axis_value(dv, gp_axisrv) > 0.5) ) {
		event_user(11);
		if ( phy_speed > -30 * (has_jetpack?2:1) ) {
	     phy_speed_x -= lengthdir_x(decel * (has_jetpack?2:1), -phy_rotation);
	     phy_speed_y -= lengthdir_y(decel * (has_jetpack?2:1), -phy_rotation);
		}
	}
	// backward
	if ( controls.down(player_number)
	 or ( gamepad_axis_value(dv, gp_axisrv) < -0.5) ) {
		event_user(11);
		if ( phy_speed < 30 * (has_jetpack?2:1) ) {
	     phy_speed_x += lengthdir_x(accel * (has_jetpack?2:1), -phy_rotation);
	     phy_speed_y += lengthdir_y(accel * (has_jetpack?2:1), -phy_rotation);
		}
	}

}


if ( player_using_classic ) {
 isPressingA=gamepad_button_check(dv,gp_face1);
 isPressingB=gamepad_button_check(dv,gp_face2);
 holdingPause=gamepad_button_check(dv,gp_face3);
} else {
 isPressingA=controls.A(player_number);
 isPressingB=controls.B(player_number);
 if ( player_using_modern ) {
	if ( gamepad_button_check(dv,gp_select) ) isPressingA=false;
	if ( gamepad_button_check(dv,gp_select) ) isPressingB=false;
 }
 holdingPause=gamepad_button_check(dv,gp_select) or gamepad_button_check(dv,gp_start);
}

isReleasedPause = wasHoldingPause and not holdingPause;

if ( isReleasedPause ) {
	global.player_hit_pause= !global.player_hit_pause;
	if ( global.player_hit_pause ) {
		global.pause_help_index=0;
		global.player_hit_left=false;
		global.player_hit_right=false;
	}
} else if ( variable_global_exists("player_hit_pause") and global.player_hit_pause ) {
	if ( !pressingRight && wasPressingRight ) global.player_hit_right=true;
	if ( !pressingLeft && wasPressingLeft ) global.player_hit_left=true;
}

keyboardPauseReleased = keyboard_check_released(vk_f1) or keyboard_check_released(vk_escape) or keyboard_check_released(vk_backspace);

wasHoldingPause = holdingPause or keyboardPauseReleased;
wasPressingLeft=pressingLeft;
wasPressingRight=pressingRight;

// A - Shoot
if ( shootA_heat > 0.0 ) shootA_heat-=global.dt;
if ( shootA_heat < 0.0 ) shootA_heat=0.0;
if ( shootA_heat == 0.0 and isPressingA ) {
	if ( using_shotgun ) {
		for ( var i=-2; i<3; i++ ) {
			var b=instance_create_layer( x+lengthdir_x(5,image_angle), y+lengthdir_y(5,image_angle), "Bullets", o_PlayerBullet );
			b.dx=lengthdir_x(2,image_angle+i*2);
			b.dy=lengthdir_y(2,image_angle+i*2);
			b.image_angle=image_angle;
			b.shot_by=id;
			b.image_index=dv;
			shootA_heat=shootA_cooldown;
		}
		play_global(sfx_shotgun,false,1,0.7+player_number/8.0*0.4,128,100);			
	} else {
		var b=instance_create_layer( x+lengthdir_x(5,image_angle), y+lengthdir_y(5,image_angle), "Bullets", o_PlayerBullet );
		b.dx=lengthdir_x(2,image_angle);
		b.dy=lengthdir_y(2,image_angle);
		b.image_angle=image_angle;
		b.shot_by=id;
		b.image_index=dv;
		shootA_heat=shootA_cooldown;
		if ( using_tommygun ) {
			shootA_heat/=2;
			play_global(sfx_tommygun,false,1,0.7+player_number/8.0*0.4,128,100);
		} else play_global(sfx_lazgun,false,1,0.7+player_number/8.0*0.4,128,100);
	}
}


if ( active_item_alpha > 0 ) {
	active_item_alpha -= 1.0/room_speed;
	if ( active_item_alpha <= 0 ) active_item_alpha=0;
}
if ( active_item_alpha <= 0.1 ) active_item_color=c_white;
if (  array_length(inventory) > 0 ) {
	// B - Use or switch inventory
	if ( isPressingB ) {
		active_item_alpha=1.0;
		if ( Bheld == room_speed*2 and active_item < array_length(inventory) ) {
			if ( inventory[active_item] == 3 ) { // consumable meds
			   if (  global.player_health[player_index] < 100 ) {
				var list=[];
				var len=array_length(inventory);
				for ( var i=0; i<len; i++ ){
					if ( i != active_item ) list[array_length(list)]=inventory[i];
				}
				inventory=list;
				active_item=0;

				if ( os_get_config() == "Steam" ) {
					if ( steam_initialised() ) {
						steam_set_achievement("ach_Medic");
					}
				}
				
				global.player_health[player_index] = 100;
			    play_global(sfx_heal,false,1,1,100,100);
			   } else {
				   active_item_color=c_red;
				   play_global(sfx_cannot_use,false,1,1,100,100);
			   }
			} else if ( inventory[active_item] == 12 ) { // tommygun
				if ( using_tommygun ) {
				  play_global(sfx_cant,false,1,1,100,100);
				  using_tommygun=false;
				} else {
				  play_global(sfx_shotgun_cock,false,1,1,100,100);
				  using_shotgun=false;
				  using_tommygun=true;
				}
			} else if ( inventory[active_item] == 9 ) { // shotgun
				if ( using_shotgun ) {
				  play_global(sfx_cant,false,1,1,100,100);
				  using_shotgun=false;
				} else {
				  play_global(sfx_shotgun_cock,false,1,1,100,100);
				  using_tommygun=false;
				  using_shotgun=true;
				}	
			} else if ( inventory[active_item] == 25 ) { // Directional Stabilizer
				if ( using_directional_stabilizer ) {
					play_global(sfx_deactivate_directional,false,1,1,100,100);
					using_directional_stabilizer = false;
					phy_angular_damping = standard_phy_angular_damping;
				} else {
					play_global(sfx_activate_directional,false,1,1,100,100);
					using_directional_stabilizer = true;
					standard_phy_angular_damping = phy_angular_damping;
					phy_angular_damping = 10;
				}
			} else if ( inventory[active_item] == 20 ) { // scissors
				play_global(sfx_snip,false,1,1,100,100);
				if ( !snipped_cord ) {
					var new_inventory = array_create(array_length(inventory)-1); // consume the scissors...
					var k=0;
					for ( var j=0; j<array_length(inventory); j++ ) {
						if ( j == active_item ) continue;
						new_inventory[k]=inventory[j];
						k++;
					}
					// snip the link
					link_snipped=2+3+floor(rrange(1,3));
					physics_joint_delete(also_delete[link_snipped].link);
					also_delete[link_snipped].previous=noone;
					also_delete[link_snipped].link=noone;
					snipped_cord=true;
					inventory=new_inventory;
				}
			} else if ( inventory[active_item] == 19 ) { // additional rope
				var worked = used_spare_oxygen_tube < 3;
				if ( worked ) worked = extend_rope(self);
				if ( worked ) {
					play_global(sfx_oxygen_tube,false,1,1,100,100);
					play_global(sfx_oxygentank,false,1,1,100,100);
					used_spare_oxygen_tube++;
					var new_inventory = array_create(array_length(inventory)-1); // consume the rope...
					var k=0;
					for ( var j=0; j<array_length(inventory); j++ ) {
						if ( j == active_item ) continue;
						new_inventory[k]=inventory[j];
						k++;
					}
					inventory=new_inventory;
				} else {
				  play_global(sfx_cannot_use,false,1,1,100,100);
				  active_item_color=c_red;
				}
			}
		} 
		Bheld++;
	} else {
		if ( array_length(inventory) > 1 and Bheld > 0 and Bheld < room_speed ) { // switch item
			active_item++;
			active_item_color=c_white;
			active_item_alpha=1.0;
			if ( active_item >= array_length(inventory) ) active_item=0;
			play_global(sfx_inventory,false,1,1,100,100);
		}
		Bheld=0;
	}
}

if ( global.player_health[player_index] <= 0 ) { // DEAD!
	global.player_entering_name[player_index]=true;
	var i=0;
	for ( i=0; i<30; i++ ) {
		var b=throw_particle(x,y,8,random(360),random(1),random(1),1,random(1)+0.5,c_red);
	}
	play_global(sfx_player_death,false,1,1,100,100);
	var len=array_length(also_delete);
	for ( i=0; i<len; i++ ) {
		var b=throw_particle(also_delete[i].x,also_delete[i].y,0,
		random(180),random(1),random(1),1,random(1)+0.5,
		  i % 2 == 1 ? caribiner.color1 : caribiner.color2 );
	}
	var tombstone=instance_create_layer(x,y,"BehindPlayer",o_Tombstone);
	tombstone.image_index=image_index;
	instance_destroy();
}

if ( has_oxygenator ) global.player_oxygen[player_index]=100;
else {
	if ( snipped_cord ) {
		global.player_oxygen[player_index]-=0.01;
		if ( global.player_oxygen[player_index] <= 0 ) {
			 global.player_oxygen[player_index]=0;
			 global.player_health[i]-=0.01;
			 if ( global.player_health[i] < 0.0 ) global.player_health[i]=0;
		}
	}
}
```

InputCandy Simple
=================

The following code populates the "devices" variable from the above code:
(Our version of the InputCandy Simple that is called in the above code)

```
/*
  GMS_any (can be refactored easily to earlier versions)
  
  InputCandySimple
  
  This is the simplest form with the widest availability.  You can make good games with it,
  but it doesn't take full use of the controller.  Consider this a "NES" controller.
  
 Extend it if you want.  The patterns are already there for more than 8 players, or to attach
 additional button checks.
 
 Lost Astronaut used this control scheme in an easy to pick up game for 8 players called Apolune 2,
 made for the Atari, and made to be super easy to play.  You can add additional support for
 more buttons (most controllers have left/right shoulder and ABXY) but the Atari VCS's "classic joystick"
 only has two buttons, so "A", "B" and "AB".  
  
  Features:
  
	 - Basic controls are Up, Down, Left, Right, A, B
     - Supports up to 8 simultaneous players.  (numbered 1,2,3,4,5,6,7,8)
	 - Control events are "On" or "Not On", no "held for time" detection or anything like that,
	   so you will find yourself using this pattern:
	      if ( controls.A(player_num) and heat == 0 ) { cooldown=heat; heat-=frametime; do_action(); }
	   Use this pattern to avoid firing bullets too often or rejumping every frame
	 - Keyboard (2 Players):
		- maps the "Arrow Keys" and "WASD" to Player 1 as Left/Right/Up/Down, 
	      with Left Ctrl as "A" and Left Shift as "B" -- QWERTY keyboards, right-handed friendly
		- maps the Numpad (Numlock must be on) and/or IJKL to Player 2, where Right Control,
	      Right Shift are "A" and "B" -- ambidextrous friendly, QWERTY keyboards
	 - Mouse: not supported.  Write that into your game yourself using the standard GML functions.
	 - On controllers:
	    - Maps XY to AB
		- Maps LRUD redundantly to provide maximum number of options.
		- Uses a commonly used threshold value to turn axis sticks into dpads
		- Uses the controlled ID as the player ID
		- Can be extended to use Start/Select-or-Back/Shoulders/Triggers, but doesn't support them
	 - If a user disconnects a controller then reconnects it, it most likely causes reordering.
	 - If a user connects a new controller, it will probably be the last item in the list.
	 
  Usage example:
  
     In your PlayerObject.Create event:
	 
	 controls=InputCandySimple();
	 player_number=1;  // change this to a different number later...
	 
	 In the PlayerObject.Step event:
	
	 if ( controls.left(player_number) ) .... move left or whatever
	 if ( controls.A(player_number) ) ... shoot or whatever
	 
	 
   The functions are:
      controls.left(player_number)
      controls.right(player_number)
      controls.up(player_number)
      controls.down(player_number)
      controls.A(player_number)
      controls.B(player_number)
 
 
  Out-of-the-box it is fairly fast but there is on admitted optimization you can do yourself:
  
  Note that one refactor you may wish to make which provides minor optimization is to remove 
  the following lines from each place they appear other than the "devices" function.
  
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
			gamepad_count = array_length(gamepads);
			
 Then, you could simply pass the output of this function to the left() right() etc functions, so
 that this loop would only have to happen once,  Just add a new parameter
 "devices", and refactor the code from there.  
 
 But it's very very fast already and this makes checking things just a little easier, so I've left
 it out for now. 
 
 */
 
function playerCanPlay( player_number ) {
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
			gamepad_count = array_length(gamepads);
			return gamepad_count > player_number-1;
}

/*
 * Creates the controls object that merges everything as described above.
 */
function get_game_controls() {
	var control_object = {
		devices: function() {			
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var gamepad_names=[];
			var gamepad_guids=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) {
				if ( gamepad_is_connected(i) ) {
					gamepads[j]=i;
					gamepad_names[j]=gamepad_get_description(i);
					gamepad_guids[j]=gamepad_get_guid(i);
					j++;
				}
			}
			gamepad_count = array_length(gamepads);
			return {
				gamepads: gamepads,
				gamepad_names: gamepad_names,
				gamepad_guids: gamepad_guids,
				count: gamepad_count
			};
		},
		deviceAvailable: function( player_number ) {			
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
			gamepad_count = array_length(gamepads);
			return gamepad_count > player_number-1;
		},
		devicesString: function( devices ) {
			var out="Gamepads: \n";
			for ( var i=0; i<devices.count; i++ ) {
				out+="Player "+int(i+1)+" using gamepad Slot #"+int(devices.gamepads[i])+"\n";
			}
			return out;
		},
		left: function ( player_number ) {
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
//			var gamepad_names=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) {
				if ( gamepad_is_connected(i) ) {
					gamepads[j]=i;
	//				gamepad_names[j]=gamepad_get_description(i);
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
		},
		right: function ( player_number ) {
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
		},
		up: function ( player_number ) {
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
		},
		down: function ( player_number ) {
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
		},
		A: function ( player_number ) {
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
			gamepad_count = array_length(gamepads);
			if ( player_number == 1 ) {
				  return keyboard_check(vk_lcontrol)
				   or keyboard_check(vk_space)
				   or keyboard_check(vk_lalt)
				   or (0 < gamepad_count
				    and (gamepad_button_check(gamepads[0],gp_face1)
				      or gamepad_button_check(gamepads[0],gp_shoulderlb)
				      or gamepad_button_check(gamepads[0],gp_shoulderrb)
				      or gamepad_button_check(gamepads[0],gp_shoulderl)
				      or gamepad_button_check(gamepads[0],gp_shoulderr)
				      or gamepad_button_check(gamepads[0],gp_face3)));
			} else if ( player_number == 2 ) {
				  return keyboard_check(vk_rcontrol)
				   or keyboard_check(vk_ralt)
				   or keyboard_check(vk_pagedown)
				   or keyboard_check(vk_enter)
				   or (1 < gamepad_count
				    and (gamepad_button_check(gamepads[1],gp_face1)
				      or gamepad_button_check(gamepads[1],gp_shoulderlb)
				      or gamepad_button_check(gamepads[1],gp_shoulderrb)
				      or gamepad_button_check(gamepads[1],gp_shoulderl)
				      or gamepad_button_check(gamepads[1],gp_shoulderr)
				      or gamepad_button_check(gamepads[1],gp_face3)));
			} else if ( player_number == 3 ) {
				  return (2 < gamepad_count
				    and (gamepad_button_check(gamepads[2],gp_face1)
				      or gamepad_button_check(gamepads[2],gp_shoulderlb)
				      or gamepad_button_check(gamepads[2],gp_shoulderrb)
				      or gamepad_button_check(gamepads[2],gp_shoulderl)
				      or gamepad_button_check(gamepads[2],gp_shoulderr)
				      or gamepad_button_check(gamepads[2],gp_face3)));
			} else if ( player_number == 4 ) {
				  return (3 < gamepad_count
				    and (gamepad_button_check(gamepads[3],gp_face1)
				      or gamepad_button_check(gamepads[3],gp_shoulderlb)
				      or gamepad_button_check(gamepads[3],gp_shoulderrb)
				      or gamepad_button_check(gamepads[3],gp_shoulderl)
				      or gamepad_button_check(gamepads[3],gp_shoulderr)
				      or gamepad_button_check(gamepads[3],gp_face3)));
			} else if ( player_number == 5 ) {
				  return (4 < gamepad_count
				    and (gamepad_button_check(gamepads[4],gp_face1)
				      or gamepad_button_check(gamepads[4],gp_shoulderlb)
				      or gamepad_button_check(gamepads[4],gp_shoulderrb)
				      or gamepad_button_check(gamepads[4],gp_shoulderl)
				      or gamepad_button_check(gamepads[4],gp_shoulderr)
				      or gamepad_button_check(gamepads[4],gp_face3)));
			} else if ( player_number == 6 ) {
				  return (5 < gamepad_count
				    and (gamepad_button_check(gamepads[5],gp_face1)
				      or gamepad_button_check(gamepads[5],gp_shoulderlb)
				      or gamepad_button_check(gamepads[5],gp_shoulderrb)
				      or gamepad_button_check(gamepads[5],gp_shoulderl)
				      or gamepad_button_check(gamepads[5],gp_shoulderr)
				      or gamepad_button_check(gamepads[5],gp_face3)));
			} else if ( player_number == 7 ) {
				  return (6 < gamepad_count
				    and (gamepad_button_check(gamepads[6],gp_face1)
				      or gamepad_button_check(gamepads[6],gp_shoulderlb)
				      or gamepad_button_check(gamepads[6],gp_shoulderrb)
				      or gamepad_button_check(gamepads[6],gp_shoulderl)
				      or gamepad_button_check(gamepads[6],gp_shoulderr)
				      or gamepad_button_check(gamepads[6],gp_face3)));
			} else if ( player_number == 8 ) {
				  return (7 < gamepad_count
				    and (gamepad_button_check(gamepads[7],gp_face1)
				      or gamepad_button_check(gamepads[7],gp_shoulderlb)
				      or gamepad_button_check(gamepads[7],gp_shoulderrb)
				      or gamepad_button_check(gamepads[7],gp_shoulderl)
				      or gamepad_button_check(gamepads[7],gp_shoulderr)
				      or gamepad_button_check(gamepads[7],gp_face3)));
			}
		},
		B: function ( player_number ) {
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
			gamepad_count = array_length(gamepads);
			if ( player_number == 1 ) {
				  return keyboard_check(vk_lshift)
				   or keyboard_check(ord("X"))
				   or keyboard_check(ord("C"))
				   or (0 < gamepad_count
				    and (gamepad_button_check(gamepads[0], gp_face2)
					  or gamepad_button_check(gamepads[0], gp_face4)));
			} else if ( player_number == 2 ) {
				  return keyboard_check(vk_rshift)
				   or keyboard_check(vk_pageup)
				   or keyboard_check(vk_numpad5)
				   or (1 < gamepad_count
				    and (gamepad_button_check(gamepads[1], gp_face2)
					  or gamepad_button_check(gamepads[1], gp_face4)));
			}else if ( player_number == 3 ) {
				  return (2 < gamepad_count
				    and (gamepad_button_check(gamepads[2],gp_face2)
				      or gamepad_button_check(gamepads[2],gp_face4)));
			} else if ( player_number == 4 ) {
				  return (3 < gamepad_count
				    and (gamepad_button_check(gamepads[3],gp_face2)
				      or gamepad_button_check(gamepads[3],gp_face4)));
			} else if ( player_number == 5 ) {
				  return (4 < gamepad_count
				    and (gamepad_button_check(gamepads[4],gp_face2)
				      or gamepad_button_check(gamepads[4],gp_face4)));
			} else if ( player_number == 6 ) {
				  return (5 < gamepad_count
				    and (gamepad_button_check(gamepads[5],gp_face2)
				      or gamepad_button_check(gamepads[5],gp_face4)));
			} else if ( player_number == 7 ) {
				  return (6 < gamepad_count
				    and (gamepad_button_check(gamepads[6],gp_face2)
				      or gamepad_button_check(gamepads[6],gp_face4)));
			} else if ( player_number == 8 ) {
				  return (7 < gamepad_count
				    and (gamepad_button_check(gamepads[7],gp_face2)
				      or gamepad_button_check(gamepads[7],gp_face4)));
			}		
		},
		AB: function ( player_number ) {
			var gamepad_count=gamepad_get_device_count();
			var gamepads=[];
			var j=0;
			for ( var i=0; i<gamepad_count; i++ ) if ( gamepad_is_connected(i) ) gamepads[j++]=i;
			gamepad_count = array_length(gamepads);
			if ( player_number == 1 ) {
				  var a_=keyboard_check(vk_lcontrol)
				   or keyboard_check(vk_space)
				   or keyboard_check(vk_lalt)
				   or (0 < gamepad_count
				    and (gamepad_button_check(gamepads[0],gp_face1)
				      or gamepad_button_check(gamepads[0],gp_face3)));
				  var b_=keyboard_check(vk_lshift)
				   or keyboard_check(ord("X"))
				   or keyboard_check(ord("C"))
				   or (0 < gamepad_count
				    and (gamepad_button_check(gamepads[0], gp_face2)
					  or gamepad_button_check(gamepads[0], gp_face4)));
				 return a_ and b_;
			} else if ( player_number == 2 ) {
				  var a_=keyboard_check(vk_rcontrol)
				   or keyboard_check(vk_ralt)
				   or keyboard_check(vk_pagedown)
				   or keyboard_check(vk_enter)
				   or (1 < gamepad_count
				    and (gamepad_button_check(gamepads[1],gp_face1)
				      or gamepad_button_check(gamepads[1],gp_face3)));
				  var b_=keyboard_check(vk_rshift)
				   or keyboard_check(vk_pageup)
				   or keyboard_check(vk_numpad5)
				   or (1 < gamepad_count
				    and (gamepad_button_check(gamepads[1], gp_face2)
					  or gamepad_button_check(gamepads[1], gp_face4)));
			     return a_ and b_;
			} else if ( player_number == 3 ) {
				  var a_=(2 < gamepad_count
				    and (gamepad_button_check(gamepads[2],gp_face1)
				      or gamepad_button_check(gamepads[2],gp_face3)));
				  var b_=(2 < gamepad_count
				    and (gamepad_button_check(gamepads[2], gp_face2)
					  or gamepad_button_check(gamepads[2], gp_face4)));
			     return a_ and b_;
			} else if ( player_number == 4 ) {
				  var a_=(3 < gamepad_count
				    and (gamepad_button_check(gamepads[3],gp_face1)
				      or gamepad_button_check(gamepads[3],gp_face3)));
				  var b_=(3 < gamepad_count
				    and (gamepad_button_check(gamepads[3], gp_face2)
					  or gamepad_button_check(gamepads[3], gp_face4)));
			     return a_ and b_;
			} else if ( player_number == 5 ) {
				  var a_=(4 < gamepad_count
				    and (gamepad_button_check(gamepads[4],gp_face1)
				      or gamepad_button_check(gamepads[4],gp_face3)));
				  var b_=(4 < gamepad_count
				    and (gamepad_button_check(gamepads[4], gp_face2)
					  or gamepad_button_check(gamepads[4], gp_face4)));
			     return a_ and b_;
			} else if ( player_number == 6 ) {
				  var a_=(5 < gamepad_count
				    and (gamepad_button_check(gamepads[5],gp_face1)
				      or gamepad_button_check(gamepads[5],gp_face3)));
				  var b_=(5 < gamepad_count
				    and (gamepad_button_check(gamepads[5], gp_face2)
					  or gamepad_button_check(gamepads[5], gp_face4)));
			     return a_ and b_;
			} else if ( player_number == 7 ) {
				  var a_=(6 < gamepad_count
				    and (gamepad_button_check(gamepads[6],gp_face1)
				      or gamepad_button_check(gamepads[6],gp_face3)));
				  var b_=(6 < gamepad_count
				    and (gamepad_button_check(gamepads[6], gp_face2)
					  or gamepad_button_check(gamepads[6], gp_face4)));
			     return a_ and b_;
			} else if ( player_number == 8 ) {
				  var a_=(7 < gamepad_count
				    and (gamepad_button_check(gamepads[7],gp_face1)
				      or gamepad_button_check(gamepads[7],gp_face3)));
				  var b_=(7 < gamepad_count
				    and (gamepad_button_check(gamepads[7], gp_face2)
					  or gamepad_button_check(gamepads[7], gp_face4)));
			     return a_ and b_;
			}
		}
	};
    return control_object;
}
```
