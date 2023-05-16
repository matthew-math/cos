function [f, df, ddf] = fn_rosenbrock(x);
% MATLAB code by: Carl Edward Rasmussen (7/21/2001)
% https://transp-or.epfl.ch/books/optimization/html/octaveDoxygen/chap11_2ex_rosenbrock_8m.html
% Note: this is the more general Rosenbrock function for n dimensions.
% If n=2, we have f(x)=100(x_2 - x_1^2)^2 + (1-x_1)^2. 
% D is the dimension of x
% The minimum is 0 at x=[1 1 ... 1]ᵀ
D = length(x);
f = sum(100*(x(2:D)-x(1:D-1).^2).^2 + (1-x(1:D-1)).^2);

if nargout > 1
	df = zeros(D, 1);
	df(1:D-1) = - 400*x(1:D-1).*(x(2:D)-x(1:D-1).^2) - 2*(1-x(1:D-1));
	df(2:D) = df(2:D) + 200*(x(2:D)-x(1:D-1).^2);

	if nargout > 2
		ddf = zeros(D,D);
		ddf(1:D-1,1:D-1) = diag(-400*x(2:D) + 1200*x(1:D-1).^2 + 2);
		ddf(2:D,2:D) = ddf(2:D,2:D) + 200*eye(D-1);
		ddf = ddf - diag(400*x(1:D-1),1) - diag(400*x(1:D-1),-1);
	end
end
