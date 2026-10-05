--[[
	Small part-building helpers shared by every map module.

	Only plain Instance/CFrame/Color3 APIs are used (no PivotTo, no Random),
	so the same code runs inside Roblox and inside Lune for offline baking.
]]

local Util = {}

local SMOOTH = Enum.SurfaceType.Smooth
local FONT = Font.fromEnum(Enum.Font.FredokaOne)
Util.FONT = FONT

export type PartOpts = {
	name: string?,
	material: Enum.Material?,
	shape: Enum.PartType?,
	transparency: number?,
	collide: boolean?,
	shadow: boolean?,
	studs: boolean?,
	className: string?,
}

-- Deterministic Park-Miller generator, so every bake places props identically.
function Util.rng(seed: number)
	local state = seed % 2147483647
	if state <= 0 then
		state += 2147483646
	end
	local r = {}
	function r.next(): number
		state = (state * 16807) % 2147483647
		return (state - 1) / 2147483646
	end
	function r.range(a: number, b: number): number
		return a + (b - a) * r.next()
	end
	function r.int(a: number, b: number): number
		return math.min(b, a + math.floor((b - a + 1) * r.next()))
	end
	function r.pick<T>(list: { T }): T
		return list[r.int(1, #list)]
	end
	return r
end

function Util.folder(parent: Instance, name: string): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

function Util.model(parent: Instance, name: string): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

function Util.part(parent: Instance, size: Vector3, cf: CFrame, color: Color3, opts: PartOpts?): BasePart
	local o: PartOpts = opts or {}
	local p = Instance.new(o.className or "Part") :: any
	p.Name = o.name or "Part"
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = o.material or Enum.Material.SmoothPlastic
	if o.shape then
		p.Shape = o.shape
	end
	if o.studs then
		p.TopSurface = Enum.SurfaceType.Studs
	else
		p.TopSurface = SMOOTH
	end
	p.BottomSurface = SMOOTH
	p.FrontSurface = SMOOTH
	p.BackSurface = SMOOTH
	p.LeftSurface = SMOOTH
	p.RightSurface = SMOOTH
	if o.transparency then
		p.Transparency = o.transparency
	end
	if o.collide == false then
		p.CanCollide = false
	end
	if o.shadow == false then
		p.CastShadow = false
	end
	p.Parent = parent
	return p
end

-- Axis-aligned block from two opposite corners (handy for walls and slabs).
function Util.box(parent: Instance, a: Vector3, b: Vector3, color: Color3, opts: PartOpts?): BasePart
	local lo = Vector3.new(math.min(a.X, b.X), math.min(a.Y, b.Y), math.min(a.Z, b.Z))
	local hi = Vector3.new(math.max(a.X, b.X), math.max(a.Y, b.Y), math.max(a.Z, b.Z))
	return Util.part(parent, hi - lo, CFrame.new((lo + hi) / 2), color, opts)
end

function Util.wedge(parent: Instance, size: Vector3, cf: CFrame, color: Color3, opts: PartOpts?): BasePart
	local o: any = table.clone(opts or {})
	o.className = "WedgePart"
	return Util.part(parent, size, cf, color, o)
end

-- Upright cylinder; `cf` is the centre of the cylinder.
function Util.cylinder(parent: Instance, radius: number, height: number, cf: CFrame, color: Color3, opts: PartOpts?): BasePart
	local o: any = table.clone(opts or {})
	o.shape = Enum.PartType.Cylinder
	return Util.part(parent, Vector3.new(height, radius * 2, radius * 2), cf * CFrame.Angles(0, 0, math.pi / 2), color, o)
end

function Util.ball(parent: Instance, radius: number, cf: CFrame, color: Color3, opts: PartOpts?): BasePart
	local o: any = table.clone(opts or {})
	o.shape = Enum.PartType.Ball
	return Util.part(parent, Vector3.new(1, 1, 1) * radius * 2, cf, color, o)
end

-- Flat glowing circle on the ground (shop/sell interaction areas).
function Util.glowCircle(parent: Instance, radius: number, pos: Vector3, color: Color3, name: string): BasePart
	local disc = Util.cylinder(parent, radius, 0.2, CFrame.new(pos + Vector3.new(0, 0.12, 0)), color, {
		name = name,
		material = Enum.Material.Neon,
		transparency = 0.55,
		collide = false,
		shadow = false,
	})
	Util.cylinder(parent, radius + 0.6, 0.12, CFrame.new(pos + Vector3.new(0, 0.07, 0)), color, {
		name = name .. "Rim",
		material = Enum.Material.Neon,
		transparency = 0.15,
		collide = false,
		shadow = false,
	})
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = radius * 1.6
	light.Brightness = 2
	light.Parent = disc
	return disc
end

--[[
	Two-tone checker surface made of tiles.
	`cf` is the centre of the visible surface: local +Y is the outward normal,
	local X spans `sizeU`, local Z spans `sizeV`. Tiles sit just behind the surface.
]]
function Util.checker(
	parent: Instance,
	name: string,
	cf: CFrame,
	sizeU: number,
	sizeV: number,
	tile: number,
	palette: { Color3 },
	thickness: number?
): Folder
	local folder = Util.folder(parent, name)
	local t = thickness or 1
	local nu = math.ceil(sizeU / tile - 1e-6)
	local nv = math.ceil(sizeV / tile - 1e-6)
	for i = 0, nu - 1 do
		local u0 = -sizeU / 2 + i * tile
		local su = math.min(tile, sizeU / 2 - u0)
		for j = 0, nv - 1 do
			local v0 = -sizeV / 2 + j * tile
			local sv = math.min(tile, sizeV / 2 - v0)
			local color = palette[((i + j) % 2) + 1]
			Util.part(folder, Vector3.new(su, t, sv), cf * CFrame.new(u0 + su / 2, -t / 2, v0 + sv / 2), color, {
				name = "Tile",
				shadow = false,
			})
		end
	end
	return folder
end

-- Ring of block segments in the local XY plane of `cf` (angles in radians, 0 = +X).
function Util.arc(
	parent: Instance,
	cf: CFrame,
	radius: number,
	thick: number,
	depth: number,
	a0: number,
	a1: number,
	segments: number,
	color: Color3,
	opts: PartOpts?
)
	local step = (a1 - a0) / segments
	local len = 2 * radius * math.sin(math.abs(step) / 2) * 1.08 + thick * 0.15
	for k = 0, segments - 1 do
		local a = a0 + step * (k + 0.5)
		Util.part(parent, Vector3.new(thick, len, depth), cf * CFrame.Angles(0, 0, a) * CFrame.new(radius, 0, 0), color, opts)
	end
end

local function makeLabel(parent: Instance, text: string, color: Color3, pos: UDim2, size: UDim2, stroke: Color3?)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.RichText = true
	label.TextScaled = true
	label.FontFace = FONT
	label.TextColor3 = color
	label.TextStrokeColor3 = stroke or Color3.new(0, 0, 0)
	label.TextStrokeTransparency = if stroke == nil then 1 else 0
	label.Position = pos
	label.Size = size
	label.Parent = parent
	return label
end
Util.label = makeLabel

export type Line = { text: string, color: Color3, stroke: Color3?, weight: number? }

local function stackLines(gui: Instance, lines: { Line })
	local total = 0
	for _, line in lines do
		total += line.weight or 1
	end
	local y = 0
	for _, line in lines do
		local h = (line.weight or 1) / total
		makeLabel(gui, line.text, line.color, UDim2.fromScale(0, y), UDim2.fromScale(1, h), line.stroke)
		y += h
	end
end

-- Floating world label (a BillboardGui attached to a part, not screen UI).
function Util.billboard(adornee: BasePart, lines: { Line }, width: number, height: number, offsetY: number): BillboardGui
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromScale(width, height)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.LightInfluence = 0
	gui.MaxDistance = 400
	gui.Parent = adornee
	stackLines(gui, lines)
	return gui
end

-- Text printed on one face of a part.
function Util.surfaceText(part: BasePart, face: Enum.NormalId, lines: { Line }, background: Color3?): SurfaceGui
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Text"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.9, 0.86)
	frame.Position = UDim2.fromScale(0.05, 0.07)
	frame.BackgroundTransparency = if background then 0 else 1
	if background then
		frame.BackgroundColor3 = background
	end
	frame.BorderSizePixel = 0
	frame.Parent = gui
	stackLines(frame, lines)
	return gui
end

return Util
