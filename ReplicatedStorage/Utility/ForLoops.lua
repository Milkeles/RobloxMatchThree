local MatchThreeClient = {}

--Red, Blue, Green, Yellow, Purple
local colors = {"14300139310", "14300142933", "14300145047", "14300148306", "14300150981"}

function MatchThreeClient:DrawBoard(board, frame)
	for row = 1, #board do
		for col = 1, #board[row] do
			local tile = board[row][col]
			local button = Instance.new("ImageButton", frame)
			button.Image = "rbxassetid://"..colors[tile]
			button.Name = row..""..col
			button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			button.BackgroundTransparency = 0.7
			local uiCorner = Instance.new("UICorner", button)
		end
	end
end


function MatchThreeClient:UpdateBoard(board, frame)
	for row = 1, #board do
		for col = 1, #board[row] do
			local tile = board[row][col]
			print(tile)
			frame[row..col].Image = "rbxassetid://"..colors[tile]
		end
	end
end


return MatchThreeClient
