let g:abolish_save_file = expand('<sfile>')

cabbrev grpe grep
cabbrev Ggrpe Ggrep
cabbrev GIt Git

if !exists(":Abolish")
  finish
endif

Abolish mian                                  main
Abolish delimeter{,s}                         delimiter{}
Abolish despara{te,tely,tion}                 despera{}
Abolish {,in}consistant{cy,t,tly}             {}inconsistent{}
Abolish {,in}conveniant{ly,ce}                {}inconvenient{}
Abolish persistan{ce,t,tly}                   persisten{}
Abolish {,ir}releven{ce,cy,t,tly}             {}relevan{}
Abolish reproducable                          reproducible
Abolish Tqbf        The quick, brown fox jumps over the lazy dog
