function testSuite(useSpecific)
	global MaxIterations; global Size; global Tolerance; global sigDigits;
	global RnSpace;
	colorOptions = [];
	
	% Get list of test objective functions, e.g. fn_<function>.m
	currentDirectory = strrep(mfilename('fullpath'), 'testSuite', 'functions/fn_*.m');
	FunctionList   = dir(currentDirectory);
	n_functions = size(FunctionList);
	testSuiteFns = strings(n_functions);
	directory_path = strrep(mfilename('fullpath'), 'testSuite', 'functions/');
	addpath(directory_path);
	for i=1:n_functions
		testSuiteFns(i) = strrep(FunctionList(i).name, '.m', '');
	end

	% Now get list of minimization algorithms
	currentDirectory = strrep(mfilename('fullpath'), 'testSuite', 'algos/algo_*.m');
	AlgoList   = dir(currentDirectory);
	n_algos = size(AlgoList, 1);
	testSuiteAlgos = strings(n_algos);
	directory_path = strrep(mfilename('fullpath'), 'testSuite', 'algos/');
	addpath(directory_path);
	for i=1:n_algos
		testSuiteAlgos(i) = append('', strrep(AlgoList(i).name, '.m', ''));
	end

	runTestSuite = true;
	algoChoice = 0;
	if useSpecific
		runTestSuite = false;
		disp('<strong>Enter number of test objective function you would like to use:</strong>')
		for i=1:n_functions
			fprintf('<strong>%i</strong>. %s\n', i, strrep(testSuiteFns(i), 'fn_', ''));
		end
		menuChoice = ui_getUserVal('menu choice', 1);
		disp(' ')
		%x0 = [0.5; 0.5];

		cstmFnStr = strrep(testSuiteFns(menuChoice), 'fn_', '');
		outputStr = append('<strong>Enter number of algorithm you would like to use to minimize ', cstmFnStr, ' function:</strong>');
		disp(outputStr)
		fprintf('%i. Test all algorithms\n', 0);
		for i=1:n_algos
			fprintf('%i. %s\n', i, strrep(testSuiteAlgos(i), 'algo_', ''));
		end
		algoChoice = ui_getUserVal('menu choice', 0);
		disp(' ')
	end

	% Get x₀ from user
	vectorStr = '[';
	% The following is a good idea, but not quite ready for primetime
	%for i=1:RnSpace
	%	if (i > 1)
	%		vectorStr = append(vectorStr, '; ');
	%	end
	%	vectorStr = append(vectorStr, '0.5');
	%end
	vectorStr = append(vectorStr, '0.5 0.5]');
	x0 = ui_getUserVector('x₀', vectorStr, RnSpace);
	
	if runTestSuite
		cprintf('*blue', '------------------------\n')
		cprintf('*blue', '  Starting Test Suite   \n')
		cprintf('*blue', '========================\n')
		cprintf('black', ' \n')
		%disp(' -----------------------')
		%disp('| Executing Test Suite  |')
		%disp(' =======================')
	end
	n_functions = size(testSuiteFns);
	for i=1:n_functions
		if useSpecific & i~=menuChoice
			continue;
		end
		%x0 = [0.5; 0.5];
		
		%fprintf('Using %s objective function\n', strrep(testSuiteFns(i), 'fn_', ''));
		objFnHdl = str2func(testSuiteFns(i));
		prettyFnName = strrep(testSuiteFns(i), 'fn_', '');
		expression = '(^|\.)\s*.';
		replace = '${upper($0)}';
		prettyFnName = regexprep(prettyFnName,expression,replace);
		times = [];
		algoList = []; kList = [];
		%figure
		%hold on
		%plot(rand(10,1),'r')
		%plot(rand(10,1),'b')
		%plot(rand(10,1),'g')
		%legend('data1','data2','data3')
		all_datapoints = zeros(1000,n_algos);
		max_points = 0;
		colorArr = turbo(n_algos); % Generate distinct color for each algo

		for j=1:n_algos
			if algoChoice > 0 & algoChoice ~= j
				continue;
			end
			algoFnName = testSuiteAlgos(j);
			algoName = strrep(algoFnName, 'algo_', '');
			prettyName = strrep(algoFnName, 'algo_', '');
			prettyName = strrep(prettyName, 'LBFGS', 'L-BFGS');
			prettyName = strrep(prettyName, 'sM', 's M');
			prettyName = strrep(prettyName, 'tD', 't D');
			expression = '(^|\.)\s*.';
			replace = '${upper($0)}';
			prettyName = regexprep(prettyName,expression,replace);
			fprintf('<strong>Optimizing %s objective function using %s algorithm</strong>\n', strrep(testSuiteFns(i), 'fn_', ''), algoName);
			tic
			[X, Y, k, metrics] = feval(algoFnName, objFnHdl, x0, MaxIterations, Size, Tolerance);
			elapsedTime = toc;
			%semilogy(metrics.f_xk, 'b');
			%all_datapoints(i) = metrics.f_xk;
			n_elements = size(metrics.f_xk, 2);
			all_datapoints(1:n_elements, j) = metrics.f_xk';
			if n_elements > max_points
				max_points = n_elements;
			end
			metrics.runtime = elapsedTime; % MATLAB runtime call doesn't seem to work reliably
			metrics.algorithm = prettyName;
			metrics.function = prettyFnName;
			displayGraphs = true;
			if runTestSuite
				displayGraphs = false;
			end
			prettyPrint(colorArr(j,:), displayGraphs, metrics, x0, X, Y, k, sigDigits, MaxIterations)
			algoList = [algoList prettyName];
			kList = [kList k];
			times = [times elapsedTime];
		end
		% remove extraneous rows
		all_datapoints([max_points+1:1000],:) = [];
		%all_datapoints(:,1)
		if algoChoice == 0
			windowTitle = append(prettyFnName, ' Minimization Progression');
			figure('Name',windowTitle,'NumberTitle','off')
			chart_title = append('Iterations toward solution of ', prettyFnName, ' objective function');
			set(groot,'defaultLineLineWidth',1.5)
			%plot(rand(10,1),'r')
			colororder(colorArr);
			for j=1:n_algos
				%colorArr(j,:);
				semilogy(all_datapoints(:,j)')
				if j==1
					hold on % first plot is used to determine y-axis
				end
			end
			hold off
			xlabel('Iterations (k)')
			ylabel('f(xₖ)')
			legend(algoList);
		end

		if useSpecific & algoChoice == 0
			algoCellList = cellstr(algoList);
			X = categorical(algoCellList);
			X = reordercats(X,algoCellList);
			Y = times;
			figure('Name','Algorithm Timing Window','NumberTitle','off')
			bh = barh(X, Y, 'FaceColor','flat');
			for j=1:n_algos
				bh.CData(j,:) = colorArr(j,:);
			end
			chart_title = append(prettyFnName, ' objective function minimization');
			title(chart_title);
			subtitle('Compare algorithm runtimes (measure in sec)')
			xlabel('Time in Seconds (shorter is better)')
			ylabel('Algorithm')
			iterX = categorical(algoList);
			iterX = reordercats(X,algoList);
			iterY = kList;
			figure('Name','Iteration Comparison Window','NumberTitle','off')
			subtitle('Compare iterations (k) needed for each algorithm')
			b = bar(iterX, iterY, 'FaceColor','flat');
			for j=1:n_algos
				b.CData(j,:) = colorArr(j,:);
			end
			chart_title = append(prettyFnName, ' objective function minimization');
			title(chart_title);
			xlabel('Algorithm')
			ylabel('Iterations (k)')
		end
	end
	if runTestSuite
		cprintf('*blue', '------------------------\n')
		cprintf('*blue', '  Test Suite Finished!  \n')
		cprintf('*blue', '========================\n')
		%disp(' =======================')
		%disp('| Test Suite Done!      |')
		%disp(' -----------------------')
	end
end