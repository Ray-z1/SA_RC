% 稀疏度的检验，逐步置零，即调整系数度查看预测范围
clc
clear
H=0;
obj=[];
spar=[];
for epoch = 1:1:50

    tau = 0;

    resSize = 100; 
    obj2=[];
    spar2=[];
    for i=-5:0.05:-2
        % L1正则化
        Wresnm = ['Data\L1\' num2str(epoch) '_'  'Wres.mat'];
        load(Wresnm)
        Winnm = ['Data\L1\' num2str(epoch) '_'  'Win.mat'];
        load(Winnm)
        
%         Wresnm = ['Data\Size80_20_200\' num2str(epoch) '_' num2str(resSize) '_' num2str(tau) 'Wres.mat'];
%         load(Wresnm)
%         Winnm = ['Data\Size80_20_200\' num2str(epoch) '_' num2str(resSize) '_' num2str(tau) 'Win.mat'];
%         load(Winnm)

        A=find(abs(Wres)<10^i);
        Wres(A)=0;

        obj1=Sparsity_F(Win,Wres);    
        obj2=[obj2,obj1];
        
        B = find(Wres==0);
        spar1 = 1-size(B,1)/10000;
        spar2=[spar2,spar1];
    end
    obj=[obj;obj2];
    spar=[spar;spar2];
end
Average = mean(obj,1);
Variance = std(obj,1);
subplot(2,1,1)
errorbar(-5:0.05:-2,Average,Variance,'-ob')
xlabel('logX')
ylabel('\Lambda_{x}t')
subplot(2,1,2)
Average1 = mean(spar,1);
Variance1 = std(spar,1);
errorbar(-5:0.05:-2,Average1,Variance1,'-ob')
xlabel('logX')
ylabel('矩阵W_{r}的稀疏度')
