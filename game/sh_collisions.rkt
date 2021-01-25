#lang racket

;; import
(require 2htdp/image)
(require "sh_helper.rkt")
(require "sh_config.rkt")
(require "sh_structs.rkt")

;; exports
(provide (all-defined-out))


;; [isPointWithin] checks whether a certain point is within the rectangle created by the points ( (x,y), (x+w, y), (x,y+h), (x+w,y+h) )
(define (isPointWithin x y w h x2 y2)
  (and
    (>= x2 x)
    (>= (+ x w) x2)
    (>= y2 y)
    (>= (+ y h) y2)
  )
)

;; [isRectangleIntersect] checks whether 2 rectangles intersect by comparing their upper left and bottom right points
(define (isRectangleIntersect x1 y1 w1 h1 x2 y2 w2 h2)
  (or
    (isPointWithin x1 y1 w1 h1 x2 y2)
    (isPointWithin x1 y1 w1 h1 (+ x2 w2) (+ y2 h2))
    (isPointWithin x1 y1 w1 h1 (+ x2 w2) y2)
    (isPointWithin x1 y1 w1 h1 x2 (+ y2 h2))
  )
)

;; [shouldIgnoreElementsCollisionsBomb] checks whether a bomb element should collide with a certain user
(define (shouldIgnoreElementsCollisionsBomb e extra user)
  (and
    (extraData-bomb-justPlaced extra)
    (equal? (extraData-bomb-user extra) user)
  )
)

;; [shouldIgnoreElementsCollisions] checks whether a element should collide with a user
(define (shouldIgnoreElementsCollisions e elemName user forceshouldcollide)
  (if forceshouldcollide
    #f
    (cond
      [(equal? elemName 'bomb) (shouldIgnoreElementsCollisionsBomb e (fieldElement-extraData e) user) ]
      [(equal? elemName 'explosion) #t ]
      [else #f]
    )
  )
)

;; [isValidDesiredPosEnt] checks whether a {fieldElement} collides with the rectangle drawn using objx, objy, objw, objh
(define (isValidDesiredPosEnt curelem objx objy objw objh user forceshouldcollide)
  (define elemname (fieldElement-elementName curelem))
  (define elemx (tileToCoord (fieldElement-xtiles curelem)))
  (define elemy (tileToCoord (fieldElement-ytiles  curelem)))
  (define elemw (tileToCoord (fieldElement-wtiles curelem)))
  (define elemh (tileToCoord (fieldElement-htiles  curelem)))


  (if (and user gameEntitiesNoCollide)
    #t
    (if (shouldIgnoreElementsCollisions curelem elemname user forceshouldcollide)
      #t
      (not
        (isRectangleIntersect elemx elemy elemw elemh objx objy (- objw 2) (- objh 2))
      )
    )
  )
)

;; [isValidDesiredPosEntsR] checks whether any {fieldElement} in given lst collides with the rectangle drawn using objx, objy, objw, objh
(define (isValidDesiredPosEntsR elements objx objy objw objh user forceshouldcollide)
  (if (empty? elements)
    #t
    (if
      (not
        (isValidDesiredPosEnt
          (car  elements)
          objx
          objy
          objw
          objh
          user
          forceshouldcollide
        )
      )
      #f
      (isValidDesiredPosEntsR
        (cdr elements)
        objx
        objy
        objw
        objh
        user
        forceshouldcollide
      )
    )
  )
)



;; [isValidDesiredPosEntsTileSet] checks whetheer a position on the field is set for the world generation
(define (isValidDesiredPosEntsTileSet field x y objw objh)
  (isValidDesiredPosEntsR field (+ x 1) (+ y 1) objw objh #f #f)
)

;; [isTileSetEnts] checks whether a tile on the field is set for the world generation, pos close to spawns are always set
(define (isTileSetEnts field tx ty ignoreSpawn)
  (if
    (and
      ignoreSpawn
      (or
        (< tx 3) (< ty 1)
        (> tx (- gameFieldWidthTiles 4))
        (> ty (- gameFieldHeightTiles 2))
      )
    )
    #t
    (not
      (isValidDesiredPosEntsTileSet
        field
        (tileToCoord tx)
        (tileToCoord ty)
        (- gameTileSize 2)
        (- gameTileSize 2)
      )
    )
  )
)


;; [isValidDesiredPosPly] checks whether a given player intersects with the rectangle created by objx, objy, objw, objh
(define (isValidDesiredPosPly curplayer objx objy objw objh)
  (define alive (player-alive curplayer))

  (if gamePlayersNoCollide
    #t
    (not
      (and
        alive
        (isRectangleIntersect
          (player-x curplayer)
          (player-y curplayer)
          gameTileSize
          gameTileSize
          objx
          objy
          (- objw 1)
          (- objh 1)
        )
      )
    )
  )
)

;; [isValidDesiredPosPlyR] checks whether any {player} in given list intersects with the rectangle created by objx, objy, objw, objh
(define (isValidDesiredPosPlyR players objx objy objw objh)
  (if (or gamePlayersNoCollide (empty? players))
    #t
    (if (not (isValidDesiredPosPly (car players) objx objy objw objh))
      #f
      (isValidDesiredPosPlyR (cdr players) objx objy objw objh)
    )
  )
)

;; [canBombSpreadToField] checks whether a bomb can spread to a certain fieldposition
(define (canBombSpreadToField field players tx ty)
  (not
    (isTileSetEnts field tx ty #f)
  )
)

;; [getEntByFieldPos] gets a {fieldElement} by its tile position
(define (getEntByFieldPos field tx ty)
  (if (empty? field)
    #f
    (let* ([curelem (car field)]
      [elemtx (fieldElement-xtiles curelem)]
      [elemty (fieldElement-ytiles  curelem)])

      (if
        (and
          (= elemtx tx)
          (= elemty ty)
        )
        curelem
        (getEntByFieldPos (cdr field) tx ty)
      )
    )
  )
)

;; [getPlayerByFieldPos] gets a {player} by his tile position
(define (getPlayerByFieldPos players tx ty)
  (if (empty? players)
    #f
    (let* ([curplayer (car players)]
      [playertx (round (coordToTile (player-x curplayer)))]
      [playerty (round (coordToTile (player-y  curplayer)))]
      [alive (player-alive curplayer)])

      (if
        (and
          alive
          (= playertx tx)
          (= playerty ty)
        )
        curplayer
        (getPlayerByFieldPos (cdr players) tx ty)
      )
    )
  )
)