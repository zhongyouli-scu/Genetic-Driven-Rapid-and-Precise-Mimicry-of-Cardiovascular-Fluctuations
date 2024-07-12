%==================================================================%
%% 文件名：ed
%% 功能：确定计算DDTW中每个点的估计导数
%% File name: ed
%% Function: determines the estimated derivatives for each point in the computed DDTW
%==================================================================%

function eu = ed(Data,i)
    
    % 若点为时间序列中第一个点，则其估计导数和第二个点相同，若为最后一个点，则其估计导数与倒数第二个点相同
    % If the point is the first point in the time series, its estimated derivative is the same as the second point, and if it is the last point, its estimated derivative is the same as the penultimate point.
    switch i
        case 1
            i = 2;
        case size(Data,2)
            i = size(Data,2)-1;
    end
    eu = (Data(2,i)-Data(2,i-1))/(Data(1,i)-Data(1,i-1))/2+(Data(2,i+1)-Data(2,i-1))/(Data(1,i+1)-Data(1,i-1))/2;
