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

allDistinct([]).
allDistinct([X|XS]):-
    notElem(X, XS),
    allDistinct(XS).

validCoord((X,Y)):-
    X<6, X>=0, Y<6, Y>=0.

validCoords([]).
validCoords([X|XS]):- validCoord(X), validCoords(XS).

assertBoxes([]).
assertBoxes([(Row, Col)|XS]):-
    assertz(caja_bloqueo(Row, Col)),
    assertBoxes(XS).

initialBoard((RobotRow, RobotCol), (TargetRow, TargetCol), BlockingBoxes):-
    (RobotRow, RobotCol) \= (TargetRow, TargetCol),

    notElem((RobotRow, RobotCol), BlockingBoxes),
    notElem((TargetRow, TargetCol), BlockingBoxes),
    allDistinct(BlockingBoxes),

    validCoord((RobotRow, RobotCol)),
    validCoord((TargetRow, TargetCol)),
    validCoords(BlockingBoxes),

    retractall(robot(_,_)),
    retractall(caja_objetivo(_, _)),
    retractall(caja_bloqueo(_, _)),

    assertz(robot(RobotRow, RobotCol)),
    assertz(caja_objetivo(TargetRow, TargetCol)),
    assertBoxes(BlockingBoxes).

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

validMoves(_,[],[]).
validMoves(State, [Move|RestMoves], [Move|ValidMoves]):-
    isValidMove(State, Move),
    !,
    validMoves(State, RestMoves, ValidMoves).
validMoves(State, [_|RestMoves], ValidMoves):-
    validMoves(State, RestMoves, ValidMoves).

appendMoves([],_,[]).
appendMoves([Move|RestMoves], List, [[Move|List]|Rest]):-appendMoves(RestMoves, List, Rest).

applyMoves(_, _, [], []).

applyMoves(CurrentState, Visited, [[CurrentMove|RestMoves]|Rest], [(NextState, [CurrentMove|RestMoves])|RestNodes]):-
    moveRobot(CurrentState, CurrentMove, state(RobotCoord, TargetCoord, RawBoxes)),
    sort(RawBoxes, SortedBoxes),
    NextState = state(RobotCoord, TargetCoord, SortedBoxes),
    notElem(NextState, Visited),
    !,
    applyMoves(CurrentState, Visited, Rest, RestNodes).

applyMoves(CurrentState, Visited, [_|Rest], RestNodes):-
    applyMoves(CurrentState, Visited, Rest, RestNodes).

concatVisited(Visited, [], Visited).
concatVisited(Visited, [(NewState, _)|RestNodes], FinalVisited):-
    concatVisited([NewState|Visited], RestNodes, FinalVisited).

solveWarehouse(state(Robot, Target, Boxes), Solution):-
    initialBoard(Robot, Target, Boxes),
    solveWarehouseBFS([(state(Robot, Target, Boxes), [])], [state(Robot, Target, Boxes)], Solution).

solveWarehouseBFS([(state(_, (5,5), _), FinalMoves)|_], _, Solution):-
    !,
    reverse(FinalMoves, Solution).

solveWarehouseBFS([(CurrentState, Moves)|RestStates], Visited, Solution):-
    validMoves(CurrentState, ['d', 'r', 'u', 'l'], ValidMoves),
    appendMoves(ValidMoves, Moves, AppendedMoves),
    applyMoves(CurrentState, Visited, AppendedMoves, AppliedNodes),
    concatVisited(Visited, AppliedNodes, NewVisited),
    append(RestStates, AppliedNodes, NewNodes),
    solveWarehouseBFS(NewNodes, NewVisited, Solution).
