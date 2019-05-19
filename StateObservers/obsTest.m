% Aaron Kandel
% Batt Temp Estimation:


clear
clc
close all

%% Define Params:

% From Kim et al. "The Estimation of Temperature Distribution in
% Cylindrical Cells under Unknown Cooling Conditions"
rho = 2047;
cp = 1148.1;
kth = 0.698;
h = 5;
R = 12.93e-3;
L = 65.15e-3;
Vb = 3.4219e-5;
a = kth/(rho*cp);

A = [(-48*a*h)/(R*(24*kth+R*h)), (-15*a*h)/(24*kth+R*h);
    (-320*a*h)/(R^2*(24*kth+R*h)), (-120*a*(4*kth+R*h))/(R^2*(24*kth+R*h))];
B = [(a/(kth*Vb)),(48*a*h)/(R*(24*kth+R*h));
    0, (320*a*h)/(R^2*(24*kth+R*h))];
C = [(24*kth-3*R*h)/(24*kth+R*h),-(120*R*kth+15*R^2*h)/(8*(24*kth+R*h));
    24*kth/(24*kth+R*h), 15*R*kth/(48*kth+2*R*h)];
D = [0,(4*R*h)/(24*kth+R*h);
    0, R*h/(24*kth+R*h)];

dt = 0.01;

P = [-1;-2];

L2 = place(A,C,P);

soc = 0:0.001:1;%VOC_data(:,1);
voc = 2.3 + soc;%VOC_data(:,2);

%% Random Acceleration data:
tmax = 500;
t = 0:0.01:tmax;
tc = 0:50:tmax;
Ic = 2 + 3*rand(1,length(tc));
Ic2 = interp1(tc,Ic,t);
[b,a] = butter(1,0.0003);
I = -filter(b,a,Ic2);
Tinf = (20)*ones(1,length(t));

x = zeros(2,length(t)+1);
x(:,1) = [Tinf(1);0.5];
xr = zeros(2,length(t)+1);
xr(:,1) = [0;Tinf(1)];
xhat = zeros(2,length(t)+1);
xhat(:,1) = [0;Tinf(1)];
Q = zeros(1,length(t));
Qh = zeros(1,length(t));

SOC = zeros(1,length(t)+1);
vrc = zeros(1,length(t)+1);
soch = zeros(1,length(t)+1);
R1 = 0.01;
R2 = 0.01;
C1 = 2500;

SOC(1) = 0.75;
soch(1) = 0.5;
QBatt = 3600*2.3;
xbr = [SOC;vrc];
xbh = [soch;vrc];




Aa = [1, 0;
      0, (1-(dt/(R1*C1)))];
Ba = [dt/QBatt; dt/C1];
aa = [0,0;0,-(1/(R1*C1))];
ba = [1/QBatt;1/C1];
ca = [1.2,1];
P2 = [-1;-2];

L = acker(Aa,ca',[-0.75,-0.45]);

Lc = acker(aa,ca',[-0.1,-0.05]);
B2 = [ba,Lc'];
sys = ss((aa),ba,ca,0);
sysO = ss((aa-Lc'*ca),B2,ca,0);

[y,t,x] = lsim(sys,I,t,xbr(:,1));
[y2,t2,x2] = lsim(sysO,[I',y],t,xbh(:,1));

sys2 = ss(A,B,C,D);
B2x = [B,L2];
D2x = [B,zeros(2)];
sys2O = ss((A-L2*C),B2x,C,D2x);
vocr = x(:,1) + 2.3;
Vsim = (ca*x' + 2.3)';
Q = I'.*(vocr-Vsim);
voch = x2(:,1) + 2.3;
vsimh = (ca*x2' + 2.3)';
Qh = I'.*(voch-vsimh);
xhat(:,1) = [28;0];
xh2 = [20;0];
[yx,tx,xx] = lsim(sys2,[Q,Tinf'],t,xhat(:,1));
[y2x,t2x,x2x] = lsim(sys2O,[Qh,Tinf',yx],t,xh2);



%% Plot Data:

figure(1)
subplot(1,3,1)
hold on
plot(t,x(1:end,1),'LineWidth',2)
plot(t2,x2(1:end,1),'--r','LineWidth',2)
ylim([0,1])
xlim([0,tmax])
grid on
xlabel('Time [s]')
ylabel('State of Charge [-]')
legend('Actual','Estimated')
subplot(1,3,2)
plot(t,I)%(t,yx(1,1:end-1));%,t,Yest(1,:))
grid on
xlim([0,tmax])
xlabel('Time [s]')
ylabel('Input Current Drive Cycle [A]')
subplot(1,3,3)
hold on
% plot(t,yx(:,1),t,yx(:,2),'LineWidth',2)
% plot(t,y2x(:,1),t,y2x(:,2),'--r','LineWidth',2)
plot(t,yx(:,1),'LineWidth',2)
plot(t,y2x(:,1),'--r','LineWidth',2)
grid on
xlim([0,tmax])
xlabel('Time [s]')
ylabel('Center Temperature [C]')
% legend('Actual Center','Actual Surface','Estimated Center','Estimated Surface')
legend('Actual','Estimated')% Center','Estimated Surface')

%% Save data:
M = [t,yx(:,1),y2x(:,1)];
csvwrite('datafill',M)
