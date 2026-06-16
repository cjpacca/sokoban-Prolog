moves('u', -1, 0).
moves('d', 1, 0).
moves('l', 0, -1).
moves('r', 0, 1).

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
