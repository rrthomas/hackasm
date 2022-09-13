#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(module+ reader
  (provide read-syntax))

(define (read-syntax path port)
  (define parse-tree (parse (make-tokenizer port path)))
  (datum->syntax
   #f
   `(,#'module hackasm-mod hackasm/expander
               ,parse-tree)))