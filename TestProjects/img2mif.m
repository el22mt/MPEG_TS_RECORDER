% Load the image
imgloc = "abc.jpg";

%indx = 1;
%for indx = 19:19
%    img = imread([imgloc + indx + ".jpg"]);
img = imread (imgloc);
img = img(:, end:-1:1, :);

% Convert image to double and scale to range 0-1
img = double(img)/255;

% Convert image to RGB565 format
R = uint16(img(:,:,1) * 31);
G = uint16(img(:,:,2) * 63);
B = uint16(img(:,:,3) * 31);
rgb565 = bitor(bitshift(R, 11), bitor(bitshift(G, 5), B));

disp("Size: " + numel(rgb565))

% Write RGB565 data to MIF file
%filename = "" + indx +".mif";
filename = "m1.mif";
disp(filename);
fd = fopen(filename, 'w');
fprintf(fd, 'WIDTH=16;\n');
fprintf(fd, 'DEPTH=%d;\n', numel(rgb565));
fprintf(fd, 'ADDRESS_RADIX=HEX;\n');
fprintf(fd, 'DATA_RADIX=HEX;\n');
fprintf(fd, 'CONTENT BEGIN\n');
for i = 1:numel(rgb565)
    fprintf(fd, '%04X : %04X;\n', i-1, rgb565(i));
end
fprintf(fd, 'END;\n');
fclose(fd);
%indx = indx + 1;
%end