% Algorithm 7.5 (L-BFGS)
function [x1, f1, k, metrics] = LBFGS(fnHandle, Xo, maxIterations, m, tolerance)
	% Some starting point X₀ and integer m > 0 are passed to L-BFGS function
	if m <= 0
		beep
		disp(['Alert! m=' num2str(m) ' was passed to LBFGS(); expecting m > 0'])
	end
	metrics = struct; % Struct for storing algorithm metrics
	arr_alpha = []; arr_k = []; arr_y = [];
	%fprintf('%5s %12s %14s\n', 'k', 'αₖ', 'f(xₖ)');

	tStart = cputime;
	k = 0; n = length(Xo); a_i = 1;
	Sk = zeros(n, m); Yk = zeros(n, m);
	
	[f0, g0] = feval(fnHandle, Xo);
	[alpha, f1, g1] = LineSearch(fnHandle, Xo, -g0, f0, g0, a_i); % line search
	arr_k = [arr_k, k+1]; arr_alpha = [arr_alpha, alpha]; arr_y = [arr_y, f1];
	
	x1 = Xo - alpha * g0;
	
	while k <= maxIterations
		k = k + 1;
		fnorm = norm(g0, "fro");
		if fnorm < tolerance % convergence
			break;
		end
		
		s0 = x1 - Xo; y0 = g1 - g0;
		hDiag = (s0'*y0) / (y0'*y0);
		p = zeros(length(g0),1);

		if k > m
			% Discard the vector pair {sₖ₋ₘ, yₖ₋ₘ} from storage
			Sk(:,1:(m-1)) = Sk(:,2:m);
			Yk(:,1:(m-1)) = Yk(:,2:m);
			Sk(:,m) = s0;
			Yk(:,m) = y0;
			p = -two_loop_recursion(g1, Sk, Yk, hDiag);
		else
			Sk(:,k) = s0;
			Yk(:,k) = y0;
			p = -two_loop_recursion(g1,Sk(:,1:k),Yk(:,1:k),hDiag); 
		end
		% Compute & save sₖ←xₖ₊₁, yₖ=∇fₖ₊₁-∇fₖ;
		
		% line search
		[alpha,fs, gs]= LineSearch(fnHandle, x1, p, f1, g1, a_i);
		Xo = x1; g0 = g1;
		x1 = x1 + alpha * p;
		f1 = fs; g1 = gs;

		%fprintf('%5d %15.4f %15.4e\n', k, alpha, f1);
		arr_k = [arr_k, k+1]; arr_alpha = [arr_alpha, alpha]; arr_y = [arr_y, f1];
	end
	k = k-1;
	metrics.runtime = cputime - tStart; % cputime to better compare algos
	metrics.k = arr_k;
	metrics.alpha_k = arr_alpha;
	metrics.f_xk = arr_y;
end

% Algorithm 7.4 (L-BFGS two-loop recursion)
function r = two_loop_recursion(g, S, Y, hDiag)
    [n, k] = size(S);
	ro = zeros(1, k);
    for i = 1:k
        ro(i,1) = 1 / (Y(:,i)' * S(:,i));
    end

    alpha = zeros(k, 1); q = zeros(n, k+1); q(:, k+1) = g;
    for i = k:-1:1 % loop 1
        alpha(i) = ro(i) * S(:,i)' * q(:,i+1);
        q(:,i) = q(:,i+1) - alpha(i) * Y(:,i);
    end

	beta = zeros(k, 1); r = zeros(n, 1); r = hDiag * q(:,1);
    for i = 1:k % loop 2
        beta(i) = ro(i) * Y(:,i)' * r;
        r = r + S(:,i) * (alpha(i) - beta(i));
	end
end