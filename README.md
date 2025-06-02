# Getting your game working on the VCS

This document focuses on GameMaker primarily.   Take a look at this video that describes everything, no matter what engine you use: []

No matter what engine you are using, feel free to report issues here, or contact me directly to help your game get on the VCS by reaching out to "Retrofriends" on the Lost Astronaut discord in the #chat channel: https://discord.gg/fFJYFsaC7w <-- you can also come here to ask for some help.

For Other Developers:

- To download one of our prebuilt "Raw Oneshot" servers that properly detects the Classic and Modern, publishing using [this one](https://github.com/LAGameStudio/AtariVCSGML/releases/download/Oneshot-Servers/AtariVCSRawGamepadServer_Oneshot-prebuilt-589-Production.zip)
- To write an interface that gets the data from the server

For GameMaker Developers, what you'll need:

- An Ubuntu 18.04 LTS physical computer for GameMaker building and packaging (or WSL2 for packaging only)
- A windows computer running GameMaker IDE
- Your VCS
- A copy of InputCandy downloaded from the VCS Store (for diagnostic purposes)
- A copy of [Tera Term](https://github.com/TeraTermProject/teraterm/releases|TeraTerm) and a copy of WinSCP from WinSCP.net (be careful which download button you press!)
- This document (to guide you on the creation of o_ControllerController, and your scripts)
- The sample script
- Your bundle.ini
- The libs we provided [here](https://github.com/LAGameStudio/AtariVCSGML/releases/tag/Libs)
- The [Oneshot Production Server](https://github.com/LAGameStudio/AtariVCSGML/releases/download/Oneshot-Servers/AtariVCSGamemakerGamepadServer_Oneshot-prebuilt-589-Production.zip)
- [j_controls.gml](https://github.com/LAGameStudio/AtariVCSGML/blob/main/j_controls.gml|j_controls.gml) (from this repo) as a starting place for your controller abstraction layer
- Time and patience

## Phase 1 - Preparing to Test

1) Set up your "Physical Build Box" running Ubuntu 18.04 LTS by following the GameMaker guidelines
2) Create the o_ControllerController object as described in the Appendix below
3) Copy and paste j_controls.gml into your game's scripts.
4) On the VCS, download the InputCandy diagnostic tool (available for developers).  Experiment.
5) Attempt to integrate j_controls as basically as possible
6) Test on Windows
7) Switch your game's targets to Ubuntu > Your Build Device > GMYYC
8) Clean
9) Build your game as a "Compressed .zip"
10) Unzip the zip into a staging folder
11) Create your bundle.ini and set the Exec=runmefirst and save it to the staging folder
12) Create the libs folder and save it to your staging folder
13) Create a text file called "runmefirst" in the staging folder containing "sh ./run_game.sh"
14) Create a text file called "run_game.sh" in the staging folder according to the Appendix below
15) Create a "server" folder under the staging folder and copy the contents of [Oneshot Production Server](https://github.com/LAGameStudio/AtariVCSGML/releases/download/Oneshot-Servers/AtariVCSGamemakerGamepadServer_Oneshot-prebuilt-589-Production.zip) to it, renaming the executable from "AtariVCSGamePad..." to "server"

## Phase 2 - Testing on the VCS

1) Using WinSCP connect to user@atari-vcs.local (or your VCS's IP Address found in System > Networking, use ethernet!)
2) Copy the staging folder to your /home/user folder on the AtariVCS
3) Enter the staging folder
4) Use the Command icon, enter "chmod 0777 -R *" to set the proper permissions on every file in your staging folder.
5) To test immediately, click the Command icon (looks like a dos prompt) in the WinSCP command bar, and type: ```export DISPLAY=:0 ; ./runmefirst```

Note that steps 3,4,5 can be done either in WinSCP or in TeraTerm (or Putty, but I no longer recommend it)

Note in step 5, this is how you can, via SSH, tell the VCS to run something on the primary display (instead of "via the text terminal" default)

## Phase 3 - Packaging and Staging-test

1) Update your bundle.ini to reflect the correct Version number (bump number up by 1)
2) Copy everything off the VCS to your Windows machine
3) Copy everything TO your build machine (or use WSL2)
4) On Ubuntu, "chmod 0777 -R *" and then "zip MyGame_Version#.zip"
5) Copy the Ubuntu-made-zip to your Windows machine, and upload via Chrome (or upload directly via Chrome but Ubuntu, but your mileage may vary) to the Atari Dev Dashboard
6) Browse to the Atari VCS Games and update your game by inspecting its details.
7) Test in the Store app
8) (optional) Try using the Fuji button to see if the audio bug occurs (known issue, no known fix)
9) Rinse, repeat
10) Once you are ready, tell @davpa to get his ass in gear!

