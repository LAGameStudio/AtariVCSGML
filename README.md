This document deals with getting your GameMaker game to work on the AtariVCS.

Feel free to report issues here, or directly to "Retrofriends" on the Lost Astronaut discord in the #inputcandy channel: https://discord.gg/fFJYFsaC7w

Please note this github/readme deals with getting your game to work _on the Atari VCS Console_ and not in Windows.  In the case of using the Atari controllers on Windows, you do not need any special "servers" or code, AFAIK.  You may benefit off *Appendix: Controller Notes* at the end of the document, however.  Generally, this document deals with issues building games for the AtariVCS OS, as there have been some technical issues encountered and dealt with.  It's only for the console itself that we had to create a workaround (if you are not using IDE 589, see below)

# PART 1: Summary

On Windows, any version of GameMaker should build fine, and most likely you can support the Atari Modern Controller and the Atari Classic Controller without too much trouble.

On the Atari VCS OS, however, you have two major implementation methods to consider to get to your goal of supporting the console and launching your game.  Pick your path as best you see fit.  It's all described in Part 2.

# PART 2: How to Deploy GameMaker Games onto the Atari VCS (Updated: 1/2024)

There are multiple methods.  It boils down to two distinct methods.  In both cases, these instructions should be followed assuming you know how to setup the Linux physical remote build environment, but read on if you are planning to research this later.

## Method 1: (Easiest to Port from GameMaker Latest): (Recommended) 

Following these instructions (below, in the next section **Preparing your GameMaker game for the Atari VCS OS**)

* If you are using a post-acquisition version of "Opera's YoyoGames GameMaker Studio" (or any version past 2.3.5)
* If you can SSH into your AtariVCS or would like to try
* You don't have a "Legacy Login" with GameMaker
* You are willing to attempt to support the controllers over a network, or you are willing to accept only partial controller support of XBOX, PS4 and Atari VCS Modern (when plugged in only)
* If you can SSH/SCP into your AtariVCS or an Ubuntu box, or would like to try
* You don't plan on supporting the Atari Classic Controller, or are willing to use our work-around (see "Notes on the Classic Controller Workaround" at the end of this document)

So, you don't feel like backporting to a legacy version of Gamemaker Studio from pre-Opera acquisition (2021)?   Not surprising.  You should be aware that building in later versions of Ubuntu or on the VCS itself will a later version of GameMaker (like current) might result in some unexpected issues around the SDL controller support. For this reason, you have two main options.

Scenario A:
* (recommended) Or, use our special InputCandy-based ICAtariControllerServerHD.zip (see Releases tab) that broadcasts device input state for keyboard, mouse, Atari Modern, other controllers and the Classic over TCP/IP directly to your game via a socket.  You put the contents into a subfolder of your game's folder, and you run the server on the Atari at the same time you run your game, like this:

```
#!/bin/sh
# https://stackoverflow.com/questions/360201/how-do-i-kill-background-processes-jobs-when-my-shell-script-exits/2173421#2173421
#trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
# https://stackoverflow.com/questions/3004811/how-do-you-run-multiple-programs-in-parallel-from-a-bash-script
(trap 'kill 0' SIGINT SIGTERM EXIT; ./server/ICAtariControllerServerHD & ./MyGame & wait)
```

In the above script we are syncing up two processes.  First, you run the server.  Then, you run ./MyGame -- ideally both will exit at the same time if killed or otherwise terminated.  Atari VCS, when you run two games, the latest game run shows up on the screen.  So, if you first run the server, then the game, which is basically a client of that localhost server, your game will be on the screen, hiding the server.  It can pull data from the server which happens to be that reliable Atari VCS controller data you want.  You want the server to shut down when the client shuts down.  If you leave the server running, though, subsequent calls to run the server won't succeed.  Clients can connect and disconnect as much as they want.  The server itself doesn't have any security concerns because it just broadcasts and ignores all input sent its way.  It is also tuned to only respond to GameMaker games, as it is not a "raw" TCP/IP server.

