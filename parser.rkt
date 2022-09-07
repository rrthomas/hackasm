#lang brag
hack-program: ([instr] /NEWLINE)* [instr]

@instr: a-instr | c-instr | label
a-instr: /"@" (INTEGER | ID | "0" | "1")
c-instr: [dest /"="] comp [/";" jump]
label: /"(" ID /")"

dest: "M" | "D" | "DM" | "A" | "AM" | "AD" | "ADM"
comp: "0" | "1" | "-1" | "D" | "A" | "!D" | "!A" | "-D" | "-A" |
      "D+1" | "A+1" | "D-1" | "A-1" | "D+A" | "D-A" | "A-D" |
      "D&A" | "D|A" | "M" | "!M" | "-M" | "M+1" | "M-1" |
      "D+M" | "D-M" | "M-D" | "D&M" | "D|M"
jump: "JGT" | "JEQ" | "JGE" | "JLT" | "JNE" | "JLE" | "JMP"
