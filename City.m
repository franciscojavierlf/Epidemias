classdef City < handle
    %CITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Population
        Homes
        NoHomes
        
        SusceptiblesByHour
        InfectiousByHour
        RecoveredByHour
        PopulationByHour
    end
    
    properties (Access = private)
        Virus
        PeoplePerHome
        LeaveHouseProbability
        ReturnHouseProbability
        MaxLeaves
        
        OriginalPopulationSize
        SusceptibleCount = 0
        InfectiousCount = 0
        RecoveredCount = 0
        
        InfectiousPeak = 1 % La hora donde hubo más infecciones
        
        CurrentHour = 0
        CurrentDay = 0
       
        BuildingsPerApple = 8
        NoHomesPerHome = 0.5
    end
    
    methods
        
        function this = City(populationSize, peoplePerHome, leaveHouseProbability, ...
                             returnHouseProbability, maxLeaves, virus, firstInfected)
            %CITY Construct an instance of this class
            this.PeoplePerHome = peoplePerHome;
            this.LeaveHouseProbability = leaveHouseProbability;
            this.ReturnHouseProbability = returnHouseProbability;
            this.MaxLeaves = maxLeaves;
            this.Virus = virus;
            this.OriginalPopulationSize = populationSize;
            
            % Crea la ciudad
            this.buildCity(populationSize);
            
            % Crea a la poblacion
            this.createPopulation(populationSize, firstInfected);
        end
        
        function res = getOriginalPopulationSize(this)
            res = this.OriginalPopulationSize;
        end
        
        function res = getPeoplePerHome(this)
            res = this.PeoplePerHome;
        end
        
        function res = getCurrentHour(this)
            res = this.CurrentHour;
        end
        
        function res = getCurrentDay(this)
            res = this.CurrentDay;
        end
        
        function res = getMaxLeaves(this)
            res = this.MaxLeaves;
        end
        
        function res = getSusceptibleCount(this)
            res = this.SusceptibleCount;
        end
        
        function res = getInfectiousCount(this)
            res = this.InfectiousCount;
        end
        
        function res = getRecoveredCount(this)
            res = this.RecoveredCount;
        end
        
        % Da el total de horas contando dias
        function res = getRealHour(this)
            res = this.CurrentDay * 24 + this.CurrentHour;
        end
        
        % Obtiene la tasa actual de transmisión
        function beta = getInfectionRate(this)
            % Solo existe cuando ha pasado un día
            if this.CurrentDay >= 1
                I0 = this.InfectiousByHour(2, 1);
                I1 = this.InfectiousByHour(2, 25);
                S0 = this.SusceptiblesByHour(2, 1);
                dI0 = (I1 - I0) / I0;
                beta = dI0 / (S0 * I0);
            else
                beta = NaN;
            end
        end
        
        % Obtiene la tasa actual de recuperados
        function gamma = getRecoveryRate(this)
            if this.CurrentDay >= 1
                beta = this.getInfectionRate();
                St_dot = this.InfectiousByHour(2, this.InfectiousPeak);
                gamma = beta * St_dot;
            else
                gamma = NaN;
            end
        end
        
        % Obtiene el número básico de reproducciones de un infectado
        function r0 = getBasicReproductionNumber(this)
            r0 = this.getInfectionRate() / this.getRecoveryRate();
        end
        
        function r = getReproductionNumber(this)
            r = this.getBasicReproductionNumber() * this.SusceptibleCount;
        end
        
        
        % Pasa una hora. Cada hora hay una probabilidad de que una persona
        % salga de su casa a un lugar publico o que regrese a su casa.
        % Igualmente cada hora es posible contagiarse si hay un contagiado
        % dentro del edificio en el que esta.
        function nextHour(this)
            this.CurrentHour = this.CurrentHour + 1;
            % Nuevo dia
            if this.CurrentHour >= 24
                % Reinicia salidas de personas
                for i = 1 : this.Population.length()
                    this.Population.getAt(i).Leaves = 0;
                end
                this.CurrentDay = this.CurrentDay + 1;
                this.CurrentHour = 0;
            end
            
            % Actualiza tiempo de enfermos por una hora
            this.updateSickPeople();
            % Mueve a las personas
            this.movePeople();
            % Una vez que todos se muevan como deban, checa las casas para
            % infecciones
            this.updateInfections();
            
            % Y actualiza la lista de contadorea
            this.updateCountLists();
        end
        
        % Pasa al siguiente dia (24 horas)
        function nextDay(this)
            for i = 1 : 24
                this.nextHour();
            end
        end
    end
    
    methods (Access = private)
        
        % Actualiza a los enfermos por una hora
        function updateSickPeople(this)
            % Tiene que ser while porque la longitud se actualiza
            i = 1;
            while i <= this.Population.length()
                p = this.Population.getAt(i);
                if p.isInfectious()
                    p.InfectedHours = p.InfectedHours + 1;
                    
                    % Puede recuperarse un enfermo
                    if p.InfectedHours >= this.Virus.getInfectionDuration()
                        p.makeRecovered();
                        this.InfectiousCount = this.InfectiousCount - 1;
                        this.RecoveredCount = this.RecoveredCount + 1;
                        
                    % Pero también puede morir
                    elseif rand() < this.Virus.getDeathProbability()
                        this.Population.remove(p.getId);
                        this.InfectiousCount = this.InfectiousCount - 1;
                        i = i - 1;
                    end
                end
                i = i + 1;
            end
        end
        
        % Actualiza los edificios, infectando donde se deba
        function updateInfections(this)
            % Casas y no casas
            buildings = this.Homes;
            for i = 1 : 2
                % Comienza con casas
                for j = 1 : buildings.length()
                    b = buildings.getAt(j);
                    % Busca infectados
                    for k = 1 : b.People.length()
                        % Pasa por cada persona si uno esta infectado
                        if b.People.getAt(k).isInfectious()
                            for l = 1 : b.People.length()
                                p = b.People.getAt(l);
                                if p.isSusceptible() && rand() < this.Virus.getInfectionProbability()
                                    p.makeInfectious();
                                    this.SusceptibleCount = this.SusceptibleCount - 1;
                                    this.InfectiousCount = this.InfectiousCount + 1;
                                end
                            end
                        end
                    end
                end
                % Ahora las no casas
                buildings = this.NoHomes;
            end
        end
        
        % Mueve a las personas
        function movePeople(this)
            for i = 1 : this.Population.length()
                p = this.Population.getAt(i);
                prob = rand();
                % Sale de su casa a un edificio
                if p.isHome() && p.Leaves < this.MaxLeaves && prob < this.LeaveHouseProbability
                    % Consigue un edificio random
                    index = ceil(randomBetween(0, this.NoHomes.length()));
                    b = this.NoHomes.getAt(index);
                    while b.isFull()
                        index = ceil(randomBetween(0, this.NoHomes.length()));
                        b = this.NoHomes.getAt(index);
                    end
                    % Y lo pone en el edificio
                    b.movePerson(p);
                    p.Leaves = p.Leaves + 1;
                % Sale de un edificio a su casa
                elseif ~p.isHome() && prob < this.ReturnHouseProbability
                    p.returnHome();
                end
            end
        end
        
        % Construye una ciudad con suficientes casas
        function buildCity(this, populationSize)
            % Maximas cuadras (cuentan casas y edificios)
            homesCount = ceil(populationSize / this.PeoplePerHome / this.BuildingsPerApple) * this.BuildingsPerApple;
            noHomesPerHome = 1;
            noHomesCount = ceil(homesCount * noHomesPerHome / this.BuildingsPerApple) * this.BuildingsPerApple;
            
            buildingsCount = homesCount + noHomesCount;
            
            % Crea la lista de edificios
            this.Homes = List(homesCount);
            this.NoHomes = List(noHomesCount);
            
            appleCount = buildingsCount / this.BuildingsPerApple;
            
            % Y luego crea las cuadras            
            buildingWidth = 15;
            buildingHeight = 30;
            streetSize = 25;
            yOffset = 0;
            width = ceil(this.BuildingsPerApple * 0.5); % Dos hileras de casas por cuadra
            height = 2;
            aWidth = ceil(sqrt(appleCount)); % Numero de cuadras en ancho
            aHeight = aWidth; % Numero de cuadras en alto
            appleWidth = buildingWidth * width;
            appleHeight = buildingHeight * height;
            isHome = false;
            
            homeChange = 0;
            count = 1;
            
            
            % Va de cuadra por cuadra
            for appleY = 0 : aHeight - 1
                xOffset = 0;
                for appleX = 0 : aWidth - 1

                    % Cambia tipo de cuadra
                    isHome = ~isHome;

                    % Crea los edificios
                    for y = 0 : height - 1
                    for x = 0 : width - 1

                        % Posicion
                        xPos = appleWidth * appleX + x * buildingWidth + xOffset;
                        yPos = appleHeight * appleY + y * buildingHeight + yOffset;

                        % Cosas especiales de cada cosa
                        if isHome
                            maxPeople = this.PeoplePerHome;
                            list = this.Homes;
                        else
                            maxPeople = 8;
                            list = this.NoHomes;
                        end

                        % Y lo agrega
                        name = sprintf('%s_%d', 'building', count);
                        b = Building(name, xPos, yPos, buildingWidth, buildingHeight, maxPeople);
                        list.add(b);
                        count = count + 1;
                    end
                    end
                    xOffset = xOffset + streetSize;
                end
                yOffset = yOffset + streetSize;
            end
        end
        
        % Crea personas y les asigna casa
        function createPopulation(this, populationSize, firstInfected)
            this.Population = List(populationSize);
            currentHouse = 1;
            for i = 1 : populationSize
                p = Person(sprintf('%s_%d', 'person', i));
                % Lo pone en una casa
                h = this.Homes.getAt(currentHouse);
                while h.isFull()
                    currentHouse = currentHouse + 1;
                    h = this.Homes.getAt(currentHouse);
                end
                % Agrega la persona a la casa
                p.Home = h;
                h.movePerson(p);
                
                % Y lo agrega
                this.Population.add(p);
            end
            
            % Infecta a n personas al principio
            for i = 1 : firstInfected
                while true
                    index = ceil(randomBetween(0, populationSize));
                    p = this.Population.getAt(index);
                    if p.isSusceptible()
                        p.makeInfectious();
                        break;
                    end
                end
            end
            
            % Actualiza los contadores por primera vez
            this.SusceptibleCount = populationSize - firstInfected;
            this.InfectiousCount = firstInfected;
            this.RecoveredCount = 0;
            
            this.updateCountLists();
        end
        
        % Agrega los contadores actuales
        function updateCountLists(this)
            rh = this.getRealHour();
            this.SusceptiblesByHour(:, rh + 1) = [rh; this.SusceptibleCount];
            this.InfectiousByHour(:, rh + 1) = [rh; this.InfectiousCount];
            this.RecoveredByHour(:, rh + 1) = [rh; this.RecoveredCount];
            this.PopulationByHour(:, rh + 1) = [rh; this.Population.length()];
            
            % Actualiza el índice del mayor número de infecciones
            if this.InfectiousByHour(2, this.InfectiousPeak) < this.InfectiousCount
                this.InfectiousPeak = rh + 1;
            end
        end
    end
end

