function [f, df, ddf] = fn_mccorm(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MCCORMICK FUNCTION
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
% The function is usually evaluated on the rectangle x1 ∈ [-1.5, 4], x2 ∈ [-3, 4].
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = xx(1);
x2 = xx(2);

term1 = sin(x1 + x2);
term2 = (x1 - x2)^2;
term3 = -1.5*x1;
term4 = 2.5*x2;

f = term1 + term2 + term3 + term4 + 1;

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
	symbolic_fn = str2sym('sin(x1 + x2) + (x1 - x2)^2 + -1.5*x1 + 2.5*x2 + 1');
	gradient_fn = gradient(symbolic_fn, vector)
	hessian_fn = hessian(symbolic_fn, vector)
end

df = [2*x1 - 2*x2 + cos(x1 + x2) - 1.5; 2*x2 - 2*x1 + cos(x1 + x2) + 2.5];
ddf = [2.0 - sin(x1 + x2), - sin(x1 + x2) - 2.0; - sin(x1 + x2) - 2.0, 2.0 - sin(x1 + x2)];

end
