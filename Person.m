classdef Person < handle
    %PERSON Summary of this class goes here
    %   Una persona
    
    properties
        Type  % Susceptible, Infectious (2 dias), Recovered (inmune)
        InfectedHours
        X
        Y
        Home
        CurrentBuilding
        Leaves = 0
    end
    
    properties (Access = private)
       Name
    end
    
    methods
        function this = Person(name)
            %PERSON Construct an instance of this class
            this.Name = name;
            this.makeSusceptible();
        end
        
        function res = getId(this)
            res = this.getName();
        end
        
        function res = getName(this)
            res = this.Name;
        end
        
        function res = isHome(this)
            res = strcmp(this.CurrentBuilding.getName(), this.Home.getName());
        end
        
        function returnHome(this)
            this.Home.movePerson(this);
        end
        
        function makeSusceptible(this)
            this.Type = 's';
            this.InfectedHours = 0;
        end
        
        function makeInfectious(this)
            this.Type = 'i';
            this.InfectedHours = 0;
        end
        
        function makeRecovered(this)
            this.Type = 'r';
            this.InfectedHours = 0;
        end
        
        function makeDeath(this)
            this.Type = 'd';
            this.InfectedHours = 0;
        end
        
        function res = isSusceptible(this)
            res = strcmp(this.Type, 's');
        end
        
        function res = isInfectious(this)
            res = strcmp(this.Type, 'i');
        end
        
        function res = isRecovered(this)
            res = strcmp(this.Type, 'r');
        end
        
        function res = isDeath(this)
            res = strcmp(this.Type, 'd');
        end
    end
end

