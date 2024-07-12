%==================================================================%
%% 文件名：Mainbody
%% 功能：主函数
%% File name: Mainbody
%% Function: Main function
%==================================================================%

% 数据清理
% Data cleansing
clc; 
clear;
close all;

% 关闭Warning提醒和运行池，创建TargetData结构体
% Turn off Warning alerts and run pools, create TargetData structure
warning('off');
delete(gcp('nocreate'));
TargetData = struct();

%==================================================================%

% 读取数据文件
% Read data files
TargetData = Read(TargetData,'Data.txt');

% 进行第一次运行模型，获取信号线信息，并创建初始种群
% Perform the first run of the model to obtain signal line information and create the initial population
TargetData = Simulink(TargetData);

% 创建保存文件夹并画图
% Create save folders and draw diagrams
TargetData = Savfil(TargetData);
TargetData = Plot(TargetData);

%==================================================================%

% 大循环开始
% Start of the Grand Cycle
while true

    % 计时
    % Timing
    timeStart = tic;

    % 标志循环数加1
    % Flag cycle number plus 1
    TargetData.System{1} = TargetData.System{1}+1;

    % 将种群放入模型中进行迭代，进行曲线距离计算
    % Iterate by placing populations into the model for curve distance calculations
    TargetData = Simulink(TargetData);

    % 对参数组合进行遗传算法
    % Genetic algorithms on parameter combinations
    TargetData = GeneticArithmetic(TargetData);

    % 画图并保存文件
    % Draw a diagram and save the file
    TargetData = Plot(TargetData);
    TargetData = Savfil(TargetData);

    % 若达到循环次数，结束大循环，否则继续循环
    % If the number of cycles is reached, the macrocycle ends, otherwise the cycle continues.
    if TargetData.System{1} >= TargetData.Info(9)
        break        
    end

    % 结束计时，如若此次迭代并行池花费太多时间，则重置并行池
    % End the timer and reset the parallel pool if this iteration of the parallel pool takes too much time
    timeEnd = toc(timeStart);
    if timeEnd > 500
        delete(gcp('nocreate'));
        TargetData.parpool = parpool(TargetData.parpoolNum(1));
    end

end

% 结束并行池，结束计算
% End parallel pool, end computation
delete(gcp('nocreate'));

%==================================================================%
