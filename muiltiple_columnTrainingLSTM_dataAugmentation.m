%% PREPARA LES DADES PER ENTRENAR LA XARXA QUE DETECTA LES LÍNIES DE COSTA
% Entreno una LSTM a partir de línies de la imatge.

clear all; close all; clc;
load('input\shorelines_CFA1_categorized.mat','T')

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



index_train=[];
index_test=[];
index_val=[];

for i=1:Num_Imatges
   
    image_category = char(T.category(i));
    
    if strcmp(image_category , 'train')
        index_train(length(index_train) + 1) = i;
        
    elseif strcmp(image_category, 'test')
        
        index_test(length(index_test) + 1) = i;
    
    elseif strcmp(image_category, 'val')
    
        index_val(length(index_val) + 1) = i;
    
    end
    
end

I_trainT = T(index_train,:);
I_testT = T(index_test,:);
I_valT = T(index_val,:);

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

number_columns=10;
synthetic_data=0; % 1 duplicates input set, 2 triplicates, etc
column_index=0; % from 0:number_columns-1
aggregated_columns=1; %Bigger than 0

%Create output directory
now=clock;

foldername = sprintf('lstm_columns_%d_synthetic_%d_column_index_%d_aggregated_columns_%d_%d_%d_%d_%d', number_columns, synthetic_data,column_index,aggregated_columns, now(1),now(2),now(3),now(4))
 
foldername = ['output\shorelines_CFA1_categorized\' foldername]

mkdir(foldername);


%% Prepara dades per Train
% Per cada imatge d'entrenament

for jj=1:floor(N_imatges_train)  % Nombre d'imatges de train que agafo per entrenar la xarxa
    
    I=imread(I_trainT.File{jj});
    x=I_trainT.xy_{jj}(1,:);
    y=I_trainT.xy_{jj}(2,:);
    Co=floor(length(x)/number_columns);

    for i=(2+column_index*Co):aggregated_columns:(Co + column_index*Co)
    
        s=zeros(R,3*aggregated_columns);
        c=zeros(R,1);
        
        rgb_index=1;
        
        shoreline_index = 0;
            
        fprintf('Aggregating columns\n')
        
        for ii=i:(i+aggregated_columns - 1)
            
            if (ii > (Co + column_index*Co))
                
                % Duplicate last column

                fprintf('Duplicating column number %d\n', (Co + column_index*Co));

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(Co + column_index*Co),1);  
                s(:,rgb_index + 1)=I(:,x(Co + column_index*Co),2); 
                s(:,rgb_index + 2)=I(:,x(Co + column_index*Co),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(Co + column_index*Co);
                
            else 

                fprintf('Aggregating column number %d\n', ii);

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(ii),1);  
                s(:,rgb_index + 1)=I(:,x(ii),2); 
                s(:,rgb_index + 2)=I(:,x(ii),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(ii);
                
            end
            
        end
        
        % average shoreline index
        shoreline_index = round(shoreline_index/aggregated_columns);
        
        % Vector de classes
        c(round(shoreline_index))=1;
        c(round(shoreline_index)+1:end)=-1;
        c_categorized=categorical(c, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});
        
        X{ee}=s';
        Y{ee}=c_categorized';
        
        ee=ee+1;
    end
            
end

% Data Augmentation


