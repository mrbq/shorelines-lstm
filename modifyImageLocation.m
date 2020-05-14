%Replace folder location of images in .mat file
clear all; close all; clc;

% Modify image location to local folder
shorelines_pictures = "C:\Users\marco\Master\shorelines-lstm\shorelines\";
last_char="/";

load('input\LiniesCostaPlatjaLLarga.mat','T');

number_images=numel(T.File);

%% Preselection of images

images_categorized={
'CFA120170531060000000pvt01.png' 'test'; % Burned right side of the image
'CFA120170531070000000pvt01.png' 'test'; % Burned rigth side of the image
'CFA120170531080000000pvt01.png' 'test'; % Burned rigth side of the image
'CFA120170531090000000pvt01.png' 'test'; % Burned rigth side of the image
'CFA120170531100000000pvt01.png' 'test'; % Burned rigth side of the image
'CFA120171120100000000pvt01.png' 'train';
'CFA120171120110000000pvt01.png' 'train';
'CFA120171120120000000pvt01.png' 'train';
'CFA120171120130000000pvt01.png' 'train';
'CFA120171123080000000pvt01.png' 'train';
'CFA120171123090000000pvt01.png' 'train';
'CFA120171123100000000pvt01.png' 'train';
'CFA120171123110000000pvt01.png' 'train';
'CFA120171123150000000pvt01.png' 'train';
'CFA120171123160000000pvt01.png' 'test'; % Burned left side of the image
'CFA120171127100000000pvt01.png' 'train';
'CFA120171127110000000pvt01.png' 'val';
'CFA120171127120000000pvt01.png' 'train';
'CFA120171127130000000pvt01.png' 'train'; % Little bit burned
'CFA120171128140000000pvt01.png' 'train'; % Little bit burned
'CFA120180117140000000pvt01.png' 'val'; % Little bit burned
'CFA120180117150000000pvt01.png' 'val'; % Little bit burned
'CFA120180117160000000pvt01.png' 'train';  % Little bit burned
'CFA120180118080000000pvt01.png' 'test'; % Burned right side of the image
'CFA120180118090000000pvt01.png' 'train'; % Little bit burned
'CFA120180118100000000pvt01.png' 'val';
'CFA120180118110000000pvt01.png' 'val';
'CFA120180313120000000pvt01.png' 'val';
'CFA120180314140000000pvt01.png' 'train';
'CFA120180314150000000pvt01.png' 'val';
'CFA120180314160000000pvt01.png' 'val';
'CFA120180314170000000pvt01.png' 'train';
'CFA120180315080000000pvt01.png' 'train';
'CFA120180315090000000pvt01.png' 'test';
'CFA120180315100000000pvt01.png' 'train';
'CFA120180315110000000pvt01.png' 'val';
'CFA120180319110000000pvt01.png' 'test';
'CFA120180319120000000pvt01.png' 'val';
'CFA120180319130000000pvt01.png' 'test';
'CFA120180319140000000pvt01.png' 'train';
'CFA120180321100000000pvt01.png' 'train';
'CFA120180321110000000pvt01.png' 'val';
'CFA120180321120000000pvt01.png' 'train';
'CFA120180321130000000pvt01.png' 'test';
};

% initialize category column

default_category = cell(1, number_images);
default_category(:) = {''};
T.category(:) = default_category;

for j=1:number_images
    
    image=images_categorized(j,:);
    
    for i=1:number_images
        
      image_file = char(T.File(i));
      indexes = find(image_file == '/');
      lastIndex = indexes(size(indexes,2));
      image_file_name =image_file(lastIndex+1:end);
      
      if image_file_name == char(image(1))
        T.category(i) = image(2);
      end
    end
end

%% Modify image file location

for i=1:number_images
  image_file = char(T.File(i));
  indexes = find(image_file == '/');
  lastIndex = indexes(size(indexes,2));
  image_file_name =image_file(lastIndex+1:end);
  T.File(i) = cellstr(shorelines_pictures + image_file_name);
end

%Truncate number of images for testing
%T=T(1:5,:);
save('input\shorelines_CFA1_categorized.mat', 'T');

