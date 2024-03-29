%% Animal Model for Septic Shock
% The data generated by the experiments done on _*Wistar Rats_ *by measuring 
% the carotid artery pressures using an _Ipex� _pressure_ _transducer connected 
% to an amplifier which is calibrated (the procedure is mentioned elsewhere), 
% along with the respiration and ECG are all recorded using _CMCDAQ� _or_ AD Instruments� 
% Lab Chart pro software. _This data is later filtered and analysed using Matlab� 
% codes.
% 
% This is the codes for running data collected from LabChart Pro�.
%% Import file through UI
%%
% [~,F_name,~] = fileparts(uigetfile('*.mat'));
% load(F_name);

[F_name,F_Path] = uigetfile('*.mat',...
    'File FOR ECOLI - 1v (1st version)');
load(F_name);
F = fullfile(F_Path,F_name);
[F_Path,F_name,F_ext] = fileparts(F);


N_dir = sprintf('%s',F_name) ;
mkdir(N_dir)
N_dir = cd(N_dir);
%% Special Considerations
% For 190213_WR_SS including the initial segment
%%
%{
S1a2 = [data(datastart(1,1):dataend(1,1)),...         % segments 1 and 2
data(datastart(1,2):dataend(1,2))];
S1a2n = S1a2-250;
ndata = [S1a2n,data(datastart(1,3):dataend(1,3));];
data = ndata;
%}
%% Make the selection of the graph
% First find the location of the comment(s) in  the data. If there are more 
% than one segments in the recording the values (location) of the comments will 
% change when the whole data is taken together as the location of each segment 
% starts from zero. 
%%
if size(datastart,2) > 1
    ncom = zeros(size(com,1),2);  
      for c = 1:size(com,1)
         if com(c,2) == 1
             ncom(c,1) = com(c,3);
          elseif com(c,2) > 1
           ncom(c,1) = com(c,3)+dataend(com(c,2)+com(c,1));    
         end
       end
  ncom(:,2) = com(:,5);
  
  X1 = contains(cellstr(comtext),'Selec 1');
  loc1 = find(X1);
  X11 = ismember(ncom,loc1);
  loc11 = find(X11)-size(com,1);
  Selec1 = ncom(loc11,1);
  
  X2 = contains(cellstr(comtext),'Selec 2');
  loc2 = find(X2);
  X22 = ismember(ncom,loc2);
  loc22 = find(X22)-size(com,1);
  
  Selec2 = ncom(loc22,1);
 
 end
  
if size(datastart,2) == 1
    X1 = contains(cellstr(comtext),'Selec 1');
     loc1 = find(X1);

    X2 = contains(cellstr(comtext),'Selec 2');
     loc2 = find(X2);
    
    Selec1 = com(loc1,3);
    Selec2 = com(loc2,3);     
end
%% Pick the selected data  'Selec1' & 'Selec2'
% Using the locations found in the previous section pick and store the data 
% into new variables. This is then plotted to see the difference.
%%
Selec1Data = data(Selec1:Selec1+60000);
Selec2Data = data(Selec2:Selec2+60000);
%% Finding Peaks and Troughs
% 1. Find peaks - systolic and diastolic of '|*Selec1Data*'|
%%
% Systolic 
figure('Visible','on')
findpeaks(Selec1Data,'minpeakprominence',25, 'minpeakdistance', 150)     % "will need change - be careful"
[sbp1,sbp1loc] = findpeaks(Selec1Data,'minpeakprominence',25,...
    'minpeakdistance', 150);

pause

% Diastolic
figure('Visible','on')
findpeaks(-Selec1Data,'minpeakprominence',10, 'minpeakdistance', 100)     % "will need change - be careful"
[dbp1,dbp1loc] = findpeaks(-Selec1Data,'minpeakprominence',10,...
    'minpeakdistance', 150);
dbp1 = -dbp1;

