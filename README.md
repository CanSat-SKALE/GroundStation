# GroundStation

Graphical user interface of the SKALE Team Ground Station developed in Matlab

### Communication Protocol

  All packets are ASCII encoded and ended by a new line character \n. The application splits packet data on both ASCII 13 and ASCII 10 characters, ACK packets also use this sequence.
  
  List of packets sent by Glider and acknowledged by Ground Station:
  
    Sensors Packet
      SEND  8099, Mission Time, Packet Count, ..., Command Count \n
      RECV  ACK-SENSOR, Packet Count \n
  
    Image Packet
      SEND  IMAGE, Frame Number, Image Data as HEX string \n
      RECV  ACK-IMAGE, Frame Number \n
  
    Log Packet
      SEND  LOG, Log Number, Message String \n
      RECV  ACK-LOG, Log Number \n
  
  
  List of packets sent by Ground Station and acknowledged by Glider:
  
    Command Packet
      SEND  COMMAND, Command Number, Command Name, Args, ... \n
      RECV  ACK-COMMAND, Command Number \n

### Compile 

    >> mcc -v -m GroundStation.m
