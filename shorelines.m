% Pere Marti-Puig 06/02/2020

% (1) Visualitza les imatges i pinta punts dels diferents observadors
% (2) Per a cada observador tracem les splines
% (3) Serveix per descartar un observador que segueix un criteri diferent
% (4) De les splines dels tres observadors definim una línia de costa contínua
% (5) Per posteriors proves guardem les línies de costa i les adreces de
%       les imatges (44) de la mateixa platja per tenir imatges de la mateixa
%       mida a la Taula T Fitxer: 'LiniesCostaPlatjaLLarga.mat'


clear all; close all; clc;
dir_base=pwd
dir_dades=[dir_base '/imagenesMensuales/shorelines']

% Seleccionem les imatges de costa amb extensió png. El resultat el tenim a imds (image dataStore)
im_ds=imageDatastore(dir_dades,'FileExtensions','.png');
num_files=numel(im_ds.Files);

controlplot=true;
controlplot=false;
if controlplot==true  % Visualitza totes les imatges
    for i=1:num_files
        I= readimage(im_ds,i); % Llegeixo imatge i
        imshow(I);
        size(I)                               % Miro la mida de les imatges
        title(num2str(i))
        pause(0.75)
    end
end

idx = 1:2:num_files;   % index imparells per imatges netes
idx_test=1+idx;          % imatges amb punts

% -----------------------------------------------------
imds = subset(im_ds,idx); % IMDS  imatges netes
imds_t = subset(im_ds,idx_test); % imatges amb punts
% -----------------------------------------------------

controlplot=true;
controlplot=false;
if controlplot==true  % Visualitza el montage de les imatges sense i amb punts
    SiZe=[];
    for i=1:num_files/2
        I= readimage(imds,i); % Llegeixo imatge i
        J= readimage(imds_t,i); % Llegeixo imatge i
        % imshow(I);
        %imshowpair(I, J, 'montage');  % Forma per mostrar dues imatges
        montage({I,J},'Size', [2 1])        % MOLT Més genèric, es poden fer muntatges amb moltes imatges 
        [m n z]=size(I);                          % Miro la mida de les imatges
        SiZe=[SiZe; m n i];
        title([num2str(i) ' [' num2str(m) 'x' num2str(n) ']'   ])
        pause(0.1)
    end
    SiZe
end

% -----------------------------------------------------
% NOTA: Les imateges que van de la 100 a la 143 (44 imatges) tenen la mateixa mida
% -----------------------------------------------------

% Estructures per agrupar noms fitxers per CLASSIFICADORS
FR=dir( [dir_dades '/*FR.txt']); % Estructura amb classif. de FR
GS=dir( [dir_dades '/*GS.txt']); % Estructura amb classif. de GS
JA=dir( [dir_dades '/*JA.txt']); % Estructura amb classif. de JA
SA=dir( [dir_dades '/*SA.txt']); % Estructura amb classif. de SA


% Visualització les imatges amb les marques dels CLASSIFICADORS MANUALS i
% DECIDIM LA FRONTERA DE LA LÍNIA DE COSTA.

% Defineixo una TAULA CELLARRAY dels mateixos elements que imds on hi guado 
% xy_ =[x_;  y_] que seran les coordenades en pixels de la línia de costa

xy_=[];
T=table(xy_,'VariableNames',{'xy_'})

