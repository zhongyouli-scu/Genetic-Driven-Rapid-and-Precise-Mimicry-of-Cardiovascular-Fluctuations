%==================================================================%
%% 文件名：InitializationParameters
%% 功能：初始化种群并开启MATLAB并行池
%% File name: InitializationParameters
%% Function: Initializes the population and opens the MATLAB parallel pool
%==================================================================%

function TargetData = InitializationParameters(TargetData)
    
    % 清空种群矩阵
    % Empty population matrix
    TargetData.pop = zeros(TargetData.Info(3),TargetData.System{3});
    
    % 产生初始种群，种群范围遍布初始参数的参数选取领域
    % Initial population generated, population ranges spread across the parameterized field of initial parameter selection
    for i = 1:TargetData.Info(3)
        TargetData.pop(i,:) =  (2*TargetData.Info(8)*i/TargetData.Info(3)+(1-TargetData.Info(8))).*TargetData.InzPrm;
    end

    % TargetData.pop = 2*TargetData.Info(8)*rand(TargetData.Info(3),TargetData.System{3}).*TargetData.InzPrm+(1-TargetData.Info(8))*TargetData.InzPrm;

    % 初始化工作
    % Initialization
    if TargetData.System{1} == 0

        % 建立并行池个数矩阵，由于种群个数并不一定等同于Matlab并行池个数，且往往可能比并行池个数多，因此并行计算时需要确认每次计算的种群个体数。
        % Create a matrix of the number of parallel pools. Since the number of populations is not necessarily equal to the number of Matlab parallel pools, and can often be more than the number of parallel pools, you need to confirm the number of population individuals per calculation for parallel computation.
        TargetData.parpoolNum = zeros();
        Poolnum = TargetData.Info(12);
        
        % 如果种群个数大于规定的并行池个数，则将种群分为几部分再带入并行池中进行计算
        % If the number of populations is greater than the specified number of parallel pools, the populations are divided into parts and brought into the parallel pools for computation.
        if TargetData.Info(3) >= Poolnum
            TargetData.parpoolNum(1,1:round(TargetData.Info(3)/Poolnum)) = Poolnum;
            if mod(TargetData.Info(3),Poolnum)
                TargetData.parpoolNum(1,round(TargetData.Info(3)/Poolnum)+1) = mod(TargetData.Info(3),Poolnum);
            end
        
        % 若种群个数小于规定的并行池个数，则直接以种群个数为并行池个数
        % If the number of populations is less than the specified number of parallel pools, the number of populations is used directly as the number of parallel pools.
        elseif TargetData.Info(3) <= Poolnum
            TargetData.parpoolNum = Poolnum;
        end  
            TargetData.parpool = parpool(TargetData.parpoolNum(1));
    end
    

    








