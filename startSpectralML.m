function varargout = startSpectralML
%STARTSPECTRALML Launch the app; optionally return its handle.
root = fileparts(mfilename('fullpath'));
addpath(genpath(root));
app = SpectralML;
if nargout>0, varargout{1}=app; end
end
