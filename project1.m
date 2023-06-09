
clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2022';
f = fred
KR = fetch(f,'NGDPRSAXDCKRQ',startdate,enddate)
JP = fetch(f,'JPNRGDPEXP',startdate,enddate)
y = log(KR.Data(:,2));
c = log(JP.Data(:,2));
q = KR.Data(:,1);

T = size(y,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauKRGDP = A\y;
tauJPGDP = A\c;

% detrended GDP
krtilde = y-tauKRGDP;
jptilde = c-tauJPGDP;

% plot detrended GDP
dates = 1994:1/4:2022.1/4; 
% zerovec = zeros(size(y));
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, krtilde,'b', q, jptilde,'r')
datetick('x', 'yyyy-qq')
legend('Korea','Japan','Location','northeast')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
krsd = std(krtilde)*100;
jpsd = std(jptilde)*100;
corryc = corrcoef(krtilde(1:T),jptilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for Korea: ', num2str(krsd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(jpsd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP for Korea and log real GDP for Japan: ', num2str(corryc),'.']);



