#lang racket

;; imports
(require 2htdp/image)
(require lang/posn)
(require "cl_helper.rkt")
(require "sh_config.rkt")
(require "sh_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config_textures.rkt")

;; exports
(provide (all-defined-out))


;; [renderHandleAnimFrameAdvanceLoop] Advances a animation frame. If at frame end, reset to first frame (loop)
(define (renderHandleAnimFrameAdvanceLoop tickCount anim newTextureNum)
    (and
        (set-animatedTexture-ticksWhenNextAnim! anim (+ tickCount (animatedTexture-frameAdvanceTicks anim)) )
        (if (> newTextureNum (length (animatedTexture-textures anim)))
            (set-animatedTexture-currentTextureNum! anim 1)
            (set-animatedTexture-currentTextureNum! anim newTextureNum)
        )

        anim
    )
)

;; [renderHandleAnimFrameAdvanceNoLoop] Advances a animation frame. If at frame end, do not change anything (no loop)
(define (renderHandleAnimFrameAdvanceNoLoop tickCount anim newTextureNum)
    (and
        (set-animatedTexture-ticksWhenNextAnim! anim (+ tickCount (animatedTexture-frameAdvanceTicks anim)) )
        (if (> newTextureNum (length (animatedTexture-textures anim)))
          anim
          (set-animatedTexture-currentTextureNum! anim newTextureNum)
        )
    )
)

;; [renderHandleAnimFrameAdvance] Calls the fitting function to advance the animation frame depending on the loop settings and incrments the current textureNumber
(define (renderHandleAnimFrameAdvance tickCount anim)
  (let ([newTextureNum (+ 1 (animatedTexture-currentTextureNum anim))])
    (if (animatedTexture-shouldLoop anim)
      (renderHandleAnimFrameAdvanceLoop tickCount anim newTextureNum)
      (renderHandleAnimFrameAdvanceNoLoop tickCount anim newTextureNum)
    )
  )
)

;; [renderHandleAnimFrameAdvance] Checks if frame should be advanced. If yes, call [renderHandleAnimFrameAdvance] to advance it
(define (renderHandleAnimFrameAdvanceIfShould tickCount anim)
  (if (or (animatedTexture-isPaused anim) (> (animatedTexture-ticksWhenNextAnim anim) tickCount))
    anim
    (renderHandleAnimFrameAdvance tickCount anim)
  )
)

;; [renderHandleAnimFrame] Renders a frame of a animatedTexture
(define (renderHandleAnimFrame tickCount anim)
  (define textures (animatedTexture-textures anim))
  (define currentTextureNum (animatedTexture-currentTextureNum anim))

  (list-ref textures (- currentTextureNum 1))
)

;; [renderGameElementG] Renders a game element using [renderHandleAnimFrame] and does the advancement handling by calling [renderHandleAnimFrameAdvanceIfShould]
(define (renderGameElementG tickCount elem anim extraData)
  (and
    (renderHandleAnimFrameAdvanceIfShould tickCount anim)
    (renderHandleAnimFrame tickCount anim)
  )
)

