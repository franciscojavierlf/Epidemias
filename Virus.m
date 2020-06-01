classdef Virus
    %VIRUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        InfectionProbability
        InfectionDuration
        DeathProbability
    end
    
    methods
        function this = Virus(infectionDuration, infectionProbability, deathProbability)
            %VIRUS Construct an instance of this class
            this.InfectionProbability = infectionProbability;
            this.InfectionDuration = infectionDuration;
            this.DeathProbability = deathProbability;
        end
        
        function res = getInfectionProbability(this)
            res = this.InfectionProbability;
        end
        
        function res = getInfectionDuration(this)
            res = this.InfectionDuration;
        end
        
        function res = getDeathProbability(this)
            res = this.DeathProbability;
        end
    end
end

