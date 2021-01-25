#lang racket

;; import
(require 2htdp/image)
(require "cl_sound.rkt")
(require "sh_config.rkt")
(require "sh_structs.rkt")
(require "sh_collisions.rkt")
(require "sh_helper.rkt")
;(require "sh_config_snds.rkt")

;; export
(provide (all-defined-out))


;; [bombTickJustPlacedDisableIfNeeded] Disables a bombs collision/just placed status if the player has moved out of the bomb
(define (bombTickJustPlacedDisableIfNeeded currentWorld elements players bomb bombData)
  (define bombOwner (extraData-bomb-user bombData))
  (define p (getPlayerByUserFromPlayers players bombOwner))

  (if
    (isValidDesiredPosEnt
      bomb (player-x p)
      (player-y p)
      gameTileSize
      gameTileSize
      (player-user p)
      #t
    )
    (and
      (set-extraData-bomb-justPlaced! bombData #f)
      currentWorld
    )
    currentWorld
  )
)

;; [bombTickJustPlacedTick] Is called for bombs which have been just placed every tick
(define (bombTickJustPlacedTick currentWorld elements players bomb bombData)
  (if (extraData-bomb-justPlaced bombData)
    (bombTickJustPlacedDisableIfNeeded currentWorld elements players bomb bombData)
    currentWorld
  )
)

;; [bombTickExplode] Turns a bomb into a explosion
(define (bombTickExplode currentWorld elements tickCount bomb bombData)
  (and
    ;(play-our-sound sndExplosion)
    (set-fieldElement-elementName! bomb 'explosion)
    (set-fieldElement-animatedTexture! bomb (animatedTextureExplosionCore))
    (set-fieldElement-extraData! bomb 
      (extraData-explosion
        (+ explosionVanishInMs (current-inexact-milliseconds))
        'core
        explosionCoreRange
        #f
        (+ tickCount explosionTickCountTillNextAnim)
        1
        (extraData-bomb-user bombData
      ) 
    )
    )
    currentWorld
  )
)


;; [bombTickExplodeWhenShould] Checks whether a bomb should explode
(define (bombTickExplodeWhenShould currentWorld elements tickCount bomb bombData)
  (if
    (>
      (current-inexact-milliseconds)
      (extraData-bomb-explodeWhen bombData)
    )
    (bombTickExplode currentWorld elements tickCount bomb bombData)
    currentWorld
  )
)

;; [bombTick] is the tick function for the bomb element and calls the [bombTickExplodeWhenShould] & [bombTickJustPlacedTick] function
(define (bombTick setGameFieldFn currentWorld elements players bomb tickCount bombData)
  (bombTickExplodeWhenShould
    (bombTickJustPlacedTick
      currentWorld
      elements
      players
      bomb
      bombData
    )
    elements
    tickCount
    bomb
    bombData
  )
)