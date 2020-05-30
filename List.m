classdef List < handle
    %LIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Cells
    end
    
    properties (Access = private)
        Length = 0
        Size
    end
    
    methods
        function this = List(initialSize)
            %LIST Construct an instance of this class
            %   Detailed explanation goes here
            this.Size = initialSize;
            this.Cells = cell(1, initialSize);
        end
        
        function add(this, obj)
            
            % Intenta aumentar tamano
            if this.Length + 1 >= this.Size
                this.expand();
            end
            
            % Y agrega el objeto
            this.Length = this.Length + 1;
            this.Cells{this.Length} = obj;
        end
        
        function remove(this, id)
            index = this.indexOf(id);
            
            % Recorre los objetos
            for i = index : this.Length - 1
               this.Cells{i} = this.Cells{i + 1};
            end
            this.Cells{this.Length} = [];
            this.Length = this.Length - 1;
            
        end
        
        function i = indexOf(this, id)
            i = 1;
            while i <= this.Length && ~strcmp(this.Cells{i}.getId(), id)
                i = i + 1;
            end
            
            if i > this.Length
                i = -1;
            end
        end
        
        function res = getAt(this, i)
            res = this.Cells{i};
        end
        
        function res = length(this)
            res = this.Length;
        end
    end
    
    methods (Access = private)
       
        % Aumenta el tamano de la lista
        function expand(this)
            
            this.Size = this.Size + 10;
            newCells = cell(1, this.Size);
            for i = 1 : this.Length
                newCells{i} = this.Cells{i};
            end
            this.Cells = newCells;
        end
    end
end

