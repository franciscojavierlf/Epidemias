clc; clear all;

infectionDuration = 48; % 2 dias
infectionProbability = 0.2;

covid19 = Virus(infectionDuration, infectionProbability);

firstInfected = 1;


population = 128;
peoplePerHouse = 3;
leaveHouseProbability = 0.2;
returnHouseProbability = 0.2;
maxLeaves = 3;

city = City(population, peoplePerHouse, leaveHouseProbability, returnHouseProbability, maxLeaves, covid19, firstInfected);


runSimulation(city, 30);