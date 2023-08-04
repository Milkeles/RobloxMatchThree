return {
	--runs function for each key in the data
	pairsForLoop = function(func, data)
		for key, value in pairs(data) do
			func(key, value)
		end
	end,
	classMethodForLoop = function(func, clientsTable)
		for client, funcName in pairs(clientsTable) do
			func(nil, client, funcName);
		end
	end,
};
