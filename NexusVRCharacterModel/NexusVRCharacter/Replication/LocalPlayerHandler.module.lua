--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Replication/LocalPlayerHandler.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



LocalPlayerHandler:Initialize()
	Initiales local player handling and network calls

--]]

local LocalPlayerHandler = {}

local VRService = game:GetService("VRService")
local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
	
function LocalPlayerHandler:Initialize()
	
	local MainCharacterCreator = require(script.Parent:WaitForChild("MainCharacterCreator"))
	local RemoteHandler = require(script.Parent:WaitForChild("RemoteHandler"))

	local LastCreatedCharacterModel
	local function CreateCharacterFromLocalPlayer()
		local CharacterModel = Player.Character
		
		if CharacterModel and CharacterModel and CharacterModel ~= LastCreatedCharacterModel then
			LastCreatedCharacterModel = CharacterModel
			
			local Character = MainCharacterCreator:CreateLocalCharacter(game.Workspace:WaitForChild("TheNexusAvenger"))
			if Character then
				Character:SetLocalTransparencyModifier(0.5)
				
				local RenderSteppedConnection
				RenderSteppedConnection = RunService.RenderStepped:Connect(function()
					if CharacterModel ~= Player.Character then RenderSteppedConnection:Disconnect() return end				
					Character:UpdateUsingControllerInput()
				end)
			end
		end
	end
	
	local Started = false
	local function StartVR()
		if not Started and VRService.VREnabled then
			Started = true
			Player.CharacterAdded:Connect(CreateCharacterFromLocalPlayer)
			CreateCharacterFromLocalPlayer()
		end
	end
	VRService.Changed:Connect(StartVR)
	StartVR()
	
	RemoteHandler:Initialize()
end

return LocalPlayerHandler
