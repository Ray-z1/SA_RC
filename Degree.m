clc
clear

% L1稀疏化后，查看度分布
clc
clear

for epoch = 1:1:49
    degree=[];
    tau = 0;

    resSize = 100; 
    i=-3.5;
    
    Wresnm = ['Data\L1\' num2str(epoch) '_'  'Wres.mat'];
    load(Wresnm)
    Winnm = ['Data\L1\' num2str(epoch) '_'  'Win.mat'];
    load(Winnm)

    A=find(abs(Wres)<10^i);
    Wres(A)=0;
        
    for j=1:1:100
        Wres1=Wres(j,:);
        B = find(Wres1~=0);
        degree1 = numel(B);
        degree = [degree,degree1];
    end
    
    subplot(7,7,49)
    subplot(7,7,epoch)
    histogram(degree)   
  
end
