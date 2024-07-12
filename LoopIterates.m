%==================================================================%
%% 文件名：LoopIterates
%% 功能：循环依次迭代的主函数
%% File name: LoopIterates
%% Function: Main function that iterates through the loop sequentially.
%==================================================================%

% 清理数据
% Data cleansing
clc; 
clear;
close all;

% 取消simulink模型的警告，并构建TargetData结构体
% Unwarn the simulink model and build the TargetData structure
warning('off');
TargetData = struct();
delete(gcp('nocreate'));

%==================================================================%

% 读取数据文件
% Read data files
TargetData = Read(TargetData,'Data.txt');

% 开始读取Simulink相关信息，尤其是信号线个数、名称
% Start reading Simulink-related information, especially the number and names of signal lines.
Num = size(TargetData.lineName,1);

for m = 1:Num
    
    TargetData = struct();
    readdata = importdata('Data.txt');
    TargetData.mdlName = readdata.textdata;
    TargetData.Info = readdata.data';
    TargetData.System = cell(1,20);TargetData.System{1} = 0;TargetData.System{2} = 0;
    load_system(TargetData.mdlName{1});
    close_system(TargetData.mdlName{2});
    BlockPaths = find_system(TargetData.mdlName{1} ,'Type','Block');
    BlockTypes = get_param(BlockPaths,'BlockType');

    TargetData.InzPrm = zeros();
    Calk = zeros;k = 0;
    for i = 1:size(BlockTypes,1)
        Prmname = strcat(TargetData.mdlName{1},'/',TargetData.mdlName{3},num2str(i)); 
        for j = 1:size(BlockPaths,1)
            if strcmp(BlockPaths{j,1},Prmname)
                k = k+1;
                Calk(1,k) = i;
                switch get_param(Prmname,'BranchType')
                    case 'R'
                        TargetData.InzPrm (1,k) = str2double(get_param(Prmname,'Resistance'));
                    case 'L'
                        TargetData.InzPrm (1,k) = str2double(get_param(Prmname,'Inductance'));
                    case 'C'
                        TargetData.InzPrm (1,k) = str2double(get_param(Prmname,'Capacitance'));
                end
            end
        end
    end

    for i = 1:size(Calk,2)
       Prmname = strcat(TargetData.mdlName{1},'/',TargetData.mdlName{3},num2str(Calk(i)));
        for j = 1:size(BlockPaths,1)
            if strcmp(BlockPaths{j,1},Prmname)
                Name = strcat('CalPrm(1,',num2str(i),')');
                switch get_param(Prmname,'BranchType')
                    case 'R'
                    set_param(Prmname,'Resistance',Name);
                    case 'L'
                    set_param(Prmname,'Inductance',Name);
                    case 'C' 
                    set_param(Prmname,'Capacitance',Name);
                end
                % set_param(Prmname,'Name',A); 
            end
        end
    end 
    
    Login =  find_system(TargetData.mdlName{1},'FindAll','on','type','line');k = 1;K = zeros();    
    for i = 1:size(Login,1)
        Find = get(Login(i)).DataLogging;
        if Find == 1
            TargetData.System{2} = TargetData.System{2}+1;
            C(k) = get(Login(i));
            K(k) = i;
            k = k+1;           
        end
    end

   TargetData.lineName = cell(size(C,2),1);
   for i = 1:size(C,2)
       TargetData.lineName(i) = cellstr(C(i).Name);
   end

    for i = 1:size(C,2)
        if i ~= m
            % lines = get_param(TargetData.mdlName{1},'Lines');
            % u = lines(K(i)).Handle;
            u = find_system(TargetData.mdlName{1},'FindAll','on','type','line','name',strcat(TargetData.lineName{i}));
            set(u,'DataLogging',0);
        end
    end

    close_system(TargetData.mdlName{1},['Model\',TargetData.mdlName{2}]);
    TargetData.System{3} = size(TargetData.InzPrm,2);
    

    simIn = Simulink.SimulationInput(TargetData.mdlName{2}); 
    simIn = simIn.setModelParameter('StopTime',num2str(TargetData.Info(1)),'SolverType','Variable-step','StartTime','0');
    simIn = simIn.setVariable('CalPrm',TargetData.InzPrm); 
    simOut = sim(simIn);

    %获取信号个数
    % Getting the number of signals
    % if TargetData.System{2} ~= simOut.logsout.numElements
    %     error(2);
    % end
    TargetData.System{2} = simOut.logsout.numElements;
    TargetData.Targetcell = cell(TargetData.System{2},4);
    for j = 1:TargetData.System{2}
        TargetData.Targetcell{j,1} = [simOut.logsout{j}.Values.Name]; 
    end
    TargetData = Target(TargetData);

    %初始参数选取，在给定参数选取邻域
    % Initial parameter selection, neighborhood selection at a given parameter
    TargetData.pop = zeros(TargetData.Info(3),TargetData.System{3});

    for i = 1:TargetData.Info(3)
        TargetData.pop(i,:) =  (2*TargetData.Info(8)*i/TargetData.Info(3)+(1-TargetData.Info(8))).*TargetData.InzPrm;
        % TargetData.pop(i,:) = TargetData.InzPrm;
    end

   
    if TargetData.System{1} == 0
        TargetData.parpoolNum = zeros();
        Poolnum = TargetData.Info(12);
        if TargetData.Info(3) >= Poolnum
            TargetData.parpoolNum(1,1:round(TargetData.Info(3)/Poolnum)) = Poolnum;
            if mod(TargetData.Info(3),Poolnum)
                TargetData.parpoolNum(1,round(TargetData.Info(3)/Poolnum)+1) = mod(TargetData.Info(3),Poolnum);
            end
        elseif TargetData.Info(3) <= Poolnum
            TargetData.parpoolNum = Poolnum;
        end  
        if m == A
            TargetData.parpool = parpool(TargetData.parpoolNum(1));
        end
    end

    TargetData = Savfil(TargetData);
    TargetData = Plot(TargetData);

    %==================================================================%
 
    while true
        timeStart = tic;
        TargetData.System{1} = TargetData.System{1}+1;
        TargetData = Simulink(TargetData);
        TargetData = GeneticArithmetic(TargetData);
        TargetData = Plot(TargetData);
        TargetData = Savfil(TargetData);   TargetData.lineName = cell(size(C,2),1);
        for i = 1:size(C,2)
            TargetData.lineName(i) = cellstr(C(i).Name);
        end
        if TargetData.System{1} >= TargetData.Info(9)
           break        
        end
        timeEnd = toc(timeStart);


        if timeEnd > 300
            delete(gcp('nocreate'));
            TargetData.parpool = parpool(TargetData.parpoolNum(1));
        end

    end
    
    [status] = mkdir(strcat(TargetData.System{8},strcat(TargetData.lineName{m})));
    movefile(TargetData.System{9},strcat(TargetData.System{8},strcat(TargetData.lineName{m}),'\'));
    clc
end

delete(gcp('nocreate'));


%==================================================================%
