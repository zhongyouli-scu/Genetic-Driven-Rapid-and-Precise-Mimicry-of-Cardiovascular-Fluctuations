%==================================================================%
%% 文件名：Normalization
%% 功能：进行数据的归一化处理
%% File name: Normalization
%% Function: Normalize the data.
%==================================================================%

function NewData = Normalization(Data,ReferenceData)
    
    % 对数据进行归一化处理，以目标曲线的最值为标准，将目标曲线和输出曲线均百分比化
    % Normalize the data to the maximum value of the target curve, and percentage both the target curve and the output curve
    DataMax = max(ReferenceData(:));
    DataMin = min(ReferenceData(:));
    DataLength = DataMax-DataMin;
    NewData = (Data-DataMin)./DataLength;