controlplot=true;
%controlplot=false;
if controlplot==true  % Visualitza el montage de les imatges sense i amb punts
    jj=1; % Index de les imatges que tenen la mateixa mida i són més nombroses
    for i=1:num_files/2         % 100:num_files/2         % Treballo amb les imatges que tenen la mateixa mida i són més nombroses
        
        I= readimage(imds,i);       % Llegeixo imatge i
        J= readimage(imds_t,i);    % Llegeixo imatge i
        
        % FR groc
        cl_FR=FR(i).name; % classe FR
        [c r s t u]=textread([dir_dades '/' cl_FR],'%f %f %s %s %s'); clear s t u
        
        % Codi de protecció per les splines
        [valors_unics, ind_unics] = unique(round(c));
        ind_repes = setdiff(1:length(c), ind_unics);
        if ~isempty(ind_repes)
            c(ind_repes)=[];r(ind_repes)=[];
        end
        
        x_FR=min(round(c)):1:max(round(c));
        y_FR=round(spline(round(c),round(r),x_FR));
        
        % GS negre
        cl_GS=GS(i).name; % classe GS
        [c1 r1 s t u]=textread([dir_dades '/' cl_GS],'%f %f %s %s %s'); clear s t u
        
        % Codi de protecció per les splines
        [valors_unicos, ind_unics] = unique(round(c1));
        ind_repes = setdiff(1:length(c1), ind_unics);
        if ~isempty(ind_repes)
            c1(ind_repes)=[];r1(ind_repes)=[];
        end
        
        x_GS=min(round(c1)):1:max(round(c1));
        y_GS=round(spline(round(c1),round(r1),x_GS));
        
        % JA vermell
        cl_JA=JA(i).name; % classe GA
        [c2 r2 s t u]=textread([dir_dades '/' cl_JA],'%f %f %s %s %s'); clear s t u
        
        % Codi de protecció per les splines
        [valors_unicos, ind_unics] = unique(round(c2));
        ind_repes = setdiff(1:length(c2), ind_unics);
        if ~isempty(ind_repes)
            c2(ind_repes)=[];r2(ind_repes)=[];
        end
        
        x_JA=min(floor(c2)):1:max(round(c2));
        y_JA=ceil(spline(c2,r2,x_JA));
        
        % SA verd (El descarto per seguir 
        
%         cl_SA=SA(i).name; % classe GA
%         [c3 r3 s t u]=textread([dir_dades '/' cl_SA],'%f %f %s %s %s'); clear s t u
%         
%         % Codi de protecció per les splines
%         [valors_unicos, ind_unics] = unique(c3);
%         ind_repes = setdiff(1:length(c3), ind_unics);
%         if ~isempty(ind_repes)
%             c3(ind_repes)=[];r3(ind_repes)=[];
%         end
%         
%         x_SA=min(round(c3)):1:max(round(c3));
%         y_SA=round(spline(round(c3),round(r3),x_SA));
        
        
        % -----------------------------------------------------
        % Proposta de linia per entrenament.
        % El punt que decideixo és el de la línia promig de les esplines
        % quan estan definides (y_GS , y_FR, y_JA). En el tram horitzontal (x_GS , x_FR, x_JA)
        
        x_Ini=min([min(x_GS) min(x_FR) min(x_JA)]);
        x_Fi=max([max(x_GS) max(x_FR) max(x_JA)]);
        x_=x_Ini:1:x_Fi;
        y_=zeros(size(x_));
        n_pixels=length(x_);
        
        for ii=1:n_pixels
            N=0; y=0;
            i_GS=find(x_GS==x_(ii));
            i_FR=find(x_FR==x_(ii));
            i_JA=find(x_JA==x_(ii));
            
            if ~isempty(i_GS) y=y+y_GS(i_GS); N=N+1; end
            if ~isempty(i_FR) y=y+y_FR(i_FR); N=N+1; end            
            if ~isempty(i_JA) y=y+y_JA(i_JA); N=N+1; end
            
            y_(ii)=y/N;
        end
        
        T.xy_{jj}=[x_; y_];  % LinC = Línia de Costa (LinC)
        jj=jj+1;
        % -----------------------------------------------------
        
        subplot(2,1,1)
        imshow(I)
        hold on
        plot(x_FR,y_FR,'y',c,r,'y.')
        plot(x_GS,y_GS,'k',c1,r1,'k.')
        plot(x_JA,y_JA,'r',c2,r2,'r.')
%         plot(x_SA,y_SA,'g',c3,r3,'g.')
        title([num2str(i) '      FR-Groc ;  GS-Negre;  JA-Vermell; SA-verd (descartat pq segueix un criteri força diferent)'])
        hold off
        
        subplot(2,1,2)
        imshow(I)
        hold on
        plot(x_,y_,'r')
        hold off
        
%         imshowpair(I, J, 'montage');  % Forma per mostrar dues imatges
%         montage({I,J},'Size', [2 1])        % MOLT Més genèric, es poden fer muntatges amb moltes imatges 

         pause(0.1)
    end                        % Ficar el breakpoint aquí per veure les fotos
    
    % Guarda taula
    Guardataula=true;
    % Guardataula=false;
    if Guardataula==true
        Tall=[imds.Files(1:143) T];
        Tall.Properties.VariableNames{'Var1'} = 'File';
        save('Sorelines_Pere.mat','Tall')
    end
    
end







