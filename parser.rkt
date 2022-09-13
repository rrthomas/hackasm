#lang br
(require "lexer.rkt")
(require parser-tools/yacc)

(define parse
  (parser
   (src-pos)
   (start hack-program)
   (end EOF)
   (error (lambda (tok-ok? tok-name tok-value start-pos end-pos)
            (displayln (format "~a ~a ~a ~a ~a" tok-ok? tok-name tok-value start-pos end-pos))))
   (tokens basic-tokens punct-tokens)

   (grammar
    (hack-program
     [(instrs) $1]
     [(instr instrs) (cons $1 $2)]
     )
    (instr
     [(a-instr) `(a-instr ,$1)]
     [(c-instr) (cons 'c-instr $1)]
     [(label) `(label ,$1)]
     )
    (instrs
     [(NEWLINE instrs) $2]
     [(NEWLINE instr instrs) (cons $2 $3)]
     [() '()]
     )

    (a-instr
     [(AT immediate) $2]
     )
    (immediate
     [(INTEGER) $1]
     [(ID) $1]
     [(ZEROONE) (string->number $1)]
     )

    (c-instr
     [(comp SEMICOLON jump) (list #f `(comp ,$1) `(jump ,$3))]
     [(comp) (list #f `(comp ,$1) #f)]
     [(dest EQ comp SEMICOLON jump) (list `(dest ,$1) `(comp ,$3) `(jump ,$5))]
     [(dest EQ comp) (list `(dest ,$1) `(comp ,$3) #f)]
     )
    (dest
     [(DEST) $1]
     [(REGISTER) $1]
     )
    (comp
     [(COMP) $1]
     [(REGISTER) $1]
     [(ZEROONE) $1]
     )
    (jump [(JUMP) $1])

    (label
     [(LPAREN ID RPAREN) $2]
     )
    )))

(provide parse)

(require "tokenizer.rkt")

(define (parse-port ip [path #f])
  (define next-token (make-tokenizer ip path))
  (parse next-token))

(define (parse-string s)
  (define ip (open-input-string s))
  (parse-port ip))
(define (parse-file f)
  (define ip (open-input-file f))
  (parse-port ip f))
