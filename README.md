This repo contains code and help for GameMaker games (and some other kinds) to run on the Atari VCS.

Games that have used or benefitted or contributed to this document include:
- Circus Interstellar by EttinSoft @ https://steamcommunity.com/app/984030
- Popcorn Rocket by Battle Geek Plus, LLC ( https://www.battlegeekplus.com/ ) @ https://www.popcornrocket.com/
- 8-Bit Bakery by Shiphaven Games @ https://shiphavengames.com/
- Uncle Flip's Sky Frizz @ https://liminalist-contraptions.itch.io/
- Battle Rockets and Ultra Mission @ https://www.gumbo-machine.com/
- My game, Apolune 2 by Lost Astronaut Studios @ https://lostastronaut.com

# Making your game work on the AtariVCS

*If you wish to review how to use IDE 589, or the rationale behind what's being described in this document, please read the README.old.md*

This document deals with
- Getting your GameMaker game (or Godot 4 game, or other custom Linux-compileable game engine) to work on the AtariVCS.  
- It's primarily written for GameMaker versions >= 2.3.5 or released after 2022.  
- On one hand it talks about getting the controllers to work.  
- On the other hand, it tells you how to prepare your package for the Atari VCS Store ecosystem.
- It mentions a separate project called InputCandy which is also on the VCS Store and is used for diagnostic purposes and to help GameMaker Developers by providing GML controller-specific code that has already been tested on the VCS.  That's here: https://github.com/LAGameStudio/InputCandy

## Time commitment

RyanBGP of Popcorn Rocket said he built on Ubuntu 20.04, using GameMaker IDE v2024.2.0 and GameMaker Runtime v2024.2.0.163 and used our code for InputCandy Simple (no TCP/IP server or anything wild, as described below) and didn't support the AtariVCS Classic Controller and had it all done and ready to launch in a couple of days.

## Can't detect the Classic?  No problem, we have a solution

In _some_ new versions of Godot and GameMaker, you won't be able to reliably use SDL to handle the controllers (particularly the Classic) because _reasons_.  So, you will have to specially package your executable in the way described here, with an ancillary utility server (provided for you) - an ephemeral TCP/IP server can be used to read state information from each device profile (along with the list of connected devices), and there is a way to, in GameMaker, easily map this to InputCandy's ICDeviceState and ICDevice classes (see the wiki over there at https://github.com/LAGameStudio/InputCandy) so that you can write sane code that doesn't use GameMaker's ``gamepad_*`` functions directly on Windows and Linux.

Note that we've recently released a raw TCP/IP version to help Godot 4 users detect and manage the Atari Classic Controller on the VCS.

Feel free to report issues here, or directly to "Retrofriends" on the Lost Astronaut discord in the #inputcandy channel: https://discord.gg/fFJYFsaC7w <-- you can also come here to ask for some help.

## Essential Downloads from this Repo

* Release: https://github.com/LAGameStudio/AtariVCSGML/releases/tag/Oneshot-Servers
 * GameMaker games use this server: https://github.com/LAGameStudio/AtariVCSGML/releases/download/Oneshot-Servers/AtariVCSGamemakerGamepadServer_Oneshot-prebuilt-589.zip
 * Godot (and other engines) use this server: https://github.com/LAGameStudio/AtariVCSGML/releases/download/Oneshot-Servers/AtariVCSRawGamepadServer_Oneshot-prebuilt-589.zip
 * Example client: https://github.com/LAGameStudio/AtariVCSGML/releases/download/Oneshot-Servers/AtariVCSGamemakerGamepadClient.project.folder.zip
* Wrapper functions for ``gamepad_*`` functions that swap between "local" INPUTCANDY (on Windows) and "localhost remote tcp/ip" controller server (on VCS/Linux): https://github.com/LAGameStudio/AtariVCSGML/blob/main/shamepad.gml

## Preparing your GameMaker game for the Atari VCS OS (without Backdating)

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

  
### Step 2: You need to move some files around and re-zip them, with special permissions, and you are going to need a small wrapper script. 

On the Ubuntu side, you need to have a copy of your game recently exported as an AppImage.  Locate it in a terminal or via SSH and type the following shell command:

```
ldd ./YourGameName
```

The output of the above command will show a list of files, and their location on the Ubuntu OS.  Those listed files will be on the left hand side.  Those are the library files required for the game to run.  When GameMaker outputs an AppImage, it collects the lib files in a folder called ``AppDir/usr/lib/`` --- but we noticed one was missing in the version covered here:  ``libgmp.so.10``  --- you will need to _include absolutely all of these lib files_ (that generally end in so.x.x.x or similar) in a folder alongside the assets folder of your game. NOTE: It may be missing another lib or two, and the best way to figure out what libs it actually needs is by running the above command, then checking the list of files in the above location that GameMaker's export gave you, and rectify missing libs by filling in anything not in that folder with the files available on your Ubuntu build machine.  Otherwise, your game will crash immediately upon loading because it cannot find the required libs.  This is always a good indicator that there is a library issue.  The LDD utility and lib files are part of the dynamic library loading system that handles this before a game's execution can begin.  To search the Ubuntu system to find a file by name or partial name, use the command ``find -name "libgmp.so.10" /`` or equivalent.

1. Create a new folder we will call ``YourGame_unwrapped`` (but you can name it whatever you want) .. this is where you will build your "unwrapped AppImage" and you will copy or move files into it and then set the permissions, create the bundle and ZIP it, then SCP it out when you are done.
2. Create a subfolder of ``YourGame_unwrapped`` called ``YourGame_unwrapped/libs``
3. Copy or move some files around.
	1. Locate the files on your Ubuntu build services or extract as previously explained.  The required files are in three folders inside the folder ``AppDir``.
	2. ``AppDir/usr/bin/YourGame.x86_64`` is the binary executable, you should copy this this to ``YourGame_unwrapped``
	3. ``AppDir/usr/lib/*`` are all of the lib files (we hope) you will need, though we found one straggler you may need to locate elsewhere on your system.  Copy them to the subfolder you created earlier ``YourGame_unwrapped/libs/``
	4. ``AppDir/assets/`` is a folder that is easier to move than copy, so move it to ``YourGame_unwrapped`` such that it is now ``YourGame_unwrapped/assets``
4. The following is the script you need to create and save as "runme.sh", and this is what you will tell ``bundle.ini`` to run instead of your game executable directly.  You should place this directly next to your game's executable in the ``YourGame_unwrapped`` folder.

```
#!/bin/sh
export LD_LIBRARY_PATH=./usr/lib:${LD_LIBRARY_PATH}
YourGame.x86_64
exit 0
```

I'll explain what the above lines mean. 

1. Basically, the first line specifies "sh" as the shell.  You should leave it as "sh" since AtariVCS OS does _not_ have Bash.
2. The second line adds your folder 'usr/lib' _based on the game's current executing folder, aka ._ to the ``LD_LIBRARY_PATH`` variable that tells the OS not to look in the standard locations, but rather to look for the libs in this special location.

You need to set permissions of *all* of these files to 0777, ie:  ``chmod -R 0777 /where/your/game/export/lives/*``
  - You can do this in Ubuntu prior to uploading.
  - Or, you can do this on Windows by using Ubuntu via Windows-Subsystem-For-Linux (WSL), I prefer this way because I can do it all from the same machine I'm working on with GameMaker.
  - Or, if you want extra pain, you can reboot Atari VCS OS after copying to Windows, copy the files via SCP to the Atari, set the perms, zip it, then copy it back to Windows and upload it, or something to that effect.

 So, to sum up, your game folder you are going to ZIP and upload to AtariVCS Developer Dashboard should contain something like this:
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

### Step 3: Upload to the Dashboard and Publish.  Download on your VCS and test. 

* If it executes and doesn't crash immediately, you've got all the lib folders.
* If it crashes for another reason, there may be a bug in your game.
* On the Ubuntu build machine, you can also run your game there from a terminal and see the output.  You should have done that prior to zipping.  If you don't see "YoyoGames Runner" then you haven't collected enough lib files yet, go and repeat step 3. 
* If you see something like "Cannot open Display X" this means you've run it from a terminal that is not running inside the Ubuntu GUI and this is expected behavior and is not the source of any crash on the Atari. The crash must be happening after that, so it is an issue with your game.  It does mean that you have collected all the lib files properly, though.

### Step 4: (Optional)  Running your game remotely via PuttySSH or equivalent shell

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


### Step 5: Using the TCP/IP Server with your GameMaker game to support Atari VCS console input

So, to solve the issues with the controllers, Lost Astronaut Studios built a TCP/IP server that spits out devices, their states, mouse and keyboard information.  Your game can connect to it on the same "localhost" and get really fast updates to controller states (gamepad buttons, axis, hats, plus keyboard keys, mouse position and click state, etc.)  ... around this you can build support for the XBOX, PS4, Atari VCS Modern and Atari VCS Classic gamepads -- really any SDL-compatible USB device that is detectable as a joystick/gamepad/etc.

You'll want to download the projects, but you'll also want to download the AtariVCS pre-built gamepad server binary, which was built with version IDE 2.3.5.589 and use that:

1. Get the pre-built-in-IDE-589 server binary "Oneshot" in the latest release.
2. Get the client code latest version in the latest release.

The Client-Server bundle contains a version that just broadcasts classic information, but the client, also written to receive whatever data is sent from the server and output it to the debug message area, can be used as a starting place to implement support for all controllers and gamepads being used on the AtariVCS.  You should test the Client-Server operation on your Windows machine.  You can also point the client to your VCS, and run the binary version built in IDE 589, and test your controller output.  Then, you can refer to the last section of this document titled "Controller Notes" to attempt to support those specialty controllers.   Note that it may be helpful to skim the detection code in *Method 2: Example for Multiplayer, One Player's Step* but you won't be able to use any gamepad_ functions.  Instead, you need to inspect the JSON that the server is providing, and use that as the source for all of your gamepads (Atari or other brands).  It's just broadcasting the ICDevice and ICDeviceState parts of the InputCandy features described in the InputCandy wiki: https://github.com/LAGameStudio/InputCandy/wiki/InputCandy%3AAdvanced-Class-Reference

If you are going to be using the server, you need to use the OneShot server in the releases section: https://github.com/LAGameStudio/AtariVCSGML/releases/tag/Oneshot-Servers

Your invocation script will change to:

```
#!/bin/sh
cd /where/your/game/root/is/
export LD_LIBRARY_PATH=./usr/lib:${LD_LIBRARY_PATH}
# put the server in the background, choose Dev-Staging until you are satisified, then choose Production
./server/AtariControllerServer &
# let the logo show and the server start up
sleep 3
# launch your game
./YourGame.x86_64
exit 0
```


You'll need the object from the ICAtariClassicClient, above, and a copy of InputCandy.  In the o_AtariClassicClient object, you need to change the variable name from "classics" to "pad_server" ...

This function will swap between InputCandy and "remote" InputCandy (on the controller server), so if you switch your game code to use InputCandy Advanced, without the ICActions parts, you should be fine on both Windows and Atari:

```
// Returns only the controller state for a given player number
function GetPlayerControllerProfile(pn) {
	var player_index=pn-1;
        if ( variable_global_exists("pad_server") ) {
		if ( is_struct(global.pad_server) ) {
			if ( player_index < array_length(global.pad_server.d) ) return global.pad_server.d[player_index];
		}
	}
	var dv=__INPUTCANDY.players[player_index].device;
	if ( dv == none or dv < 0 or dv >= array_length(__INPUTCANDY.devices) ) return false;
	return __INPUTCANDY.devices[dv];
	if ( is_struct(global.pad_server) and player_index < array_length(global.pad_server.d) ) return global.pad_server.d[player_index];
}

// Returns only the controller state for a given player number
function GetPlayerControllerState(pn) {
	var player_index=pn-1;
        if ( variable_global_exists("pad_server") ) {
		if ( is_struct(global.pad_server) ) {
			if ( player_index < array_length(global.pad_server.d) ) return global.pad_server.s[player_index];
		}
	}
	var dv=__INPUTCANDY.players[player_index].device;
	if ( dv == none or dv < 0 or dv >= array_length(__INPUTCANDY.devices) ) return false;
	return __INPUTCANDY.states[dv];
}

// Returns by player number a gamepad's basic info
function GetGamepadInfo( pn ) {
	var pi=pn-1;
	var hand=GetPlayerControllerProfile(pn);
	if ( !is_struct(hand) ) return false;
	if ( hand.type != ICDeviceType_gamepad ) return false;
	var dv=hand.slot_id;
	// AtariVCS Modern
	if ( hand.desc == "Atari Game Controller"
	  or hand.desc == "Atari Controller"
	  or hand.desc == "Atari VCS Modern Controller"
	  or ( hand.button_count==11 and hand.hat_count==1 and hand.axis_count==6 ) )
	return { player_number: pn, player_index: pi, slot_id: dv, classic: false, modern: true, xbox: false, profile: hand, state: GetPlayerControllerState(pn) };
	// XInput Controller
	if ( string_pos("x-box", string_lower(hand.desc)) or (string_pos("xbox", string_lower(hand.desc)) or string_pos("xinput", string_lower(hand.desc))) )
	return { player_number: pn, player_index: pi, slot_id: dv, classic: false, modern: false, xbox: true, profile: hand, state: GetPlayerControllerState(pn)  };
	// AtariVCS Classic
	if ( hand.desc == "Classic Controller" or hand.desc == "Atari Classic Controller"
	   or ( hand.button_count==5 and hand.hat_count==1 and hand.axis_count==1 ) )
	return { slot_id: dv, classic: true, modern: false, xbox: false }; 
	// otherwise, a yet-to-be-categorized controller
	return { player_number: pn, player_index: pi, slot_id: dv, classic: false, modern: false, xbox: false, profile: hand, state: GetPlayerControllerState(pn) }; 
}
```

This means you cannot call ``gamepad_*`` functions anymore.  You need to get the data out of InputCandy's ``device[x]`` structure, described in [ICDeviceState on the InputCandy wiki](https://github.com/LAGameStudio/InputCandy/wiki/InputCandy%3AAdvanced-Class-Reference#icdevicestate)   See also the section at the top of this document titled "Essential Downloads"

All you need to do is import the InputCandy project to your game, and instantiate a persistent o_InputCandy object.  Customize the Init({}) function, as demo'ed in the InputCandy project.  This will call the ICInit and ICStep for you.  You won't need to worry about ICMatch or ICMatchDirectional or the InputCandySimple code, just read the values as though you called gamepad_* but instead get them from the ICDeviceState per-frame snapshot.

