% 迭代200次，或者连续50次结果无变化，则停止迭代
clc
clear
Z_BC = 0;

% 参数初始化
resSize=100;
inSize = 3;
narvs = inSize*resSize + resSize* resSize;
T0 = 1;   % 初始温度
T = T0; % 迭代中温度会发生改变，第一次迭代时温度就是T0
maxgen = 200;  % 最大迭代次数
Lk = 100;  % 每个温度下的迭代次数
alfa = 0.95;  % 温度衰减系数
x_lb = -0.8 ; % x的下界
x_ub = 0.8 ; % x的上界



% 产生初始解
arhow_r =0.67;
k = 5;


% 初值Win的生成
Win1  =-1+2*rand(resSize,inSize);   % 均匀分布
% Win1 = normrnd(0,rhow_in^2,[resSize inSize])  % 正态分布
adj1 = zeros(resSize,inSize); 
A1 = rand(resSize,inSize);
B1 = find(A1<0.44);
adj1(B1)=1;
Win = adj1.*Win1;


%初值Wres的生成
adj2 = zeros(resSize,resSize);
for i = 1:resSize
    num = randperm(resSize,k);
    for j = 1:k
        adj2(i,num(j)) = 1;
    end
end
Wres1 = normrnd(0,1,[resSize resSize]); %生成正态分布随机数
Wres2 = adj2.*Wres1 ;
SR = max(abs(eig(Wres2))) ;
Wres = Wres2 .* ( arhow_r/SR);   

% ode45求解Lorenz系统
y0 = [-7.0731,-2.7263,30.5163];
[t,y] = ode45('lorenz_diff',[0.01:0.01:300],y0);
data = y';

x0 = [reshape(Win,1,[]),reshape(Wres,1,[])];
y0 = SA_RC_F(x0,data);   % 当前的预测步长

% %% 定义一些保存中间过程的量，方便输出结果和画图
max_y = y0;     % 初始化找到的最佳的解对应的函数值为y0
best_x =x0;
MAXY = zeros(maxgen,1); % 记录每一次外层循环结束后找到的max_y (方便画图）
MAXX = zeros(maxgen,narvs);
%% 模拟退火过程
for iter = 1 : maxgen  % 外循环, 我这里采用的是指定最大迭代次数
    for i = 1 : Lk  % 内循环，在每个温度下开始迭代
        B = randperm(narvs,10*resSize);
        C = zeros(1,narvs);
        y = randn(1,10*resSize); % 正态分布
%         y = -1+2*rand(1,10*resSize);  % 均匀分布
        z = y/sqrt(sum(y.^2));
        C(B) = z;
        x_new = x0 + C*sqrt(T);

        % 如果这个新解的位置超出了定义域，就对其进行调整
        LB = find(x_new<x_lb);
        UB = find(x_new>x_ub);
        if size(LB,1)~=0
            r = rand(1,size(LB,1));
            x_new(LB) = r*x_lb+(1-r)*x0(LB);
        elseif size(UB,1)~= 0
            r = rand(1,size(UB,1));
            x_new(UB) = r*x_ub+ (1-r)*x0(UB);
        end

        x1 = x_new;    % 将调整后的x_new赋值给新解x1
        y1 = SA_RC_F(x1,data);   % 计算新解的预测步长
        if y1 > y0    % 如果新解函数值大于当前解的函数值
            x0 = x1; % 更新当前解为新解
            y0 = y1;
        else
            p = exp(-abs(y1 - y0)/T); % 根据Metropolis准则计算一个概率
            if rand(1) < p   % 生成一个随机数和这个概率比较，如果该随机数小于这个概率
                x0 = x1;  % 更新当前解为新解
                y0 = y1;
            end
        end
        % 判断是否要更新找到的最佳的解
        if y0 > max_y  % 如果当前解更好，则对其进行更新
            max_y = y0;  % 更新最大的y
            best_x = x0;  % 更新找到的最好的x
        end 

    end
    MAXY(iter) = max_y; % 保存本轮外循环结束后找到的最大的y
    T = alfa*T;   % 温度下降
    MAXX(iter,:) = best_x;

    if iter>50
        if MAXY(iter) - MAXY(iter-49)==0
            break
        end
    end
end
MAXY(all(MAXY==0,2),:)=[];   %去除全部是0的行 
MAXX(all(MAXX==0,2),:)=[];   %去除全部是0的行 
MAXY=MAXY*0.01*0.906; % 转换成李雅普诺夫时间
figure
fig=plot(MAXY,'b*');
xlabel('迭代次数');
ylabel('\Lambda_{max}t');

% 查看结果
A=MAXX(end,:);
A1 = SA_RC_F1(A);
