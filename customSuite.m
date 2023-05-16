function customSuite()
	global MaxIterations; global Size; global Tolerance; global sigDigits;
	global RnSpace;

	% Get list of custom objective functions, e.g. fn_<function>.m
	currentDirectory = strrep(mfilename('fullpath'), 'customSuite', 'custom/fn_*.m');
	FunctionList   = dir(currentDirectory);
	n_functions = size(FunctionList);
	customSuiteFns = strings(n_functions);
	for i=1:n_functions
		customSuiteFns(i) = append('', strrep(FunctionList(i).name, '.m', ''));
	end

	disp('<strong>Enter number of custom objective function you would like to use</strong>')
	disp('<strong>or 0 to create custom NEW objective function:</strong>')
	for i=1:n_functions
		fprintf('%i. %s\n', i, strrep(customSuiteFns(i), 'fn_', ''));
	end
	menuChoice = ui_getUserVal('menu choice', 1);
	disp(' ')

	if menuChoice == 0
		objFunctionName = getCustomFn();
	else
		objFunctionName = customSuiteFns(menuChoice);
	end
	objFnHdl = str2func(objFunctionName);
	directory_path = strrep(mfilename('fullpath'), 'customSuite', 'custom/');
	addpath(directory_path);
	%fprintf('Using %s objective function\n', strrep(objFunctionName, 'fn_', ''));

	% Now get list of minimization algorithms
	currentDirectory = strrep(mfilename('fullpath'), 'customSuite', 'algos/algo_*.m');
	AlgoList = dir(currentDirectory);
	n_algos = size(AlgoList);
	customSuiteAlgos = strings(n_algos);
	directory_path = strrep(mfilename('fullpath'), 'customSuite', 'algos/');
	addpath(directory_path);
	for i=1:n_algos
		customSuiteAlgos(i) = append('', strrep(AlgoList(i).name, '.m', ''));
	end

	disp(' ')
	cstmFnStr = strrep(objFunctionName, 'fn_', '');
	outputStr = append('<strong>Enter number of algorithm you would like to use to minimize ', cstmFnStr, ' function:</strong>');
	disp(outputStr)
	for i=1:n_algos
		fprintf('%i. %s\n', i, strrep(customSuiteAlgos(i), 'algo_', ''));
	end
	menuChoice = ui_getUserVal('menu choice', 1);
	disp(' ')

	% Get starting point
	%x0 = [0.5; 0.5];
	vectorStr = '[';
	for i=1:RnSpace
		if (i > 1)
			vectorStr = append(vectorStr, '; ');
		end
		vectorStr = append(vectorStr, '0.5');
	end
	vectorStr = append(vectorStr, ']');
	x0 = ui_getUserVector('x₀', vectorStr, RnSpace);

	algoFnName = customSuiteAlgos(menuChoice);
	prettyAlgoName = strrep(algoFnName, 'algo_', '');
	fprintf('Minimizing %s objective function by %s algorithm\n', strrep(objFunctionName, 'fn_', ''), prettyAlgoName);
	[X, Y, k, metrics] = feval(algoFnName, objFnHdl, x0, MaxIterations, Size, Tolerance);
	metrics.algorithm = prettyAlgoName;
	metrics.function = strrep(objFunctionName, 'fn_', '');
	displayGraphs = true;
	prettyPrint('b', displayGraphs, metrics, x0, X, Y, k, sigDigits, MaxIterations)
end

function custom_fn_name = getCustomFn()
	%global MaxIterations; global Tolerance; global sigDigits; global Size;
	%global userFn; global userGrad; global userHess;
	fnStr = getUserFn('f', '(x(1)+4)^2+(x(2)-2)^2+3');
	disp(' ')

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
	symbolicStr;
	symbolic_fn = str2sym(symbolicStr);
	symbolic_fn_str = formattedDisplayText(symbolic_fn);
	symbolic_fn_str = strrep(symbolic_fn_str, char(10), '; ');
	symbolic_fn_str = append('f = ', strrep(symbolic_fn_str, ';  ', ''), ';');
	%userFn = symbolic_fn
	%args = argnames(symbolic_fn)
	%args2 = argnames(userFn)
	
	gradient_fn = gradient(symbolic_fn, vector);
	gradient_fn_str = formattedDisplayText(gradient_fn);
	gradient_fn_str = strrep(gradient_fn_str, char(10), '; ');
	gradient_fn_str = append('	df = [', strrep(gradient_fn_str, ';  ', ''), '];');
	userGrad = gradient_fn;
	%g = @(x) eval(gradient_fn);
	%gradStr = sym2str(gradient_fn)
	%g = @(x) eval(gradStr);
	
	hessian_fn = hessian(symbolic_fn, vector);
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

	disp('<strong>Enter a custom function name that describes the equation entered.</strong>')
	custom_fn_name = ui_getUserFilename('filename', 'custom');
	custom_fn_name = append('fn_', custom_fn_name);
	custom_fn_filename = append('custom/', custom_fn_name, '.m');
	disp(' ')
	disp('<strong>It is a good idea to enter a text description of this objective function.</strong>')
	custom_description = ui_getUserStr('description', '');
	userName = char(java.lang.System.getProperty('user.name'));
	userName(1) = upper(userName(1));
	comment = append('% Custom Objective Function', char(10) , '% created by ', userName, ' on ');
	t = datetime('now','TimeZone','local','Format','MMM d, y HH:mm:ss Z');
	comment = append(comment, datestr(t));
	comment = append('% ', custom_description, char(10), comment);

	% Write contents to file
	filePath = strrep(mfilename('fullpath'), 'customSuite', custom_fn_filename);
	lines = append('function [f, df, ddf] = ', custom_fn_name, '(x)');
	writelines(lines,filePath);
	writelines(comment,filePath,WriteMode="append");
	writelines(symbolic_fn_str,filePath,WriteMode="append")
	writelines('if nargout > 1',filePath,WriteMode="append")
	writelines(gradient_fn_str,filePath,WriteMode="append")
	writelines('if nargout > 2',filePath,WriteMode="append")
	writelines(hessian_fn_str,filePath,WriteMode="append")
	writelines('end',filePath,WriteMode="append")
	writelines('end',filePath,WriteMode="append")
	writelines(' ',filePath,WriteMode="append")
	lines = 'end';
	writelines(lines,filePath,WriteMode="append")
end

function [y, dy, ddy] = customFn(xx)
	% This attempt at executing a custom function using symbolic notation
	% is deprecated by writing the custom function out to a file
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
		disp(['<strong>Enter the function [Default: ' name '(x)=' defaultFn '</strong>'])
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
