#lang racket

;; imports
(require 2htdp/universe)
(require 2htdp/image)
(require "cl_sound.rkt")
(require "cl_helper.rkt")
(require "cl_network.rkt")
(require "cl_collisions.rkt")
(require "cl_sound.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")
(require "sh_helper.rkt")
(require "sh_collisions.rkt")
(require "sh_config_snds.rkt")

;; exports
(provide (all-defined-out))


;; [calculateNewPlayerPosUDGoClose] checks if position (x y) is valid and returns it if it is, else returns old Positon
(define (calculateNewPlayerPosGoClose currentWorld player x y oldPos user)
  (if (isValidDesiredPosMove currentWorld x y gameTileSize gameTileSize user)
    (list x y)
    oldPos
  )
)

;; [decIfHasTo] Decrements a number if true, else increments it
(define (decIfHasTo shoulddec val)
  (if shoulddec
    (- val 1)
    (+ val 1)
  )
)

;; [alignMoveNumX] Aligns a x move value to the current field
(define (alignMoveNumX shoulddec val)
  (if (= (modulo val gameTileSize) 0)
    (+ val 1)
    (if shoulddec
      (+ (- val (modulo val gameTileSize) ) 1)
      (+ (- val (modulo val gameTileSize) ) 1)
    )
  )
)

;; [alignMoveNumY] Aligns a y move value to the current field
(define (alignMoveNumY shoulddec val)
  (if (= (modulo (- val gameScoreHeight) gameTileSize) 0)
    (+ val 1)
    (if shoulddec
      (+ (- val (modulo (- val gameScoreHeight) gameTileSize) ) 1)
      (+ (- val (modulo (- val gameScoreHeight) gameTileSize) ) 1)
    )
  )
)

;; [calculateNewPlayerPosUDGoCloseIfWants] returns a slightly moved up/down player depending on his X on the game field. This is used to smooth out vertical movement.
(define (calculateNewPlayerPosUDGoCloseIfWants currentWorld player newPos oldPos user)
  (let* (
        [cury (second newPos)]
        [sy (exact->inexact (/ (modulo cury gameTileSize) gameTileSize))]
        [ty (round (coordToTile cury))]
        [by (exact->inexact (coordToTile (modulo ty gameTileSize)))]
        [ty2b (tileToCoord (+ ty 1))]
        [ty3b (tileToCoord (- ty 1))]
        [goUp (> (abs (- ty3b cury)) (abs (- ty2b cury)))]
        )

      (if (= by 0.05)
        oldPos
        (cond
          [(<= 0 sy 0.09) (calculateNewPlayerPosGoClose currentWorld player (first oldPos) (alignMoveNumX goUp cury) oldPos  user)]
          [(<= 0 sy 0.32)  (calculateNewPlayerPosGoClose currentWorld player (first oldPos) (decIfHasTo goUp cury) oldPos  user)]
          [(<= 0.68 sy 1.0) (calculateNewPlayerPosGoClose currentWorld player (first oldPos) (decIfHasTo goUp cury) oldPos  user)]
          [else oldPos]
        )
      )
    )
)

;; [calculateNewPlayerPosLRGoClose] returns a slightly moved left/right player depending on his X on the game field. This is used to smooth out vertical movement.
(define (calculateNewPlayerPosLRGoCloseIfWants currentWorld player newPos oldPos user)
  (let* (
        [curx (first newPos)]
        [sx (exact->inexact (/ (modulo curx gameTileSize) gameTileSize))]
        [tx (round (coordToTile curx))]
        [bx (exact->inexact (coordToTile (modulo tx gameTileSize)))]
        [tx2b (tileToCoord (+ tx 1))]
        [tx3b (tileToCoord (- tx 1))]
        [goUp (> (abs (- tx3b curx)) (abs (- tx2b curx)))]
        )

      (if (= bx 0.05)
        oldPos
        (cond
          [(<= 0 sx 0.09) (calculateNewPlayerPosGoClose currentWorld player (alignMoveNumY goUp curx) (second oldPos) oldPos  user)]
          [(<= 0 sx 0.32)  (calculateNewPlayerPosGoClose currentWorld player (decIfHasTo goUp curx) (second oldPos) oldPos  user)]
          [(<= 0.68 sx 1.0) (calculateNewPlayerPosGoClose currentWorld player (decIfHasTo goUp curx) (second oldPos) oldPos  user)]
          [else oldPos]
        )
      )
    )
)

