%{
    Modelos de transmisión de enfermedades infecciosas modelados
    como un sistema de ecuaciones diferenciales de orden 1 en
    dimensión 2 o 3. Pintar retrato de fases.

    En el proyecto lo que se hace es una simulación de cómo se desarrolaría
    una epidemia en una ciudad. Luego de eso, se obtienen ciertos valores
    para poder modelar las ecuacaciones diferenciales y los retratos fases.
%}

clc; clear all;

% Consigue variables
global app
app = App();

% Botones
app.IniciarButton.ButtonPushedFcn = @(btn, event) startSimulation();
app.ReproducirButton.ButtonPushedFcn = @(btn, event) playSimulation();
app.PausarButton.ButtonPushedFcn = @(btn, event) pauseSimulation();
app.SiguientehoraButton.ButtonPushedFcn = @(btn, event) nextHour();
app.SiguientediaButton.ButtonPushedFcn = @(btn, event) nextDay();


function startSimulation()
    global app
    global virus
    global city
    
    infectionDuration = double(app.DuraciondeinfeccionhorasEditField.Value);
    infectionProbability = double(app.ProbabilidaddeinfeccionEditField.Value);
    deathProbability = double(app.ProbabilidaddemuerteEditField.Value);
    
    virus = Virus(infectionDuration, infectionProbability, deathProbability);
    
    populationSize = double(app.PoblacionEditField.Value);
    peoplePerHome = double(app.PersonasporcasaEditField.Value);
    leaveHouseProbability = double(app.ProbabilidaddesalirdecasaEditField.Value);
    returnHouseProbability = double(app.ProbabilidadderegresaracasaEditField.Value);
    maxLeaves = double(app.MaximassalidaspordiaEditField.Value);
    firstInfected = double(app.PrimerosinfectadosEditField.Value);
    
    city = City(populationSize, peoplePerHome, leaveHouseProbability, ...
                             returnHouseProbability, maxLeaves, virus, firstInfected);
    
    drawAll();
    updateLabels();
    
    app.ReproducirButton.Enable = true;
    app.SiguientehoraButton.Enable = true;
    app.SiguientediaButton.Enable = true;
end

function playSimulation()
    global city
    global app
    
    app.PausarButton.Enable = true;
    app.ReproducirButton.Enable = false;
    app.SiguientehoraButton.Enable = false;
    app.SiguientediaButton.Enable = false;
    set(0, 'userdata', false)
    
    % Corre hasta que se apriete el boton de pausar
    while ~get(0, 'userdata') && city.getInfectiousCount() > 0
        nextHour();
        pause(1 / 24);
        drawnow
    end
    
    app.PausarButton.Enable = false;
    app.ReproducirButton.Enable = true;
    app.SiguientehoraButton.Enable = true;
    app.SiguientediaButton.Enable = true;
    
end

function pauseSimulation()
    global app
    app.PausarButton.Enable = false;
    set(0, 'userdata', true);
end

% Funciones auxiliares
function nextHour()
    global city
    city.nextHour();
    drawAll();
    updateLabels();
end

function nextDay()
    global city
    city.nextDay();
    drawAll();
    updateLabels();
end

function drawAll()
    global city
    global app
    drawCity(city, app.CityAxes, app.SIRAxes, app.PortraitPhaseAxes);
end

function updateLabels()
    global app
    global city
    app.HoraLabel.Text = sprintf('Hora   %d', city.getCurrentHour());
    app.DiaLabel.Text = sprintf('Dia   %d', city.getCurrentDay());
    app.SusceptiblesLabel.Text = sprintf('Susceptibles   %d', city.getSusceptibleCount());
    app.InfectadosLabel.Text = sprintf('Infectados   %d', city.getInfectiousCount());
    app.RecuperadosLabel.Text = sprintf('Recuperados   %d', city.getRecoveredCount());
    app.R0Label.Text = sprintf('R0   %.2f', city.getBasicReproductionNumber());
end

