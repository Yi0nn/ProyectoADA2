% Parámetros
int: J; % Número de utpee
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
array[1..J] of int: P0j; % Potencia generada por la utpee j justo antes de iniciar el horizonte dSe planificación
array[1..K] of int: Dk; % Demanda global de energía para el período k
array[1..K] of int: Rk; % Reserva especificada de energía para el período k
% Variables
array[1..J, 1..K] of var 0..max(Pj_upper): pjk; % Potencia generada por la utpee j en el período k
array[1..J, 1..K] of var 0..1: utpee_state; % Indica si la utpee j generó energía en el periodo k
array[1..J, 1..K] of var 0..1: Prendida; % Indica si la utpee j se encendió en el periodo k
array[1..J, 1..K] of var 0..1: Apagada; % Indica si la utpee j se apagó en el periodo k


%Restriccion de no negatividad
%La potencia generada por cada utpee en cada período debe ser no negativa.
constraint forall(j in 1..J, k in 1..K)(pjk[j,k] >= 0);

% Para cada unidad j y cada periodo k
constraint forall(j in 1..J, k in 1..K) (
    % *Explicación:
    % `utpee_state` indica si la utpee j está encendida en el período k.
    % `Prendida` indica si la utpee j se enciende en el período k.
    % `Apagada` indica si la utpee j se apaga en el período k.
    % **Estado de operación de la unidad**
    utpee_state[j, k] = (pjk[j, k] > 0) /\
    
    % Condición de inicio de la unidad
    Prendida[j, k] = (
        % La utpee j se enciende en el período k si y solo si
        % 1. No estaba encendida en el período anterior.
        % 2. La potencia generada en ese período es mayor que cero.
        (k > 1 /\ pjk[j, k - 1] = 0 /\ pjk[j, k] > 0) \/ 
        %O si es el primer período y la utpee j no estaba encendida en el horizonte previo.
        (k = 1 /\ Gj[j] = 0 /\ pjk[j, k] > 0)
    ) /\
    
    % Condición de apagado de la unidad
    Apagada[j, k] = (
        % La utpee j se apaga en el período k si y solo si
        % 1. Estaba encendida en el período anterior.
        % 2. La potencia generada en ese período es cero.
        (k > 1 /\ pjk[j, k - 1] > 0 /\ pjk[j, k] = 0) \/ 
        % O si es el primer período y la utpee j estaba encendida en el horizonte previo.
        (k = 1 /\ Gj[j] = 1 /\ pjk[j, k] = 0)
    )
);


% Restricción de igualdad entre generación y demanda
 % *Explicación:
 % Esta restricción garantiza que la demanda se satisfaga en cada período.
constraint forall(k in 1..K) (
  sum(j in 1..J) (pjk[j, k]) = Dk[k]
);

%Restriccion de generacion superior de potencia
 % *Explicación:
 % Esta restricción limita la potencia generada por cada utpee a su límite superior.
constraint forall(j in 1..J, k in 1..K) (
    pjk[j, k] <= Pj_upper[j]
);

%Restriccion de generacion inferior de potencia
% *Explicación:
% Esta restricción garantiza que la potencia generada por cada utpee sea al menos su límite inferior.
constraint forall(j in 1..J, k in 1..K) (
    (pjk[j, k] <= 0) \/ (pjk[j, k] >= Pj_lower[j])
);

% Restricciones de disminución de potencia
 % *Explicación:
 % Estas restricciones garantizan que la potencia generada por cada utpee no disminuya más allá de su límite inferior.
constraint forall(j in 1..J, k in 2..K) (
    (pjk[j, k] <= 0 \/ pjk[j, k - 1] <= 0 \/ pjk[j, k - 1] - pjk[j, k] <= Infj[j])
);

% Restricciones de aumento de potencia
 % *Explicación:
 % Estas restricciones garantizan que la potencia generada por cada utpee no aumente más allá de su límite superior.
constraint forall(j in 1..J, k in 2..K) (
    (pjk[j, k] <= 0 \/ pjk[j, k - 1] <= 0 \/ pjk[j, k] - pjk[j, k - 1] <= Supj[j])
);

% Restricción de reserva
 % *Explicación:
 % Esta restricción garantiza que la capacidad de generación total de las utpee sea suficiente para satisfacer la demanda más la reserva.
constraint forall(k in 1..K) (
  sum(j in 1..J) (Pj_upper[j] * utpee_state[j, k]) >= Dk[k] + Rk[k]
);

% Función objetivo 
var float: costo;

constraint costo = sum(k in 1..K) (
    % *Explicación:
     % La función objetivo del modelo es minimizar el costo total de operación de las utpee.
    sum(j in 1..J)(
    % Costo variable de generar potencia
    Vj[j] * pjk[j, k] + 
    % Costo de encender una utpee
    Ej[j] * Prendida[j, k] +
    % Costo de apagar una utpee
    Aj[j] * Apagada[j, k] + 
    % Costo fijo de operar una utpee
    Fj[j] * utpee_state[j, k]
    )
);

% Minimizar la función objetivo
solve minimize costo;

% Salida
output ["pjk = \(pjk) \ncosto = \(costo) \n"];
