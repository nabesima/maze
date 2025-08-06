#const n=4.

% 各行に queen は１つだけ
1 { queen(X,Y) : X=1..n } 1 :- Y=1..n.
% 各列に queen は１つだけ
1 { queen(X,Y) : Y=1..n } 1 :- X=1..n.   
% 斜めの衝突禁止
:- queen(X1,Y1), queen(X2,Y2), X1 != X2, |X1-X2| = |Y1-Y2|.  

#show queen/2.
