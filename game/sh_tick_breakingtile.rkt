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


;; [breakingTileTick] checks whether a breakable tile should be removed from the field
(define (breakingTileTick setGameFieldFn currentWorld elements breakingTile breakingTileData)
  (if
    (>
      (current-inexact-milliseconds)
      (extraData-breakingTile-vanishWhen breakingTileData)
    )
    (removeFieldElement setGameFieldFn currentWorld elements breakingTile)
    currentWorld
  )
)