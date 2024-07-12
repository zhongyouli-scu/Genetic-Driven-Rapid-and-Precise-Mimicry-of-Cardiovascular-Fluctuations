%==================================================================%
%% 文件名：Read
%% 功能：读取参数文件信息
%% File name: Read
%% Function: Read parameter file information
%==================================================================%N
function TargetData = Read(TargetData,str)

    % 读取参数文件信息
    % Read parameter file information
    readdata = importdata(str);
    TargetData.mdlName = readdata.textdata;
    TargetData.Info = readdata.data';

    % 建立System矩阵，保存迭代中的有关信息
    % Create System matrices to hold relevant information from iterations
    TargetData.System = cell(1,20);TargetData.System{1} = 0;TargetData.System{2} = 0;

    % 读取Simulink模型，并读取确定里面的RLC模块
    % Read the Simulink model and read to determine the RLC module inside it
    load_system(TargetData.mdlName{1});
    close_system(TargetData.mdlName{2});
    BlockPaths = find_system(TargetData.mdlName{1} ,'Type','Block');
    BlockTypes = get_param(BlockPaths,'BlockType');

    % 读取RLC模块的参数，并保存为初始参数
    % Read the parameters of the RLC module and save them as initial parameters
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

    % 修改RLC参数为矩阵元素，便于迭代
    % Modify RLC parameters to matrix elements for ease of iteration
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

    % 读取并保存Simulink模型的信号线信息
    % Read and save signal line information for Simulink models
    Login =  find_system(TargetData.mdlName{1},'FindAll','on','type','line');k = 1;    
    for i = 1:size(Login,1)
        Find = get(Login(i)).DataLogging;
        if Find == 1
            TargetData.System{2} = TargetData.System{2}+1;
            C(k) = get(Login(i));
            k = k+1;
        end
    end

    TargetData.lineName = cell(size(C,2),1);
    for i = 1:size(C,2)
        TargetData.lineName(i) = cellstr(C(i).Name);
    end
     
    % 保存为模型副本并关闭
    % Save as model copy and close
    close_system(TargetData.mdlName{1},['Model\',TargetData.mdlName{2}]);

    % 保存信号线个数
    % Number of signal lines saved
    TargetData.System{3} = size(TargetData.InzPrm,2);
    