Scenario B:
* (not recommended) Use GameMaker's gamepad functions or InputCandy from within your game.  (https://github.com/LAGameStudio/InputCandy)  None of the code for the controllers will work, so you will have to experiment.  XBOX controllers might work as expected, but the Modern won't, and the Classic won't even be detectible unless you use a TCPIP server.



## Method 2: (Best way to support Atari VCS OS natively)

(Fallback) Backdating to GameMaker IDE 2.3.5.589 and Runtime: 2.3.5.458 (or nearby, available on the GameMaker older versions download page)

Apolune 2, the first game written for AtariVCS to use GameMaker, had to backport to IDE 2.3.5.589 / Runtime 2.3.5.458

Instructions are in a shared document available on Google Drive, which also contains other useful tips about building for the Atari VCS: https://docs.google.com/document/d/1bPASvw89fePhV7ctHreugoftrYLlXfnBR53zCI7MUC8/edit?usp=drive_link

Taking this route:
* You MUST have a "Legacy account Login", not the Opera One Login.
* You will be able to write natively for the Atari Modern Controller and the Classic
* If you are starting a new project,
* You want the best native support for the current version of Atari VCS OS (probably the _only_ version that will ever be released)
* or your project is simple and can be easily rebuilt from a collection of files and scripts,
* and don't mind going back to that version.  This version is fine but may not have all of the fixes.
* If you use this method and your project is from a GameMaker that is newer, your project will break,
* If you build a project using this version, your project will probably not work in the newer version of GameMaker without changes or other efforts.

