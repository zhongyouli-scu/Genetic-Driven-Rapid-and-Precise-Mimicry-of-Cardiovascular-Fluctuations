%==================================================================%
%% 文件名：Genetic Arithmetic
%% 功能：进行遗传算法的交叉变异选择过程
%% File name: Genetic Arithmetic
%% Function: To perform a genetic algorithm for the selection process of cross mutations.
%==================================================================%

function TargetData = GeneticArithmetic(TargetData)

    % 第一次迭代，适宜值重复计数清零，记录迭代输出的最优适应度值
    % For the first iteration, the fitness value repeat count is cleared to zero and the optimal fitness value output from the iteration is recorded
    if TargetData.System{1} == 1
        TargetData.System{4} = 0;
        TargetData.System{5} = TargetData.fitness(1);
    end
  
    %计算最佳适宜度的重复次数
    % of repetitions for calculating optimal suitability
    if abs(TargetData.System{5}-TargetData.fitness(1))/(TargetData.System{5}+(TargetData.System{5} == 0)*eps) < TargetData.Info(10)
        TargetData.System{4} = TargetData.System{4} + 1;

    %如果适宜值重复次数过多，则保留目前最佳个体，将种群进行重置，再度生成随机种群
    % If the fitness value is repeated too many times, the current best individual is retained and the population is reset to generate a random population again
    elseif TargetData.System{4} > TargetData.Info(11)      
        TargetData.System{4} = 1;
        TargetData.InzPrm = TargetData.pop(1,:);
        TargetData = InitializationParameters(TargetData);
        TargetData.pop(1,:) = TargetData.InzPrm;
    end

    % 根据适宜值重复次数，确定交叉率和突变率，如若适宜值重复次数过多，进行种族大爆发阶段，交叉率和突变率大幅度上涨
    % Determine crossover and mutation rates based on the number of repetitions of the fitness value, if too many repetitions of the fitness value are performed for the race explosion phase, the crossover and mutation rates increase dramatically
    mutationRateNow = TargetData.Info(6)*TargetData.System{4};
    crossRateNow = TargetData.Info(4)*TargetData.System{4};
    if mutationRateNow >= TargetData.Info(7)
        mutationRateNow = TargetData.Info(7);
    end
    if crossRateNow >= TargetData.Info(5)
        crossRateNow = TargetData.Info(5);
    end

    
    % 更新最佳适宜度
    % Updating of optimal suitability
    TargetData.System{5} = TargetData.fitness(1);

    % 进行选择淘汰，淘汰的个数根据适宜值重复次数确定，次数越高则淘汰的个体越多。此时将种群分为三部分，剩下的亲代，需要交叉产生的子代，还有一部分空位是根据适宜值重复次数确定的随机个体空位
    % Selective culling is performed, with the number of culls determined by the number of fitness value repetitions, the higher the number the more individuals are culled. At this point the population is divided into three parts, the remaining parents, the offspring that need to be crossed over, and a portion of the vacancies that are random individual vacancies determined by the number of fitness value repetitions
    popSize(1) = max(4,round(TargetData.Info(3)/TargetData.System{4}/2,TieBreaker="tozero"));popSize(2) = TargetData.Info(3)-2*popSize(1);
%==================================================================%
    
    %开始交叉，未被淘汰的个体作为亲代
    % began to cross over, and uneliminated individuals were used as parents
    parents = TargetData.pop(1:popSize(1),:);

    %交叉种族清零
    % Cross-racial clearance
    offsprings = zeros(popSize(1),TargetData.System{3});

    %进行亲代随机交叉，产生子代
    % performed parental randomization crossover to produce offspring that
    for j = 1:popSize(1)

        % 若随机数小于交叉率，则进行随机选择亲代个体进行交叉
        % If the random number is less than the crossover rate, perform a random selection of parental individuals for crossover
        if rand < crossRateNow
            parentA = parents(randi(popSize(1)),:);
            parentB = parents(randi(popSize(1)),:);
            c = ceil(rand(1,1)*TargetData.System{3});
            d = sort(randi(TargetData.System{3},1,c-mod(c,2)));
            d(1,1) = 1;d(1,end) = TargetData.System{3};
            for k = 2:size(d,2)
                parentA(1,d(1,k-1:k)) = parentB(1,d(1,k-1:k));
            end
            offsprings(j,:) = parentA;

        % 若相反，则直接保留亲代个体作为子代
        % If the opposite is true, the parental individuals are directly retained as offspring
        else
            offsprings(j,:) = parents(randi(popSize(1)),:);
        end
    end

    %亲代种族基因进行突变
    %Parental racial genes undergo mutation
    for j = 2:popSize(1)
        if rand < mutationRateNow
            c = ceil(rand(1,1)*TargetData.System{3});
            d = sort(randi(TargetData.System{3},1,c-mod(c,2)));
            parents(j,d) = 2*rand*TargetData.Info(8)*parents(j,d)+(1-TargetData.Info(8))*parents(j,d);
        end
    end

    %子代群落进行基因突变
    %Offspring communities undergo genetic mutation
    for j = 1:popSize(1)
        for k = 1:TargetData.System{3}
            if rand < mutationRateNow
                offsprings(j,k) = 2*rand*TargetData.Info(8)*offsprings(j,k)+(1-TargetData.Info(8))*offsprings(j,k);
            end
        end
    end

  
    %合并亲代子代基因个体，并随机产生随机基因个体补充群落空位
    % merged parental offspring genetic individuals and randomly generated stochastic genetic individuals to replenish community nulls
    TargetData.pop = [parents;offsprings;2*TargetData.Info(8)*rand(popSize(2),TargetData.System{3}).*TargetData.InzPrm+(1-TargetData.Info(8))*TargetData.InzPrm];
