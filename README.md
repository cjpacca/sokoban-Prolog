# Proyecto #2 - Prolog

## Almacén Robótico Lógico

### Parte 2 - Validación de Movimientos
#### Predicado **isValidMove**

Para verificar si es válido realizar un movimiento se revisa la coordenada del robot y la que
tendrá al moverse y los 3 posibles casos, el caso donde se mueve sin empujar nada
y donde empuja los diferentes tipos de caja, siguiendo las reglas del entorno
(límites del tablero, empuje de cajas y colisiones).

Para calcular la posición del robot tras el movimiento se implementó el predicado moves

Para validar los movimientos una vez calculada la nueva posición del robot, se obtiene
la posición de la caja que este empujará o intentará empujar, se verifica
la posición del robot antes de moverse, y se verifica que ni el robot ni las cajas caigan
fuera del mapa, ni que se intente empujar una caja a la posicion de otra

### Parte 3 - Ejecución de Movimiento
#### Predicado  **moveRobot**

Se implementó la lógica para la realización de movimientos, aprovechando los predicados
*moves* y *isValidMove*
**No Se asume que el movimiento ya fue validado por isValidMove**.
Se retorna la nueva posición o estado del mapa una vez hecho el movimiento
Recordando que si el Robot se mueve hacia una caja, la coordenada de esa caja también debe actualizarse.




