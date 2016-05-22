classdef Serial < handle
    %SERIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden = true)
        serialPort;
        readBuffer;
        receivedData;
        
        updateTimer;
        lastActivity;
        
        callbacks;
        frameID;
    end
    
    properties(Constant = true, Hidden = true)
        MAX_RESPONSE_DELAY = 1;
        STATUS_UPDATE_INTERVAL = 0.1;
    end
    
    % Properties of the callbacks structure
    %   SensorData;         - Sensor data packet, starts with team ID
    %   ImageData;          - Image frame packet, starts with IMG
    %   LogData;            - Log message packet, starts with LOG
    %   ConnectionStatus;   - Serial port status update, connnection lost
    %   GliderStatus;       - Update glider connection status
        
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
            % TODO
            
            hObject.lastActivity            = 0;
            
            hObject.callbacks               = struct();
            
            hObject.frameID                 = struct();
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
                hObject.serialPort.Write(0, 0, 1);
            else
                ME = MException('Serial:portAlreadyOpened', ...
                    'Serial already conected to port %s', ...
                    char(hObject.serialPort.PortName));
                throw(ME)
            end
        end
        
        function SetCallbacks(hObject, callbacks)
            validateattributes(callbacks, {'struct'}, {'scalar'});
            
            hObject.calbacks = callbacks;
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
                    data = hObject.readBuffer.char;
                    data = data(1:numBytes);
                    hObject.receivedData = [hObject.receivedData data];
                    
                    % Split packets based on new line, char(13)
                    f = find(hObject.receivedData == char(13), 1);
                    while f
                        message = hObject.receivedData(1:f-1);
                        hObject.receivedData = hObject.receivedData(f + 1:end);
                        
                        hObject.DecodeMessage(message);
                        
                        f = find(hObject.receivedData == char(13), 1);
                    end
                    
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
                    ackMessage  = ['ACK-SENSOR,', args{3}, char(13)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                    ID          = str2double(args{3});
                    
                    if hObject.frameID.Sensor ~= ID && ...
                       isfield(hObject.callbacks, 'SensorData')
                   
                        hObject.frameID.Sensor = ID;
                        hObject.callbacks.SensorData(args);
                    end
                    
                case 'IMAGE'
                    ackMessage = ['ACK-IMAGE,', args{2}, char(13)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                    ID          = str2double(args{2});
                    
                    if hObject.frameID.Image ~= ID && ...
                       isfield(hObject.callbacks, 'ImageData')
                   
                        hObject.frameID.Image = ID;
                        hObject.callbacks.ImageData(args);
                    end
                    
                case 'LOG'
                    ackMessage = ['ACK-LOG,', args{2}, char(13)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                    ID          = str2double(args{2});
                    
                    if hObject.frameID.Log ~= ID && ...
                       isfield(hObject.callbacks, 'LogData')
                   
                        hObject.frameID.Log = ID;
                        hObject.callbacks.LogData(args);
                    end
                    
                case 'ACK-COMMAND'
                    ackMessage = ['ACK-SENSOR,', args{3}, char(13)];
                    hObject.serialPort.Write(ackMessage, 0, length(ackMessage));
                    
                otherwise
                    
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
        end
    end
    
end