pause
close all
%% 
% 2. Find peaks - systolic and diastolic of '|*Selec2Data*'|
%%
% Systolic
figure('Visible','on')
findpeaks(Selec2Data,'minpeakprominence',25, 'minpeakdistance', 150)  % "will need change - be careful"
[sbp2,sbp2loc] = findpeaks(Selec2Data,'minpeakprominence',25,...
    'minpeakdistance', 150);

pause

% Diastolic
figure('Visible','on')
findpeaks(-Selec2Data,'minpeakprominence',20,...
    'minpeakdistance', 150)   % "will need change - be careful"
[dbp2,dbp2loc] = findpeaks(-Selec2Data,'minpeakprominence',20,...
    'minpeakdistance', 150);
dbp2 = -dbp2;

pause
close all
%% 
% 3. Pair the data of '|*Selec1Data*' - |[sbp1] [sbp1loc] [dbp1] [dbp1loc]
%%
n1 = min(size(dbp1,2),size(sbp1,2));

bppairs1 = zeros(4,n1); % bppairs1(dbp1loc,dbp1,sbp1loc,sbp1)
        for m1 = 1:n1
            x1 = find(dbp1loc<sbp1loc(m1));
            if isempty(x1) || ...
               sbp1loc(m1)-dbp1loc(max(x1)) > 100

                    bppairs1(1,m1) = 0;
                    bppairs1(2,m1) = 0;                 
                    bppairs1(3,m1) = 0;                   
                    bppairs1(4,m1) = 0;
            else    
                    bppairs1(1,m1) = dbp1loc(max(x1));
                    bppairs1(2,m1) = dbp1(max(x1));                 
                    bppairs1(3,m1) = sbp1loc(m1);                  
                    bppairs1(4,m1) = sbp1(m1);
            end
        end

bppairs1 = bppairs1'; % now becomes a column vectors bppairs1(dbp1loc,dbp1,sbp1loc,sbp1)
bppairs1(~any(bppairs1,2),:) = [];
%% 
% 4. Pair the data of 'Selec2Data' - [dbp2loc] [dbp2] [sbp2loc] [sbp2];
%%
n2 = min(size(dbp2,2),size(sbp2,2)); 

bppairs2 = zeros(4,n2); % bppairs1(dbp1loc,dbp1,sbp1loc,sbp1)
        for m2 = 1:n2
            x2 = find(dbp2loc<sbp2loc(m2));
            if isempty(x2) || ...
               sbp2loc(m2)- dbp2loc(max(x2)) > 190  % "will need change"

                    bppairs2(1,m2) = 0;
                    bppairs2(2,m2) = 0;                 
                    bppairs2(3,m2) = 0;                  
                    bppairs2(4,m2) = 0;
            else    
                    bppairs2(1,m2) = dbp2loc(max(x2));
                    bppairs2(2,m2) = dbp2(max(x2));                 
                    bppairs2(3,m2) = sbp2loc(m2);                  
                    bppairs2(4,m2) = sbp2(m2);
            end
        end

bppairs2 = bppairs2'; % now becomes a column vectors bppairs2(dbp2loc,dbp2,sbp2loc,sbp2)
bppairs2(~any(bppairs2,2),:) = [];
%% Analysis
% 1. Mean Systolic and Diastolic and mean arterial pressure (MAP):
%%
%{
mean values of 'selec1Data' and 'selec2Data' (Different methods of doing the same thing)
meansbp1 = mean(bppairs1(:,4));
meandbp1 = mean(dbp1);
MAPselec1 = mean(Selec1Data);

meansbp2 = mean(sbp2);
meandbp2 = mean(dbp2);
MAPselec2 = mean(Selec2Data);
 %}       
                                % OR %
                                
                            % for 'Selec1Data'
q1 = size(bppairs1,1)-1;              
MAPselec1 = zeros(1,q1);
for p1 = 1:q1
    AUC_w1 = trapz(Selec1Data(bppairs1(p1,1):bppairs1(p1+1,1)));
    w1_time = bppairs1(p1+1,1)-bppairs1(p1,1);
    MAPselec1(p1) = AUC_w1/w1_time;
end
meansbp1 = mean(bppairs1(:,4));
meandbp1 = mean(bppairs1(:,2));

                             % for 'Selec2Data'
