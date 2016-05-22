function varargout = GroundStation(varargin)
% GROUNDSTATION MATLAB code for GroundStation.fig
%      GROUNDSTATION, by itself, creates a new GROUNDSTATION or raises the existing
%      singleton*.
%
%      H = GROUNDSTATION returns the handle to a new GROUNDSTATION or the handle to
%      the existing singleton*.
%
%      GROUNDSTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GROUNDSTATION.M with the given input arguments.
%
%      GROUNDSTATION('Property','Value',...) creates a new GROUNDSTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GroundStation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GroundStation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GroundStation

% Last Modified by GUIDE v2.5 22-May-2016 14:01:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GroundStation_OpeningFcn, ...
                   'gui_OutputFcn',  @GroundStation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GroundStation is made visible.
function GroundStation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GroundStation (see VARARGIN)

% Choose default command line output for GroundStation
handles.output = hObject;

% CSV Read
data = csvread('skale-dataV2.csv');

% Logo
img = imread('logo.png');
image(img, 'Parent', handles.axesLogo);
axis(handles.axesLogo, 'off', 'image');

% Progress Bar for mission phases
handles.axesProgressBar.UserData = {'Pre-Launch', 'Launched', 'Deployed', 'Landed'};
progressbar(handles.axesProgressBar, data(200,16));




nophoto = imread('noImage.png');
image(nophoto, 'Parent', handles.pictureAxis);
axis(handles.pictureAxis, 'off', 'image');

t = data(:, 1);
s = data(:, 4);
b = data(:, 6);

movegui(hObject, 'onscreen');

%plot(handles.mainPlot, t, s);

%[ax, hLine1, hLine2] = plotyy(handles.mainPlot, t, s, t, b);

xlabel('Time (s)')

%ylabel(ax(1),'Speed (m/s)')
%ylabel(ax(2),'Battery Voltage (V)')
%ax(2).YLim  = [0 1.5];
%ax(2).YTick = 0:0.3:1.5;

%ax(2).XLim  = [0 100];
%ax(2).XTick = 0:20:100;

%ax(1).YLim  = [0 10];
%ax(1).YTick = 0:2:10;

%ax(1).XLim  = ax(2).XLim;
%ax(1).XTick = ax(2).XTick; 


handles.logTable.Data = data;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GroundStation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GroundStation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles)
% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exportButton.
function exportButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile('*.csv','Save Flight Data');

if file
    sensorData=get(handles.logTable,'Data');
    
    csvwrite(fullfile(path, file), sensorData);
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in deploymentButton.
function deploymentButton_Callback(hObject, eventdata, handles)
% hObject    handle to deploymentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pictureButton.
function pictureButton_Callback(hObject, eventdata, handles)
% hObject    handle to pictureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in altitudeCB.
function plot_checkboxes(hObject, eventdata, handles)
% hObject    handle to altitudeCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

checkboxes = {handles.altitudeCB, handles.pressureCB, handles.speedCB, handles.temperatureCB, handles.batteryCB, handles.GPSlatCB, handles.GPSlongCB, handles.GPSsatCB, handles.GPSspeedCB};
state = zeros(length(checkboxes)); 

for i = 1:length(checkboxes)
    if (get(checkboxes{i},'Value') == get(checkboxes{i},'Max'))
        state(i) = 1;
    else
        state(i) = 0;
    end
end

data = csvread('skale-dataV2.csv');
time = data(:,2);
if (find(state))
    plot(handles.mainPlot,time, data(:, find(state) + 3));
else
    cla(handles.mainPlot,'reset')
end
% Hint: get(hObject,'Value') returns toggle state of altitudeCB




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