;; [renderGameElement] Calls [renderGameElementG] for valid elements. If a elementName is unknown, draws a error
(define (renderGameElement tickCount elem anim extraData)
  (define elementName (fieldElement-elementName elem))

  (case elementName
    ['unbreakableTile (renderGameElementG tickCount elem anim extraData) ]
    ['breakableTile  (renderGameElementG tickCount elem anim extraData) ]
    ['breakingTile (renderGameElementG tickCount elem anim extraData) ]
    ['bomb  (renderGameElementG tickCount elem anim extraData) ]
    ['explosion  (renderGameElementG tickCount elem anim extraData) ]
    [else (text (string-append (symbol->string elementName) "IS NOT A VALID ELEMENT") 18 "red")]
  )
)

;; [renderGameElementCollisions] Draws collision bounds for 'breakableTile and 'unbreakableTile, for other elements calls [renderGameElement]
(define (renderGameElementCollisions tickCount elem anim extraData)
  (cond
    [(equal? (fieldElement-elementName elem) 'unbreakableTile)  (rectangle (tileToCoord (fieldElement-wtiles elem)) (tileToCoord (fieldElement-ytiles elem)) "solid" "blue") ]
    [(equal? (fieldElement-elementName elem) 'breakableTile)  (rectangle (tileToCoord (fieldElement-wtiles elem)) (tileToCoord (fieldElement-ytiles elem)) "solid" "white") ]
    [else (renderGameElement  tickCount elem anim extraData)]
  )
)

;; [renderGameElementsEWithCollisions] Renders game elements with drawing collision bounds
(define (renderGameElementsEWithCollisions tickCount elements)
  (for/list ([element elements])
    (renderGameElementCollisions tickCount element (fieldElement-animatedTexture element) (fieldElement-extraData element))
  )
)

;; [renderGameElementsEWithoutCollisions] Renders game elements without drawing collision bounds
(define (renderGameElementsEWithoutCollisions tickCount elements)
  (for/list ([element elements])
    (renderGameElement tickCount element (fieldElement-animatedTexture element) (fieldElement-extraData element))
  )
)

;; [renderGameElementsE] Calls the right render function depending on whether game should render collisionBounds
(define (renderGameElementsE world tickCount elements)
  (if gameRenderCollisionBounds
    (renderGameElementsEWithCollisions tickCount elements)
    (renderGameElementsEWithoutCollisions tickCount (filter (lambda (elem) (not (equal? (fieldElement-elementName elem) 'unbreakableTile))) elements) )
  )
)

;; [renderGameElementsP] Calculates the posn for every game Element
(define (renderGameElementsP elements)
  (for/list ([element elements])
    (make-posn (tileToCoord (fieldElement-xtiles element)) (tileToCoordY (fieldElement-ytiles element)))
  )
)

;; [renderPlayer] Gets the current active texture of the player, calls funcs to render it and advance if needed
(define (renderPlayer tickCount player)
  (let* (
      [facingDir (player-facingDir player)]
      [facingSince (player-facingSince player)]
      [animtextures (player-animatedTextures player)]
      [anim (assoc facingDir animtextures)])

      (if anim
        (if (> (+ 100 facingSince) (current-inexact-milliseconds) )
          (and (renderHandleAnimFrameAdvanceIfShould tickCount (second anim)) (renderHandleAnimFrame tickCount (second anim)))
          (renderHandleAnimFrame tickCount  (second anim))
        )
        (rectangle
          gameTileSize
          gameTileSize
          "solid"
          "grey"
        )
      )
  )
)

;; [renderPlayersE] Renders all the players
(define (renderPlayersE tickCount currentWorld)
  (define players (clientsideWorld-players currentWorld))

  (for/list ([player players])
    (renderPlayer tickCount player)
  )
)

;; [renderPlayersP] Calcuates the posn for every player
(define (renderPlayersP currentWorld)
  (define players (clientsideWorld-players currentWorld))
  
  (for/list ([player players])
    (make-posn (player-x player) (+ (player-y player) gameScoreHeight))
  )
)

;; [renderGameScore] Renders our current score
(define (renderGameScore currentWorld localPlayer)
  (place-images/align
    (list
      (text
        (string-append "     TIME    "  (string-append (number->string (clientsideWorld-timeLeft currentWorld)) "                ")                "CURSCORE "   (number->string (player-score localPlayer)) "               LIVES   " (number->string (player-lives localPlayer)))
        24
        "white"
      )
    )
    (list
      (make-posn 0 (* gameScoreHeight 0.4))
    )
    "left"
    "top"
    (rectangle
      gameWidth
      gameScoreHeight
      "solid"
      "grey"
    )
  )
)

;; [renderRespawnText] Renders the respawn text
(define (renderRespawnText currentWorld localPlayer)
  (if (player-alive localPlayer)
    (text "" 1 "white")
    (text "HIT SPACE TO RESPAWN" 18 "red")
  )
)

;; [renderGameOver] Renders gameover
(define (renderGameOver currentWorld localPlayer)
  (place-images/align
    (list
      (text
        (string-append "     TIME    0             CURSCORE  0       GAME OVER   ")
        24
        "red"
      )
    )
    (list
      (make-posn 0 (* gameScoreHeight 0.4))
    )
    "left"
    "top"
    (rectangle
      gameWidth
      gameScoreHeight
      "solid"
      "black"
    )
  )
)


;; [renderGameR]  Renders the HUD
(define (renderHUD currentWorld localPlayer)
  
  (if (and (not (player-alive localPlayer)) (= 0 (player-lives localPlayer)))
    (list
      (renderGameOver currentWorld localPlayer)
      (text "" 1 "white")
    )
    (list
      (renderRespawnText currentWorld localPlayer)
      (renderGameScore currentWorld localPlayer)
    )
  )

)
;; [renderGameR]  Renders the current game
(define (renderGameR currentWorld elements)
  (define localPlayer (getLocalPlayer currentWorld))

  (place-images/align
    (append
      (renderHUD currentWorld localPlayer) 
      (renderGameElementsE currentWorld (clientsideWorld-tickCount currentWorld) elements)
      (renderPlayersE (clientsideWorld-tickCount currentWorld) currentWorld)
    )
    (append
      (list (make-posn 0 0) (make-posn 0 0) )
      (renderGameElementsP elements)
      (renderPlayersP currentWorld)
    )
    "left"
    "top"
    gameBackgroundTexture
  )
)

;; [renderGame] Calls functions to render the game and if collision bounds should not be drawn, removes 'unbreakableTile from element list (since we don't need to draw them extra)
(define (renderGame currentWorld)
  (if gameRenderCollisionBounds
    (renderGameR currentWorld (clientsideWorld-gameField currentWorld))
    (renderGameR currentWorld (filter (lambda (elem) (not (equal? (fieldElement-elementName elem) 'unbreakableTile)) ) (clientsideWorld-gameField currentWorld)))
  )
)