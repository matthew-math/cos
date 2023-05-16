%% Algorithm 3.5 (Line Search Algorithm) from text p.60
function [step_size, fn_s, grad_s] = LineSearch(fnHandle, Xo, Pk, fn_x0, grad_x0, a_i)
	loopExit = 1e2; a_max = 20; a_iminus1 = 0; c1 = 1e-4; c2 = 0.9;
	grad_x0 = grad_x0' * Pk; phi__a_i_prev = fn_x0; phiPrime__a_i_prev = grad_x0; i=1;
	interpolation_method = false; % false = constant multiple (p.61)
	scalar = 4; % this should probably be user-defined as well
	
    phi = @(a) fn(Xo + a*Pk); phiPrime = @(a) grad_fn(Xo + a*Pk)' * Pk;
	c1 = 1e-4; c2 = 0.9;

	% Line search algorithm satisfying strong Wolfe conditions
    while i < loopExit
		% Evaluate φ(αᵢ)
		phi__a_i = Xo + a_i * Pk;
		[phi__a_i, phiPrime__a_i] = feval(fnHandle, phi__a_i);
		fn_s = phi__a_i; grad_s = phiPrime__a_i; phiPrime__a_i = phiPrime__a_i' * Pk;
		if (phi__a_i > fn_x0 + c1 * a_i * grad_x0) || ((i > 1) & (phi__a_i >= phi__a_i_prev))
			[step_size, fn_s, grad_s, i] = zoom(fnHandle, Xo, Pk, a_iminus1, a_i, fn_x0, grad_x0, c1, c2);
			return;
		end
		if abs(phiPrime__a_i) <= -c2 * grad_x0
			step_size = a_i;
			return;
		end
		if phiPrime__a_i >= 0
			[step_size, fn_s, grad_s, i] = zoom(fnHandle, Xo, Pk, a_i, a_iminus1, fn_x0, grad_x0, c1, c2);
			return;
		end
		
		a_iminus1 = a_i; phi__a_i_prev = phi__a_i; phiPrime__a_i_prev = phiPrime__a_i;
		
		if interpolation_method
			r = rand; a_i = (a_i + a_max) * r; % αᵢ₊₁ ∈ (αᵢ, αₘₐₓ)
		else
			a_i = scalar * a_i;
		end
		if a_i > a_max
			a_i = a_max;
		end
	
		i = i+1;
	end

	step_size = a_i;
	if i >= loopExit
		beep
		disp(['Alert! LineSearch() algorithm exited prematurely after ' ...
			num2str(i) ' iterations'])
	end
end