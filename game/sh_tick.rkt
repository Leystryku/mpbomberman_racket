#lang racket

;; import
(require 2htdp/image)
(require "sh_tick_explosion.rkt")
(require "sh_tick_bomb.rkt")
(require "sh_tick_breakingtile.rkt")
(require "sh_config.rkt" )
(require "sh_structs.rkt")
(require "sh_collisions.rkt")
(require "sh_helper.rkt")

;; export
(provide (all-defined-out))


;; [elementTick] calls the fitting tick function for a given element
(define (elementTick setGameFieldFn currentWorld elements players element tickCount isServer)
  (define elementName (fieldElement-elementName element))

  (cond
    [(equal? elementName 'bomb) (bombTick setGameFieldFn currentWorld elements players element tickCount (fieldElement-extraData element))]
    [(equal? elementName 'explosion) (explosionTick setGameFieldFn currentWorld elements players element tickCount (fieldElement-extraData element) isServer)]
    [(equal? elementName 'breakingTile) (breakingTileTick setGameFieldFn currentWorld elements element (fieldElement-extraData element))]
    [else currentWorld]
  )
)

;; [doElementTicks] calls the tick function on the given elements
(define (doElementTicks setGameFieldFn currentWorld elements elementsdec players tickCount isServer)
  (if (empty? elementsdec)
    currentWorld
    (doElementTicks
      setGameFieldFn
      (elementTick
        setGameFieldFn
        currentWorld
        elements
        players
        (car elementsdec)
        tickCount
        isServer
      )
      elements
      (cdr elementsdec)
      players
      tickCount
      isServer
    )
  )
)

;; [doSharedTick] is currently only a wrapper around doElementTicks but more might be added when there's more shared logic
(define (doSharedTick setGameFieldFn currentWorld elements players tickCount isServer)
  (doElementTicks setGameFieldFn currentWorld elements  elements players tickCount isServer)
)
