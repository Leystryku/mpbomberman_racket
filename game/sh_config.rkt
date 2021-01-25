#lang racket

;; import
(require 2htdp/image)
(require "sh_structs.rkt")

;; export
(provide (all-defined-out))


;;; === configurations for network ===

;; enable sound?
;; 0 = no sound, 1 = windows only, -1 = all os
(define soundEnabled -1)

;; at what FPS should the game client render?
(define gameFPSRender 24)

;; at what FPS should the game client tick?
(define gameFPSTick 60)

;; how many players must be ready till game starts? (> gameMinumPlayers)
(define gameMinimumPlayers 1)

;; every gameMoveTicksEvery tick will be spent on checking key input and sending data if required from key handlers. the lower this is the faster you move
(define gameMoveTicksEvery (ceiling (/ gameFPSTick 6)))

;;every gameSharedTicksEvery tick will be spent on shared tick (element logic)
(define gameSharedTicksEvery (ceiling (/ gameFPSTick 10)))

;; at what FPS should the server tick?
(define gameServerFPS gameSharedTicksEvery)

;;every gameHandleDeathsEvery tick will be spent on making the server transfer kills to the client
(define gameHandleDeathsEvery (+ gameMoveTicksEvery 1))

;; amount of lifes a player gets when connecting
(define gamePlayerLifes 5)

;;duration a game lasts in seconds 
(define gameTime (* 60 3))

