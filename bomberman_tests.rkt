#lang racket

;; import

(require rackunit)
(require 2htdp/image)
(require lang/posn)
(require "bomberman_client.rkt")
(require "game/sh_collisions.rkt")
(require "game/sh_structs.rkt")
(require "game/sh_helper.rkt")
(require "game/cl_helper.rkt")
(require "game/sv_gamefieldgen.rkt")
(require "game/cl_collisions.rkt")
(require "game/sh_config.rkt")
(require "game/sv_connect.rkt")
(require "game/sv_disconnect.rkt")
(require "game/cl_input.rkt")


(define ACTIVATE_TESTS #t)


;; ACTIVATE_TESTS active?
(when ACTIVATE_TESTS

  #| ------------------------------------------------------
------------- Tests for Logic functions -----------------
---------------------------------------------------------|#

  #| --- testable, nontrivial functions in sh_collisions --- |#

  (check-true (isRectangleIntersect 10 10 20 20 29 29 20 20))
  (check-false (isRectangleIntersect 10 10 20 20 31 31 20 20))

  (check-true (isValidDesiredPosEntsR (list (fieldElement 'unbreakableTile 10 10 20 20 '() '())) 29 29 20 20 "1" #t))
  (check-false (isValidDesiredPosEntsR (list (fieldElement 'unbreakableTile 0 0 1 1 '() '())) 31 31 20 20 "1" #t))



  #| --- testable, nontrivial functions in cl_collisions --- |#

  (define players
    (list (player (bitmap/file (string-append "." "/assets/sprites/player1/up/1.png")) 20 20 'down 5 #t #t "1")
          (player (bitmap/file (string-append "." "/assets/sprites/player1/left/1.png")) 40 40 'left 5 #t #t "2")))

  (define currendWorld (clientsideWorld 'ingame 1 10 1 1 fieldLevel1 players (list  'w) #f "1"))

  (check-true (isValidDesiredPosPly currendWorld 100 100 20 20 "1")) 
  (check-false (isValidDesiredPosPly currendWorld 40 40 20 20 "1")) 



  #| --- testable, nontrivial functions in sh_helper --- |#

  (check-eqv? (coordToTile 40) 1)

  #| --- testable, nontrivial functions in cl_helper --- |#


  (check-eqv? (interp 5 8 1) 8) 
  (check-eqv? (interp 5 8 0) 5) 
  (check-eqv? (interp 5 8 0.5) 6.5) 


  #| --- testbare, nichttriviale Funktionen in sv_gamefieldgen --- |#

  (check-within (lessAnnoyingRandom 1 3) 2 1) 

  

  #| --- testbare, nichttriviale Funktionen in cl_input --- |#

  (define players2
    (list (player (bitmap/file (string-append "." "/assets/sprites/player1/up/1.png")) 41 41 'down 5 #t #t "1")
          (player (bitmap/file (string-append "." "/assets/sprites/player1/right/2.png")) 100 100 'left 5 #t #t "2")))
  (define currworld2 (clientsideWorld 'ingame 1 10 1 1 fieldLevel1 players2 (list  'w) #f "1"))

  (check-equal? (calculateNewPlayerPosMoveDir currworld2 (car players2) 'right 5 "1") '(46 41))

  

  #| --- testbare, nichttriviale Funktionen in sv_connect --- |#

(define curMilli current-inexact-milliseconds)
  (check-equal?
    (set-player-facingInfo! (generatePlayer "1" 5) (list 'left curMilli))
    (set-player-facingInfo! (player (bitmap/file (string-append "." "/assets/sprites/player1/right/2.png")) 41 41 'left 5 #t #f "1")
      (list 'left curMilli)
    )
  )


  (define currWorld  (serversideWorld empty #f 10 "" fieldLevel1 12))
  (addClient currWorld (create-world "1"))
  (check-true (= (length (serversideWorld-clients currWorld)) 1))
)