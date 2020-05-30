function runSimulation(city, days)
%DRAW Summary of this function goes here
%   Dibuja todo

FPS = 24;

% Consigue variables
app = App();

% Botones
app.ReproducirButton.ButtonPushedFcn = @(btn, event) playSimulation();
app.PausarButton.ButtonPushedFcn = @(btn, event) pauseSimulation();
app.SiguientehoraButton.ButtonPushedFcn = @(btn, event) nextHour();
app.SiguientediaButton.ButtonPushedFcn = @(btn, event) nextDay();

% Dibuja por primera vez
drawCity(city, app.UIAxes, app.UIAxes2);
updateLabels();

function playSimulation()
    app.PausarButton.Enable = true;
    app.ReproducirButton.Enable = false;
    app.SiguientehoraButton.Enable = false;
    app.SiguientediaButton.Enable = false;
    set(0, 'userdata', false)
    
    % Corre hasta que se apriete el boton de pausar
    while ~get(0, 'userdata') && city.getInfectiousCount() > 0
        nextHour();
        pause(1 / FPS);
        drawnow
    end
    
    app.PausarButton.Enable = false;
    app.ReproducirButton.Enable = true;
    app.SiguientehoraButton.Enable = true;
    app.SiguientediaButton.Enable = true;
    
end

function pauseSimulation()
    app.PausarButton.Enable = false;
    set(0, 'userdata', true);
end

% Funciones auxiliares
function nextHour()
    city.nextHour();
    drawCity(city, app.UIAxes, app.UIAxes2);
    updateLabels();
end

function nextDay()
    city.nextDay();
    drawCity(city, app.UIAxes, app.UIAxes2);
    updateLabels();
end

function updateLabels()
    app.HoraEditField.Value = sprintf('%d', city.getCurrentHour());
    app.DiaEditField.Value = sprintf('%d', city.getCurrentDay());
    app.SusceptiblesEditField.Value = sprintf('%d', city.getSusceptibleCount());
    app.InfectadosEditField.Value = sprintf('%d', city.getInfectiousCount());
    app.RecuperadosEditField.Value = sprintf('%d', city.getRecoveredCount());
end


end