You can use this Readme file only to help with your controller code, you can use InputCandy or your own GML gameepad function calls.   You do not need to do anything special and can upload the ZIP with the bundle.ini file and the right permissions as described in the document.  (See section titled *Method 2: Example for Multiplayer, One Player's Step*)


## Method 1: Preparing your GameMaker game for the Atari VCS OS (without Backdating)

The following method has been tested with GameMaker IDE: v2023.11.1.129 and Runtime: v2023.11.1.160 - this updated method was made possible as a collaboration between LostAstronaut.com (Apolune 2) and EttinSoft.com (Circus Interstellar)

GameMaker exports two kinds of Linux builds: ZIP and AppImage.  AppImage is a standard Linux way of distributing libs and assets and binary executables (compiled game code) in a single file.  You want to use the AppImage method, but you not be using the AppImage directly.  

On your build machine, the ``YourGame.AppImage`` will be created with some files and folders around it.  Among others, GameMaker will also spit out a folder ``AppDir`` that contains some important folders and files packaged within the AppImage file, along with your ``assets/`` folder and the game's binary executable, something like ``AppDir/usr/bin/YourGame.x86_64``.  You can either grab them from the Ubuntu build service, by logging in with WinSCP or equivalent file transfer program, or extract them directly from the AppImage file: https://superuser.com/questions/1301583/how-can-i-extract-files-from-an-appimage

You need to make your own "unwrapped" AppImage, since AtariVCS-OS does not have FUSE set up properly for the default "user" in its system.  So you won't be able to use an AppImage exported as a single file.  Instead, you are going to make your own custom one that will make it work fine on Atari VCS OS.  

To do this, you need to build first on Ubuntu, then figure out what libs are being used, and include them along with your game, then use the wrapper script below to wrap your game, and tell bundle.ini to run the script rather than your game.

Please note future versions may not work exactly the same, but similarly.  Specifically, around what libs should be included may change as GameMaker evolves.  I will explain in a detailed way, so you won't be lost.


### Step 0: (optional) Recommended tools for Windows users to interface with Linux/Ubuntu and AtariVCS-OS

*  Get "voidtools Everything" (search on Google), it will make your life so much easier.  Pin it to your Taskbar.  Now you can find files really, really fast.
*  Get "PuttySSH" and I also recommend TeraTerm because it supports "fullscreen" term applications better (it is found on Sourceforge, so go there directly to search for it)
*  Get and learn how to use "WinSCP" for transferring files, storing sessions and triggering PuttySSH to do things like remotely set permissions and zip folder contents into a zip file.
  
### Step 1: Export your Game From GameMaker for Ubuntu as a ZIP

* This requires you to set up a physical Ubuntu box.  You can also use the actual AtariVCS as your physical Ubuntu box, if you have Ubuntu installed on an SSD.  To do this you can make an Ubuntu Install USB Stick.  You will plug your target SSD into the AtariVCS, as well as the Ubuntu Install Stick, and turn the AtariVCS on, and then install Ubuntu onto the SSD, avoiding overwriting the existing installation on the Atari OS's internal SSD.  Then, you will boot off your newly minted Ubuntu SSD, and your Atari will boot as though it was an Ubuntu PC.  You will use this by configuring GameMaker to target it, and configuring the Ubuntu OS you just installed with the required prerequisites.  You will need to identify its IP address, as you may need to SSH into it from your PC, or at the very least, provide the credentials to GameMaker.
* You need to follow the current standard steps found in the GameMaker documentation and forums that discuss how to choose the right version of Ubuntu for the version of GameMaker you are using.
* Once you are able to successfully build a Linux Build "AppImage" version of your Game and get back a successfully built file, carry on to Step 2.

  
### Step 3: You need to move some files around and re-zip them, with special permissions, and you are going to need a small wrapper script. 
* On the Ubuntu side, you need to have a copy of your game recently exported as an AppImage.  Locate it in a terminal or via SSH and type the following shell command:
```
ldd ./YourGameName
```
* The output of the above command will show a list of files, and their location on the Ubuntu OS.  Those listed files will be on the left hand side.  Those are the library files required for the game to run.  When GameMaker outputs an AppImage, it collects the lib files in a folder called ``AppDir/usr/lib/`` --- but we noticed one was missing in the version covered here:  ``libgmp.so.10``  --- you will need to _include absolutely all of these lib files_ (that generally end in so.x.x.x or similar) in a folder alongside the assets folder of your game. NOTE: It may be missing another lib or two, and the best way to figure out what libs it actually needs is by running the above command, then checking the list of files in the above location that GameMaker's export gave you, and rectify missing libs by filling in anything not in that folder with the files available on your Ubuntu build machine.  Otherwise, your game will crash immediately upon loading because it cannot find the required libs.  This is always a good indicator that there is a library issue.  The LDD utility and lib files are part of the dynamic library loading system that handles this before a game's execution can begin.  To search the Ubuntu system to find a file by name or partial name, use the command ``find -name "libgmp.so.10" /`` or equivalent.

1. Create a new folder we will call ``YourGame_unwrapped`` (but you can name it whatever you want) .. this is where you will build your "unwrapped AppImage" and you will copy or move files into it and then set the permissions, create the bundle and ZIP it, then SCP it out when you are done.
2. Create a subfolder of ``YourGame_unwrapped`` called ``YourGame_unwrapped/libs``
3. Copy or move some files around:
 - Locate the files on your Ubuntu build services or extract as previously explained.  The required files are in three folders inside the folder ``AppDir``.
 - ``AppDir/usr/bin/YourGame.x86_64`` is the binary executable, you should copy this this to ``YourGame_unwrapped``
 - ``AppDir/usr/lib/*`` are all of the lib files (we hope) you will need, though we found one straggler you may need to locate elsewhere on your system.  Copy them to the subfolder you created earlier ``YourGame_unwrapped/libs/``
 - ``AppDir/assets/`` is a folder that is easier to move than copy, so move it to ``YourGame_unwrapped`` such that it is now ``YourGame_unwrapped/assets``
4. The following is the script you need to create and save as "runme.sh", and this is what you will tell ``bundle.ini`` to run instead of your game executable directly.  You should place this directly next to your game's executable in the ``YourGame_unwrapped`` folder.
```
#!/bin/sh
export LD_LIBRARY_PATH=./usr/lib:${LD_LIBRARY_PATH}
YourGame.x86_64
exit 0
```
 - I'll explain what the above lines mean.  Basically, the first line specifies "sh" as the shell.  You should leave it as "sh" since AtariVCS OS does _not_ have Bash.
 - The second line adds your folder 'usr/lib' _based on the game's current executing folder, aka ._ to the ``LD_LIBRARY_PATH`` variable that tells the OS not to look in the standard locations, but rather to look for the libs in this special location.
 - You need to set permissions of *all* of these files to 0777, ie:  ``chmod -R 0777 /where/your/game/export/lives/*``
   - You can do this in Ubuntu prior to uploading.
   - Or, you can do this on Windows by using Ubuntu via Windows-Subsystem-For-Linux (WSL), I prefer this way because I can do it all from the same machine I'm working on with GameMaker.
   - Or, if you want extra pain, you can reboot Atari VCS OS after copying to Windows, copy the files via SCP to the Atari, set the perms, zip it, then copy it back to Windows and upload it, or something to that effect.
 - So, to sum up, your game folder you are going to ZIP and upload to AtariVCS Developer Dashboard should contain something like this:

```
bundle.ini     (with version matching dashboard, set to run runme.sh)
runme.sh       (the script)
./YourGame.x86_64  (your game binary)
/assets        (folder contain assets exported from GameMaker)
/assets/*      (there should be a bunch of files in here, usually sounds, sprites and similar)
/libs/      (folder containing each and every lib you need, example:)
/libs/libcrypto.so.1.0.0
/libs/libcurl-gnutls.so.4
/libs/libffi.so.6
/libs/libgcrypt.so.11
/libs/libGLU.so.1
/libs/libgmp.so.10        (this file was missing, we copied it from libgmp.so.10.0.4 and renamed it)
/libs/libgnutls.so.30
/libs/libgssapi_krb5.so.2
/libs/libhogweed.so.4
/libs/libidn.so.11
/libs/libk5crypto.so.3
/libs/libkeyutils.so.1
/libs/libkrb5.so.3
/libs/libkrb5support.so.0
/libs/libnettle.so.6
/libs/libp11-kit.so.0
/libs/librtmp.so.0
/libs/libssl.so.1.0.0
/libs/libtasn1.so.6
/libs/libXau.so.6
/libs/libxcb-glx.so.0
/libs/libXdamage.so.1
/libs/libXdmcp.so.6
/libs/libXext.so.6
/libs/libXfixes.so.3
/libs/libXrandr.so.2
/libs/libXrender.so.1
/libs/libXxf86vm.so.1
```
 - To Zip your game, go into the folder ``YourGame_unwrapped`` and try:  ``zip -r -v ..\YourGame_versionX.zip . 

### Step 4: Upload to the Dashboard and Publish.  Download on your VCS and test. 

* If it executes and doesn't crash immediately, you've got all the lib folders.
* If it crashes for another reason, there may be a bug in your game.
* On the Ubuntu build machine, you can also run your game there from a terminal and see the output.  You should have done that prior to zipping.  If you don't see "YoyoGames Runner" then you haven't collected enough lib files yet, go and repeat step 3. 
* If you see something like "Cannot open Display X" this means you've run it from a terminal that is not running inside the Ubuntu GUI and this is expected behavior and is not the source of any crash on the Atari. The crash must be happening after that, so it is an issue with your game.  It does mean that you have collected all the lib files properly, though.

### Step 5: (Optional)  Running your game remotely via PuttySSH or equivalent shell

If you want to "force display 0", you can try running it like this instead, to see if it works in Ubuntu: ``export DISPLAY=:0 ; ./YourGame.x86_64`` or in a script like this:
```
#!/bin/sh
export DISPLAY 0
YourGame.x86_64
```

To run the game remotely, you would need to login to the Atari VCS OS (there is a document provided by Atari on how to do this). Once logged in, via WinSCP you can copy your game in.

To run it manually, you would do something like this to force it to use display 0 instead of display X (no display):
``env DISPLAY=:0 ./PathToYourGameExecFile``

The above code will tell the game to run on display 0 (the Atari HDMI port) -- if you are needing to run this remotely but view debug / showmessage output from GameMaker.  It's a great way to validate that you've got all the libs.  Repeat the above steps until it works.

If you are attempting to use the TCP/IP ICAtariControllerServer, you will need to download and test by building the ICAtariClassicClient project, running the server, integrating the client into your game, and using it as solution on your Atari VCS.   Read the next section which covers this.


### Step 6: Using the TCP/IP Server with your GameMaker game to support Atari VCS console input

So, to solve the issues with the controllers, Lost Astronaut Studios built a TCP/IP server that spits out devices, their states, mouse and keyboard information.  Your game can connect to it on the same "localhost" and get really fast updates to controller states (gamepad buttons, axis, hats, plus keyboard keys, mouse position and click state, etc.)  ... around this you can build support for the XBOX, PS4, Atari VCS Modern and Atari VCS Classic gamepads -- really any SDL-compatible USB device that is detectable as a joystick/gamepad/etc.

You'll want to download the projects, but you'll also want to download the AtariVCS pre-built gamepad server binary, which was built with version IDE 2.3.5.589 and use that:

1. Get the pre-built-in-IDE-589 server binary, to bundle with your AtariVCS game, and to run alongside: https://github.com/LAGameStudio/AtariVCSGML/releases/tag/IC-Game-Input-Server-HD
2. Get the client project to learn from and test "networked" gamepad input state acquisition, here: https://github.com/LAGameStudio/AtariVCSGML/releases/tag/Client-Server

The Client-Server bundle contains a version that just broadcasts classic information, but the client, also written to receive whatever data is sent from the server and output it to the debug message area, can be used as a starting place to implement support for all controllers and gamepads being used on the AtariVCS.  You should test the Client-Server operation on your Windows machine.  You can also point the client to your VCS, and run the binary version built in IDE 589, and test your controller output.  Then, you can refer to the last section of this document titled "Controller Notes" to attempt to support those specialty controllers.   Note that it may be helpful to skim the detection code in *Method 2: Example for Multiplayer, One Player's Step* but you won't be able to use any gamepad_ functions.  Instead, you need to inspect the JSON that the server is providing, and use that as the source for all of your gamepads (Atari or other brands).  It's just broadcasting the ICDevice and ICDeviceState parts of the InputCandy features described in the InputCandy wiki: https://github.com/LAGameStudio/InputCandy/wiki/InputCandy%3AAdvanced-Class-Reference

==========================================

# PART 3: Method 2: Backdated to 589: Example for Multiplayer, One Player's Step

_These code samples will only work with Method 2, building in IDE 2.3.5.589_

I don't expect you to copy and paste this code, but rather it shows you how to detect if the player is using classic, or modern, with a "generalized fallback" for keyboard or generic USB controllers.

Apolune 2 controller code for o_PlayerX object (called in Step, one object per active player):

```gml
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

## InputCandy Simple for VCS (Method 2, Backdating)

This is a reusable code snippet that you can copy and paste into your game in a script for your use.  It is based on https://github.com/LAGameStudio/InputCandy/tree/trunk/scripts/InputCandySimple and is tuned to the above code example.

The following code populates the "devices" variable from the above code:

```gml
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

==========================



# PART 4: Appendix: Controller Notes

The following behavior should be seen in Backported (Method 2) IDE 589 and using the TCP/IP ICAtariControllerServer.zip 

Controllers provide different values on Linux/VCS-OS versus Windows: Recognize there are differences in controller values provided when writing the code for controllers when “on the VCS” versus on a PC with the same controller.  It is not the same.  Notably, Linux can provide -1 to 1 instead of 0 to 1 for axis values.  Notes on the Modern and Classic controller are later in this document.    

If you want to be fully aware of what these values actually are, developers should be able to download and install through the VCS STore the “InputCandy” utility provided by Lost Astronaut Studios which shows you diagnostic information about the connected controllers (in real time).


It’s a good idea to explore the controller values for yourself using InputCandy, but here are my notes:

In these notes, A is "B" means "I pressed A but the controller said B"

## Modern Controller:
Device ID 03000000503200000210000011010000
Shows "Atari Game Controller" as name; Note that on a Windows PC, the Modern controller appears as "XInput Controller"

- Left Thumb Stick:
	- Left-Right movement: Registers as left horizontal (gp_axislh), goes 0-1 where 0.5 is the center, Left is 0, Right is 1
	- Up-Down movement: Registers as left vertical (gp_axislv), Up is 0, middle is 0.5, Down is 1,
- Right Thumb Stick:
	- Left-Right movement: Registers as right horizontal (gp_axisrh), goes 0-1 where 0 is left and 1 is right and 0.5 is centered
	- Up-Down movement: Registers as axis 4 (fifth in list, list length - 2), Up is 1 down is 0 center is 0.5 aka axis[3]
- Right Trigger = Axis 6th in list (length-1), goes from 0 to 1 depending on how much you have pulled it, aka axis[5]
- Left Trigger = Axis 2 3rd in list goes from 0 to 1 depending on how much you have pulled it, aka axis[2]
- Dpad = Hat 0, Left = "Right", Up = "Up", Right = "Down", Down = "Left"
- Fuji button registers as "Back/Select" (gp_select)
- Back button registers as "Left Trigger" (gp_shoulderlb)
- Menu burger button registers as "Right Trigger" (gp_shoulderrb)
- Right stick button registers as "Left Stick" button (gp_stickl)
- Left stick button registers as "Start" button (gp_start)

## Classic Controller: (on bluetooth or not) (Does not seem to be detected unless you "backport")
Does not have a device name or vendor info ("Unknown"); Note that on a Windows PC, "Classic Controller" is the name, but the device description is blank on the VCS in situ.
Device ID 0000000000000000021000000000000 (This value changes due to the fact that it is an error code (21) that indicates memory is full of garbage)

- Top red button 0 is A (gp_face1)
- Side bar red button 1 is B (gp_face2)
- "Back" is button 2 "X" (gp_face3)
- "Menu burger" is button 3 "Y" (gp_face4)
- "Fuji button" is "Left Shoulder" (gp_shoulderl)
- JoyStick = hat0, Up = "Up", Down = "Left", Left = "Right", Right = "Down"
- Twist/paddle is Axis 0, Axis 0-1 sometimes oscillates by .01 , aka axis[0]

## Notes on the Classic Controller Workaround
_The following section announced issues discovered prior to creation of the TCP/IP ICAtariControllerServer, it's left here as notes_

Just an update regarding GameMaker "Latest" builds running on Atari VCS.  While we have in place a process, which is actually a fairly standard process option for many different game engines, we have noticed one quirk:  The latest version of GameMaker uses a version of SDL that does not correctly detect the Atari Classic Controller when running on the VCS.  It does still detect fine in Windows, however.  And it also still works with Apolune 2, and the InputCandy application in the VCS-Dev-Store (both "Backported"). 

For this reason I wanted to update "Current GameMaker" devs that while you can easily support the Atari Modern Controller, it doesn't seem to work with the Classic.  Also, I've heard reports that the Modern Controller when not plugged in acts whacky or disappears from the device list, except in the TCP/IP server.

Preliminary tests are positive.  However, I want to fully flesh out everything and test it further before publishing.  We'll put it at the same github repo that we published the process.

In a nutshell we've worked around this by creating a local TCP server that publishes fully working classic controller states via a localhost connection to a game.  The idea is you would launch the "GameMaker Atari Classic Controller State Publishing Service", then launch your game, your game would know to get Classic controller information from the server, and apply it to your players. 

So far:
- Server works when built in the backported copy, tested on VCS #1546
- We tested and you can run two gamemaker games with one in the background and the second one shows up on the AtariVCS as the main screen, and they don't interfere with each other
- Client GML library works (it actually can work across a LAN as well, but I'm not sure why you would want to use it that way ever), so it can connect to and read back JSON describing any Classics