% Generate synthetic datra
if synthetic_data > 0
    for j=1:synthetic_data
        for jj=1:floor(N_imatges_train)  % Nombre d'imatges de train que agafo per entrenar la xarxa

            I=imread(I_trainT.File{jj});
            x=I_trainT.xy_{jj}(1,:);
            y=I_trainT.xy_{jj}(2,:);
            Co=floor(length(x)/number_columns);
            
            for i=(2+column_index*Co):aggregated_columns:(Co + column_index*Co)
    
                s=zeros(R,3*aggregated_columns);
                c=zeros(R,1);

                rgb_index=1;

                shoreline_index = 0;

                fprintf('Aggregating columns\n')

                for ii=i:(i+aggregated_columns - 1)

                    if (ii > (Co + column_index*Co))

                        % Duplicate last column

                        fprintf('Duplicating column number %d\n', (Co + column_index*Co));

                        % Colunma de color de la matriu
                        s(:,rgb_index)=I(:,x(Co + column_index*Co),1);  
                        s(:,rgb_index + 1)=I(:,x(Co + column_index*Co),2); 
                        s(:,rgb_index + 2)=I(:,x(Co + column_index*Co),3);

                        rgb_index = rgb_index + 3;

                        shoreline_index = shoreline_index + y(Co + column_index*Co);

                    else 

                        fprintf('Aggregating column number %d\n', ii);

                        % Colunma de color de la matriu
                        s(:,rgb_index)=I(:,x(ii),1);  
                        s(:,rgb_index + 1)=I(:,x(ii),2); 
                        s(:,rgb_index + 2)=I(:,x(ii),3);

                        rgb_index = rgb_index + 3;

                        shoreline_index = shoreline_index + y(ii);

                    end

                end

                % average shoreline index
                shoreline_index = round(shoreline_index/aggregated_columns);
                % Vector de classes
                c(round(shoreline_index))=1;
                c(round(shoreline_index)+1:end)=-1;
                c_categorized=categorical(c, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});


                % Should be a random number close to the shore line
                shoreline_index=find(c==1);
                maximum_displacement=R-shoreline_index;                

                displacement=randi([1 floor(maximum_displacement/2)], 1, 1);

                fprintf('Generating synthetic data for training, displacement %d\n', displacement);

                s_displaced=zeros(R,3);
                c_displaced=zeros(R,1);

                % Move displacement pixels down the shoreline

                c_displaced(1:R - displacement)=c(displacement + 1:end);
                c_displaced(R - displacement +1:end)=c_displaced(R - displacement);

                c__displaced_categorized=categorical(c_displaced, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});

                for rgb_index_displaced=1:3*aggregated_columns
                
                    %RGB displacement
                    s_displaced(1:R - displacement, rgb_index_displaced)=s(displacement + 1:end, rgb_index_displaced);
                    s_displaced(R - displacement +1:end, rgb_index_displaced)=s_displaced(R - displacement, rgb_index_displaced);
                end 
                
                X{ee}=s_displaced';
                Y{ee}=c__displaced_categorized';

                ee=ee+1;
                
            end
        end
    end    
end


