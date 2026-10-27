function [Z,state] = preprocessSpectrum(X,w,method,p,state)
% Empty state fits on training rows; a supplied state only transforms.
if nargin<5, state=[]; end
if isempty(state)
    state=struct('method',method,'params',p,'wavelength',w(:)');
    if strcmp(method,'MSC')
        switch p.reference
            case 'mean', state.reference=mean(X,1);
            case 'median', state.reference=median(X,1);
            otherwise, error('SpectralML:MSC','MSC reference must be mean or median.');
        end
    end
    if strcmp(method,'MinMax') && strcmp(p.mode,'band')
        state.minimum=min(X,[],1); state.span=max(X,[],1)-state.minimum;
        state.span(state.span==0)=1;
    elseif strcmp(method,'ZScore') && strcmp(p.mode,'band')
        state.mean=mean(X,1); state.scale=std(X,0,1); state.scale(state.scale<eps)=1;
    elseif strcmp(method,'FOD')
        state.definition='Caputo L1 on actual wavelength intervals; order 0: identity; order 1: local first derivative';
    end
end
assert(isequal(w(:)',state.wavelength), 'SpectralML:Wavelength','Wavelengths do not match the fitted preprocessor.');
switch state.method
    case 'Raw', Z=X;
    case 'SG', Z=sgSmooth(X,w,state.params.window,state.params.order);
    case 'SNV', Z=snvTransform(X);
    case 'MSC', Z=mscTransform(X,state.reference);
    case 'FD', Z=derivativeSpectrum(X,w,1,state.params);
    case 'SD', Z=derivativeSpectrum(X,w,2,state.params);
    case 'FOD', Z=fractionalDerivative(X,w,state.params.alpha);
    case 'Detrend', Z=detrendSpectrum(X,w,state.params.order);
    case 'MinMax'
        if strcmp(state.params.mode,'band')
            minimum=state.minimum; span=state.span;
        else
            minimum=min(X,[],2); span=max(X,[],2)-minimum; span(span==0)=1;
        end
        Z=state.params.lower+(X-minimum)./span*(state.params.upper-state.params.lower);
    case 'ZScore'
        if strcmp(state.params.mode,'band')
            Z=(X-state.mean)./state.scale;
        else
            scale=std(X,0,2); scale(scale<eps)=1; Z=(X-mean(X,2))./scale;
        end
    otherwise, error('SpectralML:Preprocessing','Unsupported preprocessing: %s',state.method);
end
assert(all(isfinite(Z(:))), 'SpectralML:Preprocessing','Preprocessing produced nonfinite values.');
end
