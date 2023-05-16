%% Numerical Optimization Springer 2nd Ed.
%{
Quick port from 6.2. Extra credit: program the SR1 algorithm
to supplement Final project; removed reliance on globals, abstracted
objective function reference, and updated to integrage with Convex
Optimization Suite. More clean-up could definitely be performed.
%}

function [Xp, Fobj, k, metrics] = QuasiNewton(fnHandle, method, strong_wolfe, x0, maxIterations, m, tolerance)
	x1 = x0; f1 = 1; k = 1;
	a_max = 1; rho = 0.5; c = 0.5; %initialize

	% currently available method options are:
	% SR1: Quasi-Newton Search w/ SR1 & Strong Wolfe
	% BFGS: Quasi-Newton Search w/ BFGS & Strong Wolfe
	% should be reasonably easy to extend to support other quasi-Newton
	% methods
	[Xp, Fobj, a, i, metrics] = btMin(fnHandle, strong_wolfe, x0, method, a_max, rho, c);
	k = i;
end

% Backtracking line search
function [x, Fobj, a, i, metrics] = btMin(fnHandle, strong_wolfe, x0, type, a_max, rho, c)
	%global error;
	error = false;
	B = eye(2,2); % start with Identity matrix

	i = 1;
	i_max = 1e4;
	tol = 1e-6;
	Fobj = zeros(i_max, 1);
	a = a_max * ones(i_max, 1);
	a(1) = 0;
	
	x = x0;
	x_prev = x0;
	p = 0;
	%Fobj(i) = rbFn(x);
	[f_x, grad_x] = feval(fnHandle, x);
	Fobj(i) = f_x;
	metrics = struct;
	metrics.runtime = 999;
	arr_alpha = []; arr_k = []; arr_y = []; tStart = cputime;
	if strcmp(type, 'Newton') || strcmp(type, 'Steepest Descent')
		% for methods that use Hessian
		%while norm(rbGrad(x)) > tol && i < i_max
		while norm(grad_x) > tol & i < i_max
			arr_k = [arr_k, i]; 
  			i = i + 1;
  			p = stepDir(x, type);
  			[a(i), Fobj(i)] = stepLen(fnHandle, strong_wolfe, x, p, a(i), rho, c);
  			x = x + a(i) * p;
			[~, grad_x] = feval(fnHandle, x);
		end
	elseif strcmp(type, 'FR') % Conjugate Gradient methods
		while norm(grad_x) > tol && i < i_max
			arr_k = [arr_k, i]; 
  			i = i + 1;
			B_FR = ApproxHess(fnHandle, x, x_prev, 'FR');
			if error
				disp(['Error detected at iteration ' num2str(i)])
			end
			if (p == 0) % first time thru we don't have previous p
				[~, grad_x_prev] = feval(fnHandle, x_prev);
				p = - grad_x_prev + B_FR * B
			end
			p_prev = p;
			[~, grad_x] = feval(fnHandle, x);
			p = - grad_x + B_FR * p_prev
			%p = p / norm(p);
			[a(i), Fobj(i)] = stepLen(fnHandle, strong_wolfe, x, p, a(i), rho, c);
			x_prev = x;
  			x = x + a(i) * p;
			[~, grad_x] = feval(fnHandle, x);
		end
	else
		% for methods that use approximated Hessian
		done = false;
		while ~done
			arr_k = [arr_k, i]; 
			%while norm(rbGrad(x)) > tol && i < i_max
			[~, grad_x] = feval(fnHandle, x);
			if (norm(grad_x) > tol && i < i_max)
  				i = i + 1;
  				[B, p] = stepDirQuasi(fnHandle, x, x_prev, B, type);
  				[a(i), Fobj(i)] = stepLen(fnHandle, strong_wolfe, x, p, a(i), rho, c);
				x_prev = x;
  				x = x + a(i) * p;
			else
				done = true;
			end
		end
	end
	metrics.runtime = cputime - tStart; % cputime to better compare algos
	Fobj = Fobj(1:i);
	a = a(1:i);
	%arr_alpha = a; arr_y = Fobj;
	metrics.k = arr_k;
	metrics.alpha_k = a';
	metrics.f_xk = Fobj';

end

