%==================================================================%
%% 文件名：Simulink
%% 功能：调用模型进行Simulink仿真
%% File name: Simulink
%% Function: Call model for Simulink simulation
%==================================================================%N

function TargetData = Simulink(TargetData)

    switch TargetData.System{1} == 0

        case 1

            %调用模型仿真，可调节参数
            %Call model simulation with adjustable parameters
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
            %Initial parameter selection, neighborhood selection at a given parameter
            TargetData = InitializationParameters(TargetData);
            
        case 0

            TargetData.IterationData = {};
            for j = 1:size(TargetData.parpoolNum,2)
            % 定义一个Simulink.SimulationInput对象数组，设置模型名称
            % Define an array of Simulink.SimulationInput objects, set the model name
                numSims = TargetData.parpoolNum(j); % 定义你想要运行的模拟次数 Define the number of simulations you want to run
                simIn(1:numSims) = Simulink.SimulationInput(TargetData.mdlName{2});                
                % 为每次模拟设置不同的参数或输入
                % Setting different parameters or inputs for each simulation
                for i = 1:numSims
                    simIn(i) = simIn(i).setModelParameter('StopTime',num2str(TargetData.Info(1)),'SolverType','Variable-step','StartTime','0');
                    simIn(i) = simIn(i).setVariable('CalPrm',TargetData.pop((j-1)*TargetData.parpoolNum(1)+i,:)); % 'paramName' 和 'value' 是你模型中的参数名称和值
                end
                simout = parsim(simIn,'ShowProgress', 'on');
                TargetData.IterationData = [TargetData.IterationData,simout];
            end 

            % 计算适宜值
            % Calculation of appropriate values
            TargetData = Fitness(TargetData);
            %将最佳适宜度基因赋值在下一个初始种群上
            % assigns the best fitness gene to the next initial population
            [TargetData.fitness,index] = sort(sum(TargetData.fitness,2),'ascend');
            TargetData.pop = TargetData.pop(index,:);
            TargetData.IterationData = TargetData.IterationData(index);
            TargetData.popOther{TargetData.System{1},1} = TargetData.fitness(1);
            TargetData.popOther{TargetData.System{1},2} = TargetData.pop(1,:);
    end


