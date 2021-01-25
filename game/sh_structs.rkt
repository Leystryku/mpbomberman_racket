#lang racket

;; import
(require (for-syntax racket/struct-info))

;; export
(provide (all-defined-out))


;   fieldElements have the following form: '(elementName xtiles ytiles wtiles htiles extraData)

;elementName -> 'name des Elementes
;xtiles -> x in Tile-Coords
;ytiles -> y in Tile-Coords
;wtiles -> w in Tile-Cords
;htiles -> h in Tile-Coords
;animatedTexture -> If set, then this represents the animated texture of this tile
;extraData -> Extra data about this fieldElement (for e.g. Bombs)

(struct fieldElement (elementName xtiles ytiles wtiles htiles animatedTexture extraData) #:mutable #:transparent)

(define (fieldElementToList e)
  (list (fieldElement-elementName e) (fieldElement-xtiles e) (fieldElement-ytiles e) (fieldElement-wtiles e) (fieldElement-htiles e) (fieldElement-animatedTexture e) (fieldElement-extraData e))
)

(define (listTofieldElement lst)
  (apply fieldElement lst)
)



;   animatedTexture has the following form: (ticksWhenNextAnim shouldLoop textures)

;ticksWhenNextAnim -> >= this tick Count and next texture will be displayed
;frameAdvanceTicks -> These many ticks will be added to tickCount to calculate ticksWhenNextAnim
;currentTextureNum -> The current texture number
;shouldLoop -> Should the animation loop ? if not, then it will stop playing on the last frame
;isPaused -> If this is set then will not advance texture 
;name -> When set, the name of the animationTexture
;textures -> The textures (On Server string, On Client bitmap/file)

(struct animatedTexture (ticksWhenNextAnim frameAdvanceTicks currentTextureNum shouldLoop isPaused name textures) #:mutable #:transparent)


(define (animatedTextureToList e)
  (list (animatedTexture-ticksWhenNextAnim e) (animatedTexture-frameAdvanceTicks e) (animatedTexture-currentTextureNum e) (animatedTexture-shouldLoop e) (animatedTexture-isPaused e) (animatedTexture-name e) (animatedTexture-textures e))
)

(define (listToAnimatedTexture lst)
  (apply animatedTexture lst)
)





;   players have the following form: (texture x y speed alive ready user)

;animatedTextures -> Textures of the player (On Server string, On Client bitmap/file)
;facingDir -> Info about what dir the player is looking in
;facingSince -> Since when has he been facing that way
;x -> X in Pixel-Coords
;y -> Y in Pixel-Coords
;speed -> Speed as whole number, player moves these many Pixel-Coords every MovementTick
;alive -> Is the player alive?
;ready -> Is the player ready? (Used for the lobby/TitleScreen state, ready means the player wants to join the game)
;lives -> How many lives does he have left?
;score -> Whats his current score?
;user -> The name of the current world/Universe controlling the player

(struct player (animatedTextures x y facingDir facingSince speed alive ready lives score user) #:mutable #:transparent)


(define (playerToList e)
  (list (player-animatedTextures e) (player-x e) (player-y e) (player-facingDir e) (player-facingSince e) (player-speed e) (player-alive e) (player-ready e) (player-lives e) (player-score e) (player-user e))
)

(define (listToPlayer lst)
  (apply player lst)
  )





;   extraData-bomb  has the following form: (explodeWhen justPlaced ticksWhenNextAnim numCurrentTexture user)


;explodeWhen -> Time when Bomb will explode in ms, uses  (current-inexact-milliseconds)
;justPlaced -> Whether the bomb was just placed and thus the player is still inside of it
;ticksWhenNextAnim -> >= this tick Count and next texture will be displayed
;numCurrentTexture -> which texture should be displayed right now?
;user -> The name of the owner of the bomb

(struct extraData-bomb (explodeWhen justPlaced ticksWhenNextAnim numCurrentTexture user) #:mutable #:transparent)


(define (extraData-bombToList e)
  (list (extraData-bomb-explodeWhen e) (extraData-bomb-justPlaced e) (extraData-bomb-ticksWhenNextAnim e) (extraData-bomb-numCurrentTexture e) (extraData-bomb-user e))
)

(define (listToextraData-bomb lst)
  (apply extraData-bomb lst)
)





;   extraData-breakingTile  has the following form: (vanishWhen ticksWhenNextAnim numCurrentTexture)


;vanishWhen -> Time when BreakingTile will explode in ms, uses  (current-inexact-milliseconds)
;ticksWhenNextAnim -> >= this tick Count and next texture will be displayed
;numCurrentTexture -> which texture should be displayed right now?

(struct extraData-breakingTile (vanishWhen ticksWhenNextAnim numCurrentTexture) #:mutable #:transparent)


(define (extraData-breakingTileToList e)
  (list (extraData-breakingTile-vanishWhen e) (extraData-breakingTile-ticksWhenNextAnim e) (extraData-breakingTile-numCurrentTexture e))
)

(define (listToextraData-breakingTile lst)
  (apply extraData-breakingTile lst)
)





;   extraData-explosion  has the following form: (texture x y speed alive ready user)


;vanishWhen -> Time when explosionCore will vanish in ms, uses  (current-inexact-milliseconds)
;spreadType -> Whether this is a core or a spread in a direction
;spreadsLeft -> Amount of times left to spread
;didSpread -> Did this part of the explosion spread yet?
;ticksWhenNextAnim -> >= this tick Count and next texture will be displayed
;numCurrentTexture -> which texture should be displayed right now?
;user -> The name of the owner of the explosionCore

(struct extraData-explosion (vanishWhen spreadType spreadsLeft didSpread ticksWhenNextAnim numCurrentTexture user) #:mutable #:transparent)


(define (extraData-explosionToList e)
  (list (extraData-explosion-vanishWhen e) (extraData-explosion-spreadType e) (extraData-explosion-spreadsLeft e) (extraData-explosion-didSpread e) (extraData-explosion-ticksWhenNextAnim e) (extraData-explosion-numCurrentTexture e) (extraData-explosion-user e))
)

(define (listToextraData-explosion lst)
  (apply extraData-explosion lst)
)





;   clientsideState has the following form: ; struct: '(curState tickCount timeLeft livesLeft currentScore gameField players)
;curState -> 'current State of the game on the client. Can either be 'titlescreen 'ingame or 'loadingscreen
;tickCount -> Amount of ticks elapsed since start of the current State. Used for timing animations and logic on the client.
;timeLeft -> Amount of time left till the current round of the game ends
;gameField -> The field received from the server for the current game. The unbreakable tiles are also in the field but they are not drawn visually except on showCollisions toggle.
;players -> List of all the players currently connected to the game/their playerData
;pressedKeys -> List of all currently non released keys
;renderCache -> Cache for frame renders
;renderLastTime -> Last time game was rendered 
;forceKeySend -> Force key tick data to be sent
;user -> Our username

(struct clientsideWorld (curState tickCount timeLeft gameField players pressedKeys forceKeySend renderCache renderLastTime user endTime winner) #:mutable #:transparent)







;   serversideWorld has the following form: ; struct: '(clients isInWaitingStage timeLeft gameWinner)

;clients -> List of all currently connected clients
;isInWaitingStage -> whether we are currently in the waiting stage (waiting for players to connect and press enter on their titlescreen)
;timeLeft -> Time left until the current round of the game ends
;gameWinner -> If set to string len > 0, the name of the world of the user who has won the game. Can also be "timeout" in case everybody lost because of the time out.
;gameField -> The current game Field
;killQueue -> The queue of players to be killed
;tickCount -> The current tick count

(struct serversideWorld (clients isInWaitingStage endTime gameWinner gameField killQueue tickCount) #:mutable #:transparent)







;   clientData has the following form: ; struct: '(player connection isReady)

;player -> The player related data of this user
;connection -> The connection of this user ("iWorld" as racket calls it)

(struct clientData (player connection) #:mutable #:transparent)