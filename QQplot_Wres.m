% 检验Wres是否为正态分布
clc
clear
R=[];
G=[];
for epoch = 1:1:50

    tau = 0;

    resSize = 100;
    
    Wresnm = ['Data\组合\4正态_正态\' num2str(epoch) '_' num2str(resSize) '_' num2str(tau) 'Wres.mat'];
    load(Wresnm)      
    Wres1= reshape(Wres,1,[]);
    data = Wres1;
    data=mapstd(data);
    
    h=qqplot(data);
   
    yData=h(1).YData;
    xData=h(1).XData;
    

    x=xData;
    y=yData;
    q1x = prctile(x,25);
    q3x = prctile(x,75);
    q1y = prctile(y,25);
    q3y = prctile(y,75);
    qx = [q1x; q3x];
    qy = [q1y; q3y];


    dx = q3x - q1x;
    dy = double(q3y - q1y);
    slope = dy./dx;
    centerx = (q1x + q3x)/2;
    centery = double(q1y + q3y)/2;
    maxx = max(x);
    minx = min(x);
    maxy = centery + slope.*(maxx - centerx);
    miny = centery - slope.*(centerx - minx);

    mx = [minx; maxx];
    my = [miny; maxy];
    figure
    line(mx,my,'LineStyle','-.','Marker','none');
    line(qx,qy,'LineStyle','-','Marker','none');
    line(xData,yData,'LineStyle','none','Marker','+','Color','blue');
    xlabel('Standard Normal Quantiles')
    ylabel('Quantiles of W\_res')
%     title('QQ plot of Sample Data versus Standard Normal')
    
    k=(qy(2)-qy(1))/(qx(2)-qx(1));
    b=qy(1)-k*qx(1);
    b1=0.3;
    
    X=mx(1):0.1:mx(2);
    y1=k*X+b+b1;
    y2=k*X+b-b1;
    hold on
    plot(X,k*X+b+b1,'r')
    hold on 
    plot(X,k*X+b-b1,'r')

%     计算多少个值在两条平行线之内
%     y1=k*xData+b+b1;
%     y2=k*xData+b-b1;
    A =k.*xData+b+b1-yData;
    B =yData-(k.*xData+b-b1);
    
    A1 =A >=0;
    B1 = B>=0;
    C = A1-B1;
    C1=find(C==0);
    g = numel(C1)/numel(xData);
    G=[G,g];
    
    close all


end
size(find(G>0.8),2)
[bincounts]=histc(G,0.1:0.1:1)
bar(0.1:0.1:1,bincounts,'histc')
axis([0.1 1 -inf inf])