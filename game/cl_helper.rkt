#lang racket

;; imports
(require 2htdp/image)
(require "sh_config.rkt")
(require "sh_structs.rkt")

;; exports
(provide (all-defined-out))


;; [interp] makes a number go from the number from to the number to depending on frac (fraction between 0.0, 0% and 1.0, 100%)
(define (interp from to frac)
  (cond
    [(> frac 1)  (to)]
    [(< frac 0)  (from)]
    [else (+ (* (- 1 frac) from ) (* to frac))]
  )
)

;; [interpInverse] makes a number go from the number from to the number to depending on frac (fraction between 0.0, 100% and 1.0, 0%)
(define (interpInverse from to frac)
  (interp from to (- 1 frac))
)

;; [interpTwo] interpolate between two numbers but frac -> 1 means from -> to, frac -> 2 means to -> from
(define (interpTwo numa numb frac)
  (if (< frac 1)
    (interp numa numb frac)
    (interpInverse numb numa (- 2 frac))
  )
)


;; [getOtherPlayers] gets a list of {player} structs not belonging to that user
(define (getOtherPlayers currentWorld user)
  (define players (clientsideWorld-players currentWorld))

  (filter
    (lambda (e)
      (not
        (equal?
          (player-user e)
          user
        )
      )
    )
    players
  )
)

;; [getPlayerByUser] gets a {player} struct belonging to that user
(define (getPlayerByUser currentWorld user)
  (define players (clientsideWorld-players currentWorld))

  (findf
    (lambda (e)
      (equal?
        (player-user e)
        user
      )
    )
    players
  )
)

;; [getLocalPlayer] gets a {player} struct belonging to that user
(define (getLocalPlayer currentWorld)
  (getPlayerByUser currentWorld (clientsideWorld-user currentWorld))
)

;; [getPlayerIndexByUser] gets the index of the {player} struct belonging to that user
(define (getPlayerIndexByUser currentWorld user)
  (index-of
    (clientsideWorld-players currentWorld)
    (getPlayerByUser currentWorld user)
  )
)


;; [setPlayerPosPlayer] sets a players position in his {player} struct
(define (setPlayerPosPlayer player x y dir)
  (and
    (set-player-x! player x)
    (set-player-y! player y)
    (set-player-facingDir! player dir)
    (set-player-facingSince! player (current-inexact-milliseconds))
    player
  )
)


;; [getPlayerPos] gets a players position from his {player} struct
(define (getPlayerPos currentWorld user)
  (list
    (player-x
      (getPlayerByUser currentWorld user)
    )
    (player-y
      (getPlayerByUser currentWorld user)
    )
  )
)

;; [resetAnimationFrame] resets a animation frame
(define (resetAnimationFrame frame tickCount)
  (and
    (set-animatedTexture-currentTextureNum! frame 1)
    (set-animatedTexture-ticksWhenNextAnim!
      frame
      (+
        tickCount
        (animatedTexture-frameAdvanceTicks frame)
      )
    )
    frame
  )
)

;; [resetPlayerAnimationFramesR] resets the players animations all to frame 1 by calling [resetAnimationFrame] for all of them
(define (resetPlayerAnimationFramesR player anims tickCount)
  (if (empty? anims)
    player
    (and
      (resetAnimationFrame (car anims) tickCount)
      (resetPlayerAnimationFramesR player (cdr anims) tickCount)
    )
  )
)

;; [resetPlayerAnimationFrames] calls [resetPlayerAnimationFramesR] to start the reset anim recursion
(define (resetPlayerAnimationFrames player tickCount)
  (define anims (player-animatedTextures player))
  (resetPlayerAnimationFramesR player anims tickCount)
)

;; [generateWinnersText] Generates the text for the current winner
(define (generateWinnersText currentWorld)
  (define winningPlayer (clientsideWorld-winner currentWorld))
  (string-append  "Winner Player: " (second winningPlayer) "        Score: " (number->string (first winningPlayer)))
)