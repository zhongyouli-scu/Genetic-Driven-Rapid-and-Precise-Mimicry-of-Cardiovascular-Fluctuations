function [fitresult] = createFit( X, Y)

%CREATEFIT(ERT,ERER)
%  创建一个拟合。
%
%  要进行 '拟合结果对比' 拟合的数据:
%      X 输入: ert
%      Y 输出: erer
%  输出:
%      fitresult: 表示拟合的拟合对象。
%      gof: 带有拟合优度信息的结构体。
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 11-Oct-2023 16:13:36 自动生成


%% 拟合: '无标题拟合 1'。
% [xData, yData] = prepareCurveData( X, Y);
[xData, yData] = prepareCurveData( X, Y);

% % 设置 fittype 和选项。
% ft = fittype( 'fourier8' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% 
% % 对数据进行模型拟合。
% [fitresult,gof] = fit( xData, yData, ft, opts );

% 设置 fittype 和选项。
ft = 'pchipinterp';
opts = fitoptions( 'Method', 'PchipInterpolant' );
opts.ExtrapolationMethod = 'pchip';
opts.Normalize = 'on';

% 对数据进行模型拟合。
[fitresult, gof] = fit( xData, yData, ft, opts );

% % 绘制数据拟合图。
% figure( 'Name', strcat('拟合结果对比') );
% h = plot( fitresult, xData, yData );
% legend( h, 'xData vs. yData', '拟合结果对比', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % 为坐标区加标签
% xlabel( 'xData', 'Interpreter', 'none' );
% ylabel( 'yData', 'Interpreter', 'none' );
% grid on



