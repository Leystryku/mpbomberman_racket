#lang racket

;; import
(require 2htdp/image)

;; export
(provide (all-defined-out))


;;; === configuration for texture paths ===


;;titlescreen state
(define txtTitlescreen1 (bitmap/file (string-append "." "/assets/sprites/titlescreen_1.png")))
(define txtTitlescreen2 (bitmap/file (string-append "." "/assets/sprites/titlescreen_2.png")))

;;titlescreen state
(define txtEndScreen1 (bitmap/file (string-append "." "/assets/sprites/titlescreen_1.png")))
(define txtEndScreen2 (bitmap/file (string-append "." "/assets/sprites/titlescreen_2.png")))

;;ingame
;; level bgs
(define txtLevel1 (bitmap/file (string-append "." "/assets/sprites/levels/1.png")))
(define txtLevel2 (bitmap/file (string-append "." "/assets/sprites/levels/2.png")))

;; breakable tiles
(define txtBreakableTile (bitmap/file (string-append "." "/assets/sprites/breakabletile.png")))

;; bomb
(define txtBomb1 (bitmap/file (string-append "." "/assets/sprites/bomb/1.png")))
(define txtBomb2 (bitmap/file (string-append "." "/assets/sprites/bomb/2.png")))
(define txtBomb3 (bitmap/file (string-append "." "/assets/sprites/bomb/3.png")))

;; explosions
;;; core
(define txtExplosionCore1 (bitmap/file (string-append "." "/assets/sprites/explosion/1/core.png")))
(define txtExplosionCore2 (bitmap/file (string-append "." "/assets/sprites/explosion/2/core.png")))
(define txtExplosionCore3 (bitmap/file (string-append "." "/assets/sprites/explosion/3/core.png")))
(define txtExplosionCore4 (bitmap/file (string-append "." "/assets/sprites/explosion/4/core.png")))

;;; up
(define txtExplosionUp1 (bitmap/file (string-append "." "/assets/sprites/explosion/1/up.png")))
(define txtExplosionUp2 (bitmap/file (string-append "." "/assets/sprites/explosion/2/up.png")))
(define txtExplosionUp3 (bitmap/file (string-append "." "/assets/sprites/explosion/3/up.png")))
(define txtExplosionUp4 (bitmap/file (string-append "." "/assets/sprites/explosion/4/up.png")))

;;; down
(define txtExplosionDown1 (bitmap/file (string-append "." "/assets/sprites/explosion/1/down.png")))
(define txtExplosionDown2 (bitmap/file (string-append "." "/assets/sprites/explosion/2/down.png")))
(define txtExplosionDown3 (bitmap/file (string-append "." "/assets/sprites/explosion/3/down.png")))
(define txtExplosionDown4 (bitmap/file (string-append "." "/assets/sprites/explosion/4/down.png")))

;;; left
(define txtExplosionLeft1 (bitmap/file (string-append "." "/assets/sprites/explosion/1/left.png")))
(define txtExplosionLeft2 (bitmap/file (string-append "." "/assets/sprites/explosion/2/left.png")))
(define txtExplosionLeft3 (bitmap/file (string-append "." "/assets/sprites/explosion/3/left.png")))
(define txtExplosionLeft4 (bitmap/file (string-append "." "/assets/sprites/explosion/4/left.png")))

;;; right
(define txtExplosionRight1 (bitmap/file (string-append "." "/assets/sprites/explosion/1/right.png")))
(define txtExplosionRight2 (bitmap/file (string-append "." "/assets/sprites/explosion/2/right.png")))
(define txtExplosionRight3 (bitmap/file (string-append "." "/assets/sprites/explosion/3/right.png")))
(define txtExplosionRight4 (bitmap/file (string-append "." "/assets/sprites/explosion/4/right.png")))


;; breaking tiles
(define txtBreakingTile1 (bitmap/file (string-append "." "/assets/sprites/breakingtile/1.png")))
(define txtBreakingTile2 (bitmap/file (string-append "." "/assets/sprites/breakingtile/2.png")))
(define txtBreakingTile3 (bitmap/file (string-append "." "/assets/sprites/breakingtile/3.png")))
(define txtBreakingTile4 (bitmap/file (string-append "." "/assets/sprites/breakingtile/4.png")))
(define txtBreakingTile5 (bitmap/file (string-append "." "/assets/sprites/breakingtile/5.png")))
(define txtBreakingTile6 (bitmap/file (string-append "." "/assets/sprites/breakingtile/6.png")))


;;players
;;player1

;;up
(define txtPlayer1Up1 (bitmap/file (string-append "." "/assets/sprites/player1/up/1.png")))
(define txtPlayer1Up2 (bitmap/file (string-append "." "/assets/sprites/player1/up/2.png")))
(define txtPlayer1Up3 (bitmap/file (string-append "." "/assets/sprites/player1/up/3.png")))
(define txtPlayer1Up4 (bitmap/file (string-append "." "/assets/sprites/player1/up/4.png")))

