# Mark's Boomer Shooter

![Boomer Shooter cover image](./Assets/cover-image.png)

This is an open source prototype of a Godot FPS Game.

Play it in your browser or download it for Linux and Windows on [Itch.io](https://bearlikelion.com/boomer-shooter)

I developed this over a weekend to get a better understanding of state machines.\
I learned a lot from the [Godot-4-fpsarms](https://github.com/gdquest-demos/godot-4-FPS-arms) demo

## Controls:

### Keyboard & Mouse
* WASD - Movement
* Mouse - Look
* Left Click - Shoot
* Right Click - Aim Down Sights
* R - Reload
* Space - Jump
* Shift - Sprint
* Ctrl - Crouch
* Sprint+Crouch - Slide
* 1/2/3 - Switch Weapon
* Q (Hold) - Weapon Wheel
* E - Interact
* Esc - Pause Menu

### Controller
Full controller support with analog movement and camera, plus aim assist (sticky aim) on the right stick.
* Left Stick - Movement
* Right Stick - Look
* Right Trigger - Shoot
* Left Trigger - Aim Down Sights
* X/Square - Reload
* A/Cross - Jump
* L3 (Left Stick Click) - Sprint
* B/Circle - Crouch
* Sprint+Crouch - Slide
* D-pad Up/Right/Down - Switch Weapon
* LB/L1 (Hold) - Weapon Wheel
* Y/Triangle - Interact
* Start - Pause Menu

## Save File
I use a Godot resource to save data for the player.
You can load the saved data statically using:\
	`var player_save: PlayerSave = PlayerSave.load_player_data()`

Add any export variables you wish to store, and then save using:\
	`player_save.save_player_data(player_save)`

## Credits & Attribution:
Music by **Troll-Lyd**: [SoundCloud](https://soundcloud.com/troill-lyd), [Itch.io](https://troll-lyd.itch.io/)\
Font is [Geizer](https://www.dafont.com/geizer.font)\
Enemy is [FPS Character Beetle](https://opengameart.org/content/fps-character-beetle) by **rohin_n**\
Prototype Textures by [Kenney](https://www.kenney.nl/assets/prototype-textures)\
Main Menu Backgroud image by [Écrivain](https://opengameart.org/content/backgrounds-0)
