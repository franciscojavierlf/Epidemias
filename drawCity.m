function drawCity(city, cityAxes, graphAxes)
%DRAW Summary of this function goes here
%   Detailed explanation goes here

cla(cityAxes);

hold(cityAxes, 'on');


% Dibuja las casas
xx = zeros(4,city.Homes.length());
yy = zeros(4, city.Homes.length());

for i = 1 : city.Homes.length()
    b = city.Homes.getAt(i);

    xx(:, i) = [b.X, b.X + b.Width, b.X + b.Width, b.X];
    yy(:, i) = [b.Y, b.Y, b.Y + b.Height, b.Y + b.Height];
end

patch(cityAxes, 'XData', xx, 'YData',  yy, 'FaceColor', 'none', 'EdgeColor', [0 0 1]);

% Dibuja los edificios
xx = zeros(4,city.NoHomes.length());
yy = zeros(4, city.NoHomes.length());

for i = 1 : city.NoHomes.length()
    b = city.NoHomes.getAt(i);

    xx(:, i) = [b.X, b.X + b.Width, b.X + b.Width, b.X];
    yy(:, i) = [b.Y, b.Y, b.Y + b.Height, b.Y + b.Height];
end

patch(cityAxes, 'XData', xx, 'YData',  yy, 'FaceColor', 'none', 'EdgeColor', [0.4 0.4 0.4]);

% Dibuja a las personas
sx = zeros(1, city.getSusceptibleCount());
sy = zeros(1, city.getSusceptibleCount());
ix = zeros(1, city.getInfectiousCount());
iy = zeros(1, city.getInfectiousCount());
rx = zeros(1, city.getRecoveredCount());
ry = zeros(1, city.getRecoveredCount());
sc = 1;
ic = 1;
rc = 1;
for i = 1 : city.Population.length()
    p = city.Population.getAt(i);
   
    % Casos para diferentes estados
    if p.isSusceptible()
        sx(1, sc) = p.X;
        sy(1, sc) = p.Y;
        sc = sc + 1;
    elseif p.isInfectious()
        ix(1, ic) = p.X;
        iy(1, ic) = p.Y;
        ic = ic + 1;
    elseif p.isRecovered()
        rx(1, rc) = p.X;
        ry(1, rc) = p.Y;
        rc = rc + 1;
    end
end

scatter(cityAxes, sx, sy, 25, [0 0 1], 'filled');
scatter(cityAxes, ix, iy, 25, [1 0 0], 'filled');
scatter(cityAxes, rx, ry, 25, [0.4 0.4 0.4], 'filled');


% Luego dibuja la grafica de datos
i = city.InfectiousByHour;
r = city.RecoveredByHour;

cla(graphAxes);

hold(graphAxes, 'on');
% Pinta un cuadro en el fondo
rh = city.getRealHour();
pp = city.Population.length();

% Fixes for the first iteration
if rh == 0
    rh = 1;
end
xaxis = linspace(0, rh / 24, rh + 1);
area(graphAxes, [0 rh], [pp pp]);
% Y luego pinta las otras graficas
area(graphAxes, xaxis, r(2, :), 'FaceColor', [0.4 0.4 0.4]);
area(graphAxes, xaxis, i(2, :), 'FaceColor', [1 0 0]);

axis(graphAxes, [0, rh / 24, 0, pp]);

end

