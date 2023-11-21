% Parámetros
int: J; % Número de utpees
int: K; % Longitud del horizonte de planificación
array[1..J] of int: Ej; % Costo de encender la utpee j
array[1..J] of float: Aj; % Costo de apagar la utpee j
array[1..J] of int: Gj; % Indicador de si la planta j terminó generando energía en el horizonte previo
array[1..J] of int: Fj; % Costo fijo de operación de la utpee j
array[1..J] of float: Vj; % Coeficiente para calcular el costo variable de encender la utpee j
array[1..J] of int: Pj_lower; % Límite inferior de generación de potencia de la utpee j si está generando
array[1..J] of int: Pj_upper; % Límite superior de generación de potencia de la utpee j si está generando
array[1..J] of int: Supj; % Límite superior de ampliación de potencia para la utpee j
array[1..J] of int: Infj; % Límite inferior de reducción de potencia para la utpee j
array[1..J] of int: P0j; % Potencia generada por la utpee j justo antes de iniciar el horizonte de planificación
array[1..K] of int: Dk; % Demanda global de energía para el período k
array[1..K] of int: Rk; % Reserva especificada de energía para el período k

% Variables
array[1..J, 1..K] of var 0..max(Pj_upper): pjk;
array[1..J, 1..K] of var 0..1: encendida_decision;
array[1..J] of var 0..1: inicial_encendida_decision;

% Restricciones
constraint forall(j in 1..J, k in 1..K) (
  if encendida_decision[j, k] = 1 then
    Pj_lower[j] * encendida_decision[j, k] <= pjk[j, k] /\ pjk[j, k] <= Pj_upper[j] * encendida_decision[j, k]
  else
    pjk[j, k] = 0
  endif
);

constraint forall(k in 1..K) (
  sum(j in 1..J) (encendida_decision[j, k] * pjk[j, k]) = Dk[k]
);

constraint forall(k in 1..K) (
  sum(j in 1..J) (encendida_decision[j, k] * Pj_upper[j]) >= Dk[k] + Rk[k]
);

% Función objetivo simplificada
var float: costo_total = 
  sum(j in 1..J, k in 1..K) (
    encendida_decision[j, k] * (Fj[j] + Vj[j] * pjk[j, k]) +
    (k > 1 /\ encendida_decision[j, k] = 1 /\ encendida_decision[j, k - 1] = 0) * Ej[j] +
    (k > 1 /\ encendida_decision[j, k] = 0 /\ encendida_decision[j, k - 1] = 1) * Aj[j]
  ) +
  sum(j in 1..J) (
    (P0j[j] > 0 /\ inicial_encendida_decision[j] = 0) * Aj[j] +
    (P0j[j] = 0 /\ inicial_encendida_decision[j] = 1) * Ej[j]
  );

% Minimizar la función objetivo
solve minimize costo_total;

% Output u otras operaciones si es necesario...
