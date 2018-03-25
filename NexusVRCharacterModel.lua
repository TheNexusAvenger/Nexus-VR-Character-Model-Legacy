--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel.lua
Author: TheNexusAvenger
Date: March 11th 2018

KNOWN INCOMPATABILITIES:
- Animations can't be played (automatically stopped; messes up the joints)
- Changes to Motor6Ds may be overriden, mainly C0 and C1
- Velocities of parts on character will always read 0,0,0
- Forces on character will always read 0
- Characters do not interact with seats
- Tools may not work as expected due to full range of motion and Touched behavior with head anchored
]]

local NexusVRCharacter = script:WaitForChild("NexusVRCharacter")
local Configuration = script:WaitForChild("Configuration")
Configuration.Parent = NexusVRCharacter

for _,Player in pairs(game.Players:GetPlayers()) do
	spawn(function()
		local PlayerScripts = Player:FindFirstChild("PlayerScripts")
		NexusVRCharacter:Clone().Parent = (PlayerScripts or Player:WaitForChild("PlayerGui",120))
	end)
end
NexusVRCharacter.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

if game:GetService("Workspace").FilteringEnabled then
	local Players = game:GetService("Players")
	local UpdateCFramesForCharacter = Instance.new("RemoteEvent")
	UpdateCFramesForCharacter.Name = "NexusVRCharacter_Replicator"
	UpdateCFramesForCharacter.Parent = game:GetService("ReplicatedStorage")
	
	UpdateCFramesForCharacter.OnServerEvent:Connect(function(Player,HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
		if Player and HeadCF and LeftControllerCF and RightControllerCF and LeftFootCF and RightFootCF then
			for _,OtherPlayer in pairs(Players:GetPlayers()) do
				if OtherPlayer ~= Player then
					UpdateCFramesForCharacter:FireClient(OtherPlayer,Player,HeadCF,LeftControllerCF,RightControllerCF,LeftFootCF,RightFootCF)
				end			
			end
		end
	end)
end
