# Multiplayer Bomberman in Racket (LISP dialect)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)
[![Racket Version](https://img.shields.io/badge/racket-v7.8%2Bstable-blue)](https://racket-lang.org)
[![App Version](https://img.shields.io/badge/version-v1.0.0-brightgreen)](https://github.com/Leystryku/mpbomberman_racket)

## Showcase
![ingame](https://github.com/Leystryku/mpbomberman_racket/blob/main/showcase/1.png?raw=true "Ingame")
![ingame_bomblayed](https://github.com/Leystryku/mpbomberman_racket/blob/main/showcase/2.png?raw=true "Layed a bomb")
![ingame_bombexplode](https://github.com/Leystryku/mpbomberman_racket/blob/main/showcase/3.png?raw=true "Exploding a bomb")
![ingame_bombburn](https://github.com/Leystryku/mpbomberman_racket/blob/main/showcase/4.png?raw=true "Bomb burning down some trees")
![titlescreen](https://github.com/Leystryku/mpbomberman_racket/blob/main/showcase/5.png?raw=true "Titlescreen")

This is a multiplayer Bomberman created in Racket (LISP dialect).
File convention is based on the one used in Garry's Mod (https://github.com/Facepunch/garrysmod)

The project was created for a University Course.

## Getting Started

###### Running local shared development instance (Client and Server)
- Just run bomberman_local.rkt

###### Running the Server
- Run bomberman_server.rkt
- Then proceed to run (launch-server-withport ThePortYouWant)
 
###### Running the Client
- Run bomberman_client.rkt
- Run (create-world-withipandport "ANumberGoingFrom1To4" "TheServerIp" TheServerPort)

###### Testing
- Run bomberman_tests.rkt

# Credits
- Leystryku (me)
	* Collision System
	* Movement
	* Entity System
	* Ents
	* The game Engine
	* Game Logic
	* Bomberman Logic
	* Rendering engine
	* Animation System
	* Networking
	* Field Logic
	* Game Events
	* Cleanups
	* Comments (Documentation)
	* etc
- Marc:
	* Manuals PDF
	* Gameover Serverside Logic
	* Tests
	* Cleanups
	* Comments (Documentation)
- Serhat:
	* Manuals PDF
	* Sound Assets
	* Sound System
	* Cleanups
	* Comments (Documentation)
- Assets:
	* Opengameart
- Source Engine
	* Inspiration for the events system
- Garry's Mod
	* The file convention with the cl_, sh_ sv_
