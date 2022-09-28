% Yash Shah
% 2078614

% Full Code Reference: 
% Marshall, D., Digital Audio Effects. 
% Available at: https://users.cs.cf.ac.uk/Dave.Marshall/CM0268/PDF/10_CM0268_Audio_FX.pdf 
%[Accessed April 2, 2022]. 


function wahy = wah_wah(x, Fs)

% --------- EFFECT COEFFICIENTS --------- %

% lower the damping factor the smaller the pass band
damp = 0.05;

% min and max centre cutoff frequency of variable bandpass filter
minf = 500;
maxf = 8000;

% wah frequency, how many Hz per second are cycled through
Fw = 4000; 

% change in centre frequency per sample (Hz)
% delta = 0.1;
delta = Fw/Fs;
%0.1 => at 44100 samples per second should mean  4.41kHz Fc shift per sec

% create triangle wave of centre frequency values
Fc = minf:delta:maxf;
while(length(Fc) < length(x) )
    Fc= [ Fc (maxf:-delta:minf) ];
    Fc= [ Fc (minf:delta:maxf) ];
end

% trim tri wave to size of input
Fc = Fc(1:length(x));

% difference equation coefficients
% must be recalculated each time Fc changes
F1 = 2*sin((pi*Fc(1))/Fs);
% this dictates size of the pass bands
Q1 = 2*damp;                

yh=zeros(size(x));          % create empty out vectors
yb=zeros(size(x));
yl=zeros(size(x));

% first sample, to avoid referencing of negative signals
yh(1) = x(1);
yb(1) = F1*yh(1);
yl(1) = F1*yb(1);

% apply difference equation to the sample
for n=2:length(x)
    
    yh(n) = x(n) - yl(n-1) - Q1*yb(n-1);
    yb(n) = F1*yh(n) + yb(n-1);
    yl(n) = F1*yb(n) + yl(n-1);
     
    F1 = 2*sin((pi*Fc(n))/Fs);
end

%normalise
maxyb = max(abs(yb));
yb = yb/maxyb;

wahy = yb;

clearvars -except wahy