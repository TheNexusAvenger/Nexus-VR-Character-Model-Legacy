--[[
     __        __  _______  __    __  __   __  ________
    /  \      / / / _____/  \ \  / /  \ \  \ \ \  _____\
   / /\ \    / / / /____     \ \/ /    \ \  \ \ \ \_____
  / /  \ \  / / / _____/     / /\ \     \ \  \ \ \_____ \
 / /    \ \/ / / /____      / /  \ \     \ \__\ \  ____\ \
/_/      \__/ /______/     /_/    \_\     \______\ \______\

Nexus VR Character Model, by TheNexusAvenger

File: NexusVRCharacterModel/Configuration.module.lua
Author: TheNexusAvenger
Date: March 29th 2018

]]





--------------------------------------------------
--------------------------------------------------
----------     REPLICATION PACKAGE      ----------
--------------------------------------------------
--------------------------------------------------

--------------------------------------------------
----------     MainCharacterCreator     ----------
--------------------------------------------------

--Defines controllers for player when in VR mode
--"Arc" will use teleportation controls like SteamVR Home
--"Move" will use movement controls like the default controls in Roblox
local MAINCHARACTERCREATOR_CONTROL_METHOD = "Arc"

--Scale used to convert headset space to Roblox space.
--Default (3.9/6) is optimized for people no taller than 6 feet
local MAINCHARACTERCREATOR_CHARACTER_SCALE_CALLIBRATION = 4.5/6

--Offset of hand controllers before processing
local MAINCHARACTERCREATOR_CONTROLLER_OFFSET = CFrame.Angles(-math.pi/4,0,0)

--Offset of the character when recentered. Should be based off the height of the character and HEADCREATOR_HEADSET_BACK_OFFSET
local MAINCHARACTERCREATOR_RECENTER_OFFSET = Vector3.new(0,4.5 - 0.25,0)


--------------------------------------------------
----------      LocalPlayerHandler      ----------
--------------------------------------------------

--Local transparency of the humanoid when not in 3rd person.
local LOCALPLAYERHANDLER_LOCAL_TRANSPARENCY_MODIFIER = 0.5



--------------------------------------------------
----------        RemoteHandler         ----------
--------------------------------------------------

--No configuriation










--------------------------------------------------
--------------------------------------------------
----------     CHARACTER PACKAGE      ----------
--------------------------------------------------
--------------------------------------------------

--------------------------------------------------
----------       AppendageCreator       ----------
--------------------------------------------------

--If false, Motor6Ds will be separated for arms and legs
--May want to keep false since a delay exists when changing Motor6Ds at hands and feet
local APPENDAGEEND_KEEP_MOTOR6DS = true



--------------------------------------------------
----------     AppendageEndCreator      ----------
--------------------------------------------------

--If false, Motor6Ds will be separated for hands and feet
local APPENDAGEENDCREATOR_KEEP_MOTOR6DS = false



--------------------------------------------------
----------       CharacterCreator       ----------
--------------------------------------------------

--If true, arms on the VR client will not be disconnected.
--This may cause the ahnds of the character to not reach the controllers.
local CHARACTERCREATOR_PREVENT_LOCAL_ARM_DISCONNECTION = false

--If true, arms on non-VR clients will be disconnected.
local CHARACTERCREATOR_DISCONNECT_NON_LOCAL_ARMS = false



--------------------------------------------------
----------         FootPlanter          ----------
--------------------------------------------------

--No configuration



--------------------------------------------------
----------          HeadCreator         ----------
--------------------------------------------------

--Back offset of the camera and head from the headset
local HEADCREATOR_HEADSET_BACK_OFFSET = 0.5

--Downward offset of the camera and head from the headset
local HEADCREATOR_HEADSET_DOWN_OFFSET = 0

--Max angle the head will turn before the torso's neck turns left and right
local HEADCREATOR_MAX_HEAD_ROTATION = math.rad(35)

--Max angle the head will turn before the torso's neck tilts up and down
local HEADCREATOR_MAX_HEAD_TILT = math.rad(60)



--------------------------------------------------
----------         TorsoCreator         ----------
--------------------------------------------------

