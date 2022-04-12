function dydt = lorenz_diff(t,y)
dydt = [-10*(y(1)-y(2));
        y(1)*(28-y(3))-y(2);
        y(1)*y(2)-y(3)*8/3;];