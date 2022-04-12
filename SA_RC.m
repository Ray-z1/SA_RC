% ����200�Σ���������50�ν���ޱ仯����ֹͣ����
clc
clear
Z_BC = 0;

% ������ʼ��
resSize=100;
inSize = 3;
narvs = inSize*resSize + resSize* resSize;
T0 = 1;   % ��ʼ�¶�
T = T0; % �������¶Ȼᷢ���ı䣬��һ�ε���ʱ�¶Ⱦ���T0
maxgen = 200;  % ����������
Lk = 100;  % ÿ���¶��µĵ�������
alfa = 0.95;  % �¶�˥��ϵ��
x_lb = -0.8 ; % x���½�
x_ub = 0.8 ; % x���Ͻ�



% ������ʼ��
arhow_r =0.67;
k = 5;


% ��ֵWin������
Win1  =-1+2*rand(resSize,inSize);   % ���ȷֲ�
% Win1 = normrnd(0,rhow_in^2,[resSize inSize])  % ��̬�ֲ�
adj1 = zeros(resSize,inSize); 
A1 = rand(resSize,inSize);
B1 = find(A1<0.44);
adj1(B1)=1;
Win = adj1.*Win1;


%��ֵWres������
adj2 = zeros(resSize,resSize);
for i = 1:resSize
    num = randperm(resSize,k);
    for j = 1:k
        adj2(i,num(j)) = 1;
    end
end
Wres1 = normrnd(0,1,[resSize resSize]); %������̬�ֲ������
Wres2 = adj2.*Wres1 ;
SR = max(abs(eig(Wres2))) ;
Wres = Wres2 .* ( arhow_r/SR);   

% ode45���Lorenzϵͳ
y0 = [-7.0731,-2.7263,30.5163];
[t,y] = ode45('lorenz_diff',[0.01:0.01:300],y0);
data = y';

x0 = [reshape(Win,1,[]),reshape(Wres,1,[])];
y0 = SA_RC_F(x0,data);   % ��ǰ��Ԥ�ⲽ��

% %% ����һЩ�����м���̵����������������ͻ�ͼ
max_y = y0;     % ��ʼ���ҵ�����ѵĽ��Ӧ�ĺ���ֵΪy0
best_x =x0;
MAXY = zeros(maxgen,1); % ��¼ÿһ�����ѭ���������ҵ���max_y (���㻭ͼ��
MAXX = zeros(maxgen,narvs);
%% ģ���˻����
for iter = 1 : maxgen  % ��ѭ��, ��������õ���ָ������������
    for i = 1 : Lk  % ��ѭ������ÿ���¶��¿�ʼ����
        B = randperm(narvs,10*resSize);
        C = zeros(1,narvs);
        y = randn(1,10*resSize); % ��̬�ֲ�
%         y = -1+2*rand(1,10*resSize);  % ���ȷֲ�
        z = y/sqrt(sum(y.^2));
        C(B) = z;
        x_new = x0 + C*sqrt(T);

        % �������½��λ�ó����˶����򣬾Ͷ�����е���
        LB = find(x_new<x_lb);
        UB = find(x_new>x_ub);
        if size(LB,1)~=0
            r = rand(1,size(LB,1));
            x_new(LB) = r*x_lb+(1-r)*x0(LB);
        elseif size(UB,1)~= 0
            r = rand(1,size(UB,1));
            x_new(UB) = r*x_ub+ (1-r)*x0(UB);
        end

        x1 = x_new;    % ���������x_new��ֵ���½�x1
        y1 = SA_RC_F(x1,data);   % �����½��Ԥ�ⲽ��
        if y1 > y0    % ����½⺯��ֵ���ڵ�ǰ��ĺ���ֵ
            x0 = x1; % ���µ�ǰ��Ϊ�½�
            y0 = y1;
        else
            p = exp(-abs(y1 - y0)/T); % ����Metropolis׼�����һ������
            if rand(1) < p   % ����һ���������������ʱȽϣ�����������С���������
                x0 = x1;  % ���µ�ǰ��Ϊ�½�
                y0 = y1;
            end
        end
        % �ж��Ƿ�Ҫ�����ҵ�����ѵĽ�
        if y0 > max_y  % �����ǰ����ã��������и���
            max_y = y0;  % ��������y
            best_x = x0;  % �����ҵ�����õ�x
        end 

    end
    MAXY(iter) = max_y; % ���汾����ѭ���������ҵ�������y
    T = alfa*T;   % �¶��½�
    MAXX(iter,:) = best_x;

    if iter>50
        if MAXY(iter) - MAXY(iter-49)==0
            break
        end
    end
end
MAXY(all(MAXY==0,2),:)=[];   %ȥ��ȫ����0���� 
MAXX(all(MAXX==0,2),:)=[];   %ȥ��ȫ����0���� 
MAXY=MAXY*0.01*0.906; % ת����������ŵ��ʱ��
figure
fig=plot(MAXY,'b*');
xlabel('��������');
ylabel('\Lambda_{max}t');

% �鿴���
A=MAXX(end,:);
A1 = SA_RC_F1(A);
