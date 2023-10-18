% 壁は「行き止まり」でもある
deadend(X, Y) :- block(X, Y).
% 通路の上下左右の３つ以上が行き止まりならば，その通路も行き止まり
deadend(X, Y) :- space(X, Y), 3 { deadend(X+1, Y) ; deadend(X-1, Y) ; deadend(X, Y+1) ; deadend(X, Y-1) }.
