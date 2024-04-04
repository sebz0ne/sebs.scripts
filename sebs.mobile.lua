local Library = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt")()
local VisLibrary = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Blissful4992/ESPs/main/3D%20Drawing%20Api.lua'), true))()
local Window = Library:Window("sebs.mobile - v1.0.0",Color3.fromRGB(224, 44, 44), Enum.KeyCode.RightControl)

-- Settings
local ReachEnabled = false
local ReachRadius = 0

local VisualizerEnabled = false
local VisualizerColor = Color3.fromRGB(0,0,0)



-- [[ MAIN PAGE ]] --
local MainPage = Window:Tab("Main")

-- [[ REACH SECTION ]] --
MainPage:Label("-------- REACH SETTINGS")

MainPage:Toggle("Reach Enabled",false, function(t)
    ReachEnabled = t
end)

MainPage:Textbox("Reach Radius",true, function(t)
    ReachRadius = tonumber(t) or 0
end)

-- [[ VISUALIZER SECTION ]] --
MainPage:Label("-------- VISUALIZER SETTINGS")

MainPage:Toggle("Visualizer Enabled",false, function(t)
    VisualizerEnabled = t
end)

MainPage:Colorpicker("Visualizer Color",Color3.fromRGB(0, 0, 0), function(t)
    VisualizerColor = Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255)
end)


-- [[ SCRIPT LOGIC ]] --

-- // Variables
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = PlayerService.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local LimbsToBring = {}
local WhitelistedLimbs = {"Left Arm", "Left Leg"}

local TARGET_SIZE = Vector3.new(1, 0.8, 4)
local HANDLE

-- // Visualizer
local NewCircle = VisLibrary:New3DCircle()

NewCircle.Transparency = 0.9
NewCircle.Color = Color3.new(0, 0, 0)
NewCircle.Thickness = 1
NewCircle.ZIndex = 0
NewCircle.Visible = false

-- // Functions

local function getRoundedVector(vector)
	return Vector3.new(math.round(vector.X), math.round(vector.Y), math.round(vector.Z))
end

local function getHandleNoSpatialQuery() -- // thank you enrise
	local cameraSubject = Camera.CameraSubject

	if cameraSubject then
		local character = cameraSubject:FindFirstAncestorOfClass("Model")
		
		if character and character:FindFirstChild("HumanoidRootPart", true) then
			local tool = character:FindFirstChildOfClass("Tool")
			
			if tool then
				local participants = tool:GetDescendants()
				
				for _, descendant in participants do
					if descendant:IsA("Part") and descendant.CanTouch and descendant:FindFirstChildOfClass("TouchTransmitter") then
						if getRoundedVector(descendant.Size) == getRoundedVector(TARGET_SIZE) then
							--if (descendant.Position - character:GetPivot().Position).Magnitude <= 7 and table.find(descendant:GetTouchingParts(), character.Humanoid:GetLimb(character:FindFirstChild("Right Arm"))) then
								return descendant
							--end
						end
					end
				end
			end
		end
	end
end; do
    HANDLE = getHandleNoSpatialQuery()
end


-- // Internal Loop

RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        HANDLE = getHandleNoSpatialQuery()
        LocalCharacter = LocalPlayer.Character
        
        if HANDLE then
            if HANDLE:IsDescendantOf(LocalPlayer.Backpack) then
                NewCircle.Visible = false
            else
                NewCircle.Visible = VisualizerEnabled
            end
    
            NewCircle.Color = VisualizerColor
            NewCircle.Radius = ReachRadius
            NewCircle.Position = HANDLE.Position or nil
        end

        task.spawn(function()
            for _, Player in next, PlayerService:GetPlayers() do
                if (LocalPlayer ~= Player) and (Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("Humanoid").Health > 0) then
                    local Target = Player.Character
                    local HumPart = Target:FindFirstChild("HumanoidRootPart")
        
                    if HANDLE and HumPart and Target and (HumPart.Position - HANDLE.Position).Magnitude <= ReachRadius then
                        
                        if ReachEnabled then
                            
                            for _, Limb in next, WhitelistedLimbs do
                                
                                local TargetLimb = Target[Limb]
                                TargetLimb:BreakJoints()
                                TargetLimb.CFrame = HANDLE.CFrame
                                TargetLimb.CanCollide = false
        
                            end
        
                        end
        
                    end
        
                end
            end
        end)
    end)


end)