--Max amount the center of the torso will bend when the neck is bent upward
local TORSOCREATOR_MAX_TORSO_BEND = math.rad(5)



--------------------------------------------------
----------             Util             ----------
--------------------------------------------------

--No configuration











--------------------------------------------------
--------------------------------------------------
----------    USERINTERFACE PACKAGE     ----------
--------------------------------------------------
--------------------------------------------------

--------------------------------------------------
----------     ABXYControllerCreator    ----------
--------------------------------------------------

--No Configuration



--------------------------------------------------
----------     ArcControllerCreator     ----------
--------------------------------------------------

--Gravity acceleration used for generation arc
local ARCCONTROLLERCREATOR_GRAVITY = -192.6/4

--Max segments used for arcs.
--More arcs allows a longer distance or higher quality arc, but uses more resources
local ARCCONTROLLERCREATOR_MAX_SEGMENTS = 50

--Time multiplier used in the following kinematic equation:
--d = (vi * t) + (0.5 * a * t^2)
--To generate height of arcs at given point.
--Lower number will cause beam lengths to be shorter. Will be higher quality but shorter distances.
local ARCCONTROLLERCREATOR_TIME_DISTANCE_BETWEEN_SEGMENTS = 0.05

--Thickness of the beams in studs.
local ARCCONTROLLERCREATOR_BEAM_SIZE = 0.1

--Color of arc when arc reaches destination
local ARCCONTROLLERCREATOR_BEAM_COLOR_VALID = ColorSequence.new(Color3.new(0,170/255,1))

--Color of arc when arc doesn't reach a destination (typically aimed at void)
local ARCCONTROLLERCREATOR_BEAM_COLOR_INVALID = ColorSequence.new(Color3.new(0.8,0,0))

--Intial velocity used in following equation:
--d = (vi * t) + (0.5 * a * t^2)
--To generate height of arcs at given point.
--Decreasing the velocity will cause the max teleport distance to decrease.
local ARCCONTROLLERCREATOR_BEAM_MAX_VELOCITY = 30

--Minimum radius (from 0 to 1) of touchpad/thumbstick to register input.
local ARCCONTROLLERCREATOR_MAGNITUDE_THRESHOLD = 0.05

--Max angle of touchpad/thumbstick to register input.
--Anything above math.rad(180) will cause any rotation to register input.
local ARCCONTROLLERCREATOR_ANGLE_THRESHOLD = math.rad(180)



--------------------------------------------------
----------         CameraCreator        ----------
--------------------------------------------------

--If true, the camera will use a world based 3rd person offset
local CAMERACREATOR_USE_THIRD_PERSON = false

--If CAMERACREATOR_USE_THIRD_PERSON is true, this offset will be applied in world space
local CAMERACREATOR_THIRD_PERSON_OFFSET = CFrame.new(0,0,-5) * CFrame.Angles(0,math.pi,0)

--If true, a hack will be applied to allow GUIs to track the camera
--Will be removed when fixed: https://devforum.roblox.com/t/coregui-vr-components-rely-on-headlocked-being-true/100460
local CAMERACREATOR_USE_HEADLOCKED_HACK = true



--------------------------------------------------
----------        MessageCreator        ----------
--------------------------------------------------

--No configuration



--------------------------------------------------
----------     MoveControllerCreator    ----------
--------------------------------------------------

--Minimum radius (from 0 to 1) of touchpad/thumbstick to register input.
local MOVECONTROLLERCREATOR_MAGNITUDE_THRESHOLD = 0.1



--------------------------------------------------
----------         PhysicsSolver        ----------
--------------------------------------------------

--Gravity used in falling simulation when enabled.
-- -0.75 is close to Roblox physics. Number can be positive.
local PHYSICSSOLVER_GRAVITY = -0.75

--If true, characters will fall instead of instantly snapping to the next surface.
--Enabling this may cause motion sickness. Be careful when using.
local PHYSICSSOLVER_USE_FALLING_SIMULATION = false



--------------------------------------------------
----------             Util             ----------
--------------------------------------------------

--No configuration










