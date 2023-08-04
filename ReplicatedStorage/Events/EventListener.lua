local listener = {};

--[SERVICES]--
local rs = game:GetService("ReplicatedStorage");

--Constructor--
function listener.new(asynchronousFunctions, synchronousFunctions, trace)
	local self = setmetatable({}, listener);
	--    print("Event created from " .. trace); 

	self.synchronousFunctions = synchronousFunctions;

	self.asynchronousFunctions = asynchronousFunctions;
	
	--Client--
	local success, fail = pcall (function()

		rs.Events.Asynchronous.OnClientEvent:Connect(function(trace, funcName)
			--            print(trace .. " Called an asynchronous event.")
			if self.asynchronousFunctions[funcName] then
				return self.asynchronousFunctions[funcName]()
			end;
		end)

		rs.Events.Synchronous.OnClientInvoke = function(funcName)
			if self.synchronousFunctions[funcName] then
				return self.synchronousFunctions[funcName]()
			else
				return nil
			end;
		end

	end)
	
	--Server--
	if not success then

		rs.Events.Asynchronous.OnServerEvent:Connect(function(player, funcName)
			--        print(trace .. " Called an asynchronous event.")
			if self.asynchronousFunctions[funcName] then
				return self.asynchronousFunctions[funcName](player)
			end;
        end)

		rs.Events.Synchronous.OnServerInvoke = function(player, funcName,args)
			if self.synchronousFunctions[funcName] then
				return self.synchronousFunctions[funcName](player,args)
			else
				return nil
			end;
		end
    end
    return self;
end


return listener;