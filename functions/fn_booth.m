function [f, df, ddf] = fn_booth(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BOOTH FUNCTION
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
% xx = [x1, x2]
% Global min: ₓ⋆ = [1 3]ᵀ f(ₓ⋆) = 0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = xx(1);
x2 = xx(2);

term1 = (x1 + 2*x2 - 7)^2;
term2 = (2*x1 + x2 - 5)^2;

f = term1 + term2;

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
	symbolic_fn = str2sym('(x1 + 2*x2 - 7)^2 + (2*x1 + x2 - 5)^2');
	gradient_fn = gradient(symbolic_fn, vector)
	hessian_fn = hessian(symbolic_fn, vector)
end

if nargout > 1
	df = [10*x1 + 8*x2 - 34; 8*x1 + 10*x2 - 38];
	if nargout > 2
		ddf = [10, 8; 8, 10];
	end
end

end
