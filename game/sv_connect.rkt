#lang racket 

;; import
(require 2htdp/universe)
(require "sv_helper.rkt")
(require "sh_structs.rkt")
(require "sh_config.rkt")

;; export
(provide (all-defined-out))


;; [connect-client-newuser] is responsible for establishing a conenction with a new user 
(define (connect-client-newuser currentWorld client)
  (let* ([newPlayer (generatePlayer (iworld-name client) gamePlayerSpeed)]
        [newWorld (addClient currentWorld (clientData newPlayer client))]
        [clientDatas (getClientDatas newWorld)])

    (sendToAllClients
      newWorld
        (append
          (list "game_players")
          (map playerToList clientDatas)
        )
    )
  )
)

;; [connect-client-newuser] is responsible for establishing a conenction with a reconnecting
(define (connect-client-reuseduser currentWorld client user)
  (connect-client-newuser
    (removeClientFromClientList currentWorld user)
    client
  )
)

;; [connect-client] is responsible for calling the right funcs for old/new users
(define (connect-client currentWorld client)
  (define user (iworld-name client))

  (if (getClientByUser currentWorld user)
    (connect-client-reuseduser currentWorld client user)
    (connect-client-newuser currentWorld client)
  )
)