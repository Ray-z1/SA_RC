% 查看谱半径、奇异值
clc
clear
RHO = [];
SIGMA = [];
for epoch = 1:1:50
        Rho = [];
        Sigma = [];
        D_norm =[]; 
        tau = 0;
        
        resSize = 100
           
        Wresnm = ['Data\组合\4正态_正态\' num2str(epoch) '_' num2str(resSize) '_' num2str(tau) 'Wres.mat'];
        load(Wresnm)         
        
        rho1 = max(abs(eig(Wres)));
        sigma1 = max(svd(Wres));
        

        RHO = [RHO;rho1];
        SIGMA = [SIGMA;sigma1];
end
rho = mean(RHO);
sigma = mean(SIGMA);
% d_norm = mean(D_NORM);
% norm = mean(NORM);
subplot(2,1,1)
plot(1:1:50,SIGMA,'x');
hold on
plot([0,50],[sigma,sigma],'k');
title('奇异值')
subplot(2,1,2)
plot(1:1:50,RHO,'x');
hold on
plot([0,50],[rho,rho],'k');
title('谱半径')


