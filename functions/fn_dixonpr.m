function [f, df, ddf] = fn_dixonpr(x)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DIXON-PRICE FUNCTION
%
% Authors: Sonja Surjanovic, Simon Fraser University
%          Derek Bingham, Simon Fraser University
% Questions/Comments: Please email Derek Bingham at dbingham@stat.sfu.ca.
%
% Copyright 2013. Derek Bingham, Simon Fraser University.
%
% THERE IS NO WARRANTY, EXPRESS OR IMPLIED. WE DO NOT ASSUME ANY LIABILITY
% FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
% derivative works, such modified software should be clearly marked.
% Additionally, this program is free software; you can redistribute it 
% and/or modify it under the terms of the GNU General Public License as 
% published by the Free Software Foundation; version 2.0 of the License. 
% Accordingly, this program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
% General Public License for more details.
%
% For function details and reference information, see:
% http://www.sfu.ca/~ssurjano/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
% xx = [x1, x2, ..., xd]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = x(1);
d = length(x);
if (d > 1)
	x2 = x(2);
end
term1 = (x1-1)^2;

sum = 0;
for ii = 2:d
	xi = x(ii);
	xold = x(ii-1);
	new = ii * (2*xi^2 - xold)^2;
	sum = sum + new;
end

f = term1 + sum;

% f2 = 3*x1^2 - 2*x1 + 8*x2^4 - 8*x1*x2^2 + 1

% Matthew Hellinger supplemented to support minimization algorithms that
% require gradient (and hessian); added df and ddf
displayGradHess = false;
if (displayGradHess)
	maxSymbolSupport = 2; % e.g.: x1 & x2
	vector = repmat(sym(0),[maxSymbolSupport,1]);
	for i=1:maxSymbolSupport
		symbolicVar = (['x' num2str(i)]);
		vector(i) = sym(symbolicVar);
	end
	symbolic_fn = str2sym('3*x1^2 - 2*x1 + 8*x2^4 - 8*x1*x2^2 + 1')
	gradient_fn = gradient(symbolic_fn, vector)
	hessian_fn = hessian(symbolic_fn, vector)
end

if nargout > 1
	df = [- 8*x2^2 + 6*x1 - 2; 32*x2^3 - 16*x1*x2];
	if nargout > 2
		ddf = [6, -16*x2; -16*x2, 96*x2^2 - 16*x1];
	end
end

end
