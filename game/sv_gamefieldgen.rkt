#lang racket

;; import
(require "sh_config.rkt")
(require "sh_collisions.rkt")
(require "sh_helper.rkt")
(require "sh_structs.rkt")

;; export
(provide (all-defined-out))


;; [getSetTilesInTx] Gets the currently set tiles in a given field X
(define (getSetTilesInTx field tx)
  (filter
    (lambda (num)
      (isTileSetEnts field tx num #t)
    )
    (build-list gameFieldHeightTiles values)
  )
)

;; [getNonSetTilesInTx] Gets the currently non-set tiles in a field X
(define (getNonSetTilesInTx field tx)
  (filter
    (lambda (num)
      (not (isTileSetEnts field tx num #t))
    )
    (build-list gameFieldHeightTiles values)
  )
)

;; [countSetTilesInTx] Counts the set tiles in a given field X
(define (countSetTilesInTx field tx)
  (count
    number?
    (getSetTilesInTx field tx)
  )
)

;; [countNonSetTilesInTx] Counts the set tiles in a given field X
(define (countNonSetTilesInTx world tx)
  (count
    number?
    (getNonSetTilesInTx world tx)
  )
)

;; [pickAndRemoveRandomElement] Removes a random element from a given lst
(define (pickAndRemoveRandomElement lst)
  (let* ([selectedIndex (random 0 (length lst))]
        [selectedElement (list-ref lst selectedIndex)])

    (list
      selectedElement
      selectedIndex
      (remove selectedElement lst equal?)
    )
  )
)

;; [generateBreakableWallAtPos] Generates a breakable wall at a certain field x/y
(define (generateBreakableWallAtPos xtiles ytiles)
  (list
    (fieldElement 'breakableTile xtiles ytiles 1 1 #f #f)
  )
)


;; [generateRandomizedBreakableWallsForTxGen] generates  breakable wall at  random positions for a given nonSetTiles tx
(define (generateRandomizedBreakableWallsForTxGen field xtiles ytiles cntToSet nonSetTilesInTx)
  (if (= cntToSet 0)
    '()
    (let ([pickRemove (pickAndRemoveRandomElement nonSetTilesInTx)])
      (append
        (generateBreakableWallAtPos
          xtiles
          (car pickRemove)
        )
        (generateRandomizedBreakableWallsForTxGen
          field
          xtiles
          ytiles
          (- cntToSet 1)
          (caddr pickRemove)
        )
      )
    )
  )
)

;; [lessAnnoyingRandom] Is a wrapper around [random] to ensure it'll always return a number
(define (lessAnnoyingRandom rndMin rndMax)
  (if (< rndMax rndMin)
    rndMax
    (random rndMin rndMax)
  )
)

;; [generateRandomizedBreakableWallsForTx] Generates breakable walls for a field X
(define (generateRandomizedBreakableWallsForTx field xtiles ytiles)
  (let* ([cntSettableTilesInW (countNonSetTilesInTx field xtiles)]
        [rndMin (inexact->exact (ceiling (* cntSettableTilesInW gameMinimumPercentageRandomTiles)))]
        [rndMax (inexact->exact (ceiling (* cntSettableTilesInW gameMaximumPercentageRandomTiles)))])

    (if (> cntSettableTilesInW 0)
      (generateRandomizedBreakableWallsForTxGen
        field
        xtiles
        ytiles
        (lessAnnoyingRandom
          rndMin
          rndMax
        )
        (getNonSetTilesInTx field xtiles)
      )
      '()
    )
  )
)


;; [generateRandomizedBreakableWalls] Calls the functions to generate breakable walls for a entire field
(define (generateRandomizedBreakableWalls field xtiles ytiles)
  (if (equal? xtiles 0)
      '()
      (append (generateRandomizedBreakableWallsForTx field xtiles ytiles) (generateRandomizedBreakableWalls field (- xtiles 1) ytiles))
  )
)

;; [generateGameFieldWithRandomWalls] Calls [generateRandomizedBreakableWalls] and appends its result to the current Worlds field
(define (generateGameFieldWithRandomWalls world)
  (let* ([randomWalls (generateRandomizedBreakableWalls gameField gameFieldWidthTiles gameFieldHeightTiles)]
    [result (append gameField randomWalls)])

    result
  )
)


;; [generateGameField] Calls the functions to generate random walls if noRandomWalls is false, else reutrns current field
(define (generateGameField world)
  (if noRandomWalls
    gameField
    (generateGameFieldWithRandomWalls world)
  )
)