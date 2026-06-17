moves('u', -1, 0).
moves('d', 1, 0).
moves('l', 0, -1).
moves('r', 0, 1).


:- dynamic robot/2.
:- dynamic caja_objetivo/2.
:- dynamic caja_bloqueo/2.

notElem(_, []).
notElem(X, [Y|YS]):-
    X \= Y,
    notElem(X, YS).

validCoord((X,Y)):-
    X<6, X>=0, Y<6, Y>=0.

validCoords([]).
validCoords([X|XS]):- validCoord(X), validCoords(XS).

initialBoard(RobotCoord, TargetCoord, BlockingBoxes):-
    RobotCoord \= TargetCoord,
    notElem(RobotCoord, BlockingBoxes),
    notElem(TargetCoord, BlockingBoxes),
    validCoord(RobotCoord),
    validCoord(TargetCoord),
    validCoords(BlockingBoxes).

% caso moverse sin toparse con nada
isValidMove(state((RFila, RCol), (ObjFila, ObjCol), CajasBloqueo), Move):-
    moves(Move, X, Y), NuevaX is X + RFila, NuevaY is Y + RCol,
    NuevaX>=0, NuevaX<6, NuevaY>=0, NuevaY<6,
    (NuevaX, NuevaY) \= (ObjFila, ObjCol),
    \+ member((NuevaX, NuevaY), CajasBloqueo).

% caso mover caja objetivo
isValidMove(state((RFila, RCol), (ObjFila, ObjCol), CajasBloqueo), Move):-
    moves(Move, X, Y), NuevaX is X + RFila, NuevaY is Y + RCol,
    NuevaX=:=ObjFila, NuevaY=:=ObjCol, % verificar que caigo en la caja objetivo
    NuevaCajaX is ObjFila + X, NuevaCajaY is ObjCol + Y,
    NuevaCajaX>=0, NuevaCajaX<6, NuevaCajaY>=0, NuevaCajaY<6,
    \+ member((NuevaCajaX, NuevaCajaY), CajasBloqueo).

%caso mover caja bloqueada
isValidMove(state((RFila, RCol), (ObjFila, ObjCol), CajasBloqueo), Move):-
    moves(Move, X, Y), NuevaX is X + RFila, NuevaY is Y + RCol,
    member((NuevaX, NuevaY), CajasBloqueo),
    NuevaCajaX is NuevaX + X, NuevaCajaY is NuevaY + Y,
    NuevaCajaX>=0, NuevaCajaX<6, NuevaCajaY>=0, NuevaCajaY<6,
    (NuevaCajaX, NuevaCajaY) \= (ObjFila, ObjCol),
    \+ member((NuevaCajaX, NuevaCajaY), CajasBloqueo).

% moverse sin empujar cajas
moveRobot(state((RFila, RCol), CoordCaja, CajasBloqueo), Move, state((NuevaX, NuevaY), CoordCaja, CajasBloqueo)):-
    isValidMove(state((RFila, RCol), CoordCaja, CajasBloqueo), Move),
    moves(Move, X, Y), NuevaX is X + RFila, NuevaY is Y + RCol,
    (NuevaX, NuevaY) \= CoordCaja,
    \+ member((NuevaX, NuevaY), CajasBloqueo).

% moverse empujando caja objetivo
moveRobot(state((RFila, RCol), (ObjFila, ObjCol), CajasBloqueo), Move, state((NuevaX, NuevaY), (NuevaCajaX, NuevaCajaY), CajasBloqueo)):-
    isValidMove(state((RFila, RCol), (ObjFila, ObjCol), CajasBloqueo), Move),
    moves(Move, X, Y), NuevaX is X + RFila, NuevaY is Y + RCol,
    NuevaX=:=ObjFila, NuevaY=:=ObjCol, % verificar que caigo en la caja objetivo
    NuevaCajaX is ObjFila + X, NuevaCajaY is ObjCol + Y.

moveRobot(state((RFila, RCol), CoordCaja, CajasBloqueo), Move, state((NuevaX, NuevaY), CoordCaja, NuevaCajasBloqueos)):-
    isValidMove(state((RFila, RCol), CoordCaja, CajasBloqueo), Move),
    moves(Move, X, Y), NuevaX is X + RFila, NuevaY is Y + RCol,
    member((NuevaX, NuevaY), CajasBloqueo), % verificar que caigo en la caja bloqueo
    NuevaCajaX is NuevaX + X, NuevaCajaY is NuevaY + Y,
    select((NuevaX, NuevaY), CajasBloqueo, SinCajaVieja),
    NuevaCajasBloqueos = [(NuevaCajaX, NuevaCajaY)|SinCajaVieja].
