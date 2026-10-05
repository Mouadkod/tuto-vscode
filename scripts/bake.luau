--[[
	Bakes the map offline with Lune, without opening Studio.

		lune run scripts/bake.luau

	Writes:
	  build/StealAnEggMap.rbxl  place with the map and lighting, open it in Studio
	  build/StealAnEggMap.rbxm  just the Map model, drag it into any place
	  build/topdown.json        part footprints for scripts/render_topdown.py

	The MapBuilder modules are plain Roblox code; this loader gives them the
	Roblox globals from @lune/roblox and a `script.Parent.X` style require.
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local SRC = "src/server/MapBuilder/"

local game = roblox.Instance.new("DataModel")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")

local env: { [string]: any } = {
	game = game,
	workspace = workspace,
	Instance = roblox.Instance,
	Vector3 = roblox.Vector3,
	Vector2 = roblox.Vector2,
	CFrame = roblox.CFrame,
	Color3 = roblox.Color3,
	Enum = roblox.Enum,
	UDim = roblox.UDim,
	UDim2 = roblox.UDim2,
	Font = roblox.Font,
	BrickColor = roblox.BrickColor,
	NumberRange = roblox.NumberRange,
	NumberSequence = roblox.NumberSequence,
	ColorSequence = roblox.ColorSequence,
	typeof = typeof,
}

local cache = {}
local parentProxy = setmetatable({}, {
	__index = function(_, name)
		return { __module = name }
	end,
})
env.script = { Parent = parentProxy }
env.require = function(desc)
	local name = desc.__module
	if cache[name] == nil then
		local source = fs.readFile(SRC .. name .. ".luau")
		cache[name] = luau.load(source, { debugName = name, environment = env })()
	end
	return cache[name]
end

local MapBuilder = env.require({ __module = "MapBuilder" })
local map = MapBuilder.build(workspace, lighting, nil)

-- Footprints and bounding boxes for the previews, plus a part count.
local parts = {}
local count = 0
for _, inst in map:GetDescendants() do
	if inst:IsA("BasePart") then
		count += 1
		if inst.Transparency < 1 then
			local cf, s = inst.CFrame, inst.Size / 2
			local corners = {}
			local topY = -math.huge
			local lo = { math.huge, math.huge, math.huge }
			local hi = { -math.huge, -math.huge, -math.huge }
			for _, dx in { -1, 1 } do
				for _, dy in { -1, 1 } do
					for _, dz in { -1, 1 } do
						local p = cf * roblox.Vector3.new(dx * s.X, dy * s.Y, dz * s.Z)
						table.insert(corners, { math.floor(p.X * 10) / 10, math.floor(p.Z * 10) / 10 })
						topY = math.max(topY, p.Y)
						lo = { math.min(lo[1], p.X), math.min(lo[2], p.Y), math.min(lo[3], p.Z) }
						hi = { math.max(hi[1], p.X), math.max(hi[2], p.Y), math.max(hi[3], p.Z) }
					end
				end
			end
			local c = inst.Color
			table.insert(parts, {
				c = { math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255) },
				t = inst.Transparency,
				y = topY,
				p = corners,
				b = { lo[1], lo[2], lo[3], hi[1], hi[2], hi[3] },
			})
		end
	end
end

fs.writeDir("build")
fs.writeFile("build/StealAnEggMap.rbxl", roblox.serializePlace(game))
fs.writeFile("build/StealAnEggMap.rbxm", roblox.serializeModel({ map }))
fs.writeFile("build/topdown.json", serde.encode("json", parts))
print(`Baked {count} parts into build/StealAnEggMap.rbxl`)