function [B, Bk] = ApproxHess(fnHandle, B, x, x_prev, method)
	%global error;
	error = false;

	if x == x_prev		% for the first step, just return identity
		Bk = eye(2,2);	% matrix as initial Hessian approximation, since
		return			% delta x will be a zero vector
	end

	s_k = x - x_prev;
	[~, grad_x] = feval(fnHandle, x);
	[~, grad_x_prev] = feval(fnHandle, x_prev);	
	%y_k = rbGrad(x) - rbGrad(x_prev);
	y_k = grad_x - grad_x_prev;

	% verify that yₖᵀSₖ is always positive
	value = y_k'*s_k;
	if value < 0
		error = true;
		disp(['Alert! yₖᵀSₖ in ApproxHess(' method ') is negative: ' num2str(value)])
	elseif isinf(value)
		error = true;
		disp(['Alert! yₖᵀSₖ in ApproxHess(' method ') blew up to infinity'])
	elseif isnan(value)
		error = true;
		disp(['Alert! yₖᵀSₖ in ApproxHess(' method ') is undefined (NaN)'])
	else
		error = false;
	end

	if strcmp(method, 'BFGS')
		%              BₖsₖsₖᵀBₖ      yₖyₖᵀ
		% Bₖ₊₁ = Bₖ -  --------- +  ------  (from p.24)
		%               sₖᵀBₖsₖ      yₖᵀsₖ
		B = B - (B*s_k*s_k'*B)/(s_k'*B*s_k) + (y_k*y_k')/(y_k'*s_k);
	elseif strcmp(method, 'SR1')
		%              (yₖ-Bₖsₖ)(yₖ-Bₖsₖ)ᵀ
		% Bₖ₊₁ = Bₖ +  -----------------  (from p.24)
		%                (yₖ-Bₖsₖ)ᵀsₖ
		B = B + ((y_k-B*s_k)*(y_k-B*s_k)')/((y_k-B*s_k)'*s_k);
	elseif strcmp(method, 'FR') % Fletcher-Reeves Method
		%            ∇fᵀₖ₊₁∇fₖ₊₁
		% Bᶠʳₖ₊₁ =  ------------  (from p.121)
		%             ∇fₖᵀ∇fₖ
		%B = (rbGrad(x)'*rbGrad(x))/(rbGrad(x_prev)'*rbGrad(x_prev));
		B = (grad_x'*grad_x)/(grad_x_prev'*grad_x_prev);
	else
		disp(['Oops! Called ApproxHess() with unknown method: ' method])
	end

	Bk = B;
end

% Determine unit search direction
function [B, p] = stepDirQuasi(fnHandle, x_k, x_prev, B, type)
	if strcmp(type, 'BFGS')
		[~, grad_x_k] = feval(fnHandle, x_k);
		[B, HessApprox] = ApproxHess(fnHandle, B, x_k, x_prev, 'BFGS');
		p = - HessApprox^(-1) * grad_x_k;
	elseif strcmp(type, 'SR1')
		[~, grad_x_k] = feval(fnHandle, x_k);
		[B, HessApprox] = ApproxHess(fnHandle, B, x_k, x_prev, 'SR1');
		p = - HessApprox^(-1) * grad_x_k;
	else
		% default to Newton (should pick something w/o hessian)
		[~, grad_x_k, hess_x_k] = feval(fnHandle, x_k);
		p = - hess_x_k^(-1) * grad_x_k;
	end
	p = p / norm(p);
end
function p = stepDir(x_k, type)
	if strcmp(type, 'Newton')
		p = - rbHess(x_k)^(-1) * rbGrad(x_k);
	else
		p = - rbGrad(x_k);
	end
	p = p / norm(p);
end

function [a, f_x_k] = stepLen(fnHandle, strong_wolfe, x_k, p_k, a_max, rho, c)
	%strong_wolfe = true;
	a = a_max;
	[f_x_k, grad_x_k] = feval(fnHandle, x_k);
	[f_x_k_plus_step, grad_x_k_plus_step] = feval(fnHandle, x_k + a * p_k);
	if ~strong_wolfe
		% 1st Wolfe condition
		while (f_x_k_plus_step > f_x_k + c * a * grad_x_k' * p_k)
			a = rho * a;
			[f_x_k_plus_step] = feval(fnHandle, x_k + a * p_k);
			[f_x_k, grad_x_k] = feval(fnHandle, x_k);
		end
	else
		% Strong Wolfe conditions
		% c1 ∈ [0,1]; as per text, c1 = 10e-4 (p. 33) is recommended
		% c2 ∈ [0,1]; as per text, c2 = 0.9 is recommended for (Quasi-)Newton;
		c1 = 10e-4; c2 = 0.9;
		while (f_x_k_plus_step > f_x_k + c1 * a * grad_x_k' * p_k) && (abs(p_k'*grad_x_k_plus_step) > c2 * abs(p_k'*grad_x_k))
			a = rho * a;
			[f_x_k, grad_x_k] = feval(fnHandle, x_k);
			[f_x_k_plus_step, grad_x_k_plus_step] = feval(fnHandle, x_k + a * p_k);
		end
	end
end

function displayOld(Xp, Fobj, a, i, type, x0)
	% Plot results
	figure;
	subplot(2, 1, 1);
	if strcmp(type, 'Newton')
		color = 'b';
	elseif strcmp(type, 'BFGS') || strcmp(type, 'SR1') || strcmp(type, 'FR')
		color = 'g';
	else
		color = 'r';
	end
	semilogy(1:i, Fobj, color);
	grid on
	title(['Rosenbrock fn (min) w/ ', type])
	xlabel('Iterations');
	ylabel('f(x)');
	subplot(2, 1, 2);
	semilogy(1:i, a, color)
	grid on
	title(['x₀ = ', mat2str(x0', 3) 'ᵀ', ', x* = ', mat2str(Xp', 3) 'ᵀ']);
	xlabel('Iterations');
	ylabel('α');
end


%function f_x = rbFn(x)
%	f_x = 100*(x(2) - x(1)^2)^2 + (1 - x(1))^2;
%end

%function g_x = rbGrad(x)
%	g_x = [2 * x(1) - 400 * x(1) * (- x(1).^2 + x(2)) - 2; 200 * (x(2) - x(1).^2)];
%end

%function h_x = rbHess(x)
%	h_x = [2 + 1200 * x(1).^2 - 400 * x(2), (-400)*x(1); (-400) * x(1), 200];
%end
