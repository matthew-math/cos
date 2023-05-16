function [f, df, ddf] = fn_zakharov(x)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ZAKHAROV FUNCTION
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
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
% xx = [x1, x2, ..., xd]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d = length(x);
sum1 = 0;
sum2 = 0;

for ii = 1:d
	xi = x(ii);
	sum1 = sum1 + xi^2;
	sum2 = sum2 + 0.5*ii*xi;
end

if d == 2
	f = 1.25*x(1)^2 + 2*x(2)^2 + x(1)*x(2) + 0.0625*x(1)^4 + ...
		0.5*x(1)^3*x(2) + 1.5*x(1)^2*x(2)^2 + 2*x(1)*x(2)^3 + x(2)^4;
else
	f = sum1 + sum2^2 + sum2^4;
end

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
	symbolic_fn = str2sym('1.25*x1^2 + 2*x2^2 + x1*x2 + 0.0625*x1^4 + 0.5*x1^3*x2 + 1.5*x1^2*x2^2 + 2*x1*x2^3 + x2^4')
	gradient_fn = gradient(symbolic_fn, vector)
	hessian_fn = hessian(symbolic_fn, vector)
end

% Added Gradient & Hessian for d=2
df = [0.25*x(1)^3 + 1.5*x(1)^2*x(2) + 3.0*x(1)*x(2)^2 + 2.5*x(1) + 2*x(2)^3 + x(2);
     0.5*x(1)^3 + 3.0*x(1)^2*x(2) + 6*x(1)*x(2)^2 + x(1) + 4*x(2)^3 + 4*x(2)];
ddf = [0.75*x(1)^2 + 3.0*x(1)*x(2) + 3.0*x(2)^2 + 2.5, 1.5*x(1)^2 + 6.0*x(1)*x(2) + 6*x(2)^2 + 1.0;
     1.5*x(1)^2 + 6.0*x(1)*x(2) + 6*x(2)^2 + 1, 3.0*x(1)^2 + 12*x(1)*x(2) + 12*x(2)^2 + 4.0];
end
