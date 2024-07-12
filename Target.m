%==================================================================%
%% 文件名：Target
%% 功能：拟合目标曲线离散点并将傅里叶拟合的曲线数据导入数组
%% 文件名：Target
%% 功能：拟合目标曲线离散点并将傅里叶拟合的曲线数据导入数组
%==================================================================%N
function TargetData = Target(TargetData)

    for i = 1:TargetData.System{2}
        Dataname = TargetData.Targetcell{i,1};
        DataName = strcat(Dataname,'.txt');
        readdata = load(DataName);
        readdata = readdata';   
        if TargetData.Info(2) == 1
            readdata(1,2:end) = readdata(1,2:end)+readdata(1,1);
        end       
        if or(readdata(1,end) > readdata(2,1),readdata(1,2) < readdata(1,1))
            errordlg(strcat(Dataname,'输入目标函数离散点已超出给定区域时间，请检查数据！'),'错误！')
            error(1);
        end
        TargetData.Targetcell{i,3} = readdata(1,1);TargetData.Targetcell{i,4} = readdata(2,1);
        TargetData.Targetcell{i,2} = readdata(:,2:end);
        if readdata(1,2) ~= TargetData.Targetcell{i,3}
            readdata(1,1) = TargetData.Targetcell{i,3};readdata(2,1) = readdata(2,2); 
        else
            readdata = readdata(:,2:end);
        end
        if TargetData.Targetcell{i,4} > readdata(1,end)
            readdata(1,end+1) = TargetData.Targetcell{i,4};
            readdata(2,end) = readdata(2,end-1);
        end           
        TargetData.Targetcell{i,5} = createFit(readdata(1,:),readdata(2,:));
    end