;;down
(define txtPlayer1Down1 (bitmap/file (string-append "." "/assets/sprites/player1/down/1.png")))
(define txtPlayer1Down2 (bitmap/file (string-append "." "/assets/sprites/player1/down/2.png")))
(define txtPlayer1Down3 (bitmap/file (string-append "." "/assets/sprites/player1/down/3.png")))
(define txtPlayer1Down4 (bitmap/file (string-append "." "/assets/sprites/player1/down/4.png")))

;;left
(define txtPlayer1Left1 (bitmap/file (string-append "." "/assets/sprites/player1/left/1.png")))
(define txtPlayer1Left2 (bitmap/file (string-append "." "/assets/sprites/player1/left/2.png")))
(define txtPlayer1Left3 (bitmap/file (string-append "." "/assets/sprites/player1/left/3.png")))
(define txtPlayer1Left4 (bitmap/file (string-append "." "/assets/sprites/player1/left/4.png")))

;;right
(define txtPlayer1Right1 (bitmap/file (string-append "." "/assets/sprites/player1/right/1.png")))
(define txtPlayer1Right2 (bitmap/file (string-append "." "/assets/sprites/player1/right/2.png")))
(define txtPlayer1Right3 (bitmap/file (string-append "." "/assets/sprites/player1/right/3.png")))
(define txtPlayer1Right4 (bitmap/file (string-append "." "/assets/sprites/player1/right/4.png")))

;;dying
(define txtPlayer1Die1 (bitmap/file (string-append "." "/assets/sprites/player1/dying/1.png")))
(define txtPlayer1Die2 (bitmap/file (string-append "." "/assets/sprites/player1/dying/2.png")))
(define txtPlayer1Die3 (bitmap/file (string-append "." "/assets/sprites/player1/dying/3.png")))
(define txtPlayer1Die4 (bitmap/file (string-append "." "/assets/sprites/player1/dying/4.png")))
(define txtPlayer1Die5 (bitmap/file (string-append "." "/assets/sprites/player1/dying/5.png")))
(define txtPlayer1Die6 (bitmap/file (string-append "." "/assets/sprites/player1/dying/6.png")))
(define txtPlayer1Die7 (bitmap/file (string-append "." "/assets/sprites/player1/dying/7.png")))
(define txtPlayer1Die8 (bitmap/file (string-append "." "/assets/sprites/player1/dying/8.png")))

;;player2

;;up
(define txtPlayer2Up1 (bitmap/file (string-append "." "/assets/sprites/player2/up/1.png")))
(define txtPlayer2Up2 (bitmap/file (string-append "." "/assets/sprites/player2/up/2.png")))
(define txtPlayer2Up3 (bitmap/file (string-append "." "/assets/sprites/player2/up/3.png")))

;;down
(define txtPlayer2Down1 (bitmap/file (string-append "." "/assets/sprites/player2/down/1.png")))
(define txtPlayer2Down2 (bitmap/file (string-append "." "/assets/sprites/player2/down/2.png")))
(define txtPlayer2Down3 (bitmap/file (string-append "." "/assets/sprites/player2/down/3.png")))

;;left
(define txtPlayer2Left1 (bitmap/file (string-append "." "/assets/sprites/player2/left/1.png")))
(define txtPlayer2Left2 (bitmap/file (string-append "." "/assets/sprites/player2/left/2.png")))
(define txtPlayer2Left3 (bitmap/file (string-append "." "/assets/sprites/player2/left/3.png")))

;;right
(define txtPlayer2Right1 (bitmap/file (string-append "." "/assets/sprites/player2/right/1.png")))
(define txtPlayer2Right2 (bitmap/file (string-append "." "/assets/sprites/player2/right/2.png")))
(define txtPlayer2Right3 (bitmap/file (string-append "." "/assets/sprites/player2/right/3.png")))

;;dying
(define txtPlayer2Die1 (bitmap/file (string-append "." "/assets/sprites/player2/dying/1.png")))
(define txtPlayer2Die2 (bitmap/file (string-append "." "/assets/sprites/player2/dying/2.png")))
(define txtPlayer2Die3 (bitmap/file (string-append "." "/assets/sprites/player2/dying/3.png")))
(define txtPlayer2Die4 (bitmap/file (string-append "." "/assets/sprites/player2/dying/4.png")))
(define txtPlayer2Die5 (bitmap/file (string-append "." "/assets/sprites/player2/dying/5.png")))
(define txtPlayer2Die6 (bitmap/file (string-append "." "/assets/sprites/player2/dying/6.png")))
(define txtPlayer2Die7 (bitmap/file (string-append "." "/assets/sprites/player2/dying/7.png")))
(define txtPlayer2Die8 (bitmap/file (string-append "." "/assets/sprites/player2/dying/8.png")))

