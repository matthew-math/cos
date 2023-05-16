function [f, df, ddf] = fn_camel6(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SIX-HUMP CAMEL FUNCTION
%
% Authors: Sonja Surjanovic, Simon Fraser University
%          Derek Bingham, Simon Fraser University
% Questions/Comments: Please email Derek Bingham at dbingham@stat.sfu.ca.
%
% Copyright 2013. Derek Bingha m, Simon Fraser University.
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
% https://www.sfu.ca/~ssurjano/camel6.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS:
%
% xx = [x1, x2]
% The function is usually evaluated on the rectangle x1 ∈ [-3, 3], x2 ∈ [-2, 2].
% The function has six local minima, two of which are global.
% Global min: min: ₓ⋆ = [0.0898 -0.7126]ᵀ,  [-0.0898 0.7126]ᵀ f(ₓ⋆) = -1.0316
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = xx(1);
x2 = xx(2);

term1 = (4-2.1*x1^2+(x1^4)/3) * x1^2;
term2 = x1*x2;
term3 = (-4+4*x2^2) * x2^2;

f = term1 + term2 + term3;

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
	symbolic_fn = str2sym('(4-2.1*x1^2+(x1^4)/3) * x1^2 + x1*x2 + (-4+4*x2^2) * x2^2');
	gradient_fn = gradient(symbolic_fn, vector)
	hessian_fn = hessian(symbolic_fn, vector)
end

if nargout > 1
	df = [x2 - x1^2*(4.2*x1 - (4*x1^3)/3) + 2*x1*(x1^4/3 - 2.1*x1^2 + 4); x1 + 2*x2*(4*x2^2 - 4) + 8*x2^3];
	if nargout > 2
		ddf = [x1^2*(4*x1^2 - 4.2) - 4*x1*(4.2*x1 - (4*x1^3)/3) - 4.2*x1^2 + (2*x1^4)/3 + 8, 1.0; 1, 48*x2^2 - 8];
	end
end

end