# Appendix One: The o_ControllerController object

1) Create a new object named o_ControllerController
2) Make sure it is set Persistent and Visible
3) In your startup room code (or init code, wherever), create the object ie
    ``global.pad_server=instance_create_layer(-16,-16,"Instances",o_ControllerController)``

Add Create Event:
```
global.pad_data=false;
global.pad_server=id;
attempts=0;
max_attempts=50;
host="127.0.0.1"

host="localhost"

//host="10.100.10.214"

port=1234

socket = network_create_socket(network_socket_tcp);

remote = network_connect(socket,host,port);
attempts++;
if ( remote < 0 ) {}
else{ //Send string
    var t_buffer = buffer_create(256, buffer_grow, 1);
    buffer_seek(t_buffer, buffer_seek_start, 0);
    buffer_write(t_buffer , buffer_string, "Hello");
    network_send_packet(socket, t_buffer, buffer_tell(t_buffer));
    buffer_delete(t_buffer);
}
```

Add Step Event:
```
if ( remote < 0 and attempts < max_attempts ) {	
	remote = network_connect(socket,host,port);
	if ( remote < 0 ) {}
else{ //Send string
    var t_buffer = buffer_create(256, buffer_grow, 1);
    buffer_seek(t_buffer, buffer_seek_start, 0);
    buffer_write(t_buffer , buffer_string, "Hello");
    network_send_packet(socket, t_buffer, buffer_tell(t_buffer));
    buffer_delete(t_buffer);
}	
}
```

Add Async - Networking event:
```
var n_id = ds_map_find_value(async_load, "id");
if ( socket == n_id ) {
    var t = ds_map_find_value(async_load, "type");
    if(t == network_type_data){
        var t_buffer = ds_map_find_value(async_load, "buffer"); 
		var size = ds_map_find_value(async_load, "size");
		if ( size > 0 ) {
			var data = buffer_read(t_buffer, buffer_string );
			show_debug_message(data);
			var o=global.pad_data;
			var t=false;
			try {
				t=json_parse(data);
				global.pad_data=t;
			} catch (e) {
				global.pad_data=o;
				//global.pad_data=false;
			}
		} else show_debug_message("size was 0");
	}
}
```

(Optional debug data) in DrawGUI Event:
```
/// @description Insert description here
// You can write your code in this editor

if ( debug_mode ) {

draw_set_font(Font16);

draw_set_color(c_yellow);

var str=json_encode(global.pad_data);

str+="\n-------------------------\n";

if ( is_string(global.pad_data) ) {
	str+="pad_data is a string\n";
} else
if ( global.pad_data != false ) {
	if ( is_struct(global.pad_data) ) {
		str+="pad_data is a struct\n";
		str+="Names: "+json_stringify(struct_get_names(global.pad_data))+"\n";
		str+="device list exists?" + ( variable_struct_exists(global.pad_data,"d") ? "YERS" : "NARS" ) + "\n";
		str+="array_len(d) = "+int(array_length(global.pad_data.d));
	}
}

str+="string(pad_data)= "+string(global.pad_data);

str+="\n-------------------------\n";

str+="j_server() = " + ( j_server() ? "YERS" : "NARS" ) + "\n";

str+="pad_server = " + int(global.pad_server) + "\n";

str+="vcs_atari() = " + ( vcs_atari() ? "YERS" : "NARS" ) + "\n";

str+="j_device_count() = "+int(j_device_count())+"\n";



for ( var i=0; i<j_device_count(); i++ ) {
	str+="DEVICE "+int(i)+" for PLAYER "+int(1+i)+" TYPE "+j_type(1+i)+"\n";
	str+="HATS "+int(j_hat_count(1+i))
	   +" AXIS "+int(j_axis_count(1+i))
	   +" BTN "+int(j_button_count(1+i))
	   +"\n";
	str+="A: "+int(j_pressing_A(1+i))
	   +" B: "+int(j_pressing_B(1+i))
	   +" L:" +int(j_pressing_left(1+i)) 
	   +" R:" +int(j_pressing_right(1+i)) 
	   +" U:" +int(j_pressing_up(1+i)) 
	   +" D:" +int(j_pressing_down(1+i))
	   ;
}

draw_text(16,16,str);

}
```




# Appendix Two: The run_game.sh script contents

Change "THISISMYGAME" to the appropriate executable name.

```
#!/bin/sh
export LD_LIBRARY_PATH=./libs:${LD_LIBRARY_PATH}
# put the Oneshot server in the background
cd server
./server &
cd ..
# let the logo show and the server start up
sleep 3
# launch your game
./THISISMYGAME
exit 0

```
