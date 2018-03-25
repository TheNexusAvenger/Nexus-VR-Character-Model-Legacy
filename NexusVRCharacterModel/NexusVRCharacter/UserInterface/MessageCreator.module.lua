--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/MessageCreator.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



MessageCreator:DisplayFullScreenMessage(Message)
	Displays a message on the center of the screen

--]]

local MessageCreator = {}

local LogoURL = "http://www.roblox.com/asset/?id=1499731139"
local MessageHeightRelative = 0.15
local MessageDisplayTime = 3

function MessageCreator:DisplayFullScreenMessage(Message)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	
	local Logo = Instance.new("ImageLabel")
	Logo.SizeConstraint = "RelativeYY"
	Logo.Position = UDim2.new(0.5,0,0.5,0)
	Logo.AnchorPoint = Vector2.new(0.5,0.5)
	Logo.BackgroundTransparency = 1
	Logo.Size = UDim2.new(0,0,0,0)
	Logo.Image = LogoURL
	Logo.Parent = ScreenGui
	
	local TextClips = Instance.new("Frame")
	TextClips.Size = UDim2.new(0,0,MessageHeightRelative,0)
	TextClips.Position = UDim2.new(0.5,0,0.8,0)
	TextClips.AnchorPoint = Vector2.new(0.5,0)
	TextClips.BackgroundTransparency = 1
	TextClips.ClipsDescendants = true
	TextClips.Parent = Logo
	
	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.new(14 * (0.1 / MessageHeightRelative),0,1,0)
	Text.Position = UDim2.new(0.5,0,0,0)
	Text.AnchorPoint = Vector2.new(0.5,0)
	Text.SizeConstraint = "RelativeYY"
	Text.BackgroundTransparency = 1
	Text.Font = "SourceSansBold"
	Text.TextColor3 = Color3.new(1,1,1)
	Text.TextStrokeColor3 = Color3.new(0,0,0)
	Text.TextStrokeTransparency = 0
	Text.TextScaled = true
	Text.Text = Message
	Text.Parent = TextClips
		
	Logo:TweenSize(UDim2.new(0.6,0,0.6,0),"InOut","Quad",0.5,true,function()
		TextClips:TweenSize(UDim2.new(1.4,0,MessageHeightRelative,0),"InOut","Quad",0.5,true,function()
			wait(MessageDisplayTime)
			TextClips:TweenSize(UDim2.new(0,0,MessageHeightRelative,0),"InOut","Quad",0.5,true,function()
				Logo:TweenSize(UDim2.new(0,0,0,0),"InOut","Quad",0.5,true,function()
					ScreenGui:Destroy()
				end)
			end)
		end)
	end)
end

return MessageCreator
