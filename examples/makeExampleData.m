function path = makeExampleData(outputFolder)
% Optional MATLAB generator, explicitly synthetic data (not experimental measurements).
if nargin<1, outputFolder=fileparts(mfilename('fullpath')); end
saved=rng; cleanup=onCleanup(@()rng(saved)); rng(42,'twister'); %#ok<NASGU>
n=80; wavelength=400:20:1600; a=rand(n,1); b=rand(n,1);
X=0.35+0.08*a.*exp(-((wavelength-700)/90).^2)+0.06*b.*exp(-((wavelength-1150)/130).^2) ...
    +0.03*sin(wavelength/200)+0.002*randn(n,numel(wavelength));
y=20+12*a+6*b+0.3*randn(n,1);
ID=compose('S%03d',(1:n)'); t=[table(ID,y,'VariableNames',{'ID','SOM'}),array2table(X,'VariableNames',cellstr(string(wavelength)))];
path=fullfile(outputFolder,'example_spectra_regenerated.csv'); writetable(t,path);
writetable(t,fullfile(outputFolder,'example_spectra_regenerated.xlsx'));
end
