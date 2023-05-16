function [f, df, ddf] = fn_camel3(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% THREE-HUMP CAMEL FUNCTION
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
% INPUTS:
%
% xx = [x1, x2]
% The function is usually evaluated on the square xᵢ ∈ [-5, 5], for all i = 1, 2.
% The function has three local minima.
% Global min: ₓ⋆ = [0 0]ᵀ f(ₓ⋆) = 0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = xx(1);
x2 = xx(2);

term1 = 2*x1^2;
term2 = -1.05*x1^4;
term3 = x1^6 / 6;
term4 = x1*x2;
term5 = x2^2;

f = term1 + term2 + term3 + term4 + term5;
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
	symbolic_fn = str2sym('2*x1^2 + -1.05*x1^4 + x1^6 / 6 + x1*x2 + x2^2');
	gradient_fn = gradient(symbolic_fn, vector)
	hessian_fn = hessian(symbolic_fn, vector)
end

if nargout > 1
	df = [x1^5 - 4.2*x1^3 + 4*x1 + x2; x1 + 2*x2];
	if nargout > 2
		ddf = [5*x1^4 - 12.6*x1^2 + 4, 1.0; 1, 2];
	end
end

end
