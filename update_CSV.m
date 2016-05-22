close all
clear all
%1 Team ID
team_id(1:200) = 8099;
team_id = transpose(team_id);

%2 Mission Time
mission_time = 1:200;
mission_time = transpose(mission_time)

%3 Packet Count
packet_count = mission_time;

%4 Altitude sensor
altitude = linspace(400,1,200)
altitude = transpose(altitude)

%5 Pressure
pressure = ones(200,1) + rand(200,1) + 5;

%6 Speed
speed = ones(200,1) + rand(200,1) + 10;

%7 Temperature
temperature = ones(200,1) + rand(200,1) + 30;

%8 Voltage
voltage = ones(200,1) + rand(200,1) + 3.3;

%9 GPS Latitude
GPSlat = ones(200,1) + rand(200,1) + 46.23;

%10 GPS Longitude
GPSlong = ones(200,1) + rand(200,1) + 18.23;

%11 GPS Altitude
GPSalt = ones(200,1) + rand(200,1) + 400;

%12 GPS Satellites No.
gpsSat(1:200) = 5;
gpsSat = transpose(gpsSat);

%13 GPS Speed
GPSspeed = ones(200,1) + rand(200,1) + 10;

%14 Command Time
cmd_time(1:200) = 1;
cmd_time = transpose(cmd_time);

%15 Command Count
cmd_count(1:200) = 20;
cmd_count = transpose(cmd_count);


%17 State Value
state = randi([1 5],1,200);
state = transpose(state);


matrix = [team_id mission_time packet_count altitude pressure speed temperature voltage GPSlat GPSlong GPSalt gpsSat GPSspeed cmd_time cmd_count state]

csvwrite('skale-dataV2.csv',matrix)