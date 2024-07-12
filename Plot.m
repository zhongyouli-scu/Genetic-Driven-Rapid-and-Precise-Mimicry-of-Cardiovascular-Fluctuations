%==================================================================%
%% 文件名：Plot
%% 功能：画图
%% File name: Plot
%% Function: Plot
%==================================================================%N

function TargetData = Plot(TargetData)
    
    % 导出输出路径
    % Export output path
    path = TargetData.System{8};
    savepath = TargetData.System{9};

    switch TargetData.System{1} 

        case 0
            
            % 建立保存图像的文件夹
            % Create a folder for saving images
            mkdir(strcat(savepath,'/Pic'));

            %建立图像窗口，并展示保存目标曲线
            % Create image window and show save target curves
            Figure = figure('NumberTitle','off');
            Figure.Position(1:4) = [1 1 1920 1080];
            switch TargetData.System{2}            
                case {1 2 3}
                    FigureNum(1,1) = TargetData.System{2};
                    FigureNum(1,2) = 1;
                otherwise
                FigureNum(1,1) = ceil(sqrt(TargetData.System{2}));
                FigureNum(1,2) = ceil(sqrt(TargetData.System{2}));
            end
            TargetData.System{7} = FigureNum;
            TargetData.System{6} = Figure;
            Figure.Name = sprintf('Interpolation curve fitting schematic');
            for i = 1:TargetData.System{2}
                subplot(FigureNum(1,1),FigureNum(1,2),i);
                A = TargetData.Targetcell{i,3}:(TargetData.Targetcell{i,4}-TargetData.Targetcell{i,3})/100:TargetData.Targetcell{i,4};
                plot(A,TargetData.Targetcell{i,5}(A),'b-',LineWidth=2);
                hold on;
                plot(TargetData.Targetcell{i,2}(1,:),TargetData.Targetcell{i,2}(2,:),'k.',MarkerSize=10);
                xlim([TargetData.Targetcell{i,3} TargetData.Targetcell{i,4}]);
                legend('Raw data','Interpolated Fitting Curve');
                title(TargetData.Targetcell{i,1});
                grid on
                drawnow;
            end   
            hold off;
            Picname = strcat('Curve fitting.jpg');

            % 保存目标曲线图像
            % Save target curve image
            saveas(gcf, [strcat(savepath,'\Pic\'),Picname]);

        otherwise

            % 提取有关数据
            % Extraction of relevant data
            FigureNum = TargetData.System{7};
            Figure = TargetData.System{6};

            % 进行窗口信息的更新，并展示保存输出曲线与目标曲线对比图
            % Performs update of window information and displays saved output curves against target curves
            Figure.Name = sprintf('Iteration %d, appropriate value %f',TargetData.System{1},TargetData.fitness(1)); 
            if TargetData.System{1} >= TargetData.Info(9)
                fprintf('Completed, %d iterations, Fitness value %f\n',TargetData.System{1},TargetData.fitness(1)); 
            else
                fprintf('Iteration %d, Fitness value %f\n',TargetData.System{1},TargetData.fitness(1));
            end
 
            for i = 1:TargetData.System{2}
                IterationData = TargetData.IterationData(1).logsout{i}.Values;
                subplot(FigureNum(1,1),FigureNum(1,2),i);
                [~,index] = min(abs(TargetData.Targetcell{i,3}-IterationData.Time));
                [~,outdex] = min(abs(TargetData.Targetcell{i,4}-IterationData.Time));
                while IterationData.Time(index) <= TargetData.Targetcell{i,3}
                    index = index+1;
                end         
                while IterationData.Time(outdex) >= TargetData.Targetcell{i,4}
                    outdex= outdex-1;
                end
                hold off
                A = TargetData.Targetcell{i,3}:(TargetData.Targetcell{i,4}-TargetData.Targetcell{i,3})/100:TargetData.Targetcell{i,4};
                plot(A,TargetData.Targetcell{i,5}(A),'b-',LineWidth=2);
                hold on;
                plot(TargetData.Targetcell{i,2}(1,:),TargetData.Targetcell{i,2}(2,:),'k.',MarkerSize=10);
                hold on;
                plot(IterationData.Time(index:outdex),IterationData.Data(index:outdex),'r',LineWidth=2);
                xlim([TargetData.Targetcell{i,3} TargetData.Targetcell{i,4}]);
                hold off
                title(TargetData.Targetcell{i,1});
                legend('Raw data','Interpolated Fitting Curve',sprintf('After %d iterations',TargetData.System{1}),'Location','southeast');
                legend('boxoff');
                grid on
                drawnow;
            end 

            hold off;
            Picname = strcat(num2str(TargetData.System{1}),'.jpg');
            saveas(gcf, [strcat(savepath,'\Pic\'),Picname]);


    end