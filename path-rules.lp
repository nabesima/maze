% 空白マスは「経路になる」もしくは「経路にならない」
0 { path(X, Y) } 1 :- space(X, Y).
path(X, Y) :- start(X, Y).  % 始点は「経路」である
path(X, Y) :- goal(X, Y).   % 終点は「経路」である
% 始点・終点以外の「経路」には上下左右に「経路」が２つあること
:- path(X, Y), not start(X, Y), not goal(X, Y),
    not 2 { path(X+1, Y); path(X-1, Y); path(X, Y+1); path(X, Y-1) } 2.
% 始点からは１本の経路が伸びていること（経路を伸ばすトリガー）
path(X, Y-1) :- start(X, Y).

