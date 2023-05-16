function [f, df, ddf] = fn_test(x)
% 
% Custom Objective Function
% created by Matthew on 07-May-2023 14:17:15
f = (x(2) - 2)^2 + (x(1) + 4)^2 + 3;
if nargout > 1
	df = [2*x(1) + 8; 2*x(2) - 4];
if nargout > 2
	ddf = [2, 0; 0, 2];
end
end
 
end
