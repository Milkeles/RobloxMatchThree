--[[This script handles:
	1. Replication and server functions;
	2. Player data (profile service);
	3. Match three minigame.
]]--

--[[SERVICES]]--
local PlrService = game:GetService("Players");
local RepStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--[[VARIABLE]]--
local matchThree = require(ServerStorage.Modules.MatchThreeMain)
local matchThreeBoards = {}; --[player] = {board, points}
local HttpService = game:GetService("HttpService");

--Replication related
local asynchronousFunctions = {
	["movePlayer"] = function(player)
		task.wait(5)
		player.Character.HumanoidRootPart.CFrame = CFrame.new(20, 20, 20);
	end,
};

-- Must always return something!
local synchronousFunctions =  {
	["startMinigame"] = function(player)
		local generatedBoard = matchThree:generateBoard(5, 7, 5);
		
		local playerData = {
			board = generatedBoard,
			points = 0
		}
		
		matchThreeBoards[player.Name] = playerData
		
		print(matchThreeBoards[player.Name])
		local encodedBoard = HttpService:JSONEncode(generatedBoard);
		return encodedBoard;
	end,
	["updateBoard"] = function(player, coordinates)
		local board = matchThreeBoards[player.Name]["board"]
		local x1, y1 = tonumber(coordinates[1]), tonumber(coordinates[2])
		local x2, y2 = tonumber(coordinates[3]), tonumber(coordinates[4])
		if board then
			if (math.abs(x1 - x2) == 1 and y1 == y2) or (math.abs(y1 - y2) == 1 and x1 == x2) then
				board[x1][y1], board[x2][y2] = board[x2][y2], board[x1][y1]
				board = matchThree:UpdateBoard(board)
			else
				player:Kick()
			end
		else
			player:Kick()
		end
		local encodedBoard = HttpService:JSONEncode(board);
		return encodedBoard;
	end,
};

local eventHandler = require(RepStorage.Events.EventHandler).new("ServerEventHandler");
local eventListener = require(RepStorage.Events.EventListener).new(asynchronousFunctions, synchronousFunctions, script.Name);

--Data related
local profileService = require(ServerStorage.Modules.ProfileService)

--Save only numbers and strings!
local profileTemplate = {
	items = {}, --"item_amount"
	location = {["x"] = 0, ["y"] = 3, ["z"] = 0},
	money = 0,
	lastLogin = ""
};
local profileStore = profileService.GetProfileStore(
	"PlayerData",
	profileTemplate
)
local profiles = {}; --[player] = profile

--[[FUNCTIONS]]--
function spawnLoadedPlayer(player, profile)
	profile.Data.lastLogin = os.date();
	player.Character.HumanoidRootPart.CFrame = CFrame.new(profile.Data.location["x"], profile.Data.location["y"], profile.Data.location["z"]);
end

function PlayerJoined(player)
	print(player.Name.." joined!");
	
	local profile = profileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(PlrService) == true then
			profiles[player] = profile
			-- A profile has been successfully loaded:
			repeat task.wait() until player.Character ~= nil
			spawnLoadedPlayer(player, profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		-- Roblox servers trying to load this profile at the same time:
		player:Kick("Error 101: You data could not be loaded. Sorry, please rejoin!");
	end
end

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(PlrService:GetPlayers()) do
	task.spawn(PlayerJoined, player)
end

function PlayerLeft(player)
	local profile = profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end

--[[EVENTS]]--
PlrService.PlayerAdded:Connect(PlayerJoined)
PlrService.PlayerRemoving:Connect(PlayerLeft)