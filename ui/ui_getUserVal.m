function userVal = ui_getUserVal(name, default)
	prompt = (['Enter ' name ' [Default: ' num2str(default) ']: ']);
	userInput = input(prompt);

	if isempty(userInput)
		userVal = default;
	else
		userVal = userInput;
	end
end
