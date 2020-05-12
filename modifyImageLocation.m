%Replace folder location of images in .mat file
clear all; close all; clc;

shorelines_pictures = "C:\Users\marco\Master\TFM\shorelines\";
last_char="/";

load('LiniesCostaPlatjaLLarga.mat','T');

number_images=numel(T.File);

for i=1:number_images
  image_file = char(T.File(i));
  indexes = find(image_file == '/');
  lastIndex = indexes(size(indexes,2));
  image_file_name =image_file(lastIndex+1:end);
  T.File(i) = cellstr(shorelines_pictures + image_file_name);
end

%Truncate number of images for testing
%T=T(1:5,:);
save('LiniesCostaPlatjaLLarga_marcos.mat', 'T');

