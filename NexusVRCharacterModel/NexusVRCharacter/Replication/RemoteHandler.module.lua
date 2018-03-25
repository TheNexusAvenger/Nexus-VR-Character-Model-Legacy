--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/Character/RemoteHandler.module.lua
Author: TheNexusAvenger
Date: March 11th 2018



RemoteHandler:Initialize()
	Initializes remote event handling
RemoteHandler:SendReplicationData(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
	Sends replication data to server

]]

local RemoteHandler = {}

local IsFilteringEnabled = game:GetService("Workspace").FilteringEnabled
if IsFilteringEnabled then
	local MainCharacterCreator = require(script.Parent:WaitForChild("MainCharacterCreator"))
	local Players = game:GetService("Players")
	
	local RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("NexusVRCharacter_Replicator")
	local Player = Players.LocalPlayer
	local PlayerCharacters = {}
	
	function RemoteHandler:Initialize()
		RemoteEvent.OnClientEvent:Connect(function(OtherPlayer,HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
			local CharacterModel = OtherPlayer.Character
			
			if not PlayerCharacters[OtherPlayer] or PlayerCharacters[OtherPlayer].CharacterModel ~= CharacterModel then
				if PlayerCharacters[OtherPlayer] then
					PlayerCharacters[OtherPlayer]:Disconnect()
				end
				
				PlayerCharacters[OtherPlayer] = MainCharacterCreator:CreateNetworkableCharacter(CharacterModel)
			end
			
			local VRCharacter = PlayerCharacters[OtherPlayer]
			if VRCharacter then
				VRCharacter:UpdateRig(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
			end
		end)
	end
	
	function RemoteHandler:SendReplicationData(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
		RemoteEvent:FireServer(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
	end
	
	Players.PlayerRemoving:Connect(function(Player)
		if PlayerCharacters[Player] then
			PlayerCharacters[Player]:Disconnect()
		end
	end)
else
	function RemoteHandler:Initialize()
		
	end
	
	function RemoteHandler:SendReplicationData(HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
		
	end
end

return RemoteHandler
