% main.m
% 22.10.2020
% 1.2 OFDM now can handle a number of symbols greater than 1 - Vlad 
% 1.3 Implemented dynamic cyclic prefix and pilot tone insertion - Vlad
% 1.4 ...

subcarrier_spacings = [15 30 60 120 240];
cp_lengths_us_normal = [4.69 2.34 1.17 0.57 0.29]; % length of cp in microseconds for each numerology

parameters.number_subcarriers = 90;
parameters.subcarrier_spacing = 30000; %  subcarrier spacing Hz
parameters.number_symbols = 10;
%Possible values: 128 512 1024 2048
parameters.fft_size = 2^ceil(log2(parameters.number_subcarriers));
parameters.cyclicPrefix_us=3.2*1e-6;;
parameters.pilot_frequency = 5 + 5*1i;
parameters.pilot_tones = 6;
%Possible values: 'QPSK','16QAM','64QAM'
constellation = '16QAM';

sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
sampling_period= sampling_frequency^-1;
parameters.cyclicPrefix_us=cp_lengths_us_normal(find(subcarrier_spacings==parameters.subcarrier_spacing/1000))*1e-6;;


%create frequency domain vector
frequencyDomain_symbols = zeros(parameters.number_subcarriers, parameters.number_symbols);
%get available qam symbols
qam_alphabet = QAM_mapping(constellation);
%get a number of random indexes from qam_alphabet 
random_index=ceil(length(qam_alphabet) * rand(size(frequencyDomain_symbols)));
%get randomn constellation symbols
frequencyDomain_symbols = qam_alphabet(random_index);
pilot_interval = round(parameters.number_subcarriers/parameters.pilot_tones)-mod(parameters.number_subcarriers,parameters.pilot_tones);
pilot_interval_index=[1:pilot_interval:parameters.number_subcarriers];
frequencyDomain_symbols(pilot_interval_index(1:end),:)=parameters.pilot_frequency;
out = OFDM_tx(parameters,frequencyDomain_symbols);
out = out + 0.021 * randn(size(out));

rx_constellations = OFDM_rx(parameters,out);
tx_wihout_pilot = frequencyDomain_symbols;
tx_wihout_pilot(pilot_interval_index(1:end),:) = [];
tx_constellations = reshape(tx_wihout_pilot,[],1);;


% Error
error = rx_constellations - tx_constellations;

% L^2 norm for error between rx and tx
norm_error = norm(error);
if norm_error/length(error) < 0.03
    disp('tx data = rx data');
else
    disp('tx data != rx data');
end

t=1:1:length(out);
t = t * sampling_period;

figure
plot(t,real(out))
grid on
title('Time domain data')
xlabel('Time (s)')
ylabel('Amplitude')

figure
plot(rx_constellations, 'o', 'color','blue')
hold on
plot(tx_constellations, 'o', 'color','red')
title('TX/RX constellations')