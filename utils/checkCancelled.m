function checkCancelled(callback)
if nargin==0 || isempty(callback), return; end
drawnow limitrate;
if callback(), error('SpectralML:Cancelled','Run cancelled by the user.'); end
end
