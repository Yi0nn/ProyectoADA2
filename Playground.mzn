% Parámetros de entrada
int: J;  % Número de utpee
int: K;  % Longitud del horizonte de planificación

array[1..J] of int: Ej;    % Costo de encender la utpee j
array[1..J] of float: Aj;  % Costo de apagar la utpee j
array[1..J] of int: Gj;    % Indicador de si la planta j terminó generando energía en el ciclo anterior
array[1..J] of int: Fj;    % Costo fijo de operación de la utpee j
array[1..J] of float: Vj;  % Coeficiente para calcular el costo variable de encender la utpee j
array[1..J] of int: Pj;    % Límite inferior de generación de potencia de la utpee j si está generando
array[1..J] of int: Pj_;   % Límite superior de generación de potencia de la utpee j si está generando
array[1..J] of int: Supj;  % Límite superior de ampliación de potencia para la utpee j
array[1..J] of int: Infj;  % Límite inferior de reducción de potencia para la utpee j
array[1..J] of int: P0j;   % Potencia generada por la utpee j justo antes de iniciar el horizonte de planificación
array[1..K] of int: Dk;    % Demanda global de energía para el período k
array[1..K] of int: Rk;    % Reserva especificada de energía para el período k

% Variables
array[1..J, 1..K] of var int: pjk;  % Potencia generada por la utpee j en el período k

% Restricciones
constraint forall(j in 1..J, k in 2..K) (
    pjk[j, k] >= pjk[j, k-1] - Infj[j] /\ pjk[j, k] <= pjk[j, k-1] + Supj[j]
);

constraint forall(j in 1..J, k in 2..K) (
    pjk[j, k] = pjk[j, k-1] - Ej[j] \/ pjk[j, k] = pjk[j, k-1] + Aj[j]
);

var float: costo_variable = sum(j in 1..J, k in 1..K) (Vj[j] *(pjk[j, k]));
var int: costo_total = sum(j in 1..J) (Fj[j]) + round(costo_variable);

solve minimize costo_total;

constraint forall(k in 1..K) (
    sum(j in 1..J) (pjk[j, k]) == Dk[k]
);

constraint forall(k in 2..K) (
    sum(j in 1..J where Gj[j] == 1) (pjk[j, k]) >= Dk[k] + Rk[k]
);
