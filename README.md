# Godot Platform Fighting Game
## What is is?
The Godot Platform Fighting Game tries to emulate the base Mechanics of the Super Smash Brothers Series.
To be more precise, the mechanics used in the latest iteration Super Smash Brothers Ultimate.

This game is a work in progress and tries to provide the groundwork to build easily upon. For each element of the game (character, stage, item, etc.) 
the base functionalities are planned to be provided. 

The focus of the base implementation is one on one combat. Some interactions are currently only possible in one on one battles but if the projects continous 
to grow, older parts of the code will be adapted to work with more than two players

## What is currently working?
A base class to be extended from is provided for:
* Stage 

   A basic stage with fully solid platforms, drop through platforms and working edges  
* Character
   
   KinematicBody using a State Machine for all different Action (Air, Ground, AttackAir, DamageTaken etc.). Provide stats that can be adapted on a character to character 
   basis (weight, speed, jumpspeed, gravity etc.). The base character script can be extended and, if necessary, functions can be overloaded. To showcase this, two characters 
   were created. 
   
* Projectile/Item
   
   Similar to characters, projectiles/items have different attributes like weight gravity etc, Projectiles are designed to be added and destroyed during runtime. These 
   functionalities are provided in the base script. 


Characters and Items/Projectiles all need a JSON file to work. In the JSON file the attack properties and Stats are set (damage percent, knockback angle, damage effect, etc.)

Other Game Elements Implemented:
* Basic UI overlay during gameplay, showing stocks left and character percent as well as the time left of the current game is implemented. 
* Character select screen 
* Game Set Screen (Currently the Stats are not saved during gameplay and just show placeholder stats)
   
## How to create a new Character?
Tutorial in Progess

## What are the next steps? 
* Complete the second character
* Complete the UI 
* Add custom input mapping
* Add online play
* clean up code
* provide extended documentation 
* many bug testing sessions
* custom spritesheets 

## Additional Thanks and Credits
Credit for used SpriteSheets Link : https://www.deviantart.com/gregarlink10

Credit for used SpriteSheets Mario : https://www.deviantart.com/jack-hedgehog

## SideNote
The second character Link is currently a work in progress and not tested, nor implemented completetly. Link was added to test if extending the base character and item scrips
works as inteded. (it did :) ). 


This is a passion project to better understand the mechanics behind one of my favourit game franchises. I really had fun working on all of it and hope to keep on improving
the existing codebase. 
