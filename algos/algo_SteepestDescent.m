%{
3.1 Program the steepest descent algorithms using the backtracking line 
 search, Algorithm 3.1. Use it to minimize the objective function. Set the
 initial step length α₀=1 and print the step length used at each iteration.
%}
function [x, Fobj, k, metrics] = SteepestDescent(fnHandle, x0, maxIterations, m, tolerance)
	a_max = 1; rho = 0.5; c = 0.5; %initialize
	i = 1;
	i_max = 1e6;
	tol = 1e-6;
	Fobj = zeros(i_max, 1);
	a = a_max * ones(i_max, 1);
	a(1) = 1;
	max_iterations = 1000;
	
	x = x0;
	% [Fobj(i)] = feval(fnHandle, x0);
	[Fobj(i), grad_x] = feval(fnHandle, x0);
	done = false;
	%fprintf('%5s %12s %14s\n', 'k', 'αₖ', 'f(xₖ)');
	metrics = struct; % Struct for storing algorithm metrics
	arr_alpha = []; arr_k = []; arr_y = [];

	tStart = cputime;
	while ~done & i < max_iterations
		p = - grad_x; p = p / norm(p); % Calc step dir (steepest descent)
  		[a(i), Fobj(i)] = stepLen(fnHandle, x, p, a(i), rho, c);
		arr_k = [arr_k, i]; arr_alpha = [arr_alpha, a(i)]; arr_y = [arr_y, Fobj(i)];
  		x = x + a(i) * p;
		[~, grad_x] = feval(fnHandle, x);
 		%fprintf('%5d %15.8f %15.4e\n', i, a(i), Fobj(i));

		if norm(grad_x) < tol | i >= i_max
			done = true;
			break;
		end
 		i = i + 1;
	end
	Fobj = Fobj(1:i);
	a = a(1:i);
	k = i;
	%tStart
	%cputime
	%cputime - tStart
	metrics.runtime = cputime - tStart; % cputime to better compare algos
	metrics.k = arr_k;
	metrics.alpha_k = arr_alpha;
	metrics.f_xk = arr_y;
end

% Use 1st Wolfe condition to get step length
function [a, f_x_k] = stepLen(fnHandle, x_k, p_k, a_max, rho, c)
	a = a_max;
	[f_x_k, grad_x_k] = feval(fnHandle, x_k);
	done = false;
	i = 0;
	max_iterations = 100;
	while ~done & i <= max_iterations
		[fn] = feval(fnHandle, x_k + a * p_k);
		if (fn <= f_x_k + c * a * grad_x_k' * p_k)
			done = true;
		else
			a = rho * a;
		end
		i = i + 1;
	end
end

% Display results with pretty graphics
function display2(Xp, Fobj, a, i, x0)
	figure;
	subplot(2, 1, 1);
	color = 'b';
	plot(1:i, Fobj, color);
	title(['Objective fn (min) w/ Steepest Descent)'])
	xlabel('Iterations');
	ylabel('f(x)');
	subplot(2, 1, 2);
	plot(1:i, a, color)
	title(['x₀ = ', mat2str(x0', 3) 'ᵀ', ', x* = ', mat2str(Xp', 3) 'ᵀ']);
	xlabel('Iterations');
	ylabel('α');
end