%% Numerical Optimization Springer 2nd Ed.
%{
Common Quasi-Newton core moved to shared QuasiNewton.m file to avoid
code duplication. Any code changes needed for Quasi-Newton methods,
like BFGS & SR1 should be made there.
%}

function [x1, f1, k, metrics] = SR1(fnHandle, x0, maxIterations, m, tolerance)
	[x1, f1, k, metrics] = QuasiNewton(fnHandle, 'SR1', true, x0, maxIterations, m, tolerance);
end