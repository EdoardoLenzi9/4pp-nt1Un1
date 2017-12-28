y=0.3142*(1:100);

u1=atan(y);
u2=1.5243-(y./(1+y.^2));

plot(y,u1);
hold on;
plot(y,u2);


