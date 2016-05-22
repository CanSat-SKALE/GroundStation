# GroundStation

Graphical user interface of the SKALE Team Ground Station developed in Matlab

# Communication Protocol

  All packets are ASCII encoded and ended by a new line, \n - ASCII 13
  
  List of packets sent by Glider and acknowledged by Ground Station:
  
    + Sensors Packet
        SENT 8099, Mission Time, Packet Count, ..., Command Count \n
        RECV ACK-SENSOR, Packet Count \n
  
    + Image Packet
        SENT IMAGE, Frame Number, Image Data as HEX string \n
        RECV ACK-IMAGE, Frame Number \n
  
    + Log Packet
        SENT LOG, Log Number, Message String \n
        RECV ACK-LOG, Log Number \n
  
  
  List of packets sent by Ground Station and acknowledged by Glider:
  
    + Command Packet
        SENT COMMAND, Command Number, Command Name, Args, ... \n
        RECV ACK-COMMAND, Command Number \n

# Compile 

>> mcc -v -m GroundStation.m