;;player3

;;up
(define txtPlayer3Up1 (bitmap/file (string-append "." "/assets/sprites/player3/up/1.png")))
(define txtPlayer3Up2 (bitmap/file (string-append "." "/assets/sprites/player3/up/2.png")))
(define txtPlayer3Up3 (bitmap/file (string-append "." "/assets/sprites/player3/up/3.png")))

;;down
(define txtPlayer3Down1 (bitmap/file (string-append "." "/assets/sprites/player3/down/1.png")))
(define txtPlayer3Down2 (bitmap/file (string-append "." "/assets/sprites/player3/down/2.png")))
(define txtPlayer3Down3 (bitmap/file (string-append "." "/assets/sprites/player3/down/3.png")))

;;left
(define txtPlayer3Left1 (bitmap/file (string-append "." "/assets/sprites/player3/left/1.png")))
(define txtPlayer3Left2 (bitmap/file (string-append "." "/assets/sprites/player3/left/2.png")))
(define txtPlayer3Left3 (bitmap/file (string-append "." "/assets/sprites/player3/left/3.png")))

;;right
(define txtPlayer3Right1 (bitmap/file (string-append "." "/assets/sprites/player3/right/1.png")))
(define txtPlayer3Right2 (bitmap/file (string-append "." "/assets/sprites/player3/right/2.png")))
(define txtPlayer3Right3 (bitmap/file (string-append "." "/assets/sprites/player3/right/3.png")))

;;dying
(define txtPlayer3Die1 (bitmap/file (string-append "." "/assets/sprites/player3/dying/1.png")))
(define txtPlayer3Die2 (bitmap/file (string-append "." "/assets/sprites/player3/dying/2.png")))
(define txtPlayer3Die3 (bitmap/file (string-append "." "/assets/sprites/player3/dying/3.png")))
(define txtPlayer3Die4 (bitmap/file (string-append "." "/assets/sprites/player3/dying/4.png")))
(define txtPlayer3Die5 (bitmap/file (string-append "." "/assets/sprites/player3/dying/5.png")))
(define txtPlayer3Die6 (bitmap/file (string-append "." "/assets/sprites/player3/dying/6.png")))
(define txtPlayer3Die7 (bitmap/file (string-append "." "/assets/sprites/player3/dying/7.png")))
(define txtPlayer3Die8 (bitmap/file (string-append "." "/assets/sprites/player3/dying/8.png")))

;;player4

;;up
(define txtPlayer4Up1 (bitmap/file (string-append "." "/assets/sprites/player4/up/1.png")))
(define txtPlayer4Up2 (bitmap/file (string-append "." "/assets/sprites/player4/up/2.png")))
(define txtPlayer4Up3 (bitmap/file (string-append "." "/assets/sprites/player4/up/3.png")))

;;down
(define txtPlayer4Down1 (bitmap/file (string-append "." "/assets/sprites/player4/down/1.png")))
(define txtPlayer4Down2 (bitmap/file (string-append "." "/assets/sprites/player4/down/2.png")))
(define txtPlayer4Down3 (bitmap/file (string-append "." "/assets/sprites/player4/down/3.png")))

;;left
(define txtPlayer4Left1 (bitmap/file (string-append "." "/assets/sprites/player4/left/1.png")))
(define txtPlayer4Left2 (bitmap/file (string-append "." "/assets/sprites/player4/left/2.png")))
(define txtPlayer4Left3 (bitmap/file (string-append "." "/assets/sprites/player4/left/3.png")))

;;right
(define txtPlayer4Right1 (bitmap/file (string-append "." "/assets/sprites/player4/right/1.png")))
(define txtPlayer4Right2 (bitmap/file (string-append "." "/assets/sprites/player4/right/2.png")))
(define txtPlayer4Right3 (bitmap/file (string-append "." "/assets/sprites/player4/right/3.png")))

;;dying
(define txtPlayer4Die1 (bitmap/file (string-append "." "/assets/sprites/player4/dying/1.png")))
(define txtPlayer4Die2 (bitmap/file (string-append "." "/assets/sprites/player4/dying/2.png")))
(define txtPlayer4Die3 (bitmap/file (string-append "." "/assets/sprites/player4/dying/3.png")))
(define txtPlayer4Die4 (bitmap/file (string-append "." "/assets/sprites/player4/dying/4.png")))
(define txtPlayer4Die5 (bitmap/file (string-append "." "/assets/sprites/player4/dying/5.png")))
(define txtPlayer4Die6 (bitmap/file (string-append "." "/assets/sprites/player4/dying/6.png")))
(define txtPlayer4Die7 (bitmap/file (string-append "." "/assets/sprites/player4/dying/7.png")))
(define txtPlayer4Die8 (bitmap/file (string-append "." "/assets/sprites/player4/dying/8.png")))