%% Prepara dades per Test
ee=1; % Index de les columnes que processoX
for jj=1:N_imatges_test  % Nombre d'imatges de train que agafo per entrenar la xarxa
    
    I=imread(I_testT.File{jj});
    x=I_testT.xy_{jj}(1,:);
    y=I_testT.xy_{jj}(2,:);
    Co=floor(length(x)/number_columns);

    for i=(2+column_index*Co):aggregated_columns:(Co + column_index*Co)
        
        s=zeros(R,3*aggregated_columns);
        c=zeros(R,1);
        
        rgb_index=1;
        
        shoreline_index = 0;
        
        for ii=i:(i+aggregated_columns - 1)
            
            if (ii > (Co + column_index*Co))
                
                % Duplicate last column

                fprintf('Duplicating column number %d\n', (Co + column_index*Co));

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(Co + column_index*Co),1);  
                s(:,rgb_index + 1)=I(:,x(Co + column_index*Co),2); 
                s(:,rgb_index + 2)=I(:,x(Co + column_index*Co),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(Co + column_index*Co);
                
            else 
            
                fprintf('Aggregating column number %d\n', ii);

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(ii),1);  
                s(:,rgb_index + 1)=I(:,x(ii),2); 
                s(:,rgb_index + 2)=I(:,x(ii),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(ii);
            end
            
        end
        
        % average shoreline index
        shoreline_index = round(shoreline_index/aggregated_columns);
        
        % Vector de classes
        c(round(shoreline_index))=1;
        c(round(shoreline_index)+1:end)=-1;
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
    Co=floor(length(x)/number_columns);

    for i=(2+column_index*Co):aggregated_columns:(Co + column_index*Co)
    
        s=zeros(R,3*aggregated_columns);
        c=zeros(R,1);
        
        rgb_index=1;
        
        shoreline_index = 0;
        
        for ii=i:(i+aggregated_columns - 1)
            
            if (ii > (Co + column_index*Co))
                
                % Duplicate last column

                fprintf('Duplicating column number %d\n', (Co + column_index*Co));

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(Co + column_index*Co),1);  
                s(:,rgb_index + 1)=I(:,x(Co + column_index*Co),2); 
                s(:,rgb_index + 2)=I(:,x(Co + column_index*Co),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(Co + column_index*Co);
                
            else 
            
                fprintf('Aggregating column number %d\n', ii);

                % Colunma de color de la matriu
                s(:, rgb_index)=I(:,x(ii),1);  
                s(:, rgb_index + 1)=I(:,x(ii),2); 
                s(:, rgb_index + 2)=I(:,x(ii),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(ii);
            
            end
            
        end
        
        % average shoreline index
        shoreline_index = round(shoreline_index/aggregated_columns);
        
        % Vector de classes
        c(round(shoreline_index))=1;
        c(round(shoreline_index)+1:end)=-1;
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
numFeatures=3*aggregated_columns;
numHiddenUnits=30;   % 60 sembla millor que 30 
numClasses=3;
miniBatchSize=20;

layers=[ sequenceInputLayer(numFeatures)
               % lstmLayer(numHiddenUnits,'OutputMode','sequence')
               bilstmLayer(numHiddenUnits,'OutputMode','sequence')
               fullyConnectedLayer(3)
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
    [net info] =trainNetwork(X,Y,layers,options);
    toc
    
    c=clock;
    
    nom2=['lstm_net_' '_' num2str(c(1)) '_' num2str(c(2)) '_' num2str(c(3)) '_' num2str(c(4)) '.mat' ];
    nom2=[foldername '\' nom2];
    
    save(nom2,'net','layers','options','numHiddenUnits','numFeatures','numClasses')
    
    save([foldername '\train_result.mat'], '-struct', 'info')
    training_progress = findall(groot, 'Type', 'Figure');
    saveas(training_progress, [foldername '\train_process.jpg']);
    pause(2);
    close(training_progress);

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
save([foldername '\' 'workspace_variables.mat'])

% load('PrimerExperiment.mat','net','X', 'Y', 'XTest','YTest',
% 'XVal','YVal','YPred','options','numFeatures','numHiddenUnits')

for jj=1:N_imatges_test  % Nombre d'imatges de train que agafo per entrenar la xarxa
    
    XTest2={};
    ee=1;
    I=imread(I_testT.File{jj});
    x=I_testT.xy_{jj}(1,:);
    y=I_testT.xy_{jj}(2,:);
    Co=floor(length(x)/1);

    for i=2:aggregated_columns:Co
        
        s=zeros(R,3*aggregated_columns);
        c=zeros(R,1);
        
        rgb_index=1;
        
        shoreline_index = 0;
        
        for ii=i:(i+aggregated_columns - 1)
            
            if (ii > Co)
                
                % Duplicate last column

                fprintf('Duplicating column number %d\n', (Co));

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(Co),1);  
                s(:,rgb_index + 1)=I(:,x(Co),2); 
                s(:,rgb_index + 2)=I(:,x(Co),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(Co);
                
            else 
            
                fprintf('Aggregating column number %d\n', ii);

                % Colunma de color de la matriu
                s(:,rgb_index)=I(:,x(ii),1);  
                s(:,rgb_index + 1)=I(:,x(ii),2); 
                s(:,rgb_index + 2)=I(:,x(ii),3);

                rgb_index = rgb_index + 3;

                shoreline_index = shoreline_index + y(ii);
            end
            
        end
        
        % average shoreline index
        shoreline_index = round(shoreline_index/aggregated_columns);
        
        % Vector de classes
        c(round(shoreline_index))=1;
        c(round(shoreline_index)+1:end)=-1;
        c=categorical(c, [0 1 -1], {'terra'  'linia_de_costa' 'mar'});
        
        XTest2{ee}=s';

        ee=ee+1;
    end
        
    YPred2=classify(net,XTest2);
    YPred_parsed=zeros(length(YPred2), 1);

    for index=1:length(YPred2)

        YPred_parsed(index)= length(find(grp2idx(YPred2{index}) == 1));

    end

    image_file = char(I_testT.File{jj});
    indexes = find(image_file == '\');
    lastIndex = indexes(size(indexes,2));
    image_file_name =image_file(lastIndex+1:end);
    
    figure
    imshow(I);
    hold on
    plot(I_testT.xy_{jj}(1,:),I_testT.xy_{jj}(2,:),'r');
    plot(1:aggregated_columns:(length(YPred_parsed)*aggregated_columns),YPred_parsed,'g');
    title(image_file_name);
    legend('Shoreline' , 'Predicted Shoreline');
    pause(0.5)
    saveas(gcf, [foldername '\' image_file_name '_predicted.png']);
    
    figure
    plot(T.xy_{jj}(2,:));
    title(image_file_name);
    hold on
    grid on
    plot(YPred_parsed','r');
    legend('Shoreline' , 'Predicted Shoreline');
    saveas(gcf, [foldername '\' image_file_name '_expected_vs_predicted.png']);

    save([foldername '\' image_file_name '_predicted.mat'], 'YPred2','YPred_parsed');
end