classdef Glider < handle
    %GLIDER Class that emulates Glider responses
    
    properties(Hidden = true)
        serialPort;
        readBuffer;
        receivedData;
    end
    
    methods
        function hObject = Glider(portName, baudRate)
             fprintf(1, '...........................\n');            
            
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

                
            hObject.serialPort.PortName     = portName;
            hObject.serialPort.BaudRate     = baudRate;

            hObject.serialPort.Open();

            % Test port with a dummy write
            % hObject.serialPort.Write(0, 0, 1);
            
            fprintf(1, 'Glider connected to port %s \n', char(hObject.serialPort.PortName));
        end
        
        function Receive(hObject, serialPort, ~)
                       
            numBytes = serialPort.BytesToRead;
            numBytes = serialPort.Read(hObject.readBuffer, 0, numBytes);

            if numBytes
                % Add received data to the buffer
                data = char(hObject.readBuffer.uint8);
                data = data(1:numBytes);
                fprintf(1, 'Glider received: %s\n', data);
                hObject.receivedData = [hObject.receivedData data];
            end
        end
        
        function str = recvPacketString(hObject)
            str = '';
            
            % Split packets based on new line, \r or \n
            packets = strsplit(hObject.receivedData, {'\r', '\n'});
            
            if length(packets) > 1
                str = packets{1};
                hObject.receivedData = [packets{2:end}];
            end            
        end
        
        function packet = recvPacketCell(hObject)
            packet = {};
            
            % Split packets based on new line, \r or \n
            packets = strsplit(hObject.receivedData, {'\r', '\n'});
            
            if length(packets) > 1
                packet = strtrim(strsplit(packets{1}, ','));
                hObject.receivedData = [packets{2:end}];
            end            
        end
        
        function sendPacketString(hObject, packet)
            data  = [packet, char(13), char(10)];
            
            hObject.serialPort.Write(data, 0, length(data));
            fprintf(1, 'Glider sent: %s\n', data);
        end
        
        function sendPacketCell(hObject, packet)
            data  = [cellfun(@hObject.toString, packet), char(13), char(10)];
            
            hObject.serialPort.Write(data, 0, length(data));
            
            fprintf(1, 'Glider sent: %s\n', data);
        end
        
        function clearReceiveBuffer(hObject)
            fprintf(1, 'Glider cleared receive buffer\n');
            hObject.receivedData = [];
        end
        
        function str = toString(~, data)
            if ischar(data)
                str = data;
            elseif isnumeric(data)
                str = num2str(data);
            else
                str = 'wrong type';
            end
        end
        
        function Disconnect(hObject)
            fprintf(1, 'Glider disconnected from port %s \n', char(hObject.serialPort.PortName));
            
            if hObject.serialPort.IsOpen
                hObject.serialPort.Close();
            end
        end
        
        function delete(hObject)
            fprintf(1, 'Glider object deleted \n');
            
            if hObject.serialPort.IsOpen
                hObject.serialPort.Close();
            end
            
            hObject.serialPort.Dispose();
            hObject.serialPort.delete();
        end
    end
    
end

