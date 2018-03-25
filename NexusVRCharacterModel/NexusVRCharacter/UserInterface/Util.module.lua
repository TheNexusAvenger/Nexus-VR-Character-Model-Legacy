--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/Util.module.lua
Author: TheNexusAvenger
Date: March 11th 2018

	
Util:FindCollidablePartOnRay(Start,Direction,Ignore)
	Casts a ray until collidable part or end is reached
	RETURNS: Instance or nil,Vector3

--]]

local Util = {}

local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local Raynew = Ray.new



function Util:FindCollidablePartOnRay(Start,Direction,Ignore)
	local Hit,End = Workspace:FindPartOnRayWithIgnoreList(Raynew(Start,Direction),{Camera,Ignore})
	
	if Hit and not Hit.CanCollide then
		return Util:FindCollidablePartOnRay(End + (Direction * 0.01),Direction - (Start - End),Ignore)
	end
	
	return Hit,End
end

return Util