q2 = size(bppairs2,1)-1;              
MAPselec2 = zeros(1,q2);
for p2 = 1:q2
    AUC_w2 = trapz(Selec2Data(bppairs2(p2,1):bppairs2(p2+1,1)));
    w2_time = bppairs2(p2+1,1)-bppairs2(p2,1);
    MAPselec2(p2) = AUC_w2/w2_time;
end
meansbp2 = mean(bppairs2(:,4));
meandbp2 = mean(bppairs2(:,2));
%% 
% 2. Calculate Heart Rate
% 
% First calculate the cycle length and then calculate the difference of the 
% two adjacent location values i.e |sbp1loc and| |sbp2loc.|
%%
                                % for 'Selec1Data'
cyclelength_Selec1 = diff(bppairs1(:,3));
HR_Selec1 = max(bppairs1(:,3))./cyclelength_Selec1; % beats per minute

                                % for 'Selec2Data'
cyclelength_Selec2 = diff(bppairs2(:,3));
HR_Selec2 = max(bppairs2(:,3))./cyclelength_Selec2;
%% 
% 3. Pulse pressure
%%
                                % for 'Selec1Data'
PPSelec1Data = round(bppairs1(:,4)-bppairs1(:,2),1,'decimals');

                                % for 'Selec2Data'
PPSelec2Data = round(bppairs2(:,4)-bppairs2(:,2),1,'decimals');
%% *Visualization*
%%
% Confirm points
mygreen = [0 0.6 0.2];
myblue = [0 0.45 0.75];
myred = [0.85 0.33 0.1];
mybrown = [0.64 0.08 0.18];
dotsize = 25;
%% 1. Plot "Selec1Data"
%%
% Find the max and min values on the Y axis
maxMap1 = max(bppairs1(:,4));
mM = 900:-100:100;
M1M = find((mM-maxMap1)>0 & (mM-maxMap1)<100);
yVal1 = mM(M1M)+ 100;


S1 = size(Selec1Data,2);
figure('Visible','on')
plot(Selec1Data,'linewidth',1,...
    'color',mygreen);
hold on

% scatter plot of peaks - sbp1,sbp1loc; dbp1, dbp1loc over Selec1Data
scatter(sbp1loc,sbp1,dotsize,'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor',myred);
scatter(dbp1loc(1,:),dbp1(1,:),dotsize,...
    'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor',myblue);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
xlim([0 4000])
ylim([0 yVal1])


line([0 S1],[MAPselec1(1) MAPselec1(end)],'LineStyle','--',...
    'LineWidth',1,...
    'Color',[0.1 0.1 0.1])
line([0 S1],[meansbp1 meansbp1],'LineStyle','--',...
    'LineWidth',1,...
    'Color',myred)
line([0 S1],[meandbp1 meandbp1],'LineStyle','--',...
    'LineWidth',1,...
    'Color',myblue)

xticks(0:500:4000)
xticklabels(0:0.5:4)
% yticks(0:20:200)
%     [0.190376569037657 0.725783348596814 0.388075313807531 0.187716266935672],...
mystdaxis(gca)
annotation('textbox',...
    [0.142932790645644 0.816774268603874 0.100520835574716 0.0900852896765606],...
    'String',sprintf('SBP_{mean} = %.1f mmHg\nMAP_{mean} = %.1f mmHg\nDBP_{mean} = %.1f mmHg',...
    meansbp1,mean(MAPselec1),meandbp1),...
        'FitBoxToText','on',...
        'HorizontalAlignment','left',...
        'FontName','Georgia',...
        'FontSize',9,...
        'FontAngle','italic',...
        'FontWeight','normal')

annotation('textbox',...
    [0.764824308127732,0.836574075315836,0.127745237992327,0.064814813573051],...
    'String',sprintf('HR_{avg} = %.1f/min\nPP_{avg} = %.1f mmHg',...
    mean(HR_Selec1),mean(PPSelec1Data)),...
        'FitBoxToText','on',...
        'HorizontalAlignment','right',...
        'FontName','Georgia',...
        'FontSize',9,...
        'FontAngle','italic',...
        'FontWeight','normal')
        
