%% MATH 5393: Numerical Optimization. Matthew Hellinger
%{
Algorithms from: Numerical Optimization Springer 2nd Ed.

Bulk of test functions obtained from:
https://www.sfu.ca/~ssurjano/optimization.html
%}
clc; close all; format long; % clean up workspace
global MaxIterations; global Size; global Tolerance; global sigDigits;
global Fobj; global a; global a_iterations; % for FR... remove at some pt
global RnSpace;
%global userFn; global userGrad; global userHess;

%currentDirectory = strrep(mfilename('fullpath'), 'testSuite', 'algos/algo_*.m')
uidirectory_path = strrep(mfilename('fullpath'), 'run_me', 'ui/');
addpath(uidirectory_path);

% --------------------------------------
% CONFIGURABLE VARS
% --------------------------------------
% Currently Rosenbrock is the only objective function that
% supports arbitrary n (custom functions support user-specified n)
RnSpace = 2; % Dimensions in which to minimize
MaxIterations = 200;
Size = 5; % # of iterations to keep
Tolerance = 1e-10;
% --------------------------------------
sigDigits = ceil(log10(1/Tolerance));

%disp('<strong>█████████████████████████████████████</strong>')
%disp('<strong>█     CONVEX OPTIMIZATION SUITE     █</strong>')
%disp('<strong>█████████████████████████████████████</strong>')
cprintf('blue', ' ');
cprintf('blue', ' ███                               ███\n')
cprintf('blue', '    ███ CONVEX OPTIMIZATION SUITE ███\n')
cprintf('blue', '       ')
cprintf('-blue', '█████████████*█████████████\n')
disp(' ');
done = false;
while ~done
	% common functions and datasets used for testing optimization algorithms
	disp('<strong>Enter the number of your menu choice:</strong>')
	disp('<strong>1</strong>. Run full test suite');
	disp('<strong>2</strong>. Use specific test function');
	disp('<strong>3</strong>. Read more about test functions');
	disp('<strong>4</strong>. Use custom function');
	disp('<strong>5</strong>. Display MATLAB config');
	disp('<strong>6</strong>. Close output windows');
	disp(' ')
	menuChoice = ui_getUserVal('menu choice', 1);
	disp(' ')
	
	if menuChoice == 1
		testSuite(false)
	elseif menuChoice == 2
		testSuite(true)
	elseif menuChoice == 3
		url = 'https://www.sfu.ca/~ssurjano/optimization.html';
		web(url)
	elseif menuChoice == 4
		customSuite();
		%test_userFn();
	elseif menuChoice == 5
		configinfo();
	elseif menuChoice == 6
		close all;
		clc;
	end

	if menuChoice ~= 6
		disp(' ')
		txtInput = input("<strong>Quit [Y]?</strong>", "s");
		if isempty(txtInput) | txtInput == 'Y' | txtInput == 'y'
			done = true;
			disp(' ')
		else
			disp(' ')
			txtInput = input("<strong>Clear Screen [Y]?</strong>", "s");
			if isempty(txtInput) | txtInput == 'Y' | txtInput == 'y'
				clc;
			else
				disp(' ')
			end
			done = false;
		end
	end
end
%{
Available test functions from:
https://www.sfu.ca/~ssurjano/optimization.html
https://transp-or.epfl.ch/books/optimization/html/octaveDoxygen/chap11_2ex_rosenbrock_8m.html
http://www-optima.amp.i.kyoto-u.ac.jp/member/student/hedar/Hedar_files/TestGO.htm

Many local minima: 
Bowl shaped:
Plate-shaped: fn_booth, fn_matya, fn_mccorm, fn_zakharov
Valley-shaped: fn_dixonpr, fn_camel3, fn_camel6, fn_rosenbrock
Steep Ridges/Drops: 
Other: 
%}