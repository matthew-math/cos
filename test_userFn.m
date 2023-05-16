function customSuite()
	global MaxIterations; global Size; global Tolerance; global sigDigits;
	%algoDirectory = strrep(mfilename('fullpath'), 'testSuite', 'algos/');
	%addpath(algoDirectory);

	% Get list of custom objective functions, e.g. fn_<function>.m
	currentDirectory = strrep(mfilename('fullpath'), 'testSuite', 'custom/fn_*.m');
	FunctionList   = dir(currentDirectory);
	n_functions = size(FunctionList);
	testSuiteFns = strings(n_functions);
	directory_path = strrep(mfilename('fullpath'), 'testSuite', 'custom/');
	addpath(directory_path);
	for i=1:n_functions
		testSuiteFns(i) = append('', strrep(FunctionList(i).name, '.m', ''));
	end

	% Now get list of custom minimization algorithms
	currentDirectory = strrep(mfilename('fullpath'), 'testSuite', 'algos/algo_*.m');
	AlgoList   = dir(currentDirectory);
	n_algos = size(AlgoList);
	testSuiteAlgos = strings(n_algos);
	directory_path = strrep(mfilename('fullpath'), 'testSuite', 'algos/');
	addpath(directory_path);
	for i=1:n_algos
		testSuiteAlgos(i) = append('', strrep(AlgoList(i).name, '.m', ''));
	end

	disp('Enter number of test function you would like to use:')
	for i=1:n_functions
		fprintf('%i. %5s\n', i, strrep(testSuiteFns(i), 'fn_', ''));
	end
	menuChoice = ui_getUserVal('menu choice', 1);
	disp(' ')
	x0 = [0.5; 0.5];
	
	fprintf('Using %5s function\n', strrep(testSuiteFns(menuChoice), 'fn_', ''));
	fnHandle = str2func(testSuiteFns(menuChoice));
	%[X, Y, k] = LBFGS(fnHandle, x0, MaxIterations, Size, Tolerance);
	%prettyPrint(x0, X, Y, k, sigDigits, MaxIterations)
	for i=1:n_algos
		%functionName = strrep(testSuiteAlgos(i), 'algo_', '');
		functionName = testSuiteAlgos(i);
		fprintf('Testing %5s algorithm\n', functionName);
		[X, Y, k] = feval(functionName, fnHandle, x0, MaxIterations, Size, Tolerance);
		prettyPrint(x0, X, Y, k, sigDigits, MaxIterations)
	end
end

function test_userFn2()
	global MaxIterations; global Tolerance; global sigDigits; global Size;
	global userFn; global userGrad; global userHess;
	fnStr = getUserFn('f', '(x(1)+4)^2+(x(2)-2)^2+3');

	% Allow user to enter custom function, then use it to compute gradient,
	% hessian, and write out custom file; currently supports up to N=100 
	syms x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20;
	syms x21 x22 x23 x24 x25 x26 x27 x28 x29 x30 x31 x32 x33 x34 x35 x36 x37 x38 x39 x40;
	syms x41 x42 x43 x44 x45 x46 x47 x48 x49 x50 x51 x52 x53 x54 x55 x56 x57 x58 x59 x60;
	syms x61 x62 x63 x64 x65 x66 x67 x68 x69 x70 x71 x72 x73 x74 x75 x76 x77 x78 x79 x80;
	syms x81 x82 x83 x84 x85 x86 x87 x88 x89 x90 x91 x92 x93 x94 x95 x96 x97 x98 x99 x100;
	found_symbols = false;
	for k=100:-1:1
		if ~found_symbols & contains(fnStr,['x(' num2str(k) ')'],'IgnoreCase',true)
			found_symbols = true;
			x0 = ones(k)';
			max_vars = k;
			vector = repmat(x1,max_vars,1); % init symbolic vector
			for j=1:max_vars
				symStr = append('x', num2str(j));
				vector(j) = eval(symStr);
			end
			break
		elseif found_symbols & ~contains(fnStr,['x(' num2str(k) ')'],'IgnoreCase',true)
			beep
			disp(['Notice: Skipped x(' num2str(k) ') in function declaration;'])
			disp(['This may cause problems with symbolic interpreter.'])
		end
	end
	if ~found_symbols
		disp('No usable variable symbols were detected in your function.')
		disp('They should be indicated as x(1), x(2), x(3), etc.')
	end
	
	symbolicStr = fnStr;
	for i=100:-1:1
		i_str = num2str(i);
		search_str = append('x(', i_str, ')');
		replace_str = append('x', i_str);
		symbolicStr = strrep(symbolicStr, search_str, replace_str);
	end
	symbolicStr
	symbolic_fn = str2sym(symbolicStr)
	symbolic_fn_str = formattedDisplayText(symbolic_fn);
	symbolic_fn_str = strrep(symbolic_fn_str, char(10), '; ');
	symbolic_fn_str = append('	f = ', strrep(symbolic_fn_str, ';  ', ''), ';');
	%userFn = symbolic_fn
	%args = argnames(symbolic_fn)
	%args2 = argnames(userFn)
	
	gradient_fn = gradient(symbolic_fn, vector)
	gradient_fn_str = formattedDisplayText(gradient_fn);
	gradient_fn_str = strrep(gradient_fn_str, char(10), '; ');
	gradient_fn_str = append('	df = [', strrep(gradient_fn_str, ';  ', ''), '];');
	userGrad = gradient_fn;
	%g = @(x) eval(gradient_fn);
	%gradStr = sym2str(gradient_fn)
	%g = @(x) eval(gradStr);
	
	hessian_fn = hessian(symbolic_fn, vector)
	hessian_fn_str = formattedDisplayText(hessian_fn);
	hessian_fn_str = strrep(hessian_fn_str, '[', '');
	hessian_fn_str = strrep(hessian_fn_str, ']', '');
	hessian_fn_str = strrep(hessian_fn_str, char(10), '; ');
	hessian_fn_str = append('	ddf = [', strrep(hessian_fn_str, ';  ', ''), '];');
	userHess = hessian_fn;
	for i=100:-1:1
		i_str = num2str(i);
		search_str = append('x', i_str);
		replace_str = append('x(', i_str, ')');
		symbolic_fn_str = strrep(symbolic_fn_str, search_str, replace_str);
		gradient_fn_str = strrep(gradient_fn_str, search_str, replace_str);
		hessian_fn_str = strrep(hessian_fn_str, search_str, replace_str);		
	end

	% Write contents to file
	filePath = strrep(mfilename('fullpath'), 'test_userFn', 'custom/fn_custom.m')
	lines = 'function [f, df, ddf] = fn_custom(x)';
	writelines(lines,filePath);
	writelines(symbolic_fn_str,filePath,WriteMode="append")
	writelines(gradient_fn_str,filePath,WriteMode="append")
	writelines(hessian_fn_str,filePath,WriteMode="append")
	lines = 'end';
	writelines(lines,filePath,WriteMode="append")
	
	x0 = [0.5; 0.5];
	x1 = x0(1)
	x2 = x0(2)
	dy = matlabFunction(userGrad)
	result = dy(x1, x2)

	%@customFn = []

	%[y, dy, ddy] = customFn(x0)
	%fnHandle = str2func(testSuiteFns(menuChoice));
	[X, Y, k] = LBFGS(@customFn, x0, MaxIterations, Size, Tolerance);
	prettyPrint(x0, X, Y, k, sigDigits, MaxIterations)
