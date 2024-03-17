function [topt, stimulus] = masker_probe_signal(f_args)
%MASKER_PROBE_SIGNAL
arguments
    f_args.masker_frequency = 0
    f_args.probe_frequency = 0
    f_args.thr = 0
    f_args.masker_duration (1,1) Time = Time(100, 'ms')
    f_args.probe_duration (1,1) Time = Time(15, 'ms')
    f_args.masker_ampl_re_thr (1,1) double = 30
    f_args.probe_ampl_re_thr (1,1) double = 20
    f_args.delay (1,1) Time = Time(0, 'ms')
    f_args.t_onset (1,1) Time = Time(1, 'ms')
    f_args.t_offset (1,1) Time = Time(1, 'ms')
    f_args.zeroDuration (1,1) Time = Time(100, 'ms');

end

[args, opt, memopt, paropt] = common_opts(struct(), ...
    do_not_change_settings=true, ...
    silent=true);

args.strict_signal_length = true;


if isinf(f_args.delay) || isnan(f_args.masker_duration)
    no_masker = true;
    % f_args.delay = Time(0, 'ms');
    f_args.masker_duration = Time(100, 'ms');
    f_args.delay = Time(100, 'ms');
else
    no_masker = false;
end


fadeDuration = Time(200, 'ms');

if f_args.delay + Time(50, 'ms') > fadeDuration
    fadeDuration = f_args.delay + Time(50, 'ms');
end


if no_masker
    dbprintf('no masker because delay is se to inf\n')
else
    [masker_topt, masker_signal] = devopts.stimulus( ...
        args.GlobalSamplingFrequency, ...
        f_args.masker_duration, ...
        'strict_signal_length', args.strict_signal_length, ...
        't0', Time(0, 'ms'), ...
        'onset', f_args.t_onset, ...
        'offset', f_args.t_offset, ...
        'zeroDuration', f_args.zeroDuration, ...
        'fadeDuration', fadeDuration, ...
        'amplitude_unit', 'spl', ...
        'amplitude', f_args.thr + f_args.masker_ampl_re_thr, ...
        'frequency', f_args.masker_frequency);
end

[probe_topt, probe_signal] = devopts.stimulus( ...
    args.GlobalSamplingFrequency, ...
    f_args.probe_duration, ...
    'strict_signal_length', args.strict_signal_length, ...
    't0', Time(0, 'ms'), ...
    'onset', f_args.t_onset, ...
    'offset', f_args.t_offset, ...
    'zeroDuration', ...
        f_args.zeroDuration + f_args.masker_duration + f_args.delay + f_args.t_onset + f_args.t_offset, ...
    'fadeDuration', fadeDuration - f_args.delay - f_args.probe_duration -  f_args.t_onset - f_args.t_offset, ...
    'amplitude_unit', 'spl', ...
    'amplitude', f_args.thr + f_args.probe_ampl_re_thr, ...
    'frequency', f_args.probe_frequency);

if no_masker
    stimulus = probe_signal;
    topt = probe_topt;
else
    stimulus = CompoundSignal([masker_signal, probe_signal]);
    topt = masker_topt;
end

end
