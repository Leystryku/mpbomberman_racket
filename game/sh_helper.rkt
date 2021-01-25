#lang racket

;; import
(require "sh_config.rkt")
(require "sh_structs.rkt")

;; export
(provide (all-defined-out))


;; [coordToTile] converts a coordinate from the rackets coord system to the tile system
(define (coordToTile coord)
  (/ coord gameTileSize)
)

;; [divisible?] checks whether a number is divisible by another one
(define (divisible? num by)
  (zero?
    (remainder num by)
  )
)

;; [isBomb] checks whether a given element is a bomb
(define (isBomb e)
  (equal?
    (fieldElement-elementName e)
    'bomb
  )
)

;; [getPlayersBombs] gets all bombs belonging to that players
(define (getPlayersBombs currentWorld gameField user)
  (define bombs (filter isBomb gameField))

  (filter 
    (lambda (x)
      (define edata (fieldElement-extraData x))

      (equal?
        (extraData-bomb-user edata)
        user
      )
    )
    bombs
  )
)

;; [getPlayersBombsAmount] count of how many bombs the player has spawned
(define (getPlayersBombsAmount currentWorld gameField user)
  (length
    (getPlayersBombs currentWorld gameField user)
  )
)

;; [canPlayerPlaceBombs] checks whether the player can place bombs
(define (canPlayerPlaceBombs currentWorld gameField user)
  (>
    bombMaximumtAmountPerPlayer
    (getPlayersBombsAmount currentWorld gameField user)
  )
)


;; [getPlayerByUserFromPlayers] gets a player with a given username from the given players
(define (getPlayerByUserFromPlayers players user)
  (findf
    (lambda (e)
      (equal? (player-user e) user)
    )
    players
  )
)

;; [getFittingExplosionAnim] takes a spreadType and returns the fitting animation texture belonging to it
(define (getFittingExplosionAnim spreadType)
  (cond
    [(equal? spreadType 'core) (animatedTextureExplosionCore)]
    [(equal? spreadType 'up) (animatedTextureExplosionUp)]
    [(equal? spreadType 'down) (animatedTextureExplosionDown)]
    [(equal? spreadType 'left) (animatedTextureExplosionLeft)]
    [(equal? spreadType 'right) (animatedTextureExplosionRight)]
    [else (animatedTextureExplosionCore)]
  )
)

;; [addExplosionField] Creates a explosion on the given field position
(define (addExplosionField setGameFieldFn currentWorld elements tx ty vanishWhen spreadType spreadsLeft ticksWhenNextAnim user)

  (define newField
    (append
      ((second setGameFieldFn) currentWorld) ;; do NOT replace this with elements. This hack IS required
      (list
        (fieldElement
          'explosion
          tx
          ty
          1
          1
          (getFittingExplosionAnim spreadType)
          (extraData-explosion vanishWhen spreadType spreadsLeft #f ticksWhenNextAnim 1 user)
        )
      )
    )
  )

  (and
    ((first setGameFieldFn) currentWorld newField)
    currentWorld
  )
)

;; [removeFieldElement] Removes a given fieldElement from the field
(define (removeFieldElement setGameFieldFn currentWorld elements object)
  (and
    ((first setGameFieldFn)
      currentWorld
      (remove
        object
        elements
      )
    )
    currentWorld
  )
)