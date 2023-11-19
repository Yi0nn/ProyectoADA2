% Parámetros
int: J;  % Número de unidades de generación (utpee)
int: K;  % Longitud del horizonte de planificación

array[1..J] of int: Ej;   % Costo de encender la utpee j
array[1..J] of float: Aj; % Costo de apagar la utpee j
array[1..J] of int: Gj;   % Indicador si la planta j terminó generando energía en el horizonte previo
array[1..J] of int: Fj;   % Costo fijo de operación de la utpee j
array[1..J] of float: Vj; % Coeficiente para calcular el costo variable de encender la utpee j
array[1..J] of int: Pj_inf;   % Límite inferior de generación de potencia de la utpee j si está generando
array[1..J] of int: Pj_sup;   % Límite superior de generación de potencia de la utpee j si está generando
array[1..J] of int: Supj; % Límite superior de ampliación de potencia para la utpee j
array[1..J] of int: Infj; % Límite inferior de reducción de potencia para la utpee j
array[1..J] of int: P0j;  % Potencia generada por la utpee j justo antes de iniciar el horizonte de planificación

array[1..K] of int: Dk; % Demanda global de energía para el período k
array[1..K] of int: Rk; % Reserva especificada de energía para el período k

% Variables de decisión
array[1..J, 1..K] of var int: pjk; % Potencia generada por la utpee j en el período k

% Restricciones
% (Coloca aquí las restricciones específicas del problema según la descripción)

% Función Objetivo
% (Define aquí la función objetivo para minimizar los costos)

% Ejemplo de restricción de que la potencia generada debe ser igual a la demanda global para cada período
constraint forall(k in 1..K)(sum(j in 1..J)(pjk[j, k]) == Dk[k]);

% Resuelve el problema
solve minimize costo;

% Salida de la potencia generada por cada utpee en cada período
output ["Potencia generada: \(pjk)"];
