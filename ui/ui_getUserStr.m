function userStr = ui_getUserStr(name, default)
	prompt = (['Enter ' name ' [Default: ' default ']: ']);
	userInput = input(prompt,"s");

	if userInput
		userStr = userInput;
	else
		userStr = default;
	end
end
