#lang br/quicklang
(define syms
  (make-hash
   '(
     ("SP" . 0)
     ("LCL" . 1)
     ("ARG" . 2)
     ("THIS" . 3)
     ("THAT" . 4)

     ("R0" . 0)
     ("R1" . 1)
     ("R2" . 2)
     ("R3" . 3)
     ("R4" . 4)
     ("R5" . 5)
     ("R6" . 6)
     ("R7" . 7)
     ("R8" . 8)
     ("R9" . 9)
     ("R10" . 10)
     ("R11" . 11)
     ("R12" . 12)
     ("R13" . 13)
     ("R14" . 14)
     ("R15" . 15)

     ("SCREEN" . 16384)
     ("KBD" . 24576)
     )))
(define (symbol-value var)
  (hash-ref! syms var
             (lambda ()
               (set! next-variable (add1 next-variable))
               next-variable)))
(define next-variable 15)

(define next-instruction 0)
(define (a-instr imm)
  (set! next-instruction (add1 next-instruction))
  imm)

(define (c-instr . args)
  (set! next-instruction (add1 next-instruction))
  (apply + (arithmetic-shift 7 13) (filter number? args)))

(struct duplicate-label-signal ())
(define (label lab)
  (if (hash-has-key? syms lab)
      (raise (duplicate-label-signal))
      (hash-set! syms lab next-instruction)))

(define dest-opcodes
  (hash #\M 1 #\D 2 #\A 4))
(define (dest inst)
  (arithmetic-shift
   (apply
    bitwise-ior
    (map
     (lambda (c) (hash-ref dest-opcodes c))
     (string->list inst)))
   3))

(define comp-opcodes
  (hash "0" #b101010 "1" #b111111 "-1" #b111010
        "D" #b1100 "A" #b110000 "M" #b1110000
        "!D" #b1101 "!A" #b110001 "!M" #b1110001
        "-D" #b1111 "-A" #b110011 "-M" #b1110011
        "D+1" #b11111 "A+1" #b110111 "M+1" #b1110111
        "D-1" #b1110 "A-1" #b110010 "M-1" #b1110010
        "D+A" #b10 "D+M" #b1000010
        "D-A" #b10011 "D-M" #b1010011
        "A-D" #b111 "M-D" #b1000111
        "D&A" #b0 "D&M" #b1000000
        "D|A" #b10101 "D|M" #b1010101))
(define (comp inst)
  (arithmetic-shift (hash-ref comp-opcodes inst) 6))

(define jump-opcodes
  (hash "JGT" 1 "JEQ" 2 "JGE" 3 "JLT" 4 "JNE" 5 "JLE" 6 "JMP" 7))
(define (jump inst)
  (hash-ref jump-opcodes inst))

(provide a-instr c-instr label dest comp jump)

(define (format-word w)
  (~r w #:base 2 #:min-width 16 #:pad-string "0"))

(define-macro (hack-module-begin (INSTR ...))
  #'(#%module-begin
     (for ([i (list INSTR ...)] #:unless (void? i)) ; labels produce void
       (displayln
        (format-word
         (if (number? i) i (symbol-value i)))))))
(provide (rename-out [hack-module-begin #%module-begin]))