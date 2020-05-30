classdef Building < handle
    %BUILDING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        People
        X
        Y
        Width
        Height
        MaxPeople
    end
    
    properties (Access = private)
        Name
    end
    
    methods
        function this = Building(name, x, y, width, height, maxPeople)
            %BUILDING Construct an instance of this class
            %   Detailed explanation goes here
            this.Name = name;
            this.X = x;
            this.Y = y;
            this.Width = width;
            this.Height = height;
            this.MaxPeople = maxPeople;
            this.People = List(maxPeople);
        end
        
        function res = getId(this)
            res = this.getName(this);
        end
        
        function res = getName(this)
            res = this.Name;
        end
        
        % Mueve una persona al edificio
        function movePerson(this, person)
            if ~this.isFull()
                % Saca a la persona de su edificio viejo
                if ~isempty(person.CurrentBuilding)
                    person.CurrentBuilding.removePerson(person.getName());
                end
                % La pone dentro del edificio
                this.People.add(person);
                person.CurrentBuilding = this;
                % Y luego la posiciona sin tocar a otras personas
                % Toma un paddding de 5 y un radio de 2
                
                padding = 5;
                radius = 5;
                
                minX = padding;
                maxX = this.Width - padding;
                minY = padding;
                maxY = this.Height - padding;
                
                tries = 1;
                while tries <= 10
                    x = randomBetween(minX, maxX) + this.X;
                    y = randomBetween(minY, maxY) + this.Y;
                    
                    if ~this.collides(x, y, radius)
                        break;
                    end
                    tries = tries + 1;
                end
                person.X = x;
                person.Y = y;
            end
        end
        
        function res = isFull(this)
            res = this.People.length() >= this.MaxPeople;
        end
    end
    
    methods (Access = private)
        
        function printPeople(this)
            for i = 1 : this.People.length()
                disp(this.People.getAt(i).getName());
            end
        end
        
        % Quita a una persona de un edificio
        function removePerson(this, name)
            this.People.remove(name);
        end
       
        % Checa si una posicion colisiona con otras personas
        function res = collides(this, x, y, radius)
            res = false;
            for i = 1 : this.People.length()
                p = this.People.getAt(i);
                if (p.X - x) * (p.X - x) + (p.Y - y) * (p.Y - y) <= 4 *radius * radius
                    res = true;
                    return;
                end
            end
        end
    end
end

