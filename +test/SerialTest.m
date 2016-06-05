classdef SerialTest < matlab.unittest.TestCase
    
    properties
        glider;
        serial;
    end
    
    methods(TestMethodSetup)
        % Method called before each test case - method with attribute Test
        function setupConnection(testCase)
            testCase.glider = test.Glider('COM1', 115200);
            
            testCase.serial = Serial();
            testCase.serial.Connect('COM2', 115200);
        end
    end
    
    methods(TestMethodTeardown)
        % Method called after each test case - method with attribute Test
        function teardownConnection(testCase)
            testCase.glider.Disconnect();
            testCase.glider.delete();
            
            testCase.serial.Disconnect();
            testCase.serial.delete();
        end
    end
    
    methods (Test)
        
        %% Tests related to sensor packet format
        
        function testSensorAck(testCase)
            testCase.glider.clearReceiveBuffer();
            testCase.glider.sendPacketString('8099, 1, 1, 400,6.5159, 11.736 ,31.748 ,4.5154,48.174,19.355,401.19,5,11.052,1,20,5');
            
            pause(0.1);
            
            expectAck = {'ACK-SENSOR', '1'};
            testCase.verifyEqual(testCase.glider.recvPacketCell, expectAck);
        end
        
        function testImaginarySolution(testCase)
            testCase.verifyEqual(2,2);
        end
    end
    
end

% 8099,1,1,400,6.5159,11.736,31.748,4.5154,48.174,19.355,401.19,5,11.052,1,20,5
% 8099,2,2,397.99,6.2465,11.848,31.921,4.5471,47.518,20.175,401.19,5,11.722,1,20,1
% 8099,3,3,395.99,6.4314,11.958,31.656,5.0109,47.429,19.662,401.73,5,11.746,1,20,1
% 8099,4,4,393.98,6.8629,11.979,31.792,4.8657,47.841,19.241,401.02,5,11.281,1,20,1
% 8099,5,5,391.98,6.1982,11.403,31.389,4.9734,48.164,19.622,401.55,5,11.154,1,20,5
% 8099,6,6,389.97,6.4243,11.948,31.404,4.9378,48.123,19.337,401.66,5,11.204,1,20,5
% 8099,7,7,387.97,6.0522,11.506,31.87,5.2546,47.861,19.367,401.93,5,11.833,1,20,4

% Retransmission of one command
% Retransmission of more than one command