--[[
	Bright simulator daylight: high sun, saturated colour grading, soft bloom
	so neon parts glow, a light atmosphere and puffy clouds.
]]

local Config = require(script.Parent.Config)

local Environment = {}

local rgb = Config.rgb
local MANAGED = { Sky = true, Atmosphere = true, BloomEffect = true, ColorCorrectionEffect = true, SunRaysEffect = true }

function Environment.apply(lighting: Lighting, terrain: Terrain?)
	for _, child in lighting:GetChildren() do
		if MANAGED[child.ClassName] then
			child:Destroy()
		end
	end

	lighting.ClockTime = 13.5
	lighting.GeographicLatitude = 25
	lighting.Brightness = 3
	lighting.Ambient = rgb(118, 120, 132)
	lighting.OutdoorAmbient = rgb(168, 170, 182)
	lighting.EnvironmentDiffuseScale = 1
	lighting.EnvironmentSpecularScale = 0.6
	lighting.GlobalShadows = true
	lighting.ShadowSoftness = 0.25
	lighting.ExposureCompensation = 0.1

	local sky = Instance.new("Sky")
	sky.SunAngularSize = 16
	sky.Parent = lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.22
	atmosphere.Offset = 0.12
	atmosphere.Color = rgb(206, 228, 255)
	atmosphere.Decay = rgb(120, 172, 236)
	atmosphere.Glare = 0.15
	atmosphere.Haze = 0.6
	atmosphere.Parent = lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.7
	bloom.Size = 24
	bloom.Threshold = 1.5
	bloom.Parent = lighting

	local grade = Instance.new("ColorCorrectionEffect")
	grade.Saturation = 0.2
	grade.Contrast = 0.06
	grade.Brightness = 0.02
	grade.Parent = lighting

	local rays = Instance.new("SunRaysEffect")
	rays.Intensity = 0.05
	rays.Spread = 0.6
	rays.Parent = lighting

	if terrain then
		local clouds = terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
		clouds.Cover = 0.45
		clouds.Density = 0.6
		clouds.Color = rgb(255, 255, 255)
		clouds.Parent = terrain
	end
end

return Environment
