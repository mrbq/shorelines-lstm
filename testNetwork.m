%% Predicció
% Carrego una xarxa entrenada
clear all;
close all;
% % % % Per la primera prova agafo la imatge 'a' de les imatges de test

load('LiniesCostaPlatjaLLarga_marcos.mat','T')

load('lstm_net_left_2020_5_13_0.mat','net');

a=21;
I=imread(T.File{a});
x=T.xy_{a}(1,:);
y=T.xy_{a}(2,:);
Co=floor(length(x));
[R C ~]=size(I);
figure
imshow(I);
hold on

XTest2={}; % Guardaré les columnes pel test
index=1;
for i=2:Co
    
    s=zeros(R,3);
    
    % Colunma de color de la matriu
    s(:,1)=I(:,x(i),1);  s(:,2)=I(:,x(i),2); s(:,3)=I(:,x(i),3);
    
    
    XTest2{index}=s';
    index=index + 1;
end
XTest2=XTest2';
YPred=classify(net,XTest2);




YPred_parsed=zeros(length(YPred));

for index=1:length(YPred)
    
    YPred_parsed(index)= length(find(grp2idx(YPred{index}) == 1));
    
end

plot(T.xy_{a}(1,:),T.xy_{a}(2,:),'r');
plot(YPred_parsed,'g');

figure
plot(T.xy_{a}(2,:));
hold on
plot(YPred_parsed,'r');

