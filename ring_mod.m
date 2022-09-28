% Yash Shah
% 2078614

% Full Code Reference: 
% Marshall, D., Digital Audio Effects. 
% Available at: https://users.cs.cf.ac.uk/Dave.Marshall/CM0268/PDF/10_CM0268_Audio_FX.pdf 
%[Accessed April 2, 2022]. 

function ringy = ring_mod(x, Fs)

index = 1:length(x);
% Ring Modulate with a sine wave frequency Fc
Fc = 440;
carrier = sin(2*pi*index*(Fc/Fs))'; 

% Do Ring Modulation
ringy = x.*carrier;

clearvars -except ringy
