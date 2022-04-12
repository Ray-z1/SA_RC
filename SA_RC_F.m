function obj=SA_RC_F(x0,data)
% ����ģ���˻�������½����Ԥ�ⲽ��
tau=0;
resSize=100;
inSize = 3;

Win = x0(1:inSize*resSize);
Wres = x0(inSize*resSize+1:end);
Win = reshape(Win,resSize,inSize);
Wres = reshape(Wres,resSize,resSize);


%�����ݽ��б�׼������ֵΪ0����Ϊ1
[Data, ps] = mapstd(data);


dt = 0.01;
initialen = 100/dt;
trainlen = 100/dt;
len = initialen + trainlen;
testlen = 1500;
r = zeros(resSize, 1);


% training period
for i = 1:len
    ut = Data(:,i);
    r = tau*r + (1-tau)*(tanh( Win*ut + Wres*r) );
    rtotal(:,i) = r;
end   

rtotal = rtotal(:,initialen:len-1);
rtrain = rtotal; 

% ȥ���Գ���Ӱ��
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
    % ȥ���Գ���Ӱ�� 
    for j = resSize/2+1 : resSize
        r2(j) = r2(j).^2;
    end
    vv = Wout * r2;
    testoutput = [testoutput vv];
end

testdata = Data(:,len+1:len+testlen);


% ����Ԥ�ⲽ��
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
obj = S;
% obj = S - 2.5* sum(sum(abs(Wres)));  % L1�Ż�
end

