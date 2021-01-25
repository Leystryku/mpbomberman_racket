#lang racket

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")

;; export
(provide (all-defined-out))


;; [processLayerLayedBombParseExtraData] processes the extradata for a bomb
(define (processLayerLayedBombParseExtraData currentWorld connection explodeWhen)
  (extraData-bomb
    explodeWhen
    #t
    0
    1
    (iworld-name connection)
  )
)

;; [processLayerLayedBombParseElement] Creates a new bomb fieldElement
(define (processLayerLayedBombParseElement currentWorld connection bombPos explodeWhen)
  (fieldElement
    'bomb
    (first bombPos)
    (second bombPos)
    1
    1
    (animatedTextureBomb)
    (processLayerLayedBombParseExtraData currentWorld connection explodeWhen)
  )
)

;; [processPlayerLayedBomb] Processes the laying of a bomb and appends it to our current serverside gameField
(define (processPlayerLayedBomb currentWorld connection bombPos explodeWhen)
  (define curField (serversideWorld-gameField currentWorld))
  (define newFieldElement (processLayerLayedBombParseElement currentWorld connection bombPos explodeWhen))

  (and
    (set-serversideWorld-gameField! currentWorld
      (append curField (list newFieldElement))
    )
    currentWorld
  )
)

;; [messageIngamePlayerLayedBombSend] Sends the laying of a bomb to all clients and calls the functions to process it on the server
(define (messageIngamePlayerLayedBomb currentWorld connection bombPos)
  (define clientDatas (getClientDatas currentWorld))
  (define explodeWhen (+ (current-inexact-milliseconds) (random bombMinimumExplodeDelay bombMaximumExplodeDelay)))

  (sendToAllClients
    (processPlayerLayedBomb currentWorld connection bombPos explodeWhen)
    (append
      (list "player_bomb" explodeWhen (iworld-name connection))
      bombPos
    )
  )
)