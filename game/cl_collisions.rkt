#lang racket

;; import
(require 2htdp/image)
(require "cl_helper.rkt")
(require "sh_config.rkt")
(require "sh_helper.rkt")
(require "sh_collisions.rkt")
(require "sh_structs.rkt")

;; exports
(provide (all-defined-out))


;; [isValidDesiredPosEnts] checks whether a rectangle drawn at (x, y, x+objw, y+obh) intersects with any other collision rectangle on the field
(define (isValidDesiredPosEnts currentWorld x y objw objh)
  (define elements (clientsideWorld-gameField currentWorld))

  (isValidDesiredPosEntsR elements x y objw objh (clientsideWorld-user currentWorld) #f)
)

;; [isValidDesiredPosMove] checks whether a rectangle drawn at (x, y, x+objw, y+obh) intersects with any other collision rectangle on the field or belonging to a player
(define (isValidDesiredPosMove currentWorld x y playerw playerh user)
  (and
    (isValidDesiredPosEnts currentWorld x y playerw playerh)
    (isValidDesiredPosPlyR (getOtherPlayers currentWorld user) x y playerw playerh)
  )
)

(define (isValidDesiredPosMoveLst currentWorld lst playerw playerh user)
  (isValidDesiredPosMove currentWorld (first lst) (second lst) playerw playerh user)
)
