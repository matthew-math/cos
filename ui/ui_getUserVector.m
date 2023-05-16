function x0 = ui_getUserVector(name, default, dimensions)
	gotVector = false;
	i = 1;
	while ~gotVector
		startingPosition = ui_getUserStr(name, default);
		if count(startingPosition, '[') == 0
			startingPosition = append('[', startingPosition);
		end
		if count(startingPosition, ']') == 0
			startingPosition = append(startingPosition, ']');
		end
		x0 = eval(startingPosition);
		rows = size(x0, 1);
		cols = size(x0, 2);
		if cols > rows
			x0 = x0';
			rows = size(x0, 1);
			cols = size(x0, 2);
		end
		if cols == 1% & rows == dimensions
			gotVector = true;
		%elseif rows ~= dimensions
			%cprintf('*red', 'Optimization is in Rⁿ space, where n=%d, but your starting position contains %d rows\n', dimensions, rows);
		else
			beep
			if (i < 5)
				cprintf('*red', 'Input does not appear to be a vector, try again.\n');
			else
				cprintf('*red', 'Too many failed attempts, defaulting to %s\n', default);
				x0 = eval(default);
				rows = size(x0, 1);
				cols = size(x0, 2);
				if cols > rows
					x0 = x0';
				end
				gotVector = true;
			end
		end
		i = i+1;
	end
	return

end
