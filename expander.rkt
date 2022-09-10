#lang br/quicklang
(define syms
  (make-hash
   '(
     ; Dummy entries to convert integers that lex as instructions back to integers
     ("0" . 0)
     ("1" . 1)

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
  (hash-ref syms var
            (lambda ()
              (set! next-variable (add1 next-variable))
              (hash-set! syms var next-variable)
              next-variable)))
(define next-variable 15)

(define next-instruction 0)
(define (a-instr imm)
  (set! next-instruction (add1 next-instruction))
  imm)

(define (c-instr . args)
  (set! next-instruction (add1 next-instruction))
  (apply + (arithmetic-shift 7 13) args))

(struct duplicate-label-signal ())
(define (label lab)
  (if (hash-has-key? syms lab)
      (raise (duplicate-label-signal))
      (hash-set! syms lab next-instruction)))

(define (dest inst)
  (define opcodes
    (hash #\M 1 #\D 2 #\A 4))
  (arithmetic-shift
   (apply
    bitwise-ior
    (map
     (lambda (c) (hash-ref opcodes c))
     (string->list inst)))
   3))

; FIXME: write numbers in binary
(define (comp inst)
  (define opcodes
    (hash "0" 42 "1" 63 "-1" 58 "D" 12 "A" 48 "M" 112
          "!D" 13 "!A" 49 "!M" 113 "-D" 15 "-A" 51 "-M" 115
          "D+1" 31 "A+1" 55 "M+1" 119 "D-1" 14 "A-1" 50 "M-1" 114
          "D+A" 2 "D+M" 66 "D-A" 19 "D-M" 83 "A-D" 7 "M-D" 71
          "D&A" 0 "D&M" 64 "D|A" 21 "D|M" 85))
  (arithmetic-shift (hash-ref opcodes inst) 6))

(define (jump inst)
  (define opcodes
    (hash "JGT" 1 "JEQ" 2 "JGE" 3 "JLT" 4 "JNE" 5 "JLE" 6 "JMP" 7))
  (hash-ref opcodes inst))

(provide a-instr c-instr label dest comp jump)

(define (format-word w)
  (~r w #:base 2 #:min-width 16 #:pad-string "0"))

(define-macro (hack-module-begin (hack-program INSTR ...))
  #'(#%module-begin
     (void (filter-map
            (lambda (i)
              (when (not (void? i)) ; labels produce void
                (displayln
                 (format-word
                  (if (number? i) i (symbol-value i))))))
            (list INSTR ...)))))
(provide (rename-out [hack-module-begin #%module-begin]))