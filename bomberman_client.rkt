#lang racket

;; import

(require 2htdp/universe)
(require 2htdp/image)
(require lang/posn)
(require "game/sh_collisions.rkt")
(require "game/cl_collisions.rkt")
(require "game/sh_config.rkt")
(require "game/cl_render.rkt")
(require "game/cl_input.rkt")
(require "game/cl_network.rkt")
(require "game/cl_tick.rkt")
(require "game/cl_sound.rkt")
(require "game/sh_structs.rkt")


;; export
(provide create-world)
(provide create-world-withipandport)

;; short hack, stops all sounds etc. from previous run if game opened in editor
(define (onExit)
  (stop-our-sound)
)


;; big-bang call, creates the client, we use curryr to give the client a copy of his local user
;; (/ 1 gameFPS) is given to on-tick to set the tickCount to gameFPS
(define (create-world user)
  (big-bang (clientsideWorld "titlescreen" 0 0 '() '() '() #f #f #f user 0 "")
    (on-receive (curryr onReceive user)) 
    (to-draw   renderHandler gameWidth gameHeight)
    (on-key    (curryr keyPressed user))
    (on-release   (curryr keyReleased user))
    (on-tick gameTick (/ 1 gameFPSTick))
    (name       user)
    (register   LOCALHOST)
    )
)

;;big-bang call but with IP and port
(define (create-world-withipandport user connectip connectport)
  (big-bang (clientsideWorld "titlescreen" 0 0 '() '() '() #f #f #f user 0 "")
    (on-receive (curryr onReceive user)) 
    (to-draw   renderHandler gameWidth gameHeight)
    (on-key    (curryr keyPressed user))
    (on-release   (curryr keyReleased user))
    (on-tick gameTick (/ 1 gameFPSTick))
    (name       user)
    (register   connectip)
    (port connectport)
    )
)


;; another trick to call onExit once world is killed because user pressed X on the window
(onExit)

;(create-world-withipandport "1" "77.1.88.147" 27015)
;(create-world-withipandport "2" "77.1.88.147" 27015)
;(create-world-withipandport "3" "77.1.88.147" 27015)
;(create-world-withipandport "4" "77.1.88.147" 27015)
