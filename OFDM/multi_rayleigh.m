function [y, ChFrqRep] = multi_rayleigh( SerOverGIOfdmSym, Nifftop )
% @Return：Signal After Passing through multi-ralyeigh channel  
% @Para：SerOverGIOfdmSym —— Oversampling

% @@@@@@@@ Parameters @@@@@@@@
PowerdB     = [0 -8 -17 -21 -25];   % Channel Tap power distribution(dB)
Delay       = [0 3 5 6 8];          % Deelay sample
Power       = 10.^(PowerdB / 10);   % Channel tap power distribution (linear
Ntap        = length(PowerdB);      % Number of channel taps
Lch         = Delay(end) + 1;       % Channel length

% @@@@@@@@ channel @@@@@@@@
channel     = (randn(1, Ntap) + 1i * randn(1, Ntap)).*sqrt(Power / 2);
h           = zeros(1, Lch); 
h(Delay+1)  = channel;              % channel impluse response
y           = conv(SerOverGIOfdmSym, h);

% Channel Frequency rsponse
OfdmSymIndx     = 1 : Nifftop;
H               = fft([h zeros(1, Nifftop - Lch)]); 
ChFrqRep        = H(OfdmSymIndx);
end