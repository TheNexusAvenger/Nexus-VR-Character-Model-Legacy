--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/NexusVRCharacter/UserInterface/PhysicsSolver.module.lua
Author: TheNexusAvenger
Date: March 25th 2018



PhysicsSolver:CreateSolver(CharacterClass)
	Creates a new physics solver from CharacterClass
	RETURNS: PhysicsSolverClass
	
CLASS PhysicsSolverClass
	PhysicsSolverClass:SetNewContext(Pos)
		Sets the next position to override ray casting. Used for teleporting
	PhysicsSolverClass:SetEnabled(Enabled)
		Sets whether the solver is enabled or disabled
	PhysicsSolverClass:Disconnect()
		Disconnects all events
	
--]]

local PhysicsSolver = {}



local Configuration = require(script.Parent.Parent:WaitForChild("Configuration"))
local GRAVITY = Configuration.PhysicsSolver.GRAVITY
local USE_FALLING_SIMULATION = Configuration.PhysicsSolver.USE_FALLING_SIMULATION
local DESTROY_HEIGHT = game:GetService("Workspace").FallenPartsDestroyHeight

local RunService = game:GetService("RunService")
local Util = require(script.Parent:WaitForChild("Util"))

local V3new = Vector3.new



function PhysicsSolver:CreateSolver(CharacterClass)
	local Enabled = true
	local PhysicsSolverClass = {}
	local Head = CharacterClass.CharacterModel:WaitForChild("Head")
	local LeftFoot,RightFoot
	local function UpdateFeet()
		LeftFoot = CharacterClass.CharacterModel:FindFirstChild("LeftFoot")
		RightFoot = CharacterClass.CharacterModel:FindFirstChild("RightFoot")
	end
	UpdateFeet()
	
	local OverridePos
	local LastY,LastTargetY = 0,0
	function PhysicsSolverClass:SetNewContext(NewOverridePos)
		OverridePos = NewOverridePos + V3new(0,4,0)
		LastY = NewOverridePos.Y
	end
	
	function PhysicsSolverClass:SetEnabled(NewEnabled)
		Enabled = NewEnabled
	end
	
	local DownDirection500 = V3new(0,-500,0)
	if GRAVITY > 0 then
		DownDirection500 = V3new(0,500,0)
	end
	
	local FootOffset = Vector3.new(0,4,0)
	local SolverEvent
	if USE_FALLING_SIMULATION then
		local Velocity = 0
		
		SolverEvent = RunService.RenderStepped:Connect(function(DeltaTime)
			if Enabled then
				local EndPart,BottomPos
				if OverridePos then
					EndPart,BottomPos = Util:FindCollidablePartOnRay(OverridePos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()
				elseif LeftFoot and RightFoot then
					local LeftFootPos = LeftFoot.Position + FootOffset
					local RightFootPos = RightFoot.Position + FootOffset
					
					local LeftEndPart,LeftBottomPos = Util:FindCollidablePartOnRay(LeftFootPos,DownDirection500,CharacterClass.CharacterModel)
					local RightEndPart,RightBottomPos = Util:FindCollidablePartOnRay(RightFootPos,DownDirection500,CharacterClass.CharacterModel)
					
					if LeftBottomPos.Y > RightBottomPos.Y then
						EndPart,BottomPos = LeftEndPart,LeftBottomPos
					else
						EndPart,BottomPos = RightEndPart,RightBottomPos
					end
				elseif LeftFoot then
					local LeftFootPos = LeftFoot.Position + FootOffset
					EndPart,BottomPos = Util:FindCollidablePartOnRay(LeftFootPos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()					
				elseif RightFoot then
					local RightFootPos = RightFoot.Position + FootOffset
					EndPart,BottomPos = Util:FindCollidablePartOnRay(RightFootPos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()
				else
					local HeadPos = Head.Position
					EndPart,BottomPos = Util:FindCollidablePartOnRay(HeadPos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()
				end
				
				local EndY = BottomPos.Y
				Velocity = Velocity + (GRAVITY * DeltaTime)
				local DestinationY = LastY + Velocity	
				
				if DestinationY > EndY then			
					LastY = DestinationY
				else
					Velocity = 0
					LastY = EndY	
				end	
				CharacterClass:SetWorldYOffset(LastY)
				
				if OverridePos then
					OverridePos = nil
				end
				
				if LastY < DESTROY_HEIGHT then
					Enabled = false
					CharacterClass.Humanoid.Health = 0
				end
			end
		end)
	else
		SolverEvent = RunService.RenderStepped:Connect(function()
			if Enabled then
				local EndPart,BottomPos
				if OverridePos then
					EndPart,BottomPos = Util:FindCollidablePartOnRay(OverridePos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()
				elseif LeftFoot and RightFoot then
					local LeftFootPos = LeftFoot.Position + FootOffset
					local RightFootPos = RightFoot.Position  + FootOffset
					
					local LeftEndPart,LeftBottomPos = Util:FindCollidablePartOnRay(LeftFootPos,DownDirection500,CharacterClass.CharacterModel)
					local RightEndPart,RightBottomPos = Util:FindCollidablePartOnRay(RightFootPos,DownDirection500,CharacterClass.CharacterModel)
					
					if LeftBottomPos.Y > RightBottomPos.Y then
						EndPart,BottomPos = LeftEndPart,LeftBottomPos
					else
						EndPart,BottomPos = RightEndPart,RightBottomPos
					end
				elseif LeftFoot then
					local LeftFootPos = LeftFoot.Position + FootOffset
					EndPart,BottomPos = Util:FindCollidablePartOnRay(LeftFootPos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()					
				elseif RightFoot then
					local RightFootPos = RightFoot.Position + FootOffset
					EndPart,BottomPos = Util:FindCollidablePartOnRay(RightFootPos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()
				else
					local HeadPos = Head.Position
					EndPart,BottomPos = Util:FindCollidablePartOnRay(HeadPos,DownDirection500,CharacterClass.CharacterModel)
					UpdateFeet()
				end
				
				if EndPart then			
					LastY = BottomPos.Y		
				end	
				CharacterClass:SetWorldYOffset(LastY)
				
				if OverridePos then
					OverridePos = nil
				end
				
				if LastY < DESTROY_HEIGHT then
					Enabled = false
					CharacterClass.Humanoid.Health = 0
				end
			end
		end)
	end
	
	function PhysicsSolverClass:Disconnect()
		SolverEvent:Disconnect()
	end
	
	return PhysicsSolverClass
end

return PhysicsSolver
