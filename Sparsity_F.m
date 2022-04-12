function obj=Sparsity_F(Win,Wres)
resSize=100;
tau=0;
inSize = 3;

% Win = x0(1:inSize*resSize);
% Wres = x0(inSize*resSize+1:end);
% Win = reshape(Win,resSize,inSize);
% Wres = reshape(Wres,resSize,resSize);

y0 = [-7.0731,-2.7263,30.5163];
[t,y] = ode45('lorenz_diff',[0.01:0.01:300],y0);
data = y';

% Data =data;
%对数据进行标准化，均值为0方差为1
[Data, ps] = mapstd(data);


dt = 0.01;
initialen = 100/dt;
trainlen = 100/dt;
len = initialen + trainlen;
testlen = 1500;
% testlen = 600;
r = zeros(resSize, 1);


% training period
for i = 1:len
    ut = Data(:,i);
    r = tau*r + (1-tau)*(tanh( Win*ut + Wres*r) );
    rtotal(:,i) = r;
end   

rtotal = rtotal(:,initialen:len-1);
rtrain = rtotal; 

% 去除对称性影响
for i = resSize/2+1 : resSize
    rtrain(i,:) = rtotal(i,:).^2;
end
    
traindata = Data(:,initialen+1:len);    
beta = 1e-5;
Wout = ((rtrain*rtrain' + beta*eye(resSize)) \ (rtrain*traindata'))';


% testing period
trainoutput = Wout*rtrain; 

vv = trainoutput(:,trainlen);
testoutput = [];
for i = 1:testlen
    ut =vv;
    internal(:,i) = Win*ut + Wres*r;
    r = tau*r + (1-tau)*(tanh( Win*ut + Wres*r) );
    rtest(:,i) = r;   
    r2 = r;
    % 去除对称性影响 
    for j = resSize/2+1 : resSize
        r2(j) = r2(j).^2;
    end
    vv = Wout * r2;
    testoutput = [testoutput vv];
end

testdata = Data(:,len+1:len+testlen);

% 计算预测步长
error = abs(testdata-testoutput);
a = find(error(1,:)>0.2,1,'first');
b = find(error(2,:)>0.2,1,'first');
c = find(error(3,:)>0.2,1,'first');
if isempty(a)==1
    a=testlen;
end
if isempty(b)==1
    b=testlen;
end
if isempty(c)==1
    c=testlen;
end
S = min([a,b,c]);
obj = S*0.01*0.906;

% t=(1:1:testlen)*0.01*0.906;

% figure
% subplot(3,1,1)
% plot(t(1:1:testlen),testdata(1,1:testlen),'b');
% hold on
% plot(t(1:1:testlen),testoutput(1,1:testlen),'r');
% xlabel(' t');
% ylabel(' x(t)');
% % title('testdata tx');
% legend('Actual','Predicted')
% axis([0 9 -inf inf])
% 
% subplot(3,1,2)
% plot(t(1:1:testlen),testdata(2,1:testlen),'b');
% hold on
% plot(t(1:1:testlen),testoutput(2,1:testlen),'r');
% xlabel(' t');
% ylabel(' y(t)');
% % title('testdata ty');
% axis([0 9 -inf inf])
% 
% subplot(3,1,3)
% plot(t(1:1:testlen),testdata(3,1:testlen),'b');
% hold on
% plot(t(1:1:testlen),testoutput(3,1:testlen),'r');
% xlabel(' t');
% ylabel(' z(t)');
% % title('testdata tz');
% axis([0 9 -inf inf])

% 计算MSE误差
% error = testdata-testoutput;
% error2 = zeros(1,testlen);
% for i = 1 : testlen
%     error2(i) = norm(error(:,i),2).^2;
% end
% 
% e1 = sum(error2)/testlen;
% err = e1;
% obj = err;
% obj = err + 1*10^-3*sum(sum(abs(Wres)));

% fignm = ['E:\Reservoir Computing\An experimental unification of reservoir computing methods\10\' num2str(resSize) '.jpg'];
% saveas(gca,fignm)

% close all

% Winnm = ['E:\Reservoir Computing\An experimental unification of reservoir computing methods\10\',num2str(resSize),'Win.mat'];
% Wresnm = ['E:\Reservoir Computing\An experimental unification of reservoir computing methods\10\',num2str(resSize),'Wres.mat'];
% Woutnm = ['E:\Reservoir Computing\An experimental unification of reservoir computing methods\10\',num2str(resSize),'Wout.mat'];
% % 
% save(Winnm,'Win');
% save(Wresnm,'Wres');
% save(Woutnm,'Wout');

end

