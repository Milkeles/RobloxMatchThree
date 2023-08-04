--[SERVICES]--
local Players = game:GetService("Players");
local RepStorage = game:GetService("ReplicatedStorage");
local HttpService = game:GetService("HttpService")

--[MODULES]--
local MatchThree = require(RepStorage.Utility.MatchThreeVisualizer);

--[VARIABLES]--
local asynchronousFunctions = {
};

-- Must always return something!
local synchronousFunctions =  {
};
local eventHandler = require(RepStorage.Events.EventHandler);
local eventListener = require(RepStorage.Events.EventListener);

local mainUi = Players.LocalPlayer.PlayerGui:WaitForChild("MainUI");

--[FUNCTIONS]--
repeat task.wait() until game.Players.LocalPlayer.Character ~= nil


local function updateBoard(board)

	MatchThree:UpdateBoard(board, mainUi.Board)
end

local generatingBoard = false

mainUi:FindFirstChild("MinigameButton").MouseButton1Click:Connect(function(player)
	
	if generatingBoard == true then return end
	generatingBoard = true
	
	local generatedBoard = HttpService:JSONDecode(eventHandler.synchronousServer(player, "startMinigame"));
	
	--mainUi.Board.Visible = true
	MatchThree:DrawBoard(generatedBoard, mainUi.Board)
	
	local selectedCell = nil
	for i, tile in pairs(mainUi.Board:GetChildren()) do
		if tile:IsA("ImageButton") then
			tile.MouseButton1Click:Connect(function()
				if selectedCell == nil then
					selectedCell = tile
				else
					-- Ensure the cells are neighboring ones
					local tileX, tileY = string.sub(tile.Name, 1, 1), string.sub(tile.Name, 2, 2)
					local selectedX, selectedY = string.sub(selectedCell.Name, 1, 1), string.sub(selectedCell.Name, 2, 2)
					if (math.abs(tileX - selectedX) == 1 and tileY == selectedY) or (math.abs(tileY - selectedY) == 1 and tileX == selectedX) then
						--Visually swap the two
						local oldTile = mainUi:FindFirstChild(selectedCell)
						tile.Name, selectedCell.Name = selectedCell.Name, tile.Name
						generatedBoard = HttpService:JSONDecode(eventHandler.synchronousServer(player, "updateBoard", {tileX, tileY, selectedX, selectedY}))
						print("Client: ")
						for i in ipairs(generatedBoard) do
							print(unpack(generatedBoard[i]))
						end
						
					end
					updateBoard(generatedBoard)
					selectedCell = nil
				end
			end)
		end
	end
	
	print("can run")

	
end)
