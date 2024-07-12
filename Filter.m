%==================================================================%
%% 文件名：Filter
%% 功能：过滤数组中时间相同的点
%% File name: Filter
%% Function: Filter the points in the array with the same time
%==================================================================%

function NewData = Filter(Data,dimension,number,digit)

    switch dimension
        case 1
            M = size(Data,2);
            k = 1;
            NewData(:,1) = Data(:,1);
            for i = 2:M
                if (round(Data(number,i),digit)-round(Data(number,i-1),digit)) ~= 0
                    NewData(:,k) = round(Data(:,i),digit);
                    k = k+1;
                end
            end

        case 2
            M = size(Data,1);
            k = 1;
            NewData(1,:) = Data(1,:);
            for i = 2:M
                if (round(Data(i,number),digit)-round(Data(i-1,number),digit)) ~= 0
                    NewData(k,:) = round(Data(i,:),digit);
                    k = k+1;
                end
            end

        otherwise
            error;
    end

