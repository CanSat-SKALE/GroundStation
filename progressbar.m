function progressbar(ax, step)
    % Draws a progress bar in the current axes
    % The axes should have the labels for each step assigned to the
    % UserData property of the ax as a cell array of strings
    
    %% Drawing Parameters
    
    notCompletedColor   = [0.7020, 0.6588, 0.6588]; % Gray Background 2
    completedColor      = [0.7686, 0.0000, 0.0471]; % Red Text 2
    whiteColor          = [1.0000, 1.0000, 1.0000]; % White
    
    lineWidth           = 4;
    markerSize          = 10;
    dotSize             = 4;
    
    labels              = ax.UserData;
    numSteps            = length(labels);
    
    notCompletedMarkers = (step + 1) : numSteps;
    completedMarkers    = 1 : (step - 1);
    
    
    %% Draw Progress Bar
    
    % Delete all visible data
    cla(ax);            
    axis(ax, 'off');
    ylim(ax, [-0.05, 0.2]);
    
    % Draw the bar as not completed
    line([0 numSteps], [0 0], 'LineWidth', lineWidth, 'Parent', ax, ...
            'Color', notCompletedColor);
    line(notCompletedMarkers - 0.5, zeros(size(notCompletedMarkers)), ...
            'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerSize, ...
            'MarkerEdgeColor', whiteColor, 'MarkerFaceColor', notCompletedColor, ...
            'Parent', ax);
    line(notCompletedMarkers - 0.5, zeros(size(notCompletedMarkers)), ...
            'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', dotSize, ...
            'MarkerEdgeColor', whiteColor, 'MarkerFaceColor', whiteColor, ...
            'Parent', ax);
    
    % Draw the completed part
    line([0 step], [0 0], 'LineWidth', lineWidth, 'Color', completedColor, ...
            'Parent', ax);
    line(completedMarkers - 0.5, zeros(size(completedMarkers)), ...
            'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerSize, ...
            'MarkerEdgeColor', whiteColor, 'MarkerFaceColor', completedColor, ...
            'Parent', ax);
    line(completedMarkers - 0.5, zeros(size(completedMarkers)), ...
            'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', dotSize, ...
            'MarkerEdgeColor', whiteColor, 'MarkerFaceColor', whiteColor, ...
            'Parent', ax);
        
    % Draw the current step 
    line(step - 0.5, 0, 'LineStyle', 'none', 'Marker', 'o', ...
            'MarkerSize', markerSize, 'MarkerEdgeColor', completedColor, ...
            'MarkerFaceColor', completedColor, 'Parent', ax);
        
    for i = 1:length(labels)
        text(i - 0.5, 0.1, labels{i}, 'HorizontalAlignment', 'center', ...
                'FontName', 'Verdana', 'FontSmoothing', 'off', ...
                'FontWeight', 'bold', 'Parent', ax);
    end
        