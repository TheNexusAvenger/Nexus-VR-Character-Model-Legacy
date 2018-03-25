--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter.local.lua
Author: TheNexusAvenger
Date: March 11th 2018

]]

spawn(function()
	wait()
	if script.Parent.Name ~= "PlayerScripts" then
		script.Parent = script.Parent.Parent:WaitForChild("PlayerScripts")
	end
end)

require(script:WaitForChild("Replication"):WaitForChild("LocalPlayerHandler")):Initialize()
