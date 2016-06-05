classdef Serial < handle
    % SERIAL Implements a protocol for communication with Glider
    % 
    % All packets are ASCII encoded and ended by a new line, \n - ASCII 13
    % List of packets sent by Glider and acknowledged by Ground Station:
    %
    %   + Sensors Packet
    %       SENT 8099, Mission Time, Packet Count, ..., Command Count \n
    %       RECV ACK-SENSOR, Packet Count \n
    % 
    %   + Image Packet
    %       SENT IMAGE, Frame Number, Image Data as HEX string \n
    %       RECV ACK-IMAGE, Frame Number \n
    % 
    %   + Log Packet
    %       SENT LOG, Log Number, Message String \n
    %       RECV ACK-LOG, Log Number \n
    % 
    %
    % List of packets sent by Ground Station and acknowledged by Glider:
    % 
    %   + Command Packet
    %       SENT COMMAND, Command Number, Command Name, Args, ... \n
    %       RECV ACK-COMMAND, Command Number \n
    %
    %         
    % Base 64
    % System.Convert.ToBase64String([1 2 3 4])
    % n = System.Convert.FromBase64String('AQIDBA==')
    % n.uint8
    
    properties(Hidden = true)
        serialPort;
        readBuffer;
        receivedData;
        
        updateTimer;
        lastActivity;
        
        callbacks;
        frameID;
        
        statusTimer;
        sendQueue;
    end
    
    properties(Constant = true, Hidden = true)
        MAX_RESPONSE_DELAY = 3;
        STATUS_UPDATE_INTERVAL = 0.1;
    end
    
    % Properties of the callbacks structure
    %   SensorData;         - Sensor data packet, starts with team ID
    %   ImageData;          - Image frame packet, starts with IMG
    %   LogData;            - Log message packet, starts with LOG
    %   Error;              - Error, communication of packet decoding

        
    methods (Static)
        % Converts input argument to string
        function str = toString(data)
            if ischar(data)
                str = data;
            elseif isscalar(data)
                str = num2str(data);
            elseif iscell(data)
                s   = cellfun(@Serial.toString, data, 'UniformOutput', 0);
                str = strjoin(s, ', ');
            else
                str = 'wrong type';
            end
        end
    end
    
    methods
        function hObject = Serial()
            
            % Serial port setup for asynchronous operation
            hObject.serialPort              = System.IO.Ports.SerialPort();
            hObject.serialPort.DataBits     = 8;
            hObject.serialPort.ReadTimeout  = 10;
            hObject.serialPort.WriteTimeout = 10;
            hObject.serialPort.Encoding     = System.Text.UTF8Encoding();
            hObject.serialPort.addlistener('DataReceived', @hObject.Receive);
            
            % Receive buffer initialization
            hObject.readBuffer  = NET.createArray('System.Byte', hObject.serialPort.ReadBufferSize);
            hObject.receivedData= [];
            
            % Timer setup
            hObject.statusTimer = timer('ExecutionMode', 'FixedRate', ...
                                        'Name', 'PeriodicCallback', ...
                                        'Period', Serial.STATUS_UPDATE_INTERVAL, ...
                                        'TimerFcn', @hObject.PeriodicCallback);
            start(hObject.statusTimer);
            
            hObject.lastActivity            = 0;
            
            hObject.callbacks               = struct();            
            hObject.frameID                 = struct();            
            hObject.sendQueue               = struct([]);
        end
        
        function names = ListPorts(hObject)
            
            names = cell(hObject.serialPort.GetPortNames());
        end
        
        function Connect(hObject, portName, baudRate)
            
            validateattributes(portName, {'char'}, {'vector'});
            validateattributes(baudRate, {'numeric'}, {'scalar', 'positive', 'integer'});
            
            rng('shuffle');
            
            if ~hObject.serialPort.IsOpen()
                
                % Reset frame IDs for correct acknowledges
                hObject.frameID.Sensor          = NaN;
                hObject.frameID.Image           = NaN;
                hObject.frameID.Log             = NaN;
                hObject.frameID.Command         = floor(rand * 100);
                
                hObject.lastActivity            = 0;
                
                % Clear receive buffer
                hObject.receivedData            = [];
                
                hObject.serialPort.PortName     = portName;
                hObject.serialPort.BaudRate     = baudRate;
                
                hObject.serialPort.Open();
                
                % Test port with a dummy write
                % hObject.serialPort.Write(0, 0, 1);
            else
                ME = MException('Serial:portAlreadyOpened', ...
                    'Serial already conected to port %s', ...
                    char(hObject.serialPort.PortName));
                throw(ME)
            end
        end
        
        function SetCallbacks(hObject, packetCallbacks)
            validateattributes(packetCallbacks, {'struct'}, {'scalar'});
            
            hObject.callbacks = packetCallbacks;
        end
        
        function status = IsConnected(hObject)
            status = hObject.serialPort.IsOpen();
        end
        
        function status = IsActive(hObject)
            
            % TODO: Check last received data
            status = etime(clock, hObject.lastActivity) < hObject.MAX_RESPONSE_DELAY;
        end
        
        function Receive(hObject, serialPort, ~)
            
            % Set glider as active
            hObject.lastActivity = clock;
            
            numBytes = serialPort.BytesToRead;
            
            try
                numBytes = serialPort.Read(hObject.readBuffer, 0, numBytes);
            catch ME
                
                % TODO: Connection status notify
                disp(getReport(ME,'extended','hyperlinks','default'));
            end
            
            if numBytes
                try
                    % Add received data to the buffer
                    data = char(hObject.readBuffer.uint8);
                    data = data(1:numBytes);
                    hObject.receivedData = [hObject.receivedData data];
                    
                    % Split packets based on new line, \r or \n
                    packets = strsplit(hObject.receivedData, {'\r', '\n'});
                    
                    for i = 1:(length(packets) - 1)
                        hObject.DecodeMessage(packets{i});
                    end
                    hObject.receivedData = packets{end};
                    
                catch ME
                    % TODO: Connection status notify
                    disp(getReport(ME,'extended','hyperlinks','default'));
                end
            end
        end
        
        function DecodeMessage(hObject, command)
            args = strtrim(strsplit(command, ','));
            switch args{1}
                
                case '8099'
                    ackMessage  = ['ACK-SENSOR,', args{3}, char(13), char(10)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                    ID          = str2double(args{3});
                    
                    if hObject.frameID.Sensor ~= ID && ...
                       isfield(hObject.callbacks, 'SensorData')
                   
                        hObject.frameID.Sensor = ID;
                        
                        % Call callback with predefined arguments
                        if iscell(hObject.callbacks.SensorData)
                            hObject.callbacks.SensorData{1}(args, hObject.callbacks.SensorData{2:end});
                        else
                            hObject.callbacks.SensorData(args);
                        end
                    end
                    
                case 'IMAGE'
                    ackMessage = ['ACK-IMAGE,', args{2}, char(13), char(10)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                    ID          = str2double(args{2});
                    
                    if hObject.frameID.Image ~= ID && ...
                       isfield(hObject.callbacks, 'ImageData')
                   
                        hObject.frameID.Image = ID;
                        
                        % Call callback with predefined arguments
                        if iscell(hObject.callbacks.ImageData)
                            hObject.callbacks.ImageData{1}(args, hObject.callbacks.ImageData{2:end});
                        else
                            hObject.callbacks.ImageData(args);
                        end
                    end
                    
                case 'LOG'
                    ackMessage = ['ACK-LOG,', args{2}, char(13), char(10)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                    ID          = str2double(args{2});
                    
                    if hObject.frameID.Log ~= ID && ...
                       isfield(hObject.callbacks, 'LogData')
                   
                        hObject.frameID.Log = ID;
                        
                        % Call callback with predefined arguments
                        if iscell(hObject.callbacks.LogData)
                            hObject.callbacks.LogData{1}(args, hObject.callbacks.LogData{2:end});
                        else
                            hObject.callbacks.LogData(args);
                        end
                        hObject.callbacks.LogData(args);
                    end
                    
                case 'ACK-COMMAND'                    
                    ID          = str2double(args{2});
                    
                    if isfield(hObject.sendQueue, 'ID')

                        for i = 1:length(hObject.sendQueue)
                            if hObject.sendQueue(i).ID == ID
                                % remove entry
                                hObject.sendQueue = [hObject.sendQueue(1:i-1), ...
                                                    hObject.sendQueue(i+1:end)];
                                
                                break;
                            end
                        end
                    end
            end
        end
        
        function SendCommand(hObject, commandName, varargin)
            % Auto Increment Command ID
            hObject.frameID.Command = hObject.frameID.Command + 1;
            
            % Create packet from parts
            packet = [{'COMMAND', hObject.frameID.Command, commandName}, varargin];
            packetData = [Serial.toString(packet), char(13), char(10)];
            
            hObject.serialPort.Write(packetData, 0, length(packetData));
            
            % Add packet to queue
            hObject.sendQueue(end+1).packetData = packetData;
            hObject.sendQueue(end).ID           = hObject.frameID.Command;
            hObject.sendQueue(end).time         = clock;
        end
        
        function PeriodicCallback(hObject, ~, ~)
            
            % Magic - resend commands
            if isfield(hObject.sendQueue, 'time')
                dt = zeros(1, length(hObject.sendQueue));
                
                for i = 1:length(hObject.sendQueue)
                    dt(i)   = etime(clock, hObject.sendQueue(i).time);
                end
                
                if ~isempty(dt)
                    [~, i]  = max(dt);

                    % resend an update time
                    packetData = hObject.sendQueue(i).packetData;
                    hObject.serialPort.Write(packetData, 0, length(packetData));
                    hObject.sendQueue(i).time = clock;
                end
            end
        end
        
        function Disconnect(hObject)
            if hObject.serialPort.IsOpen
                hObject.serialPort.Close();
            end
        end
        
        function delete(hObject)
            if hObject.serialPort.IsOpen
                hObject.serialPort.Close();
            end
            
            hObject.serialPort.Dispose();
            hObject.serialPort.delete();
            
            stop(hObject.statusTimer);
            delete(hObject.statusTimer);
        end
    end
    
end

