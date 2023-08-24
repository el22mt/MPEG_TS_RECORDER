clc
clear all

filename = 'd1.csv';

data = csvread(filename, 3);

time    = data(:, 1);
clock   = data(:, 2);
data1   = data(:, 3);

offset = 4;                                                                 % To adjust vertical position (spacing between signals).

% Define the text content for the note.
note_text = sprintf('TS VALID OUT is shifted up by %dV for visualisation.', offset);

note_x = 3.4e-05;                                                           % X-coordinate for the text note.
note_y = 8.5;                                                               % Y-coordinate for the text note.

% Shift the time values to start from zero instead of negative
time_shifted = time - min(time);

initialXMin = 3e-05;                                                        % Initial x-axis limit.
initialXMax = 9e-05;%max(time_shifted);                                            % Final x-axis limit.

hold on;
grid on;
grid minor;

plot(time_shifted, clock + offset + (-min(data1)), 'r');                    % Plot clock signal.
plot(time_shifted, data1 + (-min(data1)), 'b');                             % Plot data signal shifted down by offset.

% Set labels and title
title('TS VALID OUT and TS DATA [1]');
xlabel('Time (s)');
ylabel('Amplitude (V)');

text(note_x, note_y, note_text, 'HorizontalAlignment', 'left');

legend('TS VALID OUT', 'TS DATA [1]');

xlim([initialXMin, initialXMax]);                                           %% Apply limits on x-axis.

