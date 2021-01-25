#lang racket 

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_structs.rkt")

;; export
(provide (all-defined-out))


;; [disconnect-client] is responsible for removing the client when he disconnects  from our world
(define (disconnect-client currentWorld client)
  (define newWorld (removeClient currentWorld (iworld-name client)))
  
  (sendToAllClients
    newWorld
    (append
      (list "game_players")
      (map playerToList (getClientDatas newWorld))
    ) 
  )
)