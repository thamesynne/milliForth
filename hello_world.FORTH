: dup sp@ @ ;
: drop sp@ ! ;
: -1 s@ 0# ;
: 0= 0# 0# ;
: 0 s@ 0= ;
: 2* dup + ;
: invert dup nand ;
: 1 -1 2* invert ;
: 2 1 1 + ;
: 4 2 2 + ;
: 6 2 4 + ;
: latest s@ 2 + ;
: here s@ 4 + ;
: and nand invert ;
: - invert 1 + + ;
: <> - 0# ;
: = <> invert ;
: over sp@ 2 + @ ;
: swap over over sp@ 6 + ! sp@ 2 + ! ;
: 2dup over over ;
: xor 2dup 2* negate + + ;
: 2drop drop drop ;
: or invert swap invert and invert ;
: , here @ ! here @ 2 + here ! ;
: 80h 4 2* 2* 2* 2* 2* ;
: immediate latest @ 2 + dup @ 80h or swap ! ;
: [ 1 s@ ! ; immediate
: ] 0 s@ ! ;
: branch rp@ @ dup @ + rp@ ! ;
: ?branch 0# invert rp@ @ @ 2 - and rp@ @ + 2 + rp@ ! ;
: lit rp@ @ dup 2 + rp@ ! @ ;
: ['] rp@ @ dup 2 + rp@ ! @ ;
: >rexit rp@ ! ;
: >r rp@ @ swap rp@ ! >rexit ;
: r> rp@ 2 + @ rp@ @ rp@ 2 + ! lit [ here @ 6 + , ] rp@ ! ;
: if ['] ?branch , here @ 0 , ; immediate
: then dup here @ swap - swap ! ; immediate
: begin here @ ; immediate
: while ['] ?branch , here @ 0 , ; immediate
: repeat swap ['] branch , here @ - , dup here @ swap - swap ! ; immediate
: until ['] ?branch , here @ - , ; immediate
: do here @ ['] >r , ['] >r , ; immediate
: loop ['] r> , ['] r> , ['] lit , 1 , ['] + , ['] 2dup , ['] = , ['] ?branch , here @ - , ['] 2drop , ; immediate
: 0fh lit [ 4 4 4 4 + + + 1 - , ] ;
: ffh lit [ 0fh 2* 2* 2* 2* 0fh or , ] ;
: c@ @ ffh and ;
: type 0 do dup c@ emit 1 + loop drop ;
: in> >in @ c@ >in dup @ 1 + swap ! ;
: bl lit [ 1 2* 2* 2* 2* 2* , ] ;
: parse in> drop >in @ swap 0 begin over in> <> while 1 + repeat swap bl = if >in dup @ 1 - swap ! then ;
: word in> drop begin dup in> <> until >in @ 2 - >in ! parse ;
: [char] ['] lit , bl word drop c@ , ; immediate
: ." [char] " parse type ; immediate
." hello, world"
