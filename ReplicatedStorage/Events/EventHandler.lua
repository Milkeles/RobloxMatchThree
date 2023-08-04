--[SERVICES]--
local rs = game:GetService("ReplicatedStorage");

--[MODULES]--
local forLoops = require(rs.Utility.ForLoops);

local eventHandlerClass = {};
eventHandlerClass.__index = eventHandlerClass;

--Constuctor--
function eventHandlerClass.new(name)
	local self = setmetatable({}, eventHandlerClass);

	self.asynchronousBridge = rs.Events.Asynchronous;

	self.synchronousBridge = rs.Events.Synchronous;

	self.name = name;

	return self;
end

--[CLIENT]--
function eventHandlerClass:asynchronousClients(clients)
	-- Server -> Clients");
	forLoops.classMethodForLoop(self.synchronousClient, clients);
end

function eventHandlerClass:asynchronousAllClients(funcName)
	-- Server -> All Clients");
	rs.Events.Asynchronous:FireAllClients(self.Name, funcName);
end

function eventHandlerClass:synchronousClient(client, funcName)
	--Single Client -> Server");
	rs.Events.Synchronous:InvokeClient(client, funcName);
end

--[SERVER]-- 
function eventHandlerClass:synchronousServer(funcName,args)
	-- Client -> Server -> Client");
	return rs.Events.Synchronous:InvokeServer(funcName,args);
end

function eventHandlerClass:asynchronousServer(funcName)
	-- Client -> Server");
	rs.Events.Asynchronous:FireServer(funcName);
end

return eventHandlerClass;