return {
	--Replication Package
	MainCharacterCreator = {
		CONTROL_METHOD = MAINCHARACTERCREATOR_CONTROL_METHOD,
		CHARACTER_SCALE_CALLIBRATION = MAINCHARACTERCREATOR_CHARACTER_SCALE_CALLIBRATION,
		CONTROLLER_OFFSET = MAINCHARACTERCREATOR_CONTROLLER_OFFSET,
		RECENTER_OFFSET = MAINCHARACTERCREATOR_RECENTER_OFFSET,
	},
	LocalPlayerHandler = {
		LOCAL_TRANSPARENCY_MODIFIER = LOCALPLAYERHANDLER_LOCAL_TRANSPARENCY_MODIFIER,
	},
	RemoteHandler = {
		
	},
	
	--Character Package
	AppendageCreator = {
		KEEP_MOTOR6DS = APPENDAGEEND_KEEP_MOTOR6DS,
	},
	AppendageEndCreator = {
		KEEP_MOTOR6DS = APPENDAGEENDCREATOR_KEEP_MOTOR6DS,
	},
	CharacterCreator = {
		PREVENT_LOCAL_ARM_DISCONNECTION = CHARACTERCREATOR_PREVENT_LOCAL_ARM_DISCONNECTION,
		DISCONNECT_NON_LOCAL_ARMS = CHARACTERCREATOR_DISCONNECT_NON_LOCAL_ARMS,
	},
	FootPlanter = {
	
	},
	HeadCreator = {
		HEADSET_BACK_OFFSET = HEADCREATOR_HEADSET_BACK_OFFSET,
		HEADSET_DOWN_OFFSET = HEADCREATOR_HEADSET_DOWN_OFFSET,
		MAX_HEAD_ROTATION = HEADCREATOR_MAX_HEAD_ROTATION,
		MAX_HEAD_TILT = HEADCREATOR_MAX_HEAD_TILT,
	},
	TorsoCreator = {
		MAX_TORSO_BEND = TORSOCREATOR_MAX_TORSO_BEND,
	},
	Util_Character = {
		
	},
	
	--UserInterface Package
	ABXYControllerCreator = {
		
	},
	ArcControllerCreator = {
		GRAVITY = ARCCONTROLLERCREATOR_GRAVITY,
		MAX_SEGMENTS = ARCCONTROLLERCREATOR_MAX_SEGMENTS,
		TIME_DISTANCE_BETWEEN_SEGMENTS = ARCCONTROLLERCREATOR_TIME_DISTANCE_BETWEEN_SEGMENTS,
		BEAM_SIZE = ARCCONTROLLERCREATOR_BEAM_SIZE,
		BEAM_COLOR_VALID = ARCCONTROLLERCREATOR_BEAM_COLOR_VALID,
		BEAM_COLOR_INVALID = ARCCONTROLLERCREATOR_BEAM_COLOR_INVALID,
		BEAM_MAX_VELOCITY = ARCCONTROLLERCREATOR_BEAM_MAX_VELOCITY,
		MAGNITUDE_THRESHOLD = ARCCONTROLLERCREATOR_MAGNITUDE_THRESHOLD,
		ANGLE_THRESHOLD = ARCCONTROLLERCREATOR_ANGLE_THRESHOLD,
	},
	CameraCreator = {
		USE_THIRD_PERSON = CAMERACREATOR_USE_THIRD_PERSON,
		THIRD_PERSON_OFFSET = CAMERACREATOR_THIRD_PERSON_OFFSET,
		USE_HEADLOCKED_HACK = CAMERACREATOR_USE_HEADLOCKED_HACK,
	},
	MessageCreator = {
		
	},
	MoveControllerCreator = {
		MAGNITUDE_THRESHOLD = MOVECONTROLLERCREATOR_MAGNITUDE_THRESHOLD,
	},
	PhysicsSolver = {
		GRAVITY = PHYSICSSOLVER_GRAVITY,
		USE_FALLING_SIMULATION = PHYSICSSOLVER_USE_FALLING_SIMULATION,
	},
	Util_UserInterface = {
		
	},
}
