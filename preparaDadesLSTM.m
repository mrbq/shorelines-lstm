%% PREPARA LES DADES PER ENTRENAR LA XARXA QUE DETECTA LES LÍNIES DE COSTA
% Entreno una LSTM a partir de línies de la imatge.

clear all; close all; clc;
load('LiniesCostaPlatjaLLarga_marcos.mat','T')

Num_Imatges=numel(T.File);

%% Visualitza totes les imatges amb la línia de costa marcada (splines)
control_plot=false;
if control_plot==true
    for i=1:Num_Imatges
        I=imread(T.File{i});
        imshow(I)
        hold on
        plot(T.xy_{i}(1,:),T.xy_{i}(2,:),'r')
        hold off
        pause(0.5)
    end
end

%% Randomly split data into a training and test set.
% Agafo la meitat de les imatges per entrenar i l'altre per veure com
% funciona.

shuffledIdx = randperm(Num_Imatges);
idx = floor(0.5 * Num_Imatges);

N_imatges_train=idx;
N_imatges_test=floor((Num_Imatges-idx)/2);
N_imatges_val=Num_Imatges-N_imatges_train-N_imatges_test;

I_trainT = T(shuffledIdx(1:idx),:);
I_testT = T(shuffledIdx(idx+1:idx+N_imatges_test),:);
I_valT = T(shuffledIdx(idx+N_imatges_test+1:end),:);

% Prepara les dades i fas les etiquetes per entrenar

% Agafo una imatge per descobrir-ne les dimensions Raw Col
I=imread(I_trainT.File{1});
% x=I_trainT.xy_{1}(1,:);
% y=I_trainT.xy_{1}(2,:);
[R C ~]=size(I);
% imshow(I)

X={};  % 
Y={};  %
XTest={};  % 
YTest={};  %
XVal={};  % 
YVal={};  %

ee=1; % Index de les columnes que processo

%% Prepara dades per Train
% Per cada imatge d'entrenament

for jj=1:floor(N_imatges_train)  % Nombre d'imatges de train que agafo per entrenar la xarxa
    
    I=imread(I_trainT.File{jj});
    x=I_trainT.xy_{jj}(1,:);
    y=I_trainT.xy_{jj}(2,:);
    Co=length(x);

    for i=2:Co
    
        s=zeros(R,3);
        c=zeros(R,1);
        
        % Colunma de color de la matriu
        s(:,1)=I(:,x(i),1);  s(:,2)=I(:,x(i),2); s(:,3)=I(:,x(i),3);
        
        % Vector de classes
        c(round(y(i)))=1;
        c(round(y(i))+1:end)=-1;
        c=categorical(c, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});
        
        X{ee}=s';
        Y{ee}=c';
        
        ee=ee+1;
    end
            
end


%% Prepara dades per Test
ee=1; % Index de les columnes que processoX
for jj=1:N_imatges_test  % Nombre d'imatges de train que agafo per entrenar la xarxa
    
    I=imread(I_testT.File{jj});
    x=I_testT.xy_{jj}(1,:);
    y=I_testT.xy_{jj}(2,:);
    Co=length(x);

    for i=2:Co
    
        s=zeros(R,3);
        c=zeros(R,1);
        
        % Colunma de color de la matriu
        s(:,1)=I(:,x(i),1);  s(:,2)=I(:,x(i),2); s(:,3)=I(:,x(i),3);
        
        % Vector de classes
        c(round(y(i)))=1;
        c(round(y(i))+1:end)=-1;
        c=categorical(c, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});
        
        XTest{ee}=s';
        YTest{ee}=c';
        
        ee=ee+1;
    end
            
end

%% Prepara dades per Validació
ee=1; % Index de les columnes que processoX
for jj=1:N_imatges_val  % Nombre d'imatges de train que agafo per entrenar la xarxa
    
    I=imread(I_valT.File{jj});
    x=I_valT.xy_{jj}(1,:);
    y=I_valT.xy_{jj}(2,:);
    Co=length(x);

    for i=2:Co
    
        s=zeros(R,3);
        c=zeros(R,1);
        
        % Colunma de color de la matriu
        s(:,1)=I(:,x(i),1);  s(:,2)=I(:,x(i),2); s(:,3)=I(:,x(i),3);
        
        % Vector de classes
        c(round(y(i)))=1;
        c(round(y(i))+1:end)=-1;
        c=categorical(c, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});
        
        XVal{ee}=s';
        YVal{ee}=c';
        
        ee=ee+1;
    end
            
end
%%


X=X'; % XTraining
Y=Y'; % YTraining categorical

XTest=XTest';
YTest=YTest';

XVal=XVal';
YVal=YVal';

% Cal guardar les dades

%% Configuració de la xarxa i entrenament

% lstm
numFeatures=3;
numHiddenUnits=30;   % 60 sembla millor que 30 
numClasses=3;
miniBatchSize=20;

layers=[ sequenceInputLayer(numFeatures)
               % lstmLayer(numHiddenUnits,'OutputMode','sequence')
               bilstmLayer(numHiddenUnits,'OutputMode','sequence')
               fullyConnectedLayer(numClasses)
               softmaxLayer
               classificationLayer ];
           
options= trainingOptions( 'adam',...
                'ExecutionEnvironment','gpu', ...
                'MaxEpochs',2,... %15,...
                'GradientThreshold',2,... %1,...  per anar ràpid
                'MiniBatchSize', miniBatchSize, ...  %1, 5, 8
                'Verbose',0,...
                'Plots','training-progress',...
                'ValidationData',{XVal,YVal});
 
%% Entrenament de la xarxa i SAVE
new_Train='si';

if strcmp(new_Train,'si')
    tic
    net=trainNetwork(X,Y,layers,options);
    toc
    
    c=clock;
    nom2=['lstm_net' '_' num2str(c(1)) '_' num2str(c(2)) '_' num2str(c(3)) '_' num2str(c(4)) '.mat' ];
    save(nom2,'net','layers','options','numHiddenUnits','numFeatures','numClasses')
    
end


%% Predicció
% % % % Carrego una xarxa entrenada
% % % % load lstm_net_2020_2_8_22.mat
% % % % Per la primera prova agafo la imatge 'a' de les imatges de test
% % % 
% % % a=1;
% % % I=imread(I_testT.File{a});
% % % x=I_testT.xy_{a}(1,:);
% % % y=I_testT.xy_{a}(2,:);
% % % Co=length(x);
% % % 
% % % XTest={}; % Guardaré les columnes pel test
% % % 
% % % for i=2:Co
% % %     
% % %     s=zeros(R,3);
% % %     
% % %     % Colunma de color de la matriu
% % %     s(:,1)=I(:,x(i),1);  s(:,2)=I(:,x(i),2); s(:,3)=I(:,x(i),3);
% % %     
% % %     
% % %     XTest{i}=s';
% % % 
% % % end
% % % 
% % % XTest=XTest';
% % % 
% % % %XTest{1}
% % % %YPred=classify(net,XTest);

YPred=classify(net,XTest, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');

%% Graba resultats per intrpretar
save('PrimerExperiment2.mat')

% load('PrimerExperiment.mat','net','X', 'Y', 'XTest','YTest',
% 'XVal','YVal','YPred','options','numFeatures','numHiddenUnits')

