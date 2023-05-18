function [minimizer, Fobj, iterations, metrics] = Fletcher_Reeves(fnHandle, x0, maxIterations, a, tolerance, Fobj)
    xk = x0;
	[fk, Gradfk] = feval(fnHandle, xk);
    pk = -Gradfk;
	alpha_i = 1;
    k = 0;
	Fobj(k+1) = fk;
	a(k+1) = alpha_i;
	a = [];
	metrics = struct; % Struct for storing algorithm metrics
	arr_alpha = []; arr_k = []; arr_y = [];

	tStart = cputime;
    while (k < maxIterations) && (norm(Gradfk, Inf) > tolerance*(1 + abs(fk)))
		arr_k = [arr_k, k+1]; arr_alpha = [arr_alpha, alpha_i]; arr_y = [arr_y, fk];
		% Setting initial choice for α (p. 59 in text)
        if k > 0
            alpha_i = (alphak*Gradfkminus1'*pkminus1)/(Gradfk'*pk);
        end

        % Line search and calculating next iterate
        alphak = LineSearch(fnHandle, xk, pk, alpha_i);
		a(k+2) = alphak;
        xk1 = xk + alphak*pk;

		[fk, Gradfk1] = feval(fnHandle, xk1);

        % Restart strategy
        if (k > 0) && ((abs(Gradfk'*Gradfkminus1)/(norm(Gradfk)).^2 >= 0.1))
            betak1 = 0;
        else
            betak1 = (Gradfk1'*Gradfk1)/(Gradfk'*Gradfk);
        end

        pk1 = -Gradfk1 + betak1*pk;
    
        % Updating for next iteration and saving previous values for
        % restart strategy and choice of alpha_i
        k = k + 1;
        xk = xk1;
		%fk = feval(fnHandle, xk);
 		Fobj(k+1) = fk;
        Gradfkminus1 = Gradfk;
        Gradfk = Gradfk1;
        pkminus1 = pk;
        pk = pk1;

    end

    iterations = k;
	minimizer = xk;
	metrics.runtime = cputime - tStart; % cputime to better compare algos
	metrics.k = arr_k;
	metrics.alpha_k = arr_alpha;
	metrics.f_xk = arr_y;
	%[a, Fobj] = trimHistory(a, Fobj, k+1);
end


% ---------------- Line Search Algorithm (using Zoom) ------------------% 
% ----------------(satisfying strong Wolfe conditions)------------------%
function alpha_star = LineSearch(fnHandle, x, pk, alpha_i)
    c1 = 1e-4;
    c2 = 0.1;
    alpha_iminus1 = 0;
    i = 1;

    while (i <= 10)
		[phi_alpha_i, phi_prime_alpha_i] = feval(fnHandle, (x+alpha_i*pk));
		phi_prime_alpha_i = phi_prime_alpha_i' * pk;

		[phi_0, phi_prime_0] = feval(fnHandle, x); % technically x+0*pk;
		phi_prime_0 = phi_prime_0'*pk;

        if phi_alpha_i > (phi_0 + c1*alpha_i*phi_prime_0)
            alpha_star = Zoom(fnHandle, alpha_iminus1, alpha_i, x, pk, c1, c2);
            return
		else
			[phi_alpha_iminus1] = feval(fnHandle, (x+alpha_iminus1*pk));
			if phi_alpha_i >= phi_alpha_iminus1 && i > 1
				alpha_star = Zoom(fnHandle, alpha_iminus1, alpha_i, x, pk, c1, c2);
				return
			end
        end

        if abs(phi_prime_alpha_i) <= -c2*phi_prime_0
            alpha_star = alpha_i;
            return
        end

        if phi_prime_alpha_i >= 0
            alpha_star = Zoom(fnHandle, alpha_i, alpha_iminus1, x, pk, c1, c2);
            return
        end

        alpha_i = 5*alpha_i;
        i = i + 1;

    end

    disp("ERROR: Appropriate step length not found after 10 iterations")

end


% ------------------------- Zoom Algorithm -----------------------------% 
function alpha_star = Zoom(fnHandle, alpha_lo, alpha_hi, x, pk, c1, c2)

	max_iterations = 100;
	i = 0;
	prev_alpha_j = 100;
    %while abs(alpha_hi - alpha_lo) > eps
	while i<max_iterations
        % Using bisection method for simplicity
        alpha_j = (alpha_hi + alpha_lo)/2;

		% Matthew: check whether alpha_j goes from decreasing to increasing
		if alpha_j >= prev_alpha_j
			alpha_star = alpha_j;
			return
		end

		[phi_alpha_j, phi_prime_alpha_j] = feval(fnHandle, (x+alpha_j*pk));
		phi_prime_alpha_j = phi_prime_alpha_j'*pk;
		[phi_0, phi_prime_0] = feval(fnHandle, x); % technically x+0*pk;
		phi_prime_0 = phi_prime_0'*pk;
		phi_alpha_lo = feval(fnHandle, (x+alpha_lo*pk));

        if ((phi_alpha_j > phi_0 + c1*alpha_j*phi_prime_0) || ...
                (phi_alpha_j >= phi_alpha_lo))
            alpha_hi = alpha_j;
        else
            if abs(phi_prime_alpha_j) <= -c2*phi_prime_0
                alpha_star = alpha_j;
                return
            end
            if phi_prime_alpha_j*(alpha_hi - alpha_lo) >= 0
                alpha_hi = alpha_lo;
            end
            alpha_lo = alpha_j;
		end
		prev_alpha_j = alpha_j;
		i = i + 1;
    end
	alpha_star = alpha_j;
    disp(['ERROR: Zoom did not converge after ' num2str(i) ' iterations'])    
end