Ti1 = title([F_name,' Before Ecoli'],'Interpreter','none');
mystdpng_ls([F_name,' Before Ecoli'])

%% 2. Plot "Selec2Data"
%%
% Find the max and min values on the Y axis
maxMap2 = max(bppairs2(:,4));
mM = 100:100:900;
MM = find(min(abs(mM-maxMap2)));
yVal2 = mM(MM)+ 100;

S2 = size(Selec2Data,2);

figure('Visible','on')
plot(Selec2Data,'linewidth',1,'Color',mybrown);
hold on


% scatter plot of peaks - sbp2,sbp2loc; dbp2, dbp2loc over Selec1Data
scatter(sbp2loc,sbp2,dotsize,'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor',myred);
scatter(dbp2loc(1,:),dbp2(1,:),dotsize,...
    'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor',myblue);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
xlim([0 4000])
ylim([0 yVal2])


line([0 S2],[MAPselec2(1) MAPselec2(end)],'LineStyle','--',...
    'LineWidth',1,...
    'Color',[0.1 0.1 0.1])
line([0 S2],[meansbp2 meansbp2],'LineStyle','--',...
    'LineWidth',1,...
    'Color',myred)
line([0 S2],[meandbp2 meandbp2],'LineStyle','--',...
    'LineWidth',1,...
    'Color',myblue)

xticks(0:500:4000)
xticklabels(0:0.5:4)
% yticks(0:20:yVal2)

mystdaxis(gca)
annotation('textbox',...
    [0.142932790645644 0.816774268603874 0.100520835574716 0.0900852896765606],...
    'String',sprintf('SBP_{mean} = %.1f mmHg\nMAP_{mean} = %.1f mmHg \nDBP_{mean} = %.1f mmHg',...
    meansbp2,mean(MAPselec2),meandbp2),...
        'FitBoxToText','on',...
        'HorizontalAlignment','left',...
        'FontName','Georgia',...
        'FontSize',9,...
        'FontAngle','italic',...
        'FontWeight','normal');

annotation('textbox',...
    [0.764824308127732,0.836574075315836,0.127745237992327,0.064814813573051],...
    'String',sprintf('HR_{avg} = %.1f/min\nPP_{avg} = %.1f mmHg',...
    mean(HR_Selec2),mean(PPSelec2Data)),...
        'FitBoxToText','on',...
        'HorizontalAlignment','right',...
        'FontName','Georgia',...
        'FontSize',9,...
        'FontAngle','italic',...
        'FontWeight','normal');    
        
Ti2 = title([F_name,' After Ecoli'],'Interpreter','none');
mystdpng_ls([F_name,' After Ecoli'])
%% Saving the required variables in a .mat file
%%
% use this to skip the following section  %{ %}

ReqPar_Selec1 = {'meansbp1',meansbp1;'meandbp1',meandbp1;'MAPselec1', mean(MAPselec1);...
    'HR_Selec1', mean(HR_Selec1);'PPSelec1Data',mean(PPSelec1Data)};

ReqPar_Selec2 = {'meansbp2',meansbp2;'meandbp2',meandbp2;'MAPselec2', mean(MAPselec2);...
    'HR_Selec2', mean(HR_Selec2);'PPSelec2Data',mean(PPSelec2Data)};

xlswrite(sprintf('%s.xlsx',F_name), [ReqPar_Selec1 ReqPar_Selec2]);

save(sprintf('%s_clean.mat',F_name),'HR_Selec1', 'HR_Selec2',...
    'bppairs1', 'bppairs2', 'MAPselec1', 'MAPselec2',...
    'meandbp1', 'meandbp2', 'meansbp1', 'meansbp2',...
    'PPSelec1Data', 'PPSelec2Data', 'Selec1Data', 'Selec2Data',...
    'F_Path', 'F_name', 'F_ext', 'N_dir');


%% 
% *Clear all other variables*
%%
% clearvars