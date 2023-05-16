function userStr = ui_getUserFilename(name, default)
	prompt = (['Enter ' name ' without .m ending [Default: ' default ']: ']);
	userInput = input(prompt,"s");

	if userInput
		userStr = userInput;
	else
		userStr = default;
	end

	%userStr = userStr(find(~isspace(userStr))); % remove all spaces
	userStr = strtrim(userStr); % remove leading / trailing whitespace
	userStr = strrep(userStr, ' ', '_'); % swap spaces with underscore
	userStr = matlab.lang.makeValidName(userStr); % make MATLAB safe
	userStr = strip(userStr, '_'); % strip leading/trailing underscores
end
