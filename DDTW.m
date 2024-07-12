%==================================================================%
%% 文件名：DDTW
%% 功能：实现微分动态时间扭曲计算
%% File name: DDTW
%% Function: Implement differential dynamic time warping calculation
%============================================================


function [d,D,Dist,w] = DDTW(A,B,k)

    % 确认矩阵维数
    % Confirmation of matrix dimensions
    M = size(A,2);
    N = size(B,2);
    
    d= zeros(M,N);
    D = zeros(M,N);

    % 分计算情况，0为欧式距离，1为DTW，2为修正的DDTW
    % Calculation case, 0 for Euclidean distance, 1 for DTW, 2 for modified DDTW
    switch k
        case 0
            for i = 1:M
                for j = 1:N
                    d(i,j) = (A(1,i)-B(1,j))^2+(A(2,i)-B(2,j))^2;
                end
            end
        case 1
             for i = 1:M
                 eda = ed(A,i);
                for j = 1:N
                    edb = ed(B,j);
                    d(i,j) = (eda-edb)^2;
                end
             end
         case 2
             for i = 1:M
                 eda = ed(A,i);
                for j = 1:N
                    edb = ed(B,j);
                    d(i,j) = ((eda-edb)^2)*((A(1,i)-B(1,j))^2+(A(2,i)-B(2,j))^2);
                end
             end
    end
    
    % 开始在距离矩阵中寻找路径
    % Start looking for a path in the distance matrix
    D(1,1) = d(1,1);

    % 计算垂直方向对应点的距离，相邻值加上步长
    % Calculate the distance between corresponding points in the vertical direction, adjacent values plus the step size
    for i=2:M
    D(i,1)=d(i,1)+D(i-1,1); 
    end

    % 计算水平方向上对应点的距离，相邻值加上步长
    % Calculate the distance to the corresponding point in the horizontal direction, adjacent values plus the step size
    for i=2:N
        D(1,i)=d(1,i)+D(1,i-1); 
    end

    % 计算对角线上的对应点的距离，此时应该找相邻3点的最小距离相加
    % Calculate the distance to the corresponding point on the diagonal, at this point you should look for the minimum distance between the 3 neighbouring points and add them together.
    for i=2:M   
        for j=2:N
            D(i,j)=d(i,j)+min(D(i-1,j),min(D(i-1,j-1),D(i,j-1))); % this double MIn construction improves in 10-fold the Speed-up. Thanks Sven Mensing
        end
    end

    % D矩阵的最左下方的D(M,N)即为所求的最小距离
    % D(M,N), the leftmost lower part of the D matrix, is the desired minimum distance
    Dist=D(M,N);  
    n=N;
    m=M;
    k=1;
    w=[M N]; 

    % 找出最佳路径并输出
    % Find the best path and output
    while ((n+m)~=2) 
        if (n-1)==0
            m=m-1;
        elseif (m-1)==0
            n=n-1;
        else 
          [values,number]=min([D(m-1,n),D(m,n-1),D(m-1,n-1)]);
          switch number   % values值为输出的最小值，number为最小值在所在的位置索引
          case 1          % The values value is the minimum value of the output, and the number is the index of the minimum value in the location.
            m=m-1;
          case 2
            n=n-1;
          case 3
            m=m-1;
            n=n-1;
          end
        end
        k=k+1;
        w=[m n; w]; 
        % w为最终的最优路径
        % w is the final optimal path
    end

end








    

    