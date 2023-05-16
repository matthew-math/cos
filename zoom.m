% Algorithm 3.6 (zoom) from text p.61 (Strong Wolfe Conditions)
% The order of input arguments is such that each call has the form:
% zoom(αₗₒ, αₕᵢ) [author has added additional fields for broader
% application], where:
% a. the interval bounded by αₗₒ, αₕᵢ contains step lengths safisfying
%    Strong Wolfe conditions;
% b. αₗₒ is, among all step lengths generated so far and satisfying the
%    sufficient decrease condition, the one giving the smallest fn value;
% c. αₗₒ is chosen so that φ'(αₗₒ)(αₕᵢ - αₗₒ) < 0.
% Each iteration of zoom generates an iterate αⱼ between αₗₒ and αₕᵢ, and
% then replaces one of these endpoints by αⱼ in such a way that the
function [a, fn_s, grad_s, i] = zoom(fnHandle, x0, Pk, a_lo, a_hi, fx0, gx0, c1, c2)
	loopExit = 1e6; % to assure no infinite loop
	% For Strong Wolfe conditions:
	% c1 ∈ [0,1]; as per text, c1 = 10e-4 (p. 33) is recommended
	% c2 ∈ [0,1]; as per text, c2 = 0.9 is recommended for (Quasi-)Newton;
	if (c1 >= c2) || (c1 <= 0) || (c2 >= 1)
		c1 = 10e-4; c2 = 0.9;
		beep
		disp(['Alert! zoom() algorithm with ' method ' method ' ...
			'adjusted initial c1 & c2 values to ' num2str(c1) ...
			' and ' num2str(c2)])
	end

	% Each iteration generates an iterate αⱼ between αₗₒ and αₕᵢ, and then
	% replaces one of these endpoints by αⱼ in such a way that the
	% properties (a), (b), and (c) [above] continue to hold.
	i=0;
    while i < loopExit
		i = i + 1;
		% Interpolate (using quadratic, cubic, or bisection) to find a
		% trial step length αⱼ between αₗₒ and αₕᵢ
		a_j = (a_hi + a_lo)/2; % bisection (easy)

		a = a_j;
		phi__a_j = x0 + a_j*Pk;
		[phi__a_i, phiPrime__a_i] = feval(fnHandle,phi__a_j);
		fn_s = phi__a_i;
		grad_s = phiPrime__a_i;
		phiPrime__a_i = phiPrime__a_i'*Pk;
		xl = x0 + a_lo*Pk;
		fxl = feval(fnHandle,xl);
		if ((phi__a_i > fx0 + c1*a_j*gx0) || (phi__a_i >= fxl))
			a_hi = a_j;
		else
			if abs(phiPrime__a_i) <= -c2*gx0
				a = a_j;
			return;
		end
		if phiPrime__a_i*(a_hi-a_lo) >= 0
			a_hi = a_lo;
		end
		a_lo = a_j;
		end
		i = i+1;
	end
	a = a_j;

	if (i >= loopExit)
		beep
		disp(['Alert! zoom() algorithm exited prematurely after ' ...
			num2str(i) ' iterations'])
	end
end