end

function [y, dy, ddy] = customFn(xx)
	global userFn; global userGrad; global userHess;
	disp('Called custom function');
	syms x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20;
	N = size(xx);
	x1 = xx(1);
	x2 = xx(2);

	%y = matlabFunction(userFn)
	%dy = matlabFunction(userGrad)
	%ddy = matlabFunction(userHess)

	%if N > 2
	%	x3 = xx(3);
	%	if N > 3
	%		x4 = xx(4);
	%	end
	%end
	
	%y = matlabFunction(userFn)
	%dy = matlabFunction(userGrad)
	%ddy = matlabFunction(userHess)
	term1 = 0.26 * (x1^2 + x2^2);
	term2 = -0.48*x1*x2;

	user_function = matlabFunction(userFn)
	user_gradient = matlabFunction(userGrad)
	%result = argnames(user_gradient)
	%grad_args = nargin(user_gradient)
	%args = symvar(userFn)
	user_hessian = matlabFunction(userHess)
	%hess_args = nargin(user_hessian)
	%for i=1:hess_args
	%	s = inputname(i)
	%end
	y = user_function(x1, x2)
	dy = user_gradient(x1, x2)
	ddy = user_hessian()
	%result = dy(x1, x2)
	
	%y = term1 + term2;
	%dy = [0.52*x1 - 0.48*x2; 0.52*x2 - 0.48*x1];
	%ddy = [ 0.52, -0.48; -0.48,  0.52];
	
	%y = term1 + term2;
	%dy = [0.52*x1 - 0.48*x2; 0.52*x2 - 0.48*x1];
	%ddy = [ 0.52, -0.48; -0.48,  0.52];
end

% Matthew custom functions for common user input
function fnStr = getUserFn(name, defaultFn)
	gotFn = false;
	while ~gotFn
		disp(['Enter the function [Default: ' name '(x)=' defaultFn])
		prompt = ([name '(x)= ']);
		userFn = input(prompt, 's');
		if contains(userFn,'e^','IgnoreCase',true)
			disp('Your function contains e^... you probably meant to use exp():')
			disp(userFn)
			disp('Try again...')
		elseif contains(userFn,'ln','IgnoreCase',true)
			disp('Your function contains ln... you probably meant to use log() [Note: Base 10 log is noted as log10 in MATLAB]:')
			disp(userFn)
			disp('Try again...')
		elseif contains(userFn,'0x','IgnoreCase',true) | contains(userFn,'1x','IgnoreCase',true) | contains(userFn,'2x','IgnoreCase',true) ...
			| contains(userFn,'3x','IgnoreCase',true) | contains(userFn,'4x','IgnoreCase',true) | contains(userFn,'5x','IgnoreCase',true) ...
			| contains(userFn,'6x','IgnoreCase',true) | contains(userFn,'7x','IgnoreCase',true) | contains(userFn,'8x','IgnoreCase',true) ...
			| contains(userFn,'9x','IgnoreCase',true)
			disp('Your function appears to be missing a multiplication operator:')
			disp(userFn)
			disp('Try again...')
		else
			gotFn = true;
		end
	end
	if ~isempty(userFn) & gotFn
		fnStr = userFn;
	elseif ~isempty(userFn)
		disp(['Function you entered: ' name '(x)=' userFn])
	else
		fnStr = defaultFn;
	end
end

function userVal = getUserVal(name, default)
	disp(['Enter ' name ' [Default: ' num2str(default) '] ']);
	prompt = ([name '= ']);
	userInput = input(prompt);

	if userInput
		userVal = userInput;
	else
		userVal = default;
	end
end
