function prettyPrint(color, displayGraphs, metrics, x0, X, Y, k, sigDigits, MaxIterations)
	% Display algorithm metrics
	fields = fieldnames(metrics);
	total_fields = size(fields, 1);
	colnames = "";
	j = 0;
	output_rows = strings(100);
	total_cols = 0;
	atomic_values = "";
	for i=1:total_fields
		fieldname = string(fields(i));
		output_fieldname = fieldname;
		output_fieldname = strrep(output_fieldname, '_xk', '(xₖ)');
		output_fieldname = strrep(output_fieldname, '_k', 'ₖ');
		output_fieldname = strrep(output_fieldname, '_x', 'ₓ');
		output_fieldname = strrep(output_fieldname, 'alpha', 'α');
		output_fieldname = strrep(output_fieldname, 'beta', 'β');
		output_fieldname = strrep(output_fieldname, 'rho', 'ρ');
		output_fieldname = strrep(output_fieldname, 'phi', 'φ');
		fieldvalue = metrics.(fieldname);
		fieldsize = size(fieldvalue, 2);
		if fieldsize == 1 | isstring(fieldvalue) | ischar(fieldvalue)
			if fieldname == 'cputime' || fieldname == 'runtime' || fieldname == 'walltime'
				tmp = sprintf('<strong>%s:</strong> %15.15fs\n', fieldname, fieldvalue);
			elseif fieldname == 'k'
				tmp = sprintf('<strong>%s:</strong> %5d\n', fieldname, fieldvalue);
			elseif isstring(fieldvalue) | ischar(fieldvalue)
				tmp = sprintf('<strong>%s:</strong> %5s\n', fieldname, fieldvalue);
			else
				tmp = sprintf('<strong>%s:</strong> %15.6f\n', fieldname, fieldvalue);
			end
			atomic_values = append(atomic_values, tmp);
		else %presumed array
			total_cols = total_cols + 1;
			formatted_fieldname = sprintf('<strong>%15s</strong>',output_fieldname);
			colnames = append(colnames, formatted_fieldname);
			for j=1:fieldsize
				fieldvalue(j);
				if fieldname == 'k'
					formatted_fieldvalue = sprintf('%15d', fieldvalue(j));
				elseif count(fieldname, 'alpha') > 0
					formatted_fieldvalue = sprintf('%15.6f', fieldvalue(j));
				elseif isstring(fieldvalue(j)) | ischar(fieldvalue(j))
					formatted_fieldvalue = sprintf('%15s', fieldvalue(j));
				else
					formatted_fieldvalue = sprintf('%15.6e', fieldvalue(j));
				end
				output_rows(j) = append(output_rows(j), formatted_fieldvalue);
			end
		end
	end
	if j > 0
		output_rows = output_rows(1:j);
		total_rows = size(output_rows,2);
	else
		total_rows = 0;
	end
	if total_rows > 0 && k < MaxIterations
		%disp('<strong>Step-wise values</strong>')
		fprintf('%s\n', colnames);
		for m=1:total_rows
			disp(output_rows(m))
		end
	end
	if strlength(atomic_values) > 0
		%disp(atomic_values)
		fprintf('%s', atomic_values);
	end

	% Display solution
	%disp(' ')
	disp(['<strong>iterations (k):</strong> ' num2str(k)])
	x_str = '<strong>x₀:</strong> ';
	x_str = append(x_str, mat2str(x0', sigDigits));
	x_str = append(x_str, 'ᵀ');
	disp(x_str)
	if k < MaxIterations
		if isvector(Y)
			disp(['<strong>f(ₓ⋆):</strong> ' num2str(Y(end), sigDigits)])
		else
			disp(['<strong>f(ₓ⋆):</strong> ' num2str(Y, sigDigits)])
		end
		disp('<strong> ∗ </strong>')
		x_str = append('<strong>X = ', mat2str(X', sigDigits), 'ᵀ</strong>');
		disp(x_str)
		if metrics.runtime ~= 999 & displayGraphs
			display(color, X, metrics.f_xk, 1, metrics.algorithm, metrics.function, x0, metrics.alpha_k)
		end
	else
		%disp(['Alert! ' num2str(k) ' iterations reached, but no minimizer found!'])
		cprintf('*red', 'Alert! %d iterations reached, but no minimizer found!\n', k)
	end
	disp(' ')
end

function display(color, X_star, Fobj, a, algoStr, objFnStr, Xo, a_iterations)
	% Plot results on log-Y scale so that it is easier to visualize
	% the details of descent toward minimum
	i = size(Fobj, 2);
	%figure;
	windowTitle = append(objFnStr, '(', algoStr, ')');
	figure('Name',windowTitle,'NumberTitle','off')
	subplot(2, 1, 1);
	% Matlab colors: red, green, blue, cyan, magenta, yellow, black, white
	% Details here: https://www.mathworks.com/help/matlab/ref/loglog.html
	lcolor = 'black';
	%plot(1:i, Fobj, color);
	semilogy(0:i-1, Fobj, lcolor);
	grid on
	titleStr = append(objFnStr, ' function minimized with ', algoStr, ' algorithm');
	title(titleStr)
	xlabel('k');
	ylabel('fₖ(x)');
	subplot(2, 1, 2);
	%i = size(a, 1);
	i = size(a_iterations, 2);
	semilogy(0:i-1, a_iterations, lcolor)
	grid on
	title(['x₀ = ', mat2str(Xo', 3) 'ᵀ', ', x* = ', mat2str(X_star', 3) 'ᵀ']);
	i = size(a_iterations, 2);
	xlabel('k');
	ylabel('αₖ (step length)');
	% Add a red frame to the figure.
	lineWidth = 20; % Whatever you want.
	annotation('line', [0, 0], [0, 1], 'LineWidth', lineWidth, 'Color', color);
	annotation('line', [1, 1], [0, 1], 'LineWidth', lineWidth, 'Color', color);
	annotation('line', [0, 1], [0, 0], 'LineWidth', lineWidth, 'Color', color);
	annotation('line', [1, 0], [1, 1], 'LineWidth', lineWidth, 'Color', color);
	%subplot(3, 1, 3);
	%plot(0:i-1, a_iterations, color);
	%grid on
	%title(['Iterations needed to find step length (αₖ) at each kth iteration']);
	%xlabel('k');
	%ylabel('α iterations');
end