;debug network? (cl->sv msgs)
(define debugNetwork #f)

; how many breakable walls should at least be placed in % (0 -> 0%, 1 -> 100%)
(define gameMinimumPercentageRandomTiles 0.2)

; how many breakable walls should at max be placed in % (0 -> 0%, 1 -> 100%)
(define gameMaximumPercentageRandomTiles 1.0)






;;; === configurations for players ===

;when should the next walking anim be played
(define playerTickCountTillNextAnim (ceiling (/ gameFPSTick 15)))

;when should the next dying anim be played
(define playerDeathTickCountTillNextAnim (* playerTickCountTillNextAnim 4))

;;; ===  configurations for breaking tiles ===
(define breakingTileTickCountTillNextAnim (* playerTickCountTillNextAnim 2))
(define breakingTileVanishInMs 600)






;;; ===  configurations for bombs ===

; when do bombs explode by default in ms
(define bombMinimumExplodeDelay 1500)

(define bombMaximumExplodeDelay 3000)

; how many bombs can 2 player have max on the field by default
(define bombMaximumtAmountPerPlayer 2)

(define bombTickCountTillNextAnim (* playerTickCountTillNextAnim 2))


(define gameBombsCanExplodeEachOther #t)






;;; === configurations for explosion ====

(define explosionVanishInMs 630)

;; explosion core
;How far should explosions spread
(define explosionCoreRange 2)
;How many ticks till next frame
(define explosionTickCountTillNextAnim (ceiling (* playerTickCountTillNextAnim 2.5)))






;;; ===  configurations for collision ===

;; render collision bounds for unbreakable walls?
(define gameRenderCollisionBounds #f)

;; no collisions for players?
(define gamePlayersNoCollide #f)


;; no collisions with objects on the field?
(define gameEntitiesNoCollide #f)

; disable generation of random walls
(define noRandomWalls #f)






;;; ===  configurations for GUI ===

;; how large should the game be
(define gameWidth 680)
(define gameHeight 600)

;;how large should each tile be (their size = their width = their height)
(define gameTileSize 40)

;;how many tiles wide should the  is the gamefiled in tiles
(define gameFieldWidthTiles 17)

;;how many tiles high should the  is the gamefiled in tiles
(define gameFieldHeightTiles 13)

;;how tall should the score display be
(define gameScoreHeight (inexact->exact (* gameTileSize 2)))

;;how large should the gameField be
(define gameFieldWidth gameWidth)
(define gameFieldHeight (- gameHeight gameScoreHeight))

;; where does the game field start
(define gameFieldY gameScoreHeight)

;; right tile border
(define rightBorderXt (- gameFieldWidthTiles 1))
;; bottom tile border
(define bottomBorderYt (- gameFieldHeightTiles 1))



;; this is here because we need it for the spawns and the spawn ss ould be in config, otherwise this would belong in sh_helper but since the spawns need to be here, this is here.

(define (tileToCoord tv)
    (* tv gameTileSize)
)

(define (tileToCoordY tv)
    (+
        (* tv gameTileSize)
        gameScoreHeight
    )
)






;;; === configuration for default player properties ===


(define gamePlayerSpeed 4)

(define gamePlayerSpawns
    (list
        (list (+ gameTileSize 1) (+ gameTileSize 1)) ; player 1
        (list (+ (- (tileToCoord rightBorderXt) gameTileSize ) 1) (- (tileToCoord bottomBorderYt) gameTileSize 1) ) ; player 2
        (list (+ (- (tileToCoord rightBorderXt) gameTileSize ) 1) (- gameTileSize 1)) ; player 3
        (list (+ gameTileSize 1) (- (tileToCoord bottomBorderYt) gameTileSize 1)) ; player 4
    )
)






;;; === load configuration for texture paths ===
(require "sh_config_textures.rkt")







;;; ===  configuration for animated Textures ===
;; (yes, these are procedures on purpose. We need a different struct for every animated thing)

; breakableTile
(define (animatedBreakableTile)
    (animatedTexture 0 bombTickCountTillNextAnim 1 #f #t 'breakableTile (list txtBreakableTile))
)

; bomb
(define (animatedTextureBomb)
    (animatedTexture 0 bombTickCountTillNextAnim 1 #t #f 'bombAnim (list txtBomb3 txtBomb2 txtBomb1 txtBomb2 txtBomb1 txtBomb2))
)

; breakingTile
(define (animatedTextureBreakingTile)
    (animatedTexture 0 breakingTileTickCountTillNextAnim 1 #f #f 'breakingTileAnim (list txtBreakingTile1 txtBreakingTile2 txtBreakingTile3 txtBreakingTile4 txtBreakingTile5 txtBreakingTile6))
)

;; players
(define animatedTexturesPlayer1
    (list
        (list 'up (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'up (list txtPlayer1Up1 txtPlayer1Up2 txtPlayer1Up3 txtPlayer1Up4)))
        (list 'down (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'down (list txtPlayer1Down1 txtPlayer1Down2 txtPlayer1Down3 txtPlayer1Down4)))
        (list 'left (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'left (list txtPlayer1Left1 txtPlayer1Left2 txtPlayer1Left3 txtPlayer1Left4)))
        (list 'right (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'right (list txtPlayer1Right1 txtPlayer1Right2 txtPlayer1Right3 txtPlayer1Right4)))
        (list 'dying (animatedTexture 0 playerDeathTickCountTillNextAnim 1 #f #f 'dying (list txtPlayer1Die1 txtPlayer1Die2 txtPlayer1Die3 txtPlayer1Die4 txtPlayer1Die5 txtPlayer1Die6 txtPlayer1Die7 txtPlayer1Die8)))
    )
)

(define animatedTexturesPlayer2
    (list
        (list 'up (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'up (list txtPlayer2Up1 txtPlayer2Up2 txtPlayer2Up3)))
        (list 'down (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'down (list txtPlayer2Down1 txtPlayer2Down2 txtPlayer2Down3)))
        (list 'left (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'left (list txtPlayer2Left1 txtPlayer2Left2 txtPlayer2Left3)))
        (list 'right (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'right (list txtPlayer2Right1 txtPlayer2Right2 txtPlayer2Right3)))
        (list 'dying (animatedTexture 0 playerDeathTickCountTillNextAnim 1 #f #f 'dying (list txtPlayer2Die1 txtPlayer2Die2 txtPlayer2Die3 txtPlayer2Die4 txtPlayer2Die5 txtPlayer2Die6 txtPlayer2Die7 txtPlayer2Die8)))
    )
)

(define animatedTexturesPlayer3
    (list
        (list 'up (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'up (list txtPlayer3Up1 txtPlayer3Up2 txtPlayer3Up3)))
        (list 'down (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'down (list txtPlayer3Down1 txtPlayer3Down2 txtPlayer3Down3)))
        (list 'left (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'left (list txtPlayer3Left1 txtPlayer3Left2 txtPlayer3Left3)))
        (list 'right (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'right (list txtPlayer3Right1 txtPlayer3Right2 txtPlayer3Right3)))
        (list 'dying (animatedTexture 0 playerDeathTickCountTillNextAnim 1 #f #f 'dying (list txtPlayer3Die1 txtPlayer3Die2 txtPlayer3Die3 txtPlayer3Die4 txtPlayer3Die5 txtPlayer3Die6 txtPlayer3Die7 txtPlayer3Die8)))
    )
)

(define animatedTexturesPlayer4
    (list
        (list 'up (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'up (list txtPlayer4Up1 txtPlayer4Up2 txtPlayer4Up3)))
        (list 'down (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'down (list txtPlayer4Down1 txtPlayer4Down2 txtPlayer4Down3)))
        (list 'left (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'left (list txtPlayer4Left1 txtPlayer4Left2 txtPlayer4Left3)))
        (list 'right (animatedTexture 0 playerTickCountTillNextAnim 1 #t #f 'right (list txtPlayer4Right1 txtPlayer4Right2 txtPlayer4Right3)))
        (list 'dying (animatedTexture 0 playerDeathTickCountTillNextAnim 1 #f #f 'dying (list txtPlayer4Die1 txtPlayer4Die2 txtPlayer4Die3 txtPlayer4Die4 txtPlayer4Die5 txtPlayer4Die6 txtPlayer4Die7 txtPlayer4Die8)))
    )
)

;; explosions
;; core
(define (animatedTextureExplosionCore)
    (animatedTexture 0 explosionTickCountTillNextAnim 1 #f #f 'explosionCore (list txtExplosionCore1 txtExplosionCore2 txtExplosionCore3 txtExplosionCore4 txtExplosionCore3 txtExplosionCore2 txtExplosionCore1))
)

;; up
(define (animatedTextureExplosionUp)
    (animatedTexture 0 explosionTickCountTillNextAnim 1 #f #f 'explosionUp (list txtExplosionUp1 txtExplosionUp2 txtExplosionUp3 txtExplosionUp4 txtExplosionUp3 txtExplosionUp2 txtExplosionUp1))
)

;; down
(define (animatedTextureExplosionDown)
    (animatedTexture 0 explosionTickCountTillNextAnim 1 #f #f 'explosionDown (list txtExplosionDown1 txtExplosionDown2 txtExplosionDown3 txtExplosionDown4 txtExplosionDown3 txtExplosionDown2 txtExplosionDown1))
)

;; left
(define (animatedTextureExplosionLeft)
    (animatedTexture 0 explosionTickCountTillNextAnim 1 #f #f 'explosionLeft (list txtExplosionLeft1 txtExplosionLeft2 txtExplosionLeft3 txtExplosionLeft4 txtExplosionLeft3 txtExplosionLeft2 txtExplosionLeft1))
)

;; right
(define (animatedTextureExplosionRight)
    (animatedTexture 0 explosionTickCountTillNextAnim 1 #f #f 'explosionRight (list txtExplosionRight1 txtExplosionRight2 txtExplosionRight3 txtExplosionRight4 txtExplosionRight3 txtExplosionRight2 txtExplosionRight1))
)


#| --- configuration for default field/these tiles are always there --- |#

;fieldElements haben die Form: '(elementName xtiles ytiles wtiles htiles)

(define fieldLevel1
  (list
    (fieldElement 'unbreakableTile 0 0 gameFieldWidthTiles 1 #f #f) ; top
    (fieldElement 'unbreakableTile 0 bottomBorderYt gameFieldWidthTiles 1 #f #f) ; bottom
    (fieldElement 'unbreakableTile 0 0 1 gameFieldHeightTiles #f #f) ; left
    (fieldElement 'unbreakableTile rightBorderXt 0 1 gameFieldHeightTiles #f #f) ; right

    
    (fieldElement 'unbreakableTile 2 2 1 9 #f #f) ; strip 1
    (fieldElement 'unbreakableTile 4 2 1 9 #f #f) ; strip 2
    (fieldElement 'unbreakableTile 6 2 1 9 #f #f) ; strip 3
    (fieldElement 'unbreakableTile 8 2 1 9 #f #f) ; strip 4
    (fieldElement 'unbreakableTile 10 2 1 9 #f #f) ; strip 5
    (fieldElement 'unbreakableTile 12 2 1 9 #f #f) ; strip 6
    (fieldElement 'unbreakableTile 14 2 1 9 #f #f) ; strip 7
    
    )
  )

(define fieldLevel2
  (list
    (fieldElement 'unbreakableTile 0 0 gameFieldWidthTiles 1 #f #f) ; top
    (fieldElement 'unbreakableTile 0 bottomBorderYt gameFieldWidthTiles 1 #f #f) ; bottom
    (fieldElement 'unbreakableTile 0 0 1 gameFieldHeightTiles #f #f) ; left
    (fieldElement 'unbreakableTile rightBorderXt 0 1 gameFieldHeightTiles #f #f) ; right

    
    (fieldElement 'unbreakableTile 2 2 1 1 #f #f) ; alignment 1
    (fieldElement 'unbreakableTile 4 2 1 1 #f #f) ; alignment 2
    (fieldElement 'unbreakableTile 6 2 1 1 #f #f) ; alignment 3
    (fieldElement 'unbreakableTile 8 2 1 1 #f #f) ; alignment 4
    (fieldElement 'unbreakableTile 10 2 1 1 #f #f) ; alignment 5
    (fieldElement 'unbreakableTile 12 2 1 1 #f #f) ; alignment 6
    (fieldElement 'unbreakableTile 14 2 1 1 #f #f) ; alignment 7

    (fieldElement 'unbreakableTile 2 4 1 1 #f #f) ; alignment 1
    (fieldElement 'unbreakableTile 4 4 1 1 #f #f) ; alignment 2
    (fieldElement 'unbreakableTile 6 4 1 1 #f #f) ; alignment 3
    (fieldElement 'unbreakableTile 8 4 1 1 #f #f) ; alignment 4
    (fieldElement 'unbreakableTile 10 4 1 1 #f #f) ; alignment 5
    (fieldElement 'unbreakableTile 12 4 1 1 #f #f) ; alignment 6
    (fieldElement 'unbreakableTile 14 4 1 1 #f #f) ; alignment 7

    (fieldElement 'unbreakableTile 2 6 1 1 #f #f) ; alignment 1
    (fieldElement 'unbreakableTile 4 6 1 1 #f #f) ; alignment 2
    (fieldElement 'unbreakableTile 6 6 1 1 #f #f) ; alignment 3
    (fieldElement 'unbreakableTile 8 6 1 1 #f #f) ; alignment 4
    (fieldElement 'unbreakableTile 10 6 1 1 #f #f) ; alignment 5
    (fieldElement 'unbreakableTile 12 6 1 1 #f #f) ; alignment 6
    (fieldElement 'unbreakableTile 14 6 1 1 #f #f) ; alignment 7

    (fieldElement 'unbreakableTile 2 8 1 1 #f #f) ; alignment 1
    (fieldElement 'unbreakableTile 4 8 1 1 #f #f) ; alignment 2
    (fieldElement 'unbreakableTile 6 8 1 1 #f #f) ; alignment 3
    (fieldElement 'unbreakableTile 8 8 1 1 #f #f) ; alignment 4
    (fieldElement 'unbreakableTile 10 8 1 1 #f #f) ; alignment 5
    (fieldElement 'unbreakableTile 12 8 1 1 #f #f) ; alignment 6
    (fieldElement 'unbreakableTile 14 8 1 1 #f #f) ; alignment 7

    (fieldElement 'unbreakableTile 2 10 1 1 #f #f) ; alignment 1
    (fieldElement 'unbreakableTile 4 10 1 1 #f #f) ; alignment 2
    (fieldElement 'unbreakableTile 6 10 1 1 #f #f) ; alignment 3
    (fieldElement 'unbreakableTile 8 10 1 1 #f #f) ; alignment 4
    (fieldElement 'unbreakableTile 10 10 1 1 #f #f) ; alignment 5
    (fieldElement 'unbreakableTile 12 10 1 1 #f #f) ; alignment 6
    (fieldElement 'unbreakableTile 14 10 1 1 #f #f) ; alignment 7
    
    )
  )



;; config to set level
(define gameBackgroundTexture txtLevel2)
(define gameField fieldLevel2)