;; [calculateNewPlayerPosVertical] returns a {list} with x and y if the position is valid. Otherwise, it calls another function to correct it
(define (calculateNewPlayerPosVertical currentWorld player newPos oldPos user)
  (if (isValidDesiredPosMoveLst currentWorld newPos gameTileSize gameTileSize user)
    newPos
    (calculateNewPlayerPosLRGoCloseIfWants currentWorld player newPos oldPos user)
  )
)

;; [calculateNewPlayerPosHorizontal] returns a {list} with x and y if the position is valid. Otherwise, it calls another function to correct it
(define (calculateNewPlayerPosHorizontal currentWorld player newPos oldPos user)
  (if (isValidDesiredPosMoveLst currentWorld newPos gameTileSize gameTileSize user)
    newPos
    (calculateNewPlayerPosUDGoCloseIfWants currentWorld player newPos oldPos user)
  )
)

;; [calculateNewPlayerPos] returns a new player position depenedent on his current position from his {player} struct and the moveDir.
(define (calculateNewPlayerPosMoveDir currentWorld player moveDir speed user)
  (define x (player-x player))
  (define y (player-y player))
  (if (<= speed 0)
    (list x y)
    (case moveDir
      ['up (calculateNewPlayerPosVertical currentWorld player (list x (- y speed)) (list x y) user)]
      ['down (calculateNewPlayerPosVertical currentWorld player (list x (+ y speed)) (list x y) user)]
      ['left (calculateNewPlayerPosHorizontal currentWorld player (list (- x speed) y) (list x y) user)]
      ['right (calculateNewPlayerPosHorizontal currentWorld player (list (+ x speed) y) (list x y) user)]
      [else (list x y)]
    )
  )
)


;; [keyPressedLayBomb] sends a bomb if can be to be placed on the field if one can be placed at the current playerpos
(define (keyPressedLayBomb currentWorld user)
  (let* ([localPos (getPlayerPos currentWorld user)]
        [field (clientsideWorld-gameField currentWorld)]
        [canPlaceBombs (canPlayerPlaceBombs currentWorld field user)]
        [xTiles (round (coordToTile (car localPos)))]
        [yTiles (round (coordToTile (cadr localPos)))]
        [newBomb (list "bomb" xTiles yTiles)]
        [playersBombs (getPlayersBombs currentWorld field user)]
        )

    (if (and canPlaceBombs (isValidDesiredPosEntsR playersBombs (tileToCoord xTiles) (tileToCoord yTiles) gameTileSize gameTileSize user #t))
      (and
        (set-clientsideWorld-forceKeySend! currentWorld #t)
        (play-our-sound sndLayBomb)
        (sendToServer currentWorld "bomb" newBomb)
      )
      currentWorld
    )
  )
)

;; [keyPressedTryRespawn] requests a respawn from the server
(define (keyPressedTryRespawn currentWorld user)
  (and
    (set-clientsideWorld-forceKeySend! currentWorld #t)
    (if (> (player-lives (getPlayerByUser currentWorld user)) 0)
      (sendToServer currentWorld "respawn" (list "respawn"))
      (and
        (play-our-sound sndRespawnInvalid)
        currentWorld
      )
    )
  )
)

;; [keyPressedEnterIngame] Is called whenever confirmation key is pressed while ingame
(define (keyPressedEnterIngame currentWorld user)
  (define curPlayer (getPlayerByUser currentWorld user))

  (if (player-alive curPlayer)
    (keyPressedLayBomb currentWorld user)
    (keyPressedTryRespawn currentWorld user)
  )
)

;; [keyPressedIngameMove] sends a move packet to the server
(define (keyPressedIngameMove currentWorld move user)
  (let* ([curPlayer (getPlayerByUser currentWorld user)]
        [newPos (calculateNewPlayerPosMoveDir currentWorld curPlayer move (player-speed curPlayer) user)]
        [oldPos (getPlayerPos currentWorld user)]
        [alive (player-alive curPlayer)])

    (if alive
      (and
        (setPlayerPosPlayer curPlayer (car newPos) (cadr newPos) move)
        ;(play-our-sound sndWalk)
        (sendToServer
          currentWorld
          "move"
          (append
            '("movedto")
            (list
              newPos
              move
              (+ 1000 (current-inexact-milliseconds))
            )
          )
        )
      )
      currentWorld
    )
  )
)


;; [keyPressedEnterGame] sets our stage to the loadingscreen stage
(define (keyPressedEnterGame currentWorld user)
  (and
    (stop-our-sound)
    (set-clientsideWorld-curState! currentWorld "loadingscreen")
    (set-clientsideWorld-tickCount! currentWorld 0)
    currentWorld
  )
)

;; [keyPressedSpace] checks the current state and depending on it calls the function to either skip the titlescreen, lay a bomb or does nothing
;; this is handled seperately because you hit the key only once, while the movekeys (W|A|S|D) will be held
(define (keyPressedSpace currentWorld pressedKey user)
  (cond
    [(equal? (clientsideWorld-curState currentWorld) "titlescreen") (keyPressedEnterGame currentWorld user)]
    [(equal? (clientsideWorld-curState currentWorld) "ingame") (keyPressedEnterIngame currentWorld user)]
    [else currentWorld]
  )
)

;; [keyPressedTickIngame] Is called every tick to process current waiting key presses for the ingame state
(define (keyPressedTickIngame currentWorld pressedKey user)
  (cond
    [(key=? pressedKey "w") (keyPressedIngameMove currentWorld 'up user)]
    [(key=? pressedKey "s") (keyPressedIngameMove currentWorld 'down user)]
    [(key=? pressedKey "a") (keyPressedIngameMove currentWorld 'left user)]
    [(key=? pressedKey "d") (keyPressedIngameMove currentWorld 'right user)]
    [else #f]
  )
)


;; [keyPressedTick] Is called every tick to process current waiting key presses
(define (keyPressedTick currentWorld pressedKey user)
  (if (equal? (clientsideWorld-curState currentWorld) "ingame")
    (or (keyPressedTickIngame currentWorld pressedKey user) currentWorld)
    #f
  )
)

;; [keyTickWithKeys] Checks if there are any keys being pressed, and if yes calls [keyPressedTick] to process them
(define (keyTickWithKeys currentWorld currentKeys user)
  (if (empty? currentKeys)
    #f
    (or
      (keyPressedTick currentWorld (car currentKeys) user)
      (keyTickWithKeys currentWorld (cdr currentKeys) user)
    )
  )
)

;; [keyTick] Is called every tick and gets the current pressed keys and calls [keyTickWithKeys] with them
(define (keyTick currentWorld user)
  (define currentKeys (clientsideWorld-pressedKeys currentWorld))
  (keyTickWithKeys currentWorld currentKeys user)
)

;; [keyIsMovementKey] Checks whether the current key is a movement Key
(define (keyIsMovementKey pressedKey)
  (cond
    [(key=? pressedKey "w") #t]
    [(key=? pressedKey "s") #t]
    [(key=? pressedKey "a") #t]
    [(key=? pressedKey "d")  #t]
    [else #f]
  )
)

;; [keyIsSubmitKey] Checks whether the current key is a submit key
(define (keyIsSubmitKey pressedKey)
  (cond
    [(key=? pressedKey "\r") #t]
    [(key=? pressedKey " ") #t]
    [else #f]
  )
)

;; [keyPressedMovementKey] Appends the current movementKey to the list of pressedKeys
(define (keyPressedMovementKey currentKeys currentWorld pressedKey user)
  (if (member pressedKey currentKeys)
    currentWorld
    (and
      (set-clientsideWorld-pressedKeys!
        currentWorld
        (append currentKeys (list pressedKey))
      )
      currentWorld
    )
  )
)

;; [keyPressedMovementKey] Appends the current movementKey to the list of pressedKeys
(define (keyPressed currentWorld pressedKey user)
  (define currentKeys (clientsideWorld-pressedKeys currentWorld))

  (cond
    [(keyIsSubmitKey pressedKey) (keyPressedSpace currentWorld pressedKey user)]
    [(keyIsMovementKey pressedKey) (keyPressedMovementKey currentKeys currentWorld pressedKey user)]
    [else currentWorld]
  )
)

;; [keyPressedMovementKey] Appends the current movementKey to the list of pressedKeys
(define (keyReleasedMovementKey currentKeys currentWorld pressedKey user)
  (if (not (member pressedKey currentKeys))
    currentWorld
    (and
      (set-clientsideWorld-pressedKeys! currentWorld (remove pressedKey currentKeys))
      currentWorld
    )
  )
)

;; [keyPressedMovementKey] Appends the current movementKey to the list of pressedKeys
(define (keyReleased currentWorld pressedKey user)
  (define currentKeys (clientsideWorld-pressedKeys currentWorld))

  (cond
    [(keyIsMovementKey pressedKey) (keyReleasedMovementKey currentKeys currentWorld pressedKey user)]
    [else currentWorld]
  )
)