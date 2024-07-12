%==================================================================%
%% 文件名：Savfil
%% 功能：储存文件
%% File name: Savfil
%% Function: Storing files
%==================================================================%N

function TargetData = Savfil(TargetData)
    
    % 确定适应度函数计算方式，与文件夹名称有关
    % Determine how the fitness function is calculated, in relation to the folder name
    switch TargetData.System{1} == 0

        case 1

            switch TargetData.Info(13)
                case 0
                    Fitnessname = 'DTW';
                case 1
                    Fitnessname = 'DDTW';
                case 2                    
                    Fitnessname = 'DDTW MULTIPLY';
            end  
            
            % 输入输出数据保存路径，并建立保存数据的文件夹，名称为"模型文件名 参数选取范围，适应度函数计算方式，种群个数，规定的迭代次数"
            % Input and output data save path and create a folder to save the data with the name “Model file name Parameter selection range, fitness function calculation method, number of populations, specified number of iterations”.
            path = strcat(TargetData.mdlName{4,1},'\');
            savepath = strcat(path,TargetData.mdlName{2},32,num2str(TargetData.Info(8)),32,Fitnessname,32,num2str(TargetData.Info(3)),32,num2str(TargetData.Info(9)));

            % 确认是否建立文件夹，如若该文件夹已存在，则只清空文件夹内容
            % Confirms whether a folder has been created or not, and if the folder already exists, only empties the contents of the folder
            [status] = mkdir(strcat(savepath));
            if status == 1
                rmdir(savepath,'s');
            end
            mkdir(savepath);
            
            % 建立储存目标函数数据的文件夹
            % Create a folder for storing objective function data
            mkdir(strcat(savepath,'\Fit curve'));

            % 储存目标函数
            % Storage objective function
            for i = 1:TargetData.System{2}
                A = [(TargetData.Targetcell{i,3}:(TargetData.Targetcell{i,4}-TargetData.Targetcell{i,3})/100:TargetData.Targetcell{i,4})',TargetData.Targetcell{i,5}(TargetData.Targetcell{i,3}:(TargetData.Targetcell{i,4}-TargetData.Targetcell{i,3})/100:TargetData.Targetcell{i,4})];
                A = Filter(A,2,1,4);
                A(:,1) = A(:,1)-TargetData.Targetcell{i,3};
                A = num2cell(A);
                title = {'Time','Data'};             
                A = [title;A];
                writecell(A,[strcat(savepath,'\Fit curve\'),strcat(TargetData.Targetcell{i,1},'.xlsx')]);
            end

            % 将路径保存在TargetData结构体中
            % Save the path in the TargetData structure
            TargetData.System{8} = path;
            TargetData.System{9} = savepath;

        case 0

            % 读取路径
            % Read path
            path = TargetData.System{8};
            savepath = TargetData.System{9};

            % 建立每次循环的文件夹
            % Create a folder for each cycle
            mkdir(strcat(savepath,'\',num2str(TargetData.System{1})));

            % 保存输出曲线数据
            % Save output curve data
            for i = 1:TargetData.System{2}
                A = [TargetData.IterationData(1).logsout{i}.Values.Time,TargetData.IterationData(1).logsout{i}.Values.Data];
                A = Filter(A,2,1,4);
                [~,K] = min(abs(A(:,1)-TargetData.Targetcell{i,3}));
                [~,E] = min(abs(A(:,1)-TargetData.Targetcell{i,4}));
                A = A(K:E,:);
                A(:,1) = A(:,1)-TargetData.Targetcell{i,3};
                A = num2cell(A);
                title = {'Time','Data'};             
                A = [title;A];
                writecell(A,[strcat(savepath,'\',num2str(TargetData.System{1}),'\'),strcat(TargetData.Targetcell{i,1},'.xlsx')]);
            end

            % 保存此次迭代的最优参数、初始参数及两者差异值
            % Saves the optimal parameters, the initial parameters, and the difference between the two for this iteration
            B = [TargetData.pop(1,:)',TargetData.InzPrm',((TargetData.InzPrm~=0).*(TargetData.pop(1,:)-TargetData.InzPrm)./TargetData.InzPrm+(TargetData.InzPrm==0).*(TargetData.pop(1,:)-TargetData.InzPrm))'];            
            B = num2cell(B);
            title = {'Iterationpop','InzPrm','Difference'};
            B = [title;B];
            writecell(B,[strcat(savepath,'\',num2str(TargetData.System{1}),'\'),'pop.xlsx']);

            % 如完成规定迭代次数，输出每次迭代的最佳适应度函数
            % If a specified number of iterations are completed, output the best fitness function for each iteration
            if TargetData.System{1} == TargetData.Info(9)
                writecell(TargetData.popOther(:,1),[strcat(savepath,'\'),'Fitness.xlsx']);
            end

    end