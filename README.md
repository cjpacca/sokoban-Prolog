# Proyecto #2 - Prolog

## Almacén Robótico Lógico

### Parte 1 - Inicialización del tablero
#### Predicado `initialBoard`

Para la inicialización del tablero se crearon una serie de predicados auxiliares para cada uno de los requerimientos del problema. El predicado `validCoord`, que dada una coordenada (X, Y) verifica si esta se encuentra dentro de los límites del tablero, va acompañado de `validCoords`, que chequea si una lista de coordenadas (las cajas de bloqueo) se encuentran todas dentro de los límites.

Se utilizó un predicado `notElem` para comprobar que ni el robot ni la caja objetivo tengan coordenadas idénticas a ninguna de las cajas de bloqueo, y el predicado `allDistinct` para comprobar que no existieran cajas de bloqueo en la misma posición.

Después de verificar el estado del tablero, se utiliza `retractall` para limpiar la base de datos dinámica de cualquier ejecución anterior, y acto seguido se insertan los nuevos hechos correspondientes al Robot, la caja objetivo y las cajas de bloqueo mediante `assertz`.

### Parte 2 - Validación de Movimientos
#### Predicado `isValidMove`

Para verificar si es válido realizar un movimiento se revisa la coordenada del robot y la que tendrá al moverse, considerando los 3 posibles casos: el caso donde se mueve sin empujar nada y donde empuja los diferentes tipos de caja, siguiendo las reglas del entorno (límites del tablero, empuje de cajas y colisiones).

Para calcular la posición del robot tras el movimiento se implementó el predicado `moves`.

Para validar los movimientos una vez calculada la nueva posición del robot, se obtiene la posición de la caja que este empujará o intentará empujar, se verifica la posición del robot antes de moverse, y se asegura que ni el robot ni las cajas caigan fuera del mapa, ni que se intente empujar una caja a la posición de otra.

### Parte 3 - Ejecución de Movimiento
#### Predicado  `moveRobot`

Se implementó la lógica para la realización de movimientos, aprovechando los predicados `moves` y `isValidMove`. **No se asume que el movimiento ya fue validado por isValidMove**, por lo que se hace una validación interna defensiva. Se retorna la nueva posición o estado del mapa una vez hecho el movimiento, recordando que si el Robot se mueve hacia una caja, la coordenada de esa caja también debe actualizarse en el estado resultante.

### Parte 4 - Solución
#### Predicado `solveWarehouse`

Para la solución del problema se implementó un algoritmo de búsqueda en anchura (BFS) que se encarga de guardar todos los estados visitados anteriormente para evitar ciclos infinitos. Este utiliza una cola de denominados `nodos`, que consisten en una tupla donde el primer elemento corresponde a un estado (el estado actual desde el que moverse) y el segundo a una lista de movimientos (todos los movimientos realizados hasta llegar a ese estado en específico). 

Por cada iteración de nodo `(estado, [movimientos])` se realizan distintas comprobaciones en el siguiente orden:

* Se obtiene una lista con todos los movimientos posibles a partir del estado actual.
* A partir de esta lista, se aplican los movimientos respectivos al estado actual.
* Antes de verificar si un estado ya fue visitado, se utiliza el predicado nativo `sort/2` para ordenar la lista de coordenadas de las cajas de bloqueo. Esto garantiza que estados lógicamente idénticos (pero con las cajas guardadas en distinto orden) no engañen a la lista de visitados.
* Se comprueba que el estado obtenido al aplicar el movimiento no se encuentre en la lista de visitados.
* Se hace append del nodo `(nuevo estado, [ultimo movimiento | movimientos])` al final de la cola para mantener la estrategia de búsqueda en anchura.
* Se realiza la llamada recursiva a nuestro predicado BFS.
* **Generación de la ruta:** Por eficiencia, el historial de movimientos de cada nodo se construye agregando los nuevos pasos al inicio de la lista. Al encontrar la meta, se utiliza el predicado nativo `reverse/2` para entregar la solución final en el orden cronológico correcto.
