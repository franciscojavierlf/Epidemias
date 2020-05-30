classdef Virus
    %VIRUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        InfectionProbability
        InfectionDuration        
    end
    
    methods
        function this = Virus(infectionDuration, infectionProbability)
            %VIRUS Construct an instance of this class
            this.InfectionProbability = infectionProbability;
            this.InfectionDuration = infectionDuration;
        end
        
        function res = getInfectionProbability(this)
            res = this.InfectionProbability;
        end
        
        function res = getInfectionDuration(this)
            res = this.InfectionDuration;
        end
    end
end

