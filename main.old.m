%{
    Modelos de transmisión de enfermedades infecciosas modelados
    como un sistema de ecuaciones diferenciales de orden 1 en
    dimensión 2 o 3. Pintar retrato de fases.

    https://repositorio.unican.es/xmlui/bitstream/handle/10902/7125/Andrea%20Garcia%20Pi%C3%B1era.pdf
%}

close all; clc

%% Ecuación diferencial

% El tiempo
t0 = 0;
tf = 100;

% Valores de la epidemia
beta = 0.0022; % Tasa per-cápita de transmisión de la enfermedad
v = 0.4477; % Tasa de retiro


% Valores iniciales
Y0s = zeros(3, 1);
Y0s(:, 1) = [763, 1, 0];

% Función
f = @(t, Y) [
            -beta * Y(1) * Y(2) ; % Tasa de infección
             beta * Y(1) * Y(2) - v * Y(2); % Tasa de susceptibles
             v * Y(2) % Tasa de retirados
             ];

%% Plotear retrato fase

% Plotea algunas soluciones
[~, n] = size(Y0s);

max_x = -inf;
max_y = -inf;
hold on
for i = 1 : n
    % Obtiene solucion
    [~,ys] = ode45(f, [t0 tf], Y0s(:, i));
    % Guarda el valor máximo y mínimo de cada eje
    new_max_x = max(ys(:, 1));
    new_max_y = max(ys(:, 2));
    if new_max_x > max_x
        max_x = new_max_x;
    end
    if new_max_y > max_y
        max_y = new_max_y;
    end
    
    % Plotea la solución
    plot3(ys(:,1), ys(:,2), ys(:, 3))
    plot3(ys(1,1), ys(1,2), ys(1, 3),'bo') % starting point
    plot3(ys(end,1), ys(end,2), ys(end, 3),'ks') % ending point
end

% Luego plotea los vectores direccionales

% El mayor eje para que todo sea proporcional
max_val = max(max_x, max_y);
% Y plotea
y1 = linspace(0, max_val, 25);
y2 = linspace(0, max_val, 25);
y3 = linspace(0, max_val, 25);
[x, y, z] = meshgrid(y1, y2, y3);

u = zeros(size(x));
v = zeros(size(y));
w = zeros(size(z));

for i = 1 : numel(x)
    % Se asume que el tiempo inicial es cero
    ydot = f(0, [x(i) ; y(i) ; z(i)]);
    u(i) = ydot(1);
    v(i) = ydot(2);
    w(i) = ydot(3);
end

% Dibuja las flechas
quiver3(x, y, z, u, v, w, 'r'); figure(gcf)
axis tight equal;
hold off