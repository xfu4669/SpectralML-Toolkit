function setWavelengthAxis(ax,wavelength)
% Explicit bounds prevent automatic axes from extending 350 nm data down to 0.
wavelength=double(wavelength(:)); lo=min(wavelength); hi=max(wavelength);
assert(isfinite(lo) && isfinite(hi) && hi>lo,'SpectralML:Plot','Invalid wavelength range.');
xlim(ax,[lo hi]);
rough=(hi-lo)/5; base=10^floor(log10(rough)); choices=[1 2 2.5 5 10]*base;
[~,at]=min(abs(choices-rough)); step=choices(at);
ticks=(ceil(lo/step)*step):step:(floor(hi/step)*step);
% Keep actual endpoints visible and remove nearby interior ticks.
ticks=ticks(ticks-lo>=0.3*step & hi-ticks>=0.3*step);
xticks(ax,unique([lo,ticks,hi])); xtickformat(ax,'%.6g'); ax.XAxis.Exponent=0;
end
