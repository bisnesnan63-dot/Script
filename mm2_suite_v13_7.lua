--[[
    MM2 Suite v12  (Roblox Luau, executor script, Murder Mystery 2)

    Needs:    getnamecallmethod + (hookmetamethod OR getrawmetatable/setreadonly)   -> silent aim
    Optional: checkcaller, firetouchinterest / fireproximityprompt, writefile / readfile / isfile, gethui

    v13.7: watermark without the site name, the logo is R
    v13.6: visuals tab (fx): player esp, local, world, crosshair and tracer, ported from the uploaded script
    v13.5: fling returns to its spot: the spin's momentum is stopped, the root snaps back and is held there a few frames
    v13.4: sheriff silent aim: auto tune (ping + hits on the murderer picks the lead scale), fire when modes
    v12.13: gui in the reference look (black, small type, white checks, groups in the sidebar, a profile,
            a top watermark); the window is resizable: the corner grip, or the width / height sliders in presets
    v12.12: gui in the pasta look (nursultan.txt) with a phone layout: tab strip on small screens, round launcher,
            touch drag and sliders, compact watermark. the neverlose library is gone (the file is much smaller)
    v12.11: gui rebuilt on the neverlose ui library (ui.lua, embedded): tabs game funcs / esp & fov / target lock /
            ping & learning / look & binds. theme, wallpaper, colours card and config paste are gone (the library
            has its own config and a key list)
    v12.10: gui restyle to the fatality look: black palette with panels and outlines, sharper corners,
            dropdowns instead of arrow cycles, colours card (accent + 8 slots with a palette), insert bind
    v12.9: auras from the mm2 script: kill aura + kill all for the murderer, particle aura on your character
           (8 types, 6 colours)
    v12.8: script aim waits for the target to settle: reaction, predictor warm-up, both outside the lobby,
           range, a clear line at the moment of the shot. a switch or a wall step restarts the reaction
    v12.7: script aim card (game funcs): the mm2 script sheriff engine, wall checker + auto shot + prediction,
           max defaults; while on it owns the gun shots and the built-in silent / auto shoot step aside
    v12.6: map vote card (game funcs): pick maps by priority, optional die-first reset, walks into the
           vote zone of the first open pick and holds there until the window closes
    v12.5: aim accuracy - self-calibration is OFF by default (it could not see the server timing and drifted the
           lead by up to +200 ms; now experimental, +-30 ms, never saved, old saved values are dropped),
           accel model respects the walk-speed cap and stops instead of moving backwards, input models are muted
           when MoveDirection is not replicated, shot line also tries sideways offsets (bimodal juke clouds),
           target hysteresis no longer mixes studs and pixels, force shoot feeds the real lead to the calibration
    v12.4: fixes - hook is re-installed after a rejoin (stale status), role poll no longer blocks on a silent server,
           force shoot / grab gun can no longer get stuck, GUI frame loop is pcall-safe, auto profile no longer
           overwrites hand-tuned values on innocent -> sheriff, safe mode always starts ON (file or imported string)
           new: shot feedback toast, learn mode for unknown shot remotes (debug log), config copy / import
    v12.3: ESP redesign (nameplate cards); dead / lobby players are re-checked and dropped from ESP + roles;
           background image now sits under translucent panels (panel opacity), jpg + retry fixes
    v12.2: flat look (no gradients), one consistent corner scale, web images (tab icons + your own background)
    v12.1: white (light) theme, rounder edges, small design polish
           settings > appearance > theme (or bind a key in settings > keybinds)

    What is new in v12
      - one persistent __namecall hook (no stacking on re-execute), cached remote classification,
        checkcaller bypass for the script's own calls, arguments shape learned from your real shots
      - Kalman-filter velocity models + shot-time re-solve (fresh time, knife flight time)
      - every frame is wrapped in pcall (an error can no longer leave a stale aim point)
      - Safe mode: teleport / origin-spoof features locked, rate limits, reaction jitter
      - random object names, ESP lives in the hidden gui container (nothing is added to characters)
      - compact hub GUI: sidebar tabs, two-column cards, check rows with "..." drawers, search,
        accent themes, ui scale, keybinds, toasts, player lock list

    Insert = show / hide the hub (rebind it in settings)
]]

local VERSION = "v13.7"
local ENV = (getgenv and getgenv()) or _G

if ENV.MM2SuiteUnload then
    pcall(ENV.MM2SuiteUnload)
    ENV.MM2SuiteUnload = nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

local running = true
local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    connections[#connections + 1] = c
    return c
end

---------------------------------------------------------------------
-- Small helpers / capability probe
---------------------------------------------------------------------
local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function rname()
    local t = {}
    for i = 1, 10 do t[i] = string.char(math.random(97, 122)) end
    return table.concat(t)
end

local function flat(v) return Vector3.new(v.X, 0, v.Z) end

local function lookCF(from, to)
    if (to - from).Magnitude < 0.1 then return CFrame.new(from) end
    return CFrame.lookAt(from, to)
end

local function curCam() return workspace.CurrentCamera end

local CAP = {
    hook = (getnamecallmethod ~= nil) and (hookmetamethod ~= nil or (getrawmetatable ~= nil and setreadonly ~= nil)),
    caller = checkcaller ~= nil,
    touch = firetouchinterest ~= nil,
    prompt = fireproximityprompt ~= nil,
    fs = (writefile ~= nil) and (readfile ~= nil) and (isfile ~= nil),
    hui = gethui ~= nil,
}

local COLORS = {
    Murderer = Color3.fromRGB(255, 70, 80),
    Sheriff = Color3.fromRGB(70, 150, 255),
    Innocent = Color3.fromRGB(70, 230, 130),
    GunDrop = Color3.fromRGB(255, 214, 10),
}

---------------------------------------------------------------------
-- Settings, options, config file
---------------------------------------------------------------------
local DEFAULTS = {
    SafeMode = true,        -- locks teleport / origin-spoof features, adds rate limits
    AutoProfile = true,
    Debug = false,
    ShotToast = true,

    ESP = true, ESPInfo = true, ESPGun = true, ESPHideLobby = true, ESPPulse = true,
    ShowFOV = true, ShowAim = true, HUD = true, MurdererAlert = true, AlertDist = 40,

    SilentAim = true, TargetMode = "Auto", AimPart = "Chest", AimHeight = 0,
    FOV = 150, MaxDist = 250, VisibleOnly = false, AvoidInnocents = true,

    Prediction = true, AimMode = "Smart", PredStrength = 1, Interp = 70,
    HitRadius = 1.6, Overshoot = 2.5, Calibrate = false,
    AutoTune = true,

    AutoShoot = false, SmartShot = true, ShotCooldown = 2.0, Reaction = 180, MaxShootDist = 160,
    FireMode = "Auto",
    WallBypass = false, SmartOrigin = true, OriginMax = 30,

    ThrowSilent = true, PredMurder = true, KnifeFlight = true, KnifeSpeed = 110,

    AutoGun = true, GrabMode = "Remote only",

    MapVote = false, MapVoteDie = false, MapVotePicks = "", MapVoteSeen = "",
    ScriptAim = false, ScriptPredict = true, ScriptWall = true, ScriptAuto = true, ScriptForce = false,
    ScriptStandOff = 15, ScriptDelay = 0, ScriptReact = 180, ScriptRange = 160,
    KillAura = false, KillAll = false, KillDistance = 30,
    WorldAura = false, AuraType = "angel", AuraColor = "ice",

    FlingTime = 0.8,
    FxEsp = false, FxBox = false, FxBoxFill = false, FxBoxColor = "white", FxBoxStyle = "Static",
    FxSkel = false, FxSkelColor = "white",
    FxArrows = false, FxArrowSize = 24, FxArrowRange = 300,
    FxArrowInno = "green", FxArrowMurder = "red", FxArrowSheriff = "blue",
    FxName = false, FxNameColor = "white", FxAvatar = false, FxDist = false,
    FxGlow = false, FxGlowInno = "green", FxGlowMurder = "red", FxGlowSheriff = "blue",
    FxMat = false, FxMatStyle = "ForceField",
    FxFlags = false, FxFlagsGrad = false,
    FxChina = false, FxChinaColor = "violet",
    FxBacktrack = false, FxBacktrackColor = "cyan",
    FxSelfChams = false, FxSelfStyle = "ForceField", FxSelfColor = "cyan",
    FxToolChams = false, FxToolStyle = "ForceField", FxToolColor = "pink",
    FxLanding = false, FxLandColor = "cyan", FxLandOpacity = 0.8, FxLandDur = 0.82,
    FxFullbright = false,
    FxAmbient = false, FxAmbientColor = "dim",
    FxFog = false, FxFogStart = 0, FxFogEnd = 1000, FxFogColor = "silver",
    FxTime = false, FxClock = 12,
    FxExposure = false, FxExposureValue = 0,
    FxSky = false, FxSkyName = "Jungle",
    FxShader = false, FxShaderType = "morning",
    FxParticles = false, FxParticleType = "Snow", FxParticleColor = "ice", FxParticleRate = 250,
    FxCross = false, FxCrossHide = false, FxCrossGap = 4, FxCrossLen = 8, FxCrossThick = 2, FxCrossSpin = 0,
    FxCrossColor = "white", FxCrossOutline = "black",
    FxTracer = false, FxTracerColor = "sky", FxTracerDur = 1,
}

local FX_COLORS = { "white", "black", "red", "orange", "yellow", "green", "cyan", "blue", "violet", "pink", "gray", "amber", "sky", "ice", "silver", "dim" }
local OPTS = {
    TargetMode = { "Auto", "Murderer", "Cursor", "Nearest" },
    AimPart = { "Chest", "Head", "Body" },
    AimMode = { "Smart", "Simple" },
    GrabMode = { "Remote only", "Remote + hop" },
    FireMode = { "Auto", "Strict", "Loose", "Instant" },
    FxBoxStyle = { "Static", "Corners" },
    FxMatStyle = { "ForceField", "Flat", "Chromatic" },
    FxSelfStyle = { "ForceField", "Flat", "Chromatic" },
    FxToolStyle = { "ForceField", "Flat", "Chromatic" },
    FxSkyName = { "Purple", "Red night", "Blossom", "Jungle", "Foggy", "Galaxy", "Anime", "Minecraft" },
    FxShaderType = { "morning", "midday", "evening", "night" },
    FxParticleType = { "Snow", "Sakura" },
    FxBoxColor = FX_COLORS, FxSkelColor = FX_COLORS, FxArrowInno = FX_COLORS, FxArrowMurder = FX_COLORS,
    FxArrowSheriff = FX_COLORS, FxNameColor = FX_COLORS, FxGlowInno = FX_COLORS, FxGlowMurder = FX_COLORS,
    FxGlowSheriff = FX_COLORS, FxChinaColor = FX_COLORS, FxBacktrackColor = FX_COLORS, FxSelfColor = FX_COLORS,
    FxToolColor = FX_COLORS, FxLandColor = FX_COLORS, FxAmbientColor = FX_COLORS, FxFogColor = FX_COLORS,
    FxParticleColor = FX_COLORS, FxCrossColor = FX_COLORS, FxCrossOutline = FX_COLORS, FxTracerColor = FX_COLORS,
}

local RANGES = {
    AimHeight = { -3, 3 }, FOV = { 30, 400 }, MaxDist = { 50, 500 },
    PredStrength = { 0.5, 2 }, Interp = { 0, 200 }, HitRadius = { 0.8, 3 }, Overshoot = { 0, 8 },
    ShotCooldown = { 0.8, 6 }, Reaction = { 0, 500 }, MaxShootDist = { 30, 400 },
    OriginMax = { 10, 150 }, KnifeSpeed = { 30, 400 }, AlertDist = { 10, 120 },
    ScriptStandOff = { 0, 40 }, ScriptDelay = { 0, 600 }, ScriptReact = { 0, 500 }, ScriptRange = { 30, 400 },
    KillDistance = { 5, 60 }, FlingTime = { 0.2, 2 },
    FxArrowSize = { 10, 60 }, FxArrowRange = { 40, 520 }, FxLandOpacity = { 0, 1 }, FxLandDur = { 0.1, 3 },
    FxClock = { 0, 24 }, FxExposureValue = { -5, 5 }, FxFogStart = { 0, 1000 }, FxFogEnd = { 0, 1000 },
    FxParticleRate = { 20, 900 }, FxCrossGap = { 0, 20 }, FxCrossLen = { 2, 30 }, FxCrossThick = { 1, 5 },
    FxCrossSpin = { 0, 10 }, FxTracerDur = { 0.2, 3 },
}

local ACCENTS = {
    { "violet", Color3.fromRGB(139, 92, 246) },
    { "blue", Color3.fromRGB(59, 130, 246) },
    { "mint", Color3.fromRGB(16, 185, 129) },
    { "rose", Color3.fromRGB(244, 63, 94) },
    { "amber", Color3.fromRGB(245, 158, 11) },
}

local Settings = {}
for k, v in pairs(DEFAULTS) do Settings[k] = v end

local UI = {
    accent = nil,                              -- { r, g, b } once the colour picker was used (nil = default)
    binds = { menu = "RightShift", shoot = "" },   -- hub key / force shoot key ("" = none)
}

-- learned server-delay correction, per 50 ms ping bucket (survives re-execute even without a config file)
local lag = ENV.MM2Lag or { bias = 0, buckets = {} }
ENV.MM2Lag = lag
-- a lead correction left over from an older run (it could reach +200 ms) is cut down to the new safe range
lag.bias = clamp(tonumber(lag.bias) or 0, -0.03, 0.03)
for k, v in pairs(lag.buckets) do lag.buckets[k] = clamp(tonumber(v) or 0, -0.03, 0.03) end
-- auto tune: hits / shots per ping bucket (100 ms) and overall, for each lead scale (see TUNE)
lag.tune = type(lag.tune) == "table" and lag.tune or {}
lag.tuneAll = type(lag.tuneAll) == "table" and lag.tuneAll or {}

local ST = {
    forced = nil,        -- player locked from the Players tab
    dropRoot = nil,      -- cached GunDrop instance
    listening = nil,     -- keybind capture callback
    dirtyAt = nil,       -- config autosave marker
    gui = nil, toast = nil,
    errCount = 0, lastErr = nil,
    shape = {},          -- argument shapes of your real shots (kind -> table.pack)
    lastAim = nil, lastAimT = 0,
    profile = "none",
    ownRemote = nil, ownUntil = 0,
    role = "Innocent",
}

local CFG_FILE = "mm2suite_v12.json"

local function markDirty() ST.dirtyAt = os.clock() end

local function setSetting(key, v)
    if Settings[key] == v then return end
    Settings[key] = v
    markDirty()
end

local function buildConfigData()
    -- the learned lag is session-only now: it is not written to the file
    return { app = "mm2suite", v = 13, settings = Settings, ui = UI }
end

local function saveConfig()
    if not CAP.fs then return false end
    local ok = pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(buildConfigData())) end)
    return ok
end

local function inList(list, v)
    for _, x in ipairs(list) do if x == v then return true end end
    return false
end

local function applyConfigData(data, fromImport)
    if type(data.settings) == "table" then
        for k, dv in pairs(DEFAULTS) do
            local v = data.settings[k]
            if v ~= nil and type(v) == type(dv) then
                if OPTS[k] and not inList(OPTS[k], v) then v = dv end
                if RANGES[k] and type(v) == "number" then v = clamp(v, RANGES[k][1], RANGES[k][2]) end
                Settings[k] = v
            end
        end
    end
    if type(data.ui) == "table" then
        local acc = data.ui.accent
        if type(acc) == "table" and #acc == 3 and type(acc[1]) == "number" and type(acc[2]) == "number" and type(acc[3]) == "number" then
            UI.accent = { clamp(math.floor(acc[1]), 0, 255), clamp(math.floor(acc[2]), 0, 255), clamp(math.floor(acc[3]), 0, 255) }
        end
        if type(data.ui.w) == "number" then UI.w = clamp(math.floor(data.ui.w), 260, 900) end
        if type(data.ui.h) == "number" then UI.h = clamp(math.floor(data.ui.h), 220, 800) end
        if type(data.ui.binds) == "table" then
            for k in pairs(UI.binds) do
                if type(data.ui.binds[k]) == "string" then UI.binds[k] = data.ui.binds[k] end
            end
        end
    end
    -- v12.5: calibration is opt-in now; older files carried it switched on
    if (tonumber(data.v) or 0) < 13 then Settings.Calibrate = false end
    -- safe mode always starts ON: a config file or a pasted string can never switch it off behind your back
    Settings.SafeMode = true
end

local function loadConfig()
    if not CAP.fs then return false end
    local ok, raw = pcall(function()
        if isfile(CFG_FILE) then return readfile(CFG_FILE) end
        return nil
    end)
    if not ok or type(raw) ~= "string" then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then return false end
    applyConfigData(data, false)
    return true
end

loadConfig()

local function getGuiParent()
    local ok, p = pcall(function()
        if gethui then return gethui() end
        return game:GetService("CoreGui")
    end)
    if ok and p then return p end
    return lp:WaitForChild("PlayerGui")
end
local guiParent = getGuiParent()

local function notify(text, kind)
    if ST.toast then pcall(ST.toast, text, kind) end
end

-- Safe mode gates (the risky features only work when Safe mode is off)
local function wallBypassOn() return Settings.WallBypass and not Settings.SafeMode end
local function hopGrabOn() return Settings.GrabMode == "Remote + hop" and not Settings.SafeMode end
local function shotCooldown()
    local c = Settings.ShotCooldown
    if Settings.SafeMode and c < 1.8 then c = 1.8 end
    return c + math.random() * 0.4
end
local function reactionDelay()
    local r = Settings.Reaction / 1000
    if Settings.SafeMode and r < 0.12 then r = 0.12 end
    return r * (0.7 + math.random() * 0.6)
end

---------------------------------------------------------------------
-- Roles: the game's own player-data first (other players' Backpacks do not replicate), tools as fallback
---------------------------------------------------------------------
local roleData, dataOk = {}, false
local dataAt = 0                                  -- when roleData was last refreshed from the server
local life = setmetatable({}, { __mode = "k" })   -- [player] = { dead, spawnAt, conn }
local roleRemote
local lastPoll, pollWanted = 0, true
local ROLE_REMOTES = { "GetPlayerData", "GetCurrentPlayerData", "GetCurrentDataPlayer" }

-- Lobby detection. Players standing in the lobby still carry the last round's role in the server data,
-- so a "dead sheriff" kept showing at the spawn. Uses the Lobby model's bounding box; if there is no
-- such model it falls back to the distance to SpawnLocation parts.
local lobby = { at = -100, cf = nil, half = nil, spawns = {}, scanned = false }

local function scanSpawns()
    lobby.scanned = true
    task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("SpawnLocation") then lobby.spawns[#lobby.spawns + 1] = d end
            n = n + 1
            if n % 3000 == 0 then task.wait() end
        end
    end)
    connect(workspace.DescendantAdded, function(d)
        if d:IsA("SpawnLocation") then lobby.spawns[#lobby.spawns + 1] = d end
    end)
end

local function refreshLobby()
    lobby.at = os.clock()
    lobby.cf, lobby.half = nil, nil
    local m = workspace:FindFirstChild("Lobby")
    if m and m:IsA("Model") then
        local ok, cf, size = pcall(m.GetBoundingBox, m)
        if ok and cf then lobby.cf, lobby.half = cf, size / 2 + Vector3.new(4, 12, 4) end
    elseif not lobby.scanned then
        scanSpawns()
    end
end

local function inLobby(pos)
    if os.clock() - lobby.at > 15 then refreshLobby() end
    if lobby.cf then
        local r = lobby.cf:PointToObjectSpace(pos)
        local h = lobby.half
        return math.abs(r.X) <= h.X and math.abs(r.Y) <= h.Y and math.abs(r.Z) <= h.Z
    end
    for _, sp in ipairs(lobby.spawns) do
        if sp.Parent then
            local d = pos - sp.Position
            if math.abs(d.Y) < 14 and Vector3.new(d.X, 0, d.Z).Magnitude < 22 then return true end
        end
    end
    return false
end

local function roleFromData(plr)
    local e = roleData[plr.Name]
    if type(e) ~= "table" or type(e.Role) ~= "string" then return nil end
    -- entries flagged dead are ignored (the Humanoid.Died tracking below covers the rest)
    if e.Dead == true then return nil end
    local L = life[plr]
    if L then
        if L.dead then return nil end
        -- data fetched before this life began is stale: wait for the re-poll that every respawn triggers
        if L.spawnAt and roleRemote and dataAt < L.spawnAt then return nil end
    end
    if Settings.ESPHideLobby then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp and inLobby(hrp.Position) then return nil end
    end
    local r = e.Role
    if r == "Murderer" then return "Murderer" end
    if r == "Sheriff" or r == "Hero" then return "Sheriff" end
    return "Innocent"
end

local function hasTool(plr, name)
    local bp = plr:FindFirstChild("Backpack")
    local ch = plr.Character
    return (bp and bp:FindFirstChild(name)) or (ch and ch:FindFirstChild(name))
end

local function getRole(plr)
    local r = roleFromData(plr)
    if r then return r end
    if hasTool(plr, "Knife") then return "Murderer" end
    if hasTool(plr, "Gun") then return "Sheriff" end
    return "Innocent"
end

local function isAlive(plr)
    local ch = plr.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and ch:FindFirstChild("HumanoidRootPart")
end

-- a player counts as "in the round" only while alive, not flagged dead by the server, and not in the lobby
local function inRound(plr)
    local hrp = isAlive(plr)
    if not hrp then return false end
    local L = life[plr]
    if L and L.dead then return false end
    local e = roleData[plr.Name]
    if type(e) == "table" and e.Dead == true then return false end
    if Settings.ESPHideLobby and inLobby(hrp.Position) then return false end
    return true
end

local pdc = RS:FindFirstChild("PlayerDataChanged", true)
if pdc and not pdc:IsA("RemoteEvent") then pdc = nil end

local lastFind = -100
local pollSeq, appliedSeq = 0, 0
local pollBusy, pollSince = false, 0

local function findRoleRemote()
    if roleRemote and roleRemote.Parent then return roleRemote end
    roleRemote = nil
    -- the recursive search is slow: while nothing is found it runs once per 5 s
    if os.clock() - lastFind < 5 then return nil end
    lastFind = os.clock()
    for _, n in ipairs(ROLE_REMOTES) do
        local r = RS:FindFirstChild(n, true)
        if r and r:IsA("RemoteFunction") then roleRemote = r break end
    end
    return roleRemote
end

-- InvokeServer yields: it runs in its own thread, so a server that never answers cannot freeze the poll loop.
-- An answer that arrives late (older than data we already applied) is dropped.
local function pollRoles()
    local rf = findRoleRemote()
    if not rf then return end
    if pollBusy and os.clock() - pollSince < 6 then
        pollWanted = true -- the previous call is still waiting: try again a bit later
        return
    end
    local started = os.clock()
    pollSeq = pollSeq + 1
    local seq = pollSeq
    pollBusy, pollSince, lastPoll = true, started, started
    task.spawn(function()
        local ok, data = pcall(rf.InvokeServer, rf)
        if seq == pollSeq then pollBusy = false end
        if ok and type(data) == "table" and seq > appliedSeq and running then
            appliedSeq = seq
            roleData = data
            dataOk = true
            dataAt = started -- the moment the question left, not the moment the answer came back
        end
    end)
end

task.spawn(function()
    while running do
        task.wait(0.25)
        -- the PlayerDataChanged event does the real work; polling is only a safety net
        local gap = pollWanted and 1.5 or (pdc and 10 or 4)
        if os.clock() - lastPoll >= gap then
            pollWanted = false
            pcall(pollRoles)
        end
    end
end)

if pdc then
    connect(pdc.OnClientEvent, function(d)
        if type(d) == "table" then
            roleData = d
            dataOk = true
            dataAt = os.clock()
            appliedSeq = pollSeq -- polls that left before this event carry older data
        end
    end)
end

---------------------------------------------------------------------
-- Character list + shared raycast params (rebuilt only when characters change)
---------------------------------------------------------------------
local RP = RaycastParams.new()
RP.FilterType = Enum.RaycastFilterType.Exclude
RP.RespectCanCollide = true
local charDirty, charAt = true, 0

local function markChars() charDirty = true end
local function getRP()
    if charDirty or os.clock() - charAt > 2 then
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then list[#list + 1] = plr.Character end
        end
        RP.FilterDescendantsInstances = list
        charDirty, charAt = false, os.clock()
    end
    return RP
end

-- every life is tracked: a death (or a respawn) forces a fresh role poll, so nobody keeps an old role
local function hookChar(plr, ch, initial)
    local L = life[plr]
    if not L then
        L = {}
        life[plr] = L
    end
    if L.conn then
        pcall(function() L.conn:Disconnect() end)
        L.conn = nil
    end
    L.dead = false
    if not initial then
        L.spawnAt = os.clock() -- role data older than this life is stale
        lastPoll, pollWanted = 0, true
    end
    task.spawn(function()
        local hum = ch:FindFirstChildOfClass("Humanoid") or ch:WaitForChild("Humanoid", 8)
        if not hum or not running then return end
        if hum.Health <= 0 then L.dead = true end
        L.conn = hum.Died:Connect(function()
            L.dead = true
            L.diedAt = os.clock()
            lastPoll, pollWanted = 0, true -- the server data changes when somebody dies: re-check everyone
        end)
    end)
end

local function watchPlayer(plr)
    connect(plr.CharacterAdded, function(ch)
        markChars()
        hookChar(plr, ch, false)
    end)
    connect(plr.CharacterRemoving, markChars)
    if plr.Character then hookChar(plr, plr.Character, true) end
end
for _, plr in ipairs(Players:GetPlayers()) do watchPlayer(plr) end
connect(Players.PlayerAdded, function(plr) watchPlayer(plr) markChars() end)
connect(Players.PlayerRemoving, function(plr)
    markChars()
    if ST.forced == plr then ST.forced = nil end
end)

-- gun drop cache (no more recursive FindFirstChild every few frames)
local function getDropPart()
    local d = ST.dropRoot
    if not d or not d.Parent then
        ST.dropRoot = nil
        return nil
    end
    if d:IsA("BasePart") then return d end
    return d:FindFirstChildWhichIsA("BasePart", true)
end
do
    local existing = workspace:FindFirstChild("GunDrop", true)
    if existing then ST.dropRoot = existing end
    connect(workspace.DescendantAdded, function(inst)
        if inst.Name == "GunDrop" then ST.dropRoot = inst end
    end)
    connect(workspace.DescendantRemoving, function(inst)
        if inst == ST.dropRoot then ST.dropRoot = nil end
    end)
end
---------------------------------------------------------------------
-- ESP (objects live in the hidden gui container, characters are never touched)
---------------------------------------------------------------------
local FX = {}   -- fx visuals: engine block before buildHub, shot hook in dispatch
local ESP = { root = nil, objs = {}, drop = nil }

local function espRoot()
    if ESP.root and ESP.root.Parent then return ESP.root end
    local f = Instance.new("Folder")
    f.Name = rname()
    f.Parent = guiParent
    ESP.root = f
    return f
end

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function round(o, r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }, o) end

local CARD_BG = Color3.fromRGB(10, 10, 15)
local ESP_STYLE = {
    Murderer = { fill = 0.5, card = 0.08, pulse = true },
    Sheriff = { fill = 0.62, card = 0.12, pulse = false },
    Innocent = { fill = 0.86, card = 0.34, pulse = false },
    Gun = { fill = 0.45, card = 0.08, pulse = true },
}
local ROLE_CHIP = { Murderer = "M", Sheriff = "S", Innocent = "I", Gun = "G" }

-- one marker = a highlight + a small nameplate card (role chip, name, role / distance, health bar)
local function makeESP(root)
    local hl = mk("Highlight", {
        Name = rname(), FillTransparency = 0.8, OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    }, root)
    local tag = mk("BillboardGui", {
        Name = rname(), Size = UDim2.fromOffset(150, 50), StudsOffset = Vector3.new(0, 3.2, 0),
        AlwaysOnTop = true, LightInfluence = 0,
    }, root)
    local card = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(126, 38),
        BackgroundColor3 = CARD_BG, BackgroundTransparency = 0.2, BorderSizePixel = 0,
    }, tag)
    round(card, 9)
    local line = mk("UIStroke", { Thickness = 1.5, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
    local scale = mk("UIScale", {}, card)
    local chip = mk("TextLabel", {
        Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(6, 5), BorderSizePixel = 0,
        Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = CARD_BG,
    }, card)
    round(chip, 7)
    local name = mk("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -42, 0, 16), Position = UDim2.fromOffset(36, 3),
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)
    local sub = mk("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -42, 0, 12), Position = UDim2.fromOffset(36, 19),
        Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(190, 190, 206),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local hpBg = mk("Frame", {
        Position = UDim2.fromOffset(6, 32), Size = UDim2.new(1, -12, 0, 3),
        BackgroundColor3 = Color3.fromRGB(44, 44, 58), BorderSizePixel = 0,
    }, card)
    round(hpBg, 2)
    local hpFill = mk("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(80, 230, 130), BorderSizePixel = 0,
    }, hpBg)
    round(hpFill, 2)
    return {
        hl = hl, tag = tag, card = card, line = line, scale = scale, chip = chip, name = name, sub = sub,
        hpBg = hpBg, hpFill = hpFill, info = nil, tween = nil,
    }
end

local function destroyESP(o)
    if o.tween then pcall(function() o.tween:Cancel() end) end
    pcall(function() o.hl:Destroy() end)
    pcall(function() o.tag:Destroy() end)
end

local function espClearAll()
    for plr, o in pairs(ESP.objs) do
        destroyESP(o)
        ESP.objs[plr] = nil
    end
    if ESP.drop then
        destroyESP(ESP.drop)
        ESP.drop = nil
    end
end

local function hexOf(c)
    return string.format("#%02x%02x%02x",
        math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function espLayout(o, info)
    if o.info == info then return end
    o.info = info
    if info then
        o.card.Size = UDim2.fromOffset(126, 38)
        o.chip.Size, o.chip.Position = UDim2.fromOffset(24, 24), UDim2.fromOffset(6, 5)
        o.name.Position = UDim2.fromOffset(36, 3)
        o.sub.Visible, o.hpBg.Visible = true, true
    else
        o.card.Size = UDim2.fromOffset(112, 26)
        o.chip.Size, o.chip.Position = UDim2.fromOffset(18, 18), UDim2.fromOffset(5, 4)
        o.name.Position = UDim2.fromOffset(30, 5)
        o.sub.Visible, o.hpBg.Visible = false, false
    end
end

local function espPulse(o, on, base)
    if on then
        if not o.tween then
            o.hl.FillTransparency = base
            o.tween = TweenService:Create(o.hl,
                TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                { FillTransparency = math.min(base + 0.3, 0.95) })
            o.tween:Play()
        end
    else
        if o.tween then
            pcall(function() o.tween:Cancel() end)
            o.tween = nil
        end
        o.hl.FillTransparency = base
    end
end

local function espStyle(o, kind, c, nameText, subText, info, hpFrac, dist)
    local st = ESP_STYLE[kind]
    o.hl.FillColor, o.hl.OutlineColor = c, c
    o.line.Color = c
    o.chip.BackgroundColor3 = c
    o.card.BackgroundTransparency = st.card
    espPulse(o, st.pulse and Settings.ESPPulse, st.fill)
    espLayout(o, info)
    local chipText = ROLE_CHIP[kind]
    if o.chip.Text ~= chipText then o.chip.Text = chipText end
    if o.name.Text ~= nameText then o.name.Text = nameText end
    if info then
        if o.sub.Text ~= subText then o.sub.Text = subText end
        if hpFrac then
            local f = math.clamp(hpFrac, 0, 1)
            o.hpBg.Visible = true
            o.hpFill.Size = UDim2.fromScale(f, 1)
            o.hpFill.BackgroundColor3 = Color3.fromRGB(255, 84, 84):Lerp(Color3.fromRGB(80, 230, 130), f)
        else
            o.hpBg.Visible = false
        end
    end
    o.scale.Scale = math.clamp(1.12 - dist / 300, 0.64, 1) -- far tags shrink a little
end

local function espUpdate()
    if not Settings.ESP then
        if next(ESP.objs) or ESP.drop then espClearAll() end
        return
    end
    local root = espRoot()
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local ch = plr.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local head = ch and ch:FindFirstChild("Head")
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            -- re-checked on every pass: a dead player, or one that is back in the lobby, loses the marker at once
            if hum and head and hrp and inRound(plr) then
                seen[plr] = true
                local o = ESP.objs[plr]
                if not o then
                    o = makeESP(root)
                    ESP.objs[plr] = o
                end
                if o.hl.Adornee ~= ch then o.hl.Adornee = ch end
                if o.tag.Adornee ~= head then o.tag.Adornee = head end
                local role = getRole(plr)
                local dist = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0
                local hpFrac = hum.MaxHealth > 0 and hum.Health / hum.MaxHealth or 1
                espStyle(o, role, COLORS[role], plr.DisplayName,
                    string.format("%s  %dm", role:lower(), math.floor(dist + 0.5)),
                    Settings.ESPInfo, hpFrac, dist)
            end
        end
    end
    for plr, o in pairs(ESP.objs) do
        if not seen[plr] then
            destroyESP(o)
            ESP.objs[plr] = nil
        end
    end

    -- dropped gun
    local part = Settings.ESPGun and getDropPart() or nil
    if part then
        local o = ESP.drop
        if not o then
            o = makeESP(root)
            ESP.drop = o
        end
        if o.hl.Adornee ~= part then o.hl.Adornee = part end
        if o.tag.Adornee ~= part then o.tag.Adornee = part end
        local dist = myHrp and (myHrp.Position - part.Position).Magnitude or 0
        espStyle(o, "Gun", COLORS.GunDrop, "Gun", string.format("dropped  %dm", math.floor(dist + 0.5)),
            Settings.ESPInfo, nil, dist)
    elseif ESP.drop then
        destroyESP(ESP.drop)
        ESP.drop = nil
    end
end

task.spawn(function()
    while running do
        task.wait(0.12)
        pcall(espUpdate)
    end
end)

---------------------------------------------------------------------
-- Ping tracker (smoothed RTT + jitter, the prediction horizon follows it)
---------------------------------------------------------------------
local PING = { rtt = 0.1, jitter = 0.01, stable = true, hist = {} }

local function samplePing()
    local raw
    local ok = pcall(function()
        raw = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    if not ok or not raw or raw <= 0 then
        raw = nil
        pcall(function() raw = lp:GetNetworkPing() * 2 end)
    end
    if not raw then return end
    raw = clamp(raw, 0.01, 0.8)
    local h = PING.hist
    h[#h + 1] = raw
    if #h > 60 then table.remove(h, 1) end
    local dev = math.abs(raw - PING.rtt)
    local a = (dev > 0.08) and 0.15 or 0.3 -- a sudden jump is trusted slowly, a drift quickly
    PING.rtt = PING.rtt + (raw - PING.rtt) * a
    PING.jitter = PING.jitter + (dev - PING.jitter) * 0.15
    PING.stable = PING.jitter < 0.03
end

task.spawn(function()
    while running do
        task.wait(0.1)
        pcall(samplePing)
    end
end)

---------------------------------------------------------------------
-- Aim state shared with the hook / GUI
---------------------------------------------------------------------
local A = {
    pos = nil, origin = nil, plr = nil, name = nil, mean = nil,
    blocked = false, cover = 0, visible = false, stable = true, lagging = false,
    model = "-", weights = {}, T = 0.2, lead = 0.2, t = 0,
}
local FR = nil        -- last frame context (used to re-solve at the exact moment of the shot)
local statesByPlr = setmetatable({}, { __mode = "k" })

local function clearAim()
    A.pos, A.origin, A.plr, A.name, A.mean = nil, nil, nil, nil, nil
    A.blocked, A.cover, A.visible, A.lagging, A.stable = false, 0, false, false, true
    A.model, A.weights = "-", {}
    FR = nil
end

---------------------------------------------------------------------
-- Targeting
---------------------------------------------------------------------
local function aimOrigin2D()
    if UIS.TouchEnabled and not UIS.MouseEnabled then
        return curCam().ViewportSize / 2
    end
    return UIS:GetMouseLocation()
end

local function cursorDist(pos)
    local v, onScreen = curCam():WorldToViewportPoint(pos)
    if not onScreen then return math.huge end
    return (Vector2.new(v.X, v.Y) - aimOrigin2D()).Magnitude
end

local function effectiveMode(role)
    local mode = Settings.TargetMode
    if mode == "Auto" then
        -- murderer: whoever is closest to the cursor. everyone else: the murderer
        return role == "Murderer" and "Cursor" or "Murderer"
    end
    return mode
end

local function hasLOS(ch)
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end
    local params = getRP()
    local from = myHrp.Position + Vector3.new(0, 1.5, 0)
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local head = ch:FindFirstChild("Head")
    for _, p in ipairs({ hrp, head }) do
        if p and not workspace:Raycast(from, p.Position - from, params) then
            return true
        end
    end
    return false
end

local function pickTarget(role)
    local forced = ST.forced
    if forced then
        if forced.Parent and isAlive(forced) then return forced end
        ST.forced = nil
    end
    local mode = effectiveMode(role)
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position
    local best, bestScore, curScore
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local hrp = isAlive(plr)
            if hrp then
                local dist = myPos and (myPos - hrp.Position).Magnitude or 0
                local score
                if dist <= Settings.MaxDist then
                    if mode == "Murderer" then
                        if getRole(plr) == "Murderer" then score = dist end
                    elseif mode == "Cursor" then
                        local d = cursorDist(hrp.Position)
                        if d <= Settings.FOV then score = d end
                    else
                        score = dist
                    end
                end
                if score and Settings.VisibleOnly and not hasLOS(plr.Character) then score = nil end
                if score then
                    if plr == A.plr then curScore = score end
                    if not bestScore or score < bestScore then best, bestScore = plr, score end
                end
            end
        end
    end
    if not best and mode == "Murderer" then pollWanted = true end
    -- hysteresis: do not flip between two close candidates every frame
    -- slack in the units of the score: pixels for Cursor mode, studs otherwise
    local slack = (mode == "Cursor") and 18 or 6
    if best and A.plr and best ~= A.plr and curScore and curScore <= bestScore * 1.35 + slack then
        return A.plr
    end
    return best
end

---------------------------------------------------------------------
-- Predictor ensemble (weights learned per player) + Kalman velocity models
---------------------------------------------------------------------
local PRED = { "window", "inst", "input", "avg", "blend", "damped", "accel", "flip", "stop", "kfs", "kfa" }
local PRIOR = { inst = 1, window = 1.5, kfs = 1.6, kfa = 1.4, blend = 2, input = 3, accel = 3, damped = 3, avg = 3, flip = 3, stop = 6 }

local lagState = { cur = nil }
local calib = { hits = 0, shots = 0 }
local shotLog = {}

-- auto tune: lead scales for the murderer's shots. index 1 = the normal lead (the default, tried first), then nearest first.
-- each murderer shot is scored by the death within 0.8 s + ping (a hit); the scale with the best hit rate for this ping wins
local TUNE = { 1, 0.85, 1.15, 0.7, 1.35, 0.4, 0 }
local function tuneBucket() return math.floor(PING.rtt / 0.1) end
local function tuneCounts(row, i)
    local r = row and row[i]
    if type(r) ~= "table" then return 0, 0 end
    return tonumber(r[1]) or 0, tonumber(r[2]) or 0
end
-- UCB over hits / shots: this ping's own counts plus half of the overall ones, untried scales get their turn
local function tuneBest()
    local rowB = lag.tune[tuneBucket()]
    local stats, total = {}, 0
    for i = 1, #TUNE do
        local hb, nb = tuneCounts(rowB, i)
        local hg, ng = tuneCounts(lag.tuneAll, i)
        stats[i] = { h = hb + 0.5 * hg, n = nb + 0.5 * ng }
        total = total + stats[i].n
    end
    local best, bestV = 1, -math.huge
    for i = 1, #TUNE do
        local st = stats[i]
        local v = (st.h + 1) / (st.n + 2) + 0.35 * math.sqrt(math.log(total + 2) / (st.n + 1))
        if v > bestV then best, bestV = i, v end
    end
    return best
end
local function tuneRecord(bucket, cand, hit)
    local function add(row, key)
        if type(row[key]) ~= "table" then row[key] = { 0, 0 } end
        row[key][1] = (tonumber(row[key][1]) or 0) + (hit and 1 or 0)
        row[key][2] = (tonumber(row[key][2]) or 0) + 1
    end
    if type(lag.tune[bucket]) ~= "table" then lag.tune[bucket] = {} end
    add(lag.tune[bucket], cand)
    add(lag.tuneAll, cand)
end
local function tuneLine()
    if not Settings.AutoTune then return "tune off" end
    local best = tuneBest()
    local h, n = tuneCounts(lag.tune[tuneBucket()], best)
    return string.format("tune x%.2f  %d / %d hits  ping %d ms", TUNE[best], h, n, math.floor(PING.rtt * 1000 + 0.5))
end

-- 2-state constant-velocity Kalman filter (one axis): position measurement, white acceleration noise q
local function kfNew() return { p = 0, v = 0, p00 = 1, p01 = 0, p11 = 900, init = false } end

local function kfStep(k, z, dt, q, r)
    if not k.init then
        k.p, k.v, k.init = z, 0, true
        k.p00, k.p01, k.p11 = r, 0, 900
        return
    end
    local dt2 = dt * dt
    local p = k.p + k.v * dt
    local p00 = k.p00 + dt * (2 * k.p01 + dt * k.p11) + q * dt2 * dt2 / 4
    local p01 = k.p01 + dt * k.p11 + q * dt2 * dt / 2
    local p11 = k.p11 + q * dt2
    local s = p00 + r
    local k0, k1 = p00 / s, p01 / s
    local y = z - p
    k.p = p + k0 * y
    k.v = k.v + k1 * y
    k.p00 = (1 - k0) * p00
    k.p01 = (1 - k0) * p01
    k.p11 = p11 - k1 * p01
end

local function velOver(hist, win)
    local b = hist[#hist]
    if not b then return nil end
    local a = b
    for i = #hist - 1, 1, -1 do
        if b.t - hist[i].t > win then break end
        a = hist[i]
    end
    local span = b.t - a.t
    if span < 0.03 then return nil end
    return (b.p - a.p) / span
end

local function newState()
    local err = {}
    for _, n in ipairs(PRED) do err[n] = PRIOR[n] or 3 end
    return {
        hist = {}, err = err, queue = {}, flips = {}, takeoffs = {},
        lastDir = nil, lastPush = 0, lastMoveT = os.clock(), lastPos = nil,
        prevState = nil, vPrev = Vector3.zero, tPrev = nil, acc = Vector3.zero,
        hrpH = 3, kf = nil,
    }
end

-- horizontal displacement over horizon T for each model
-- constant-acceleration model that obeys the game: speed never goes above the walk speed, and an
-- acceleration that opposes the motion stops the body (it does not push it backwards)
local function accelDisp(c, T)
    local v = flat(c.vInst)
    local a = flat(c.acc)
    local cap = math.max(c.maxSpeed or 16, v.Magnitude)
    local pos, t = Vector3.zero, 0
    while t < T - 1e-6 do
        local dt = math.min(0.05, T - t)
        local nv = v + a * dt
        if v.Magnitude > 0.01 and nv:Dot(v) < 0 then
            nv = Vector3.zero
            a = Vector3.zero
        end
        if nv.Magnitude > cap then nv = nv.Unit * cap end
        pos = pos + (v + nv) * (0.5 * dt)
        v = nv
        t = t + dt
    end
    return pos
end

local DISP = {
    window = function(c, T) return flat(c.vWin) * T end,
    inst   = function(c, T) return flat(c.vInst) * T end,
    input  = function(c, T) return flat(c.vInput) * T end,
    avg    = function(c, T) return flat(c.vLong) * T end,
    blend  = function(c, T) return (flat(c.vInst) + flat(c.vInput)) * 0.5 * T end,
    damped = function(c, T) return flat(c.vWin) * T * 0.6 end,
    accel  = accelDisp,
    kfs    = function(c, T) return c.vKS * T end,
    kfa    = function(c, T) return c.vKA * T end,
    flip   = function(c, T)
        -- strafe rhythm: expect the next direction reversal at the same interval as the last one
        local v = flat(c.vInst)
        local n = #c.flips
        if n >= 2 then
            local period = c.flips[n] - c.flips[n - 1]
            if period > 0.1 and period < 1.2 then
                local tf = period - (c.now - c.flips[n])
                if tf > 0 and tf < T then
                    return v * (2 * tf - T)
                end
            end
        end
        return v * T
    end,
    stop   = function() return Vector3.zero end,
}

-- vertical channel: real gravity, landing on the ground below, optional bhop re-jump
local function simY(y0, vy, T, groundY, rejumpV)
    local g = workspace.Gravity
    local y, v, t = y0, vy, 0
    while t < T do
        local dt = math.min(1 / 30, T - t)
        v = v - g * dt
        y = y + v * dt
        t = t + dt
        if groundY and y <= groundY and v < 0 then
            y = groundY
            v = rejumpV or 0
        end
    end
    return y
end

-- reads everything the replication gives us about the target this frame
local function updateState(S, hrp, hum, now, params, rtt)
    local cur = hrp.Position
    local lastH = S.hist[#S.hist]
    if lastH and (cur - lastH.p).Magnitude > 12 then
        S.hist, S.queue, S.flips, S.takeoffs = {}, {}, {}, {}
        S.lastDir, S.lastPos, S.kf = nil, nil, nil
    end
    S.hist[#S.hist + 1] = { t = now, p = cur }
    while #S.hist > 2 and now - S.hist[1].t > 0.6 do
        table.remove(S.hist, 1)
    end

    -- Kalman velocity: smooth (kfs) and agile (kfa) variants, the ensemble decides which one to trust
    local kf = S.kf
    if not kf then
        kf = { t = now, sx = kfNew(), sz = kfNew(), ax = kfNew(), az = kfNew() }
        S.kf = kf
    end
    local dt = now - kf.t
    if dt > 0.3 then
        kf.sx, kf.sz, kf.ax, kf.az = kfNew(), kfNew(), kfNew(), kfNew()
        dt = 0.016
    end
    if dt >= 0.002 or not kf.sx.init then
        kfStep(kf.sx, cur.X, dt, 500, 0.12)
        kfStep(kf.sz, cur.Z, dt, 500, 0.12)
        kfStep(kf.ax, cur.X, dt, 4000, 0.12)
        kfStep(kf.az, cur.Z, dt, 4000, 0.12)
        kf.t = now
    end
    local vKS = Vector3.new(kf.sx.v, 0, kf.sz.v)
    local vKA = Vector3.new(kf.ax.v, 0, kf.az.v)
    if vKS.Magnitude > 60 then vKS = vKS.Unit * 60 end
    if vKA.Magnitude > 60 then vKA = vKA.Unit * 60 end

    -- the slower the replication (high ping), the longer the window needed to see a real velocity
    local vWin = velOver(S.hist, clamp(0.12 + rtt * 0.4, 0.14, 0.3)) or Vector3.zero
    local vLong = velOver(S.hist, 0.5) or vWin
    local vInst = hrp.AssemblyLinearVelocity -- replicated instantaneous velocity
    if vInst.Magnitude < 0.5 and vWin.Magnitude > 3 then vInst = vWin end
    if vInst.Magnitude > 60 then vInst = vInst.Unit * 60 end
    local vInput = flat(hum.MoveDirection) * hum.WalkSpeed

    -- smoothed horizontal acceleration
    if S.tPrev and now - S.tPrev >= 0.016 then
        local a = (flat(vInst) - flat(S.vPrev)) / (now - S.tPrev)
        if a.Magnitude > 60 then a = a.Unit * 60 end
        S.acc = S.acc:Lerp(a, 0.3)
    end
    S.vPrev, S.tPrev = vInst, now

    -- direction reversals (A/D strafe, juke rhythm)
    local h = flat(vInst)
    if h.Magnitude > 4 then
        local d = h.Unit
        if S.lastDir and d:Dot(S.lastDir) < -0.3 then
            local n = #S.flips
            if n == 0 or now - S.flips[n] > 0.08 then
                S.flips[n + 1] = now
                if #S.flips > 6 then table.remove(S.flips, 1) end
            end
        end
        S.lastDir = d
    end

    -- humanoid state: takeoffs and bhop rhythm
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Jumping and S.prevState ~= Enum.HumanoidStateType.Jumping then
        S.takeoffs[#S.takeoffs + 1] = now
        if #S.takeoffs > 4 then table.remove(S.takeoffs, 1) end
    end
    S.prevState = state
    local bhop = false
    local n = #S.takeoffs
    if n >= 3 and now - S.takeoffs[n] < 0.7
        and S.takeoffs[n] - S.takeoffs[n - 1] < 0.9
        and S.takeoffs[n - 1] - S.takeoffs[n - 2] < 0.9 then
        bhop = true
    end

    -- ground below (for landing prediction)
    local airborne = hum.FloorMaterial == Enum.Material.Air
    local groundY
    local hit = workspace:Raycast(cur, Vector3.new(0, -200, 0), params)
    if hit then
        if not airborne then S.hrpH = clamp(cur.Y - hit.Position.Y, 1.5, 6) end
        groundY = hit.Position.Y + S.hrpH
    end

    -- lag: replicated velocity says "moving" but the position stopped updating
    if S.lastPos and (cur - S.lastPos).Magnitude > 0.05 then S.lastMoveT = now end
    S.lastPos = cur
    local lagging = (now - S.lastMoveT > (0.1 + rtt * 0.6)) and vInst.Magnitude > 3

    return {
        now = now, vWin = vWin, vLong = vLong, vInst = vInst, vInput = vInput, vKS = vKS, vKA = vKA,
        acc = S.acc, flips = S.flips, airborne = airborne, state = state,
        groundY = groundY, bhop = bhop, lagging = lagging, maxSpeed = hum.WalkSpeed * 1.1,
    }
end

-- score finished predictions against where the player really went
local function evaluate(S, cur, now)
    local q = S.queue
    while q[1] and q[1].due <= now do
        local e = table.remove(q, 1)
        local actual = flat(cur - e.base)
        local k = math.min((0.2 / math.max(e.T or 0.2, 0.05)) ^ 2, 16) -- error scaled to a 0.2 s horizon
        for _, n in ipairs(PRED) do
            local d = actual - e.disp[n]
            local e2 = math.min(d:Dot(d) * k, 100)
            S.err[n] = S.err[n] * 0.85 + e2 * 0.15
        end
    end
end

-- centre-horizon displacement of every model at horizon T (buildSamples scores with it; the error model
-- learns on the unscaled horizon, so the auto tune never touches it)
local function dispAt(ctx, T)
    local out = {}
    for _, n in ipairs(PRED) do
        local d = DISP[n](ctx, T)
        local lim = 52 * T
        if d.Magnitude > lim then d = d.Unit * lim end
        out[n] = d
    end
    return out
end

local function pushQueue(S, base, disp, due, now, T)
    if now - S.lastPush < 0.05 or #S.queue > 40 then return end
    S.lastPush = now
    S.queue[#S.queue + 1] = { due = due, base = base, disp = disp, T = T }
end

-- how unsure we are about *when* the server looks at the target
local function timeSigma()
    return clamp(PING.jitter * 0.75 + 0.012 + PING.rtt * 0.06, 0.015, 0.08)
end

-- one weighted position guess per model (walls / floor clip them)
local function buildSamples(S, ctx, hum, hrp, basePos, T, params, sigma)
    local simple = Settings.AimMode == "Simple"
    -- the server looks at the target at T +- sigma (ping jitter): guess positions at all three moments
    local Hs, Fs
    if simple then
        Hs, Fs = { T }, { 1 }
    else
        Hs, Fs = { math.max(T - sigma, 0.01), T, T + sigma }, { 0.25, 0.5, 0.25 }
    end
    local mid = (#Hs + 1) / 2

    -- centre-horizon displacement of every model (used to score the models later)
    local dispAll = dispAt(ctx, T)

    -- vertical channel (shared): real gravity, landing on the ground below, bhop re-jump
    local vy = ctx.vInst.Y
    if ctx.airborne and math.abs(vy) < 0.1 then vy = ctx.vWin.Y end
    local jumpV = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
    local jumping = ctx.state == Enum.HumanoidStateType.Jumping
    if jumping and vy < 5 then vy = jumpV end -- takeoff shows in the state before the velocity
    local nearGround = ctx.groundY and (hrp.Position.Y - ctx.groundY) < 0.6
    local needSim = (ctx.airborne and not nearGround) or jumping or ctx.bhop
    local y0 = hrp.Position.Y
    local dys = {}
    for k, h in ipairs(Hs) do
        dys[k] = needSim
            and clamp(simY(y0, vy, h, ctx.groundY, ctx.bhop and jumpV or nil) - y0, -6, 6)
            or 0
    end

    local samples, total, byName = {}, 0, {}
    for _, n in ipairs(PRED) do
        local w = 1 / ((0.3 + S.err[n]) ^ 2)
        if simple then w = (n == "inst") and 1 or 0 end
        if ctx.lagging then w = (n == "stop") and 1 or 0 end
        -- MoveDirection of other players may not replicate: a fast target with zero input means the input models are blind
        if (n == "input" or n == "blend") and ctx.vInst.Magnitude > 6 and ctx.vInput.Magnitude < 0.5 then w = 0 end
        if w > 0 then
            local ps = {}
            for k, h in ipairs(Hs) do
                local d = DISP[n](ctx, h)
                local lim = 52 * h
                if d.Magnitude > lim then d = d.Unit * lim end
                ps[k] = basePos + d + Vector3.new(0, dys[k], 0)
            end
            -- walls / floor: one ray along the longest guess, every guess is cut at that distance
            local far = ps[#ps] - basePos
            if far.Magnitude > 0.05 then
                local hit = workspace:Raycast(basePos, far, params)
                if hit then
                    local cut = math.max((hit.Position - basePos).Magnitude - 0.6, 0)
                    for k = 1, #ps do
                        local v = ps[k] - basePos
                        if v.Magnitude > cut and v.Magnitude > 0 then
                            ps[k] = basePos + v.Unit * cut
                        end
                    end
                end
            end
            for k = 1, #ps do
                local wk = w * Fs[k]
                samples[#samples + 1] = { pos = ps[k], w = wk, name = n, c = (k == mid) }
                total = total + wk
                byName[n] = (byName[n] or 0) + wk
            end
        end
    end

    local bestW, bestN = 0, "-"
    for n, w in pairs(byName) do
        byName[n] = w / total
        if byName[n] > bestW then bestW, bestN = byName[n], n end
    end
    for _, smp in ipairs(samples) do smp.w = smp.w / total end
    return samples, dispAll, bestN, byName
end

---------------------------------------------------------------------
-- Line solver: pick the shot line that covers the most probable positions
---------------------------------------------------------------------
-- a player is tall and thin: a vertical miss counts less than a sideways one
local function lineDist(p, o, d)
    local t = (p - o):Dot(d)
    if t < 0 then t = 0 end
    local v = p - (o + d * t)
    return math.sqrt(v.X * v.X + v.Z * v.Z + (v.Y * 0.55) ^ 2), t
end

local function playerOnLine(o, aim, exclude)
    local dir = aim - o
    local len = dir.Magnitude
    if len < 1 then return false end
    local d = dir / len
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr ~= exclude then
            local hrp = isAlive(plr)
            if hrp then
                local p = hrp.Position
                local t = (p - o):Dot(d)
                if t > 1 and t < len - 1 and (p - (o + d * t)).Magnitude < 2.4 then
                    return true
                end
            end
        end
    end
    return false
end

-- returns aim point, line blocked by another player, probability mass covered (0..1)
local function solveAim(origin, samples, targetPlr, role)
    if not samples or #samples == 0 then return nil end
    local check = Settings.AvoidInnocents and role ~= "Murderer"

    local mean = Vector3.zero
    for _, s in ipairs(samples) do mean = mean + s.pos * s.w end
    local cands = { mean }
    for _, s in ipairs(samples) do
        if s.c then cands[#cands + 1] = s.pos end
    end
    -- sideways offsets of the mean line: a cloud with two heavy lobes (juke left / right) is covered better
    -- by a line shifted toward the heavier lobe than by the line through the middle of nothing
    local flatDir = flat(mean - origin)
    if flatDir.Magnitude > 1 then
        local perp = Vector3.new(-flatDir.Z, 0, flatDir.X).Unit * (Settings.HitRadius * 0.5)
        cands[#cands + 1] = mean + perp
        cands[#cands + 1] = mean - perp
    end

    local radius = Settings.HitRadius
    local bestAim, bestScore, bestBlocked
    for _, c in ipairs(cands) do
        local dir = c - origin
        local len = dir.Magnitude
        if len > 0.5 then
            local d = dir / len
            local score, sumT, sumW = 0, 0, 0
            for _, s in ipairs(samples) do
                local dist, t = lineDist(s.pos, origin, d)
                if dist < radius then
                    local f = s.w * (1 - dist / radius)
                    score = score + f
                    sumT = sumT + t * f
                    sumW = sumW + f
                end
            end
            if sumW > 0 then
                local aim = origin + d * (sumT / sumW)
                local blocked = (check and playerOnLine(origin, aim, targetPlr)) or false
                local better = false
                if not bestAim then
                    better = true
                elseif bestBlocked and not blocked then
                    better = true
                elseif blocked == bestBlocked and score > bestScore then
                    better = true
                end
                if better then
                    bestAim = origin + d * (sumT / sumW + (Settings.Overshoot or 0))
                    bestScore, bestBlocked = score, blocked
                end
            end
        end
    end
    if not bestAim then return mean, false, 0, mean end
    return bestAim, bestBlocked, bestScore, mean
end
---------------------------------------------------------------------
-- Self-calibration: after a miss, find when the target actually crossed the shot line
---------------------------------------------------------------------
local function syncBucket()
    local b = math.floor(PING.rtt / 0.05)
    if b ~= lagState.cur then
        if lagState.cur then lag.buckets[lagState.cur] = lag.bias end
        lagState.cur = b
        if lag.buckets[b] then lag.bias = lag.buckets[b] end
    end
end

-- how far ahead of what you see the server looks: round trip + interpolation delay + jitter margin
local function pingHorizon()
    syncBucket()
    local T = (PING.rtt + Settings.Interp / 1000 + PING.jitter * 0.5) * Settings.PredStrength + (Settings.Calibrate and lag.bias or 0)
    return clamp(T, 0.02, 0.6)
end

local function registerShot(origin, aim, plr, lead, cand)
    -- shots aimed with a prediction only (prediction off = no lead to learn): the trail timing (calibration,
    -- normal lead only) and the hit outcome (auto tune)
    local calibrate = (Settings.Calibrate and not cand and FR and FR.pred) and true or false
    if not (calibrate or cand) or not plr then return end
    local dir = aim - origin
    if dir.Magnitude < 0.5 then return end
    -- the death shows up about one round trip after the shot: the window grows with the ping (capped at +1 s)
    shotLog[#shotLog + 1] = { t = os.clock(), o = origin, d = dir.Unit, plr = plr, lead = lead, trail = {},
        cand = cand, bucket = tuneBucket(), calib = calibrate, win = 0.8 + math.min(tonumber(PING.rtt) or 0, 1) }
    if #shotLog > 8 then table.remove(shotLog, 1) end
end

local function distToRay(p, o, d)
    local t = (p - o):Dot(d)
    if t < 0 then return (p - o).Magnitude end
    return (p - (o + d * t)).Magnitude
end

local function finalizeShot(sh)
    if not sh.plr.Parent then return end
    local hum = sh.plr.Character and sh.plr.Character:FindFirstChildOfClass("Humanoid")
    local dead = (not hum) or hum.Health <= 0
    if sh.cand then tuneRecord(sh.bucket, sh.cand, dead) end
    if not sh.calib then return end
    calib.shots = calib.shots + 1
    if dead then
        calib.hits = calib.hits + 1
        return
    end
    local pts = {}
    for _, s in ipairs(sh.trail) do
        local rel = s.t - sh.t
        if rel >= 0 and rel <= 0.5 then pts[#pts + 1] = { rel = rel, p = s.p } end
    end
    if #pts < 4 then return end
    -- timing can only be read from a straight run: skip standing / turning targets
    local path = 0
    for i = 2, #pts do path = path + (pts[i].p - pts[i - 1].p).Magnitude end
    local chord = (pts[#pts].p - pts[1].p).Magnitude
    if chord < 2 or path > chord * 1.25 then return end
    local bestD, bestT = math.huge, nil
    for _, s in ipairs(pts) do
        local dist = distToRay(s.p, sh.o, sh.d)
        if dist < bestD then bestD, bestT = dist, s.rel end
    end
    if bestT and bestD < 3.5 then
        -- the line would have hit at local time +bestT: pull the lead toward it
        lag.bias = clamp(lag.bias + 0.25 * (bestT - sh.lead), -0.03, 0.03)
        if lagState.cur then lag.buckets[lagState.cur] = lag.bias end
        markDirty()
    end
end

local function updateShots(now)
    for i = #shotLog, 1, -1 do
        local sh = shotLog[i]
        if now - sh.t <= (sh.win or 0.8) then
            local ch = sh.plr.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp and #sh.trail < 80 then
                sh.trail[#sh.trail + 1] = { t = now, p = hrp.Position }
            end
        else
            table.remove(shotLog, i)
            pcall(finalizeShot, sh)
        end
    end
end

local function resetLearning()
    lag.bias = 0
    for k in pairs(lag.buckets) do lag.buckets[k] = nil end
    calib.hits, calib.shots = 0, 0
    for k in pairs(lag.tune) do lag.tune[k] = nil end
    for k in pairs(lag.tuneAll) do lag.tuneAll[k] = nil end
    for k in pairs(statesByPlr) do statesByPlr[k] = nil end
    markDirty()
end

---------------------------------------------------------------------
-- Per-frame aim update (always inside pcall: an error never leaves a stale aim point)
---------------------------------------------------------------------
local function predOn(role)
    if role == "Murderer" then return Settings.PredMurder end
    return Settings.Prediction
end

local function myHead()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    return hrp.Position + Vector3.new(0, 1.5, 0), hrp
end

local function weightedMean(samples)
    local mean = Vector3.zero
    for _, s in ipairs(samples) do mean = mean + s.pos * s.w end
    return mean
end

local function updateAim(now)
    updateShots(now)
    local role = getRole(lp)
    ST.role = role
    local params = getRP()
    local m = pickTarget(role)
    if not m then
        clearAim()
        return
    end

    local ch = m.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then
        clearAim()
        return
    end
    local S = statesByPlr[m]
    if not S then
        S = newState()
        statesByPlr[m] = S
    end

    local ctx = updateState(S, hrp, hum, now, params, PING.rtt)
    evaluate(S, hrp.Position, now)

    local basePos
    if Settings.AimPart == "Head" then
        local head = ch:FindFirstChild("Head")
        basePos = head and head.Position or (hrp.Position + Vector3.new(0, 1.5, 0))
    elseif Settings.AimPart == "Chest" then
        local chest = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
        basePos = chest and chest.Position or (hrp.Position + Vector3.new(0, 0.9, 0))
    else
        basePos = hrp.Position
    end
    basePos = basePos + Vector3.new(0, Settings.AimHeight, 0)

    -- horizon: my round trip + their replication/interpolation delay + learned correction
    local pred = predOn(role)
    local Tbase = pingHorizon()
    -- auto tune scales it for the murderer, prediction shots only: the lead scale the hits picked for this ping
    local cand, scale = nil, 1
    if pred and Settings.AutoTune and getRole(m) == "Murderer" then
        cand = tuneBest()
        scale = TUNE[cand]
    end
    local T = Tbase * scale
    A.lead = T
    A.T = T

    local samples, dispAll, best, byName
    if pred then
        samples, dispAll, best, byName = buildSamples(S, ctx, hum, hrp, basePos, T, params, timeSigma())
        -- the error model always learns at the normal horizon: the tuned one only moves the aim
        if not ctx.lagging then
            pushQueue(S, hrp.Position, scale == 1 and dispAll or dispAt(ctx, Tbase), now + Tbase, now, Tbase)
        end
    else
        samples, best, byName = { { pos = basePos, w = 1, name = "now", c = true } }, "-", {}
    end
    local mean = weightedMean(samples)

    -- wall bypass origin (only when Safe mode is off): a point next to the target with a clear line to it
    local headPos, myHrp = myHead()
    local bypassOrigin
    if wallBypassOn() and myHrp then
        local cands = {}
        local vflat = flat(ctx.vInst)
        if Settings.SmartOrigin and vflat.Magnitude > 4 and not ctx.airborne then
            cands[#cands + 1] = mean - vflat.Unit * 3.5 + Vector3.new(0, 1, 0)
        end
        local toMe = myHrp.Position - mean
        if toMe.Magnitude > 4 then
            cands[#cands + 1] = mean + toMe.Unit * 3 + Vector3.new(0, 1, 0)
        else
            cands[#cands + 1] = myHrp.Position
        end
        for i, c in ipairs(cands) do
            local near = (c - myHrp.Position).Magnitude <= Settings.OriginMax
            if near and (i == #cands or not workspace:Raycast(mean, c - mean, params)) then
                bypassOrigin = c
                break
            end
        end
    end

    local origin = bypassOrigin or headPos
    local aim, blocked, cover
    if origin then
        aim, blocked, cover = solveAim(origin, samples, m, role)
    end
    if not aim then aim, blocked, cover = mean, false, 0 end

    A.pos, A.origin, A.plr, A.name, A.mean = aim, bypassOrigin, m, m.DisplayName, mean
    A.blocked, A.cover = blocked, cover
    A.model, A.weights = best, byName
    A.lagging = ctx.lagging
    A.stable = (#S.flips == 0 or now - S.flips[#S.flips] > 0.5) and ctx.acc.Magnitude < 25
    A.visible = hasLOS(ch)
    A.t = now
    ST.lastAim, ST.lastAimT = aim, now

    FR = { S = S, ctx = ctx, hum = hum, hrp = hrp, basePos = basePos, plr = m, t = now, T = T,
        params = params, pred = pred, cand = cand }
end

connect(RunService.Heartbeat, function()
    local ok, err = pcall(updateAim, os.clock())
    if not ok then
        clearAim()
        ST.errCount = ST.errCount + 1
        ST.lastErr = tostring(err)
        if Settings.Debug and ST.errCount <= 5 then
            warn("[MM2 Suite] aim update error: " .. tostring(err))
        end
    end
end)

-- Re-solve the aim at the exact moment of the shot: fresh time offset, knife flight time, real origin
local function computeShotAim(kind, from)
    local F = FR
    if not (F and F.plr and F.plr.Parent and F.hrp and F.hrp.Parent) then return nil end
    local role = ST.role or "Innocent"
    local extra = clamp(os.clock() - F.t, 0, 0.12)
    local sigma = timeSigma()
    local function build(t)
        if not F.pred then return { { pos = F.basePos, w = 1, name = "now", c = true } } end
        local s = buildSamples(F.S, F.ctx, F.hum, F.hrp, F.basePos, t, F.params, sigma)
        return s
    end
    local T = F.T + extra
    local samples
    if kind == "knife" and Settings.KnifeFlight and F.pred then
        local pos = A.mean or F.basePos
        for _ = 1, 2 do
            T = F.T + extra + (pos - from).Magnitude / math.max(Settings.KnifeSpeed, 20)
            samples = build(T)
            pos = weightedMean(samples)
        end
    else
        samples = build(T)
    end
    local aim, blocked, cover = solveAim(from, samples, F.plr, role)
    return aim, cover, T, F.plr, (F.pred and F.cand) or nil
end

---------------------------------------------------------------------
-- Silent aim hook: ONE persistent __namecall hook, the logic is swapped through ENV.MM2Dispatch
---------------------------------------------------------------------
local setNC = setnamecallmethod or function() end
local newcc = newcclosure or function(f) return f end
local remoteKind = setmetatable({}, { __mode = "k" })

local function classify(inst)
    local cls = inst.ClassName
    if cls ~= "RemoteEvent" and cls ~= "UnreliableRemoteEvent" and cls ~= "RemoteFunction" then
        return false
    end
    local n = inst.Name
    local lower = n:lower()
    local p, depth = inst.Parent, 0
    while p and depth < 4 do
        if p.Name == "Knife" and lower:find("throw") then return "knife" end
        p = p.Parent
        depth = depth + 1
    end
    if n == "Shoot" or n == "CreateBeam" then return "gun" end
    p, depth = inst.Parent, 0
    while p and depth < 4 do
        -- only the remotes that carry a shot, not every remote inside the tool
        if p.Name == "Gun" and (n == "RemoteFunction" or lower:find("shoot") or lower:find("fire")) then
            return "gun"
        end
        p = p.Parent
        depth = depth + 1
    end
    return false
end

local function firstCFramePos(...)
    for i = 1, select("#", ...) do
        local a = select(i, ...)
        if typeof(a) == "CFrame" then return a.Position end
    end
    return nil
end

-- Handles the known shot formats:
--   (CFrame origin, CFrame target) / (Vector3 target) / (1, Vector3, "key")
-- origin (optional) replaces the first CFrame -> wall bypass
local function buildArgs(target, origin, ...)
    local args = table.pack(...)
    local cfIdx = {}
    local hasV3 = false
    for i = 1, args.n do
        local t = typeof(args[i])
        if t == "Vector3" then
            args[i] = target
            hasV3 = true
        elseif t == "CFrame" then
            cfIdx[#cfIdx + 1] = i
        end
    end
    if #cfIdx >= 2 then
        local from = origin or args[cfIdx[1]].Position
        if (target - from).Magnitude > 0.1 then
            args[cfIdx[1]] = lookCF(from, target)
        end
        for k = 2, #cfIdx do
            args[cfIdx[k]] = CFrame.new(target)
        end
    elseif #cfIdx == 1 and not hasV3 then
        args[cfIdx[1]] = CFrame.new(target)
    end
    return args
end

local function logCall(remote, ...)
    local args = table.pack(...)
    local parts = {}
    for i = 1, args.n do
        parts[#parts + 1] = typeof(args[i]) .. ":" .. tostring(args[i])
    end
    print("[MM2 Suite] " .. remote.Name .. " (" .. remote.ClassName .. ") <- " .. table.concat(parts, ", "))
end

-- small toast per redirected shot (never built inside the hook: deferred, and at most one per 0.8 s)
local function shotNote(text, kind)
    if not Settings.ShotToast then return end
    local now = os.clock()
    if now - (ST.noteT or 0) < 0.8 then return end
    ST.noteT = now
    task.defer(notify, text, kind)
end

-- learn mode (debug log on): a tool remote that sends a position but is not recognised gets printed once,
-- so a game update that renames the shot remote can be spotted without reading the whole script
local learned = setmetatable({}, { __mode = "k" })
local function learnRemote(remote, ...)
    if learned[remote] then return end
    local hasPos = false
    local parts = {}
    for i = 1, select("#", ...) do
        local t = typeof((select(i, ...)))
        if t == "Vector3" or t == "CFrame" then hasPos = true end
        parts[#parts + 1] = t
    end
    if not hasPos then return end
    if not remote:FindFirstAncestorOfClass("Tool") then return end
    learned[remote] = true
    print(string.format("[MM2 Suite] learn: unclassified shot-like remote %s (%s) args: %s",
        remote:GetFullName(), remote.ClassName, table.concat(parts, ", ")))
end

local function handleShot(kind, remote, ...)
    -- keep the real argument shape: force shoot replays it (no hard-coded keys that break on updates)
    ST.shape[kind] = table.pack(...)
    if Settings.Debug then logCall(remote, ...) end
    local silent
    if kind == "knife" then silent = Settings.ThrowSilent else silent = Settings.SilentAim end
    if not silent then return nil end

    local aim, fresh = A.pos, true
    if not aim and ST.lastAim and os.clock() - ST.lastAimT < 0.35 then
        aim, fresh = ST.lastAim, false -- target flickered out for a moment: reuse the last good aim
    end
    if not aim then
        if Settings.Debug then print("[MM2 Suite] shot NOT redirected: no target") end
        shotNote("no target: shot unchanged", "warn")
        return nil
    end

    local headPos = myHead()
    local origin = wallBypassOn() and A.origin or nil
    local from = origin or firstCFramePos(...) or headPos
    local target = aim
    if fresh and from then
        local plr = FR and FR.plr
        local ok, a, cover, T, _, cand = pcall(computeShotAim, kind, from)
        if ok and a then
            target = a
            shotNote(string.format("%s -> %s  lead %dms  cover %d%%", kind, tostring(A.name),
                math.floor((T or 0) * 1000), math.floor((cover or 0) * 100)), "good")
            if kind == "gun" then registerShot(from, a, plr, T, cand) end
            if Settings.Debug then
                print(string.format("[MM2 Suite] redirect %s -> %s | dist %.1f | lead %dms | cover %d%% | model %s",
                    kind, tostring(A.name), (a - from).Magnitude, math.floor((T or 0) * 1000),
                    math.floor((cover or 0) * 100), tostring(A.model)))
            end
        end
    end
    return buildArgs(target, origin, ...)
end

local function dispatch(oldNC, method, self, ...)
    if running and typeof(self) == "Instance" then
        local kind = remoteKind[self]
        if kind == nil then
            local ok, k = pcall(classify, self)
            kind = (ok and k) or false
            remoteKind[self] = kind
        end
        local own = (self == ST.ownRemote and os.clock() < ST.ownUntil)
            or (CAP.caller and checkcaller())
        if kind == false and Settings.Debug and not own then
            pcall(learnRemote, self, ...)
        end
        local scriptOwns = Settings.ScriptAim and kind ~= "knife"
        if kind and not own and not scriptOwns then
            local ok, res = pcall(handleShot, kind, self, ...)
            if ok and res then
                if kind == "gun" then pcall(FX.shot, res) end
                setNC(method)
                return oldNC(self, table.unpack(res, 1, res.n))
            elseif not ok and Settings.Debug then
                warn("[MM2 Suite] redirect failed, shot sent unchanged: " .. tostring(res))
            end
        end
        if kind == "gun" then pcall(FX.shot, table.pack(...)) end
    end
    setNC(method)
    return oldNC(self, ...)
end

local function installHook()
    if not CAP.hook then return "none" end
    -- the status lives in getgenv and survives a rejoin, the hook itself does not: compare the server
    if ENV.MM2HookStatus and ENV.MM2HookJob == game.JobId then return ENV.MM2HookStatus end
    local status = "none"
    local ok = pcall(function()
        if hookmetamethod then
            local old
            old = hookmetamethod(game, "__namecall", newcc(function(self, ...)
                local d = ENV.MM2Dispatch
                if d then
                    local m = getnamecallmethod()
                    if m == "FireServer" or m == "InvokeServer" then
                        return d(old, m, self, ...)
                    end
                end
                return old(self, ...)
            end))
            status = "hookmetamethod"
        else
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcc(function(self, ...)
                local d = ENV.MM2Dispatch
                if d then
                    local m = getnamecallmethod()
                    if m == "FireServer" or m == "InvokeServer" then
                        return d(old, m, self, ...)
                    end
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
            status = "rawmetatable"
        end
    end)
    if ok and status ~= "none" then
        ENV.MM2HookStatus = status
        ENV.MM2HookJob = game.JobId
    end
    return status
end

local hookStatus = installHook()
ENV.MM2Dispatch = dispatch
if hookStatus == "none" then
    warn("[MM2 Suite] Executor can't hook __namecall - click-to-shoot redirect unavailable, use the force shoot button.")
end

---------------------------------------------------------------------
-- Manual / auto shot
---------------------------------------------------------------------
local shooting = false

local function findGunRemote(gun)
    local r = gun:FindFirstChild("Shoot", true)
    if r then return r end
    for _, d in ipairs(gun:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and classify(d) == "gun" then return d end
    end
    return gun:FindFirstChild("RemoteFunction", true)
end

local function forceShootRaw()
    if not A.pos then return notify("no target", "warn") end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not char:FindFirstChild("Gun") then
        local bp = lp:FindFirstChild("Backpack")
        local g = bp and bp:FindFirstChild("Gun")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if g and hum then
            hum:EquipTool(g)
            task.wait(0.25)
        end
    end
    local gun = char:FindFirstChild("Gun")
    if not gun then
        return notify("you don't have the gun", "warn")
    end
    local remote = findGunRemote(gun)
    if not remote then
        return notify("shoot remote not found", "bad")
    end

    local headPos = myHead()
    local origin = wallBypassOn() and A.origin or nil
    local from = origin or headPos or hrp.Position
    -- the aim can vanish while the gun is being equipped: fall back to the last good point
    local target = A.pos or ST.lastAim
    if not target then return notify("no target", "warn") end
    local ok, a, _, Ts, _, cand = pcall(computeShotAim, "gun", from)
    local reg = nil
    if ok and a then
        target = a
        reg = { from = from, aim = a, plr = FR and FR.plr, lead = Ts or A.T, cand = cand }
    end

    local shape = ST.shape.gun
    local args
    if shape then
        args = buildArgs(target, origin, table.unpack(shape, 1, shape.n))
    elseif remote:IsA("RemoteFunction") then
        args = { 1, target, "AH2", n = 3 }
    else
        args = { lookCF(from, target), CFrame.new(target), n = 2 }
    end

    -- our own call must not be redirected a second time
    ST.ownRemote, ST.ownUntil = remote, os.clock() + 0.05
    local sent = true
    if remote:IsA("RemoteFunction") then
        task.spawn(function()
            ST.ownRemote, ST.ownUntil = remote, os.clock() + 0.05
            pcall(function() remote:InvokeServer(table.unpack(args, 1, args.n)) end)
        end)
    else
        sent = pcall(function() remote:FireServer(table.unpack(args, 1, args.n)) end)
    end
    -- learn from the shot only once it has actually left (a failed send leaves no false miss)
    if reg and sent then registerShot(reg.from, reg.aim, reg.plr, reg.lead, reg.cand) end
    notify("shot fired", "good")
end

-- the flag is released even when something inside throws (before: one error = force shoot + auto shoot dead)
local function forceShoot()
    if shooting then return end
    shooting = true
    local ok, err = pcall(forceShootRaw)
    shooting = false
    if not ok then
        ST.lastErr = tostring(err)
        if Settings.Debug then warn("[MM2 Suite] shot failed: " .. tostring(err)) end
    end
end

-- how much the prediction models must agree before auto shoot fires:
-- a jittery connection asks for more agreement, a steady runner for less
local function gateCover()
    if Settings.FireMode == "Strict" then return 0.8 end
    if Settings.FireMode == "Loose" then return 0.55 end
    local c = 0.5 + clamp(PING.jitter * 3, 0, 0.12)
    if A.stable then c = c - 0.08 end
    return c
end

task.spawn(function()
    local lastShot, readySince, fireAt = 0, nil, nil
    local cooldown = 0
    while running do
        task.wait(0.05)
        local now = os.clock()
        local ready = false
        if Settings.AutoShoot and not Settings.ScriptAim and A.pos and not shooting and not A.blocked and now - lastShot > cooldown
            and hasTool(lp, "Gun") and isAlive(lp) then
            local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local thrp = A.plr and A.plr.Character and A.plr.Character:FindFirstChild("HumanoidRootPart")
            local dist = (myHrp and thrp) and (myHrp.Position - thrp.Position).Magnitude or 0
            if dist <= Settings.MaxShootDist and (wallBypassOn() or A.visible) then
                readySince = readySince or now
                local waitMax = (Settings.FireMode == "Strict") and 4 or 1.5
                local calm = (not Settings.SmartShot) or (Settings.FireMode == "Instant")
                    or (A.cover >= gateCover() and not A.lagging) or (now - readySince > waitMax)
                ready = calm
            end
        end
        if ready then
            -- human-like reaction delay between "target is good" and the click
            fireAt = fireAt or (now + reactionDelay())
            if now >= fireAt then
                lastShot, fireAt, readySince = now, nil, nil
                cooldown = shotCooldown()
                pcall(forceShoot)
            end
        else
            fireAt = nil
            if not A.pos then readySince = nil end
        end
    end
end)

---------------------------------------------------------------------
-- Auto grab gun (remote touch only unless hop is unlocked)
---------------------------------------------------------------------
local grabbing = false
local lastGrabTry = 0

-- triggers the pickup without walking: simulated touch + proximity prompt, if the executor has them
local function touchDrop(hrp, drop)
    if firetouchinterest then
        firetouchinterest(hrp, drop, 0)
        task.wait()
        firetouchinterest(hrp, drop, 1)
    end
    local pp = drop:FindFirstChildWhichIsA("ProximityPrompt", true)
    if pp and fireproximityprompt then
        pcall(fireproximityprompt, pp)
    end
end

local function grabGunRaw(manual)
    if hasTool(lp, "Gun") or hasTool(lp, "Knife") then return end
    if getRole(lp) == "Murderer" or not isAlive(lp) then return end

    local drop = getDropPart()
    if not drop then
        if manual then notify("no gun on the ground", "warn") end
        return
    end
    if ST.grabFor ~= ST.dropRoot then
        ST.grabFor, ST.grabCount = ST.dropRoot, 0
    end
    if not manual then
        if ST.grabCount >= 6 or os.clock() - lastGrabTry < 1.5 then return end
    end
    lastGrabTry = os.clock()
    ST.grabCount = (ST.grabCount or 0) + 1

    local hrp = isAlive(lp)
    if not hrp then return end
    local canTouch = CAP.touch or CAP.prompt

    if canTouch then
        pcall(touchDrop, hrp, drop)
        local t0 = os.clock()
        while os.clock() - t0 < 0.4 and not hasTool(lp, "Gun") do
            task.wait(0.05)
        end
        if hasTool(lp, "Gun") then
            notify("gun grabbed", "good")
            return
        end
    end

    -- optional fallback (Safe mode off): hop to the gun for a moment, then come back
    if hopGrabOn() then
        local oldCF = hrp.CFrame
        hrp.CFrame = drop.CFrame
        pcall(touchDrop, hrp, drop)
        task.wait(0.2)
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = oldCF end
        if hasTool(lp, "Gun") then notify("gun grabbed (hop)", "good") end
    elseif manual then
        notify(canTouch and "remote grab didn't work" or "executor can't do remote touch", "warn")
    end
end

local function grabGun(manual)
    if grabbing then return end
    grabbing = true
    local ok, err = pcall(grabGunRaw, manual)
    grabbing = false
    if not ok then
        ST.lastErr = tostring(err)
        if Settings.Debug then warn("[MM2 Suite] grab failed: " .. tostring(err)) end
    end
end

task.spawn(function()
    while running do
        task.wait(0.4)
        if Settings.AutoGun then pcall(grabGun, false) end
    end
end)

---------------------------------------------------------------------
-- fling: spin your root part into the target, the contact throws them.
-- target = the locked player, else the nearest one in the round; or the sheriff / the murderer.
-- the spin runs for Settings.FlingTime, then the spin is stopped and your root goes back to where it was.
---------------------------------------------------------------------
local FLING = { busy = false, hold = 15 } -- hold: frames the root is kept at its spot after the spin

function FLING.pick(kind)
    if kind == nil then
        local locked = ST.forced
        if locked and locked ~= lp and inRound(locked) then return locked end
        local me = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not me then return nil end
        local best, bestD = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and inRound(plr) then
                local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (root.Position - me.Position).Magnitude
                    if d < bestD then best, bestD = plr, d end
                end
            end
        end
        return best
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and inRound(plr) and getRole(plr) == kind then return plr end
    end
    return nil
end

function FLING.run(plr, secs)
    if FLING.busy then return end
    local ch = lp.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local thrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not thrp then notify("fling: no target", "warn") return end
    FLING.busy = true
    local home = hrp.CFrame
    local spin = Instance.new("BodyAngularVelocity")
    spin.Name = "mm2Fling"
    spin.AngularVelocity = Vector3.new(0, 9e4, 0)
    spin.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    spin.P = 9e9
    spin.Parent = hrp
    local t0 = os.clock()
    local ok, err = pcall(function()
        while running and os.clock() - t0 < secs and hrp.Parent and thrp.Parent do
            hrp.CFrame = thrp.CFrame
            RunService.Heartbeat:Wait()
        end
    end)
    -- the spin leaves the root with its speed: stop the spin first, then kill the momentum, go back and hold
    -- the spot for a few frames (one snap back alone is undone by the leftover momentum)
    pcall(function()
        spin.AngularVelocity = Vector3.zero
        spin:Destroy()
    end)
    for _ = 1, FLING.hold do
        if not hrp.Parent then break end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = home
        end)
        RunService.Heartbeat:Wait()
    end
    FLING.busy = false
    if not ok then notify("fling failed: " .. tostring(err), "warn") end
end

function FLING.action(kind)
    if Settings.SafeMode then notify("locked by safe mode (settings)", "warn") return end
    local plr = FLING.pick(kind)
    if not plr then
        notify(kind and ("no " .. string.lower(kind) .. " in the round") or "no player in range", "warn")
        return
    end
    notify("fling " .. plr.DisplayName, "info")
    task.spawn(FLING.run, plr, Settings.FlingTime or 0.8)
end

---------------------------------------------------------------------
-- Role profiles: the script re-tunes itself when your role changes
---------------------------------------------------------------------
local refreshAll -- assigned by the GUI

local PROFILES = {
    -- sheriff, or an innocent who is about to pick the gun up: hit the murderer
    gun = {
        AimPart = "Chest", AimMode = "Smart", Prediction = true,
        AvoidInnocents = true, SmartOrigin = true, SmartShot = true,
        VisibleOnly = false, HitRadius = 1.6, Overshoot = 2.5,
    },
    -- murderer: knife throw at whoever is closest to the cursor
    knife = {
        AimPart = "Chest", AimMode = "Smart", PredMurder = true,
        AvoidInnocents = false,
        VisibleOnly = false, HitRadius = 1.8, Overshoot = 2,
    },
}

local function applyProfile(name)
    local p = PROFILES[name]
    if not p then return end
    for k, v in pairs(p) do Settings[k] = v end
    ST.profile = name
    markDirty()
    if refreshAll then pcall(refreshAll) end
end

task.spawn(function()
    local lastRole, lastProfile
    while running do
        task.wait(0.5)
        local role = getRole(lp)
        if role ~= lastRole then
            lastRole = role
            local want = (role == "Murderer") and "knife" or "gun"
            -- innocent -> sheriff keeps the same profile: values you tuned by hand are not overwritten again
            if Settings.AutoProfile and want ~= lastProfile then
                lastProfile = want
                applyProfile(want)
                notify("profile: " .. ST.profile .. " (" .. role:lower() .. ")", "info")
            end
        end
    end
end)

-- config autosave (debounced)
task.spawn(function()
    while running do
        task.wait(1.5)
        if ST.dirtyAt and os.clock() - ST.dirtyAt > 1.5 then
            ST.dirtyAt = nil
            pcall(saveConfig)
        end
    end
end)
---------------------------------------------------------------------
-- HUB GUI
---------------------------------------------------------------------
local unload -- assigned below

---------------------------------------------------------------------
-- map vote (game funcs > map vote)
-- walks you into the vote zone of the first open map from your priority list and holds you
-- there while the window is open. one run per window; re-arms when the window closes.
---------------------------------------------------------------------
local MV = { busy = false, armed = false, gen = 0, hold = nil, pads = nil, padsAt = -100 }

-- lists are stored as "|a|b|" strings so they survive the config file (DEFAULTS are strings)
local function mvList(key)
    local out = {}
    for name in string.gmatch(Settings[key] or "", "([^|]+)") do out[#out + 1] = name end
    return out
end

local function mvSave(key, list)
    Settings[key] = (#list > 0) and ("|" .. table.concat(list, "|") .. "|") or ""
    markDirty()
end

-- ASSUMPTION: vote pads live under a "VotePads" folder; each pad model has Pad (part), MapInfoGui
-- (enabled = window open) and VoteInfoGui.Container.MapName. fix only this function if your map differs.
local function mvPads()
    if os.clock() - MV.padsAt < 1 and MV.pads then return MV.pads end
    MV.padsAt = os.clock()
    local out = {}
    local vp = workspace:FindFirstChild("VotePads", true)
    if vp then
        for _, model in ipairs(vp:GetChildren()) do
            local pad = model:FindFirstChild("Pad")
            local info = model:FindFirstChild("MapInfoGui")
            local vote = model:FindFirstChild("VoteInfoGui")
            local box = vote and vote:FindFirstChild("Container")
            local title = box and box:FindFirstChild("MapName")
            if pad and pad:IsA("BasePart") and info and title then
                out[#out + 1] = { pad = pad, name = title.Text, open = info.Enabled == true }
            end
        end
    end
    MV.pads = out
    return out
end

local function mvOpen()
    for _, e in ipairs(mvPads()) do
        if e.open then return true end
    end
    return false
end

-- learns the names currently on the pads into the "seen" list (the picker only shows seen names)
local function mvScan()
    local seen = mvList("MapVoteSeen")
    local have = {}
    for _, n in ipairs(seen) do have[n] = true end
    local added = 0
    for _, e in ipairs(mvPads()) do
        if e.name ~= "" and not have[e.name] and #seen < 30 then
            seen[#seen + 1] = e.name
            have[e.name] = true
            added = added + 1
        end
    end
    mvSave("MapVoteSeen", seen)
    return added
end

-- first pick in priority order that is open on the pads right now
local function mvTarget()
    local pads = mvPads()
    for _, name in ipairs(mvList("MapVotePicks")) do
        for _, e in ipairs(pads) do
            if e.name == name and e.open then return e end
        end
    end
    return nil
end

local function mvRelease()
    if MV.hold then
        pcall(function() MV.hold:Disconnect() end)
        MV.hold = nil
    end
end

local function mvStop()
    MV.gen = MV.gen + 1 -- invalidates a running session
    mvRelease()
    MV.busy = false
end

local function mvKill()
    local char = lp.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
        pcall(function() hum.Health = 0 end)
    elseif char then
        pcall(function() char:BreakJoints() end)
    end
end

local function mvSession(gen, entry)
    local function alive()
        return running and MV.gen == gen and Settings.MapVote and not Settings.SafeMode
    end

    -- die first: reset into the lobby, then walk to the zone
    if Settings.MapVoteDie then
        local before = lp.Character
        mvKill()
        local t0 = os.clock()
        while alive() and os.clock() - t0 < 12 do
            local c = lp.Character
            if c and c ~= before and c:FindFirstChild("HumanoidRootPart") then break end
            task.wait(0.1)
        end
        task.wait(0.4)
        if not alive() then return end
    end

    -- the window may have moved on while we were dead; re-pick
    local e = mvTarget()
    if not e then
        notify("map vote: no picked map is open", "warn")
        return
    end

    local spot = e.pad.Position + Vector3.new(0, 3, 0)
    mvRelease()
    MV.hold = RunService.Heartbeat:Connect(function()
        if MV.gen ~= gen then return end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local flat = Vector3.new(hrp.Position.X - spot.X, 0, hrp.Position.Z - spot.Z)
        if flat.Magnitude > 2.5 then hrp.CFrame = CFrame.new(spot) end
    end)
    notify("map vote: " .. e.name, "good")

    -- stay until the window closes, the character dies, or 2 minutes pass
    local t0 = os.clock()
    while alive() and mvOpen() and os.clock() - t0 < 120 do
        local c = lp.Character
        local hum = c and c:FindFirstChildWhichIsA("Humanoid")
        if not hum or hum.Health <= 0 then break end
        task.wait(0.2)
    end
end

local function mvEnd(gen)
    if MV.gen ~= gen then return end
    mvRelease()
    MV.busy = false
    MV.armed = true
end

local function mvPoll()
    while running do
        pcall(function()
            local on = Settings.MapVote and not Settings.SafeMode
            if not on or not mvOpen() then
                if MV.busy then mvStop() end
                MV.armed = false
                return
            end
            if MV.busy or MV.armed then return end
            local e = mvTarget()
            if not e then return end
            MV.busy = true
            MV.gen = MV.gen + 1
            local gen = MV.gen
            task.spawn(function()
                local ok, err = pcall(mvSession, gen, e)
                if not ok then warn("[map vote] " .. tostring(err)) end
                mvEnd(gen)
            end)
        end)
        task.wait(0.25)
    end
end
task.spawn(mvPoll)

-- sheriff engine: ported from the mm2 script (target lead, wall checker, force origin, auto shot).
-- it owns the gun shots while the card is on; the built-in silent / auto shoot yield to it.
local function scriptEngine()
    local rs = game:GetService("ReplicatedStorage")
    local players = game:GetService("Players")
    local collection = game:GetService("CollectionService")
    local run = game:GetService("RunService")
    local lp = players.LocalPlayer

    local stats = game:GetService("Stats")

    getgenv().SILENT_S = {
        enabled = false,
        predict = true,
        force = false,
        auto_on = false,
        auto_delay = 0,
        am_sheriff = false,
        fire_gap = 0,
        last_shot = 0,
        stand_off = 15,
        react = 0.18,      -- reaction time after the target becomes visible (set from the card)
        warm = 0.25,       -- predictor warm-up after the target is picked up
        range = 160,       -- max distance to the target (set from the card)
        wallcheck = true,
    }
    local S = getgenv().SILENT_S


    local MAX_RANGE = 300

    local gap_min = 0
    local gap_seen = false
    local gap_gun = nil
    local want_since = 0

    local function gap_reset()
        gap_min = 0
        gap_seen = false
        S.fire_gap = 0
    end

    local function gap_push(value)
        if value <= 0 then return end
        if not gap_seen or value < gap_min then
            gap_min = value
            gap_seen = true
            S.fire_gap = value
        end
    end

    local round_mod = nil

    local function get_round()
        if round_mod then return round_mod end
        local ok, m = pcall(function()
            return require(rs:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
        end)
        if ok and type(m) == "table" then round_mod = m end
        return round_mod
    end

    local function holds(container, name)
        return container ~= nil and container:FindFirstChild(name) ~= nil
    end

    local function lp_has_gun()
        return holds(lp.Character, "Gun") or holds(lp:FindFirstChildOfClass("Backpack"), "Gun")
    end

    local target_player = nil
    local target_char = nil
    local target_part = nil
    local target_hum = nil

    local function refresh_target()
        local found = nil
        local m = get_round()
        local data = m and m.PlayerData or nil
        if type(data) == "table" then
            local me = data[lp.Name]
            S.am_sheriff = (me ~= nil and (me.Role == "Sheriff" or me.Role == "Hero")) or lp_has_gun()
            for name, d in pairs(data) do
                if type(d) == "table" and d.Role == "Murderer" and not d.Dead then
                    found = players:FindFirstChild(name)
                    break
                end
            end
        else
            S.am_sheriff = lp_has_gun()
        end
        if not found then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= lp and holds(plr.Character, "Knife") then
                    found = plr
                    break
                end
            end
        end
        if found ~= target_player then
            target_player = found
            target_char = nil
            target_part = nil
            target_hum = nil
        end
        if not found then return end
        local char = found.Character
        if char ~= target_char then
            target_char = char
            target_part = nil
            target_hum = nil
        end
        if not char then return end
        if not target_part or not target_part.Parent then
            target_part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        end
        if not target_hum or not target_hum.Parent then
            target_hum = char:FindFirstChildOfClass("Humanoid")
        end
    end

    local function target_alive()
        if not target_part or not target_part.Parent then return false end
        if not target_hum or not target_hum.Parent then return false end
        return target_hum.Health > 0
    end

    local ray_params = RaycastParams.new()
    ray_params.FilterType = Enum.RaycastFilterType.Exclude
    ray_params.IgnoreWater = false

    local ignore_base = {}
    local ignore_work = {}
    local ignore_time = 0

    local function refresh_ignore()
        local now = os.clock()
        if #ignore_base > 0 and now - ignore_time < 0.5 then return end
        ignore_time = now
        table.clear(ignore_base)
        local char = lp.Character
        if char then ignore_base[1] = char end
        local ok, tagged = pcall(function() return collection:GetTagged("WeaponPassthrough") end)
        if ok and type(tagged) == "table" then
            for k = 1, #tagged do
                ignore_base[#ignore_base + 1] = tagged[k]
            end
        end
    end

    local function trace(origin, direction)
        refresh_ignore()
        table.clear(ignore_work)
        for k = 1, #ignore_base do ignore_work[k] = ignore_base[k] end
        local result = nil
        for _ = 1, 6 do
            ray_params.FilterDescendantsInstances = ignore_work
            result = workspace:Raycast(origin, direction, ray_params)
            if not result then break end
            local inst = result.Instance
            if not inst then break end
            local ok, tr = pcall(function() return inst.Transparency end)
            if not ok or tr ~= 1 then break end
            ignore_work[#ignore_work + 1] = inst
        end
        return result
    end

    local function gun_attachment()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil end
        return hrp:FindFirstChild("GunRaycastAttachment"), hrp
    end

    local function origin_cframe()
        local att, hrp = gun_attachment()
        if att then return att.WorldCFrame end
        if hrp then return hrp.CFrame end
        return nil
    end

    local function grav()
        local ok, g = pcall(function() return workspace.Gravity end)
        if ok and type(g) == "number" and g > 0 then return g end
        return 0
    end

    local P = {
        snap = 48,
        ring = 48,
        hit_r = 2.1,
        pad = 2.6,
        min_span = 5,
        max_span = 90,
        acc_t = 0.15,
        acc_max = 280,
        acc_min = 40,
        speed_floor = 26,
        speed_head = 1.3,
    }

    local snap_t = table.create(P.snap, 0)
    local snap_p = table.create(P.snap, Vector3.zero)
    local snap_n = 0
    local snap_i = 0

    local TR = {
        part = nil,
        pos = nil,
        time = 0,
        since = 0,
        vel = Vector3.zero,
        gap = 0,
        ready = false,
        fresh = Vector3.zero,
        air = false,
        air_since = 0,
        jumping = false,
        jump_v = 0,
        fresh_ok = false,
        turn = 0,
        spoof = 0,
        clr = 0,
        air_edge = 0,
        jump_fresh = false,
    }

    local SK = {
        vt = table.create(P.ring, 0),
        dx = table.create(P.ring, 0),
        dz = table.create(P.ring, 0),
        vn = 0,
        vi = 0,
    }

    local EC = {
        ping = 0,
        rtt = 0,
        jitter = 0,
        seen = false,
        step = 0,
        step_seen = false,
    }

    local function step_push(dt)
        if dt <= 0 or dt > 0.5 then return end
        if EC.step_seen then
            EC.step = EC.step * 0.85 + dt * 0.15
        else
            EC.step = dt
            EC.step_seen = true
        end
    end

    local function sample_span()
        local span = math.max(EC.step, TR.gap)
        if span <= 0 then return 0 end
        return span
    end

    local HY = {
        pos = {},
        w = {},
        n = 0,
        weight = 0,
        primary = nil,
        stamp = 0,
        conf = 0,
    }

    local ground_params = RaycastParams.new()
    ground_params.FilterType = Enum.RaycastFilterType.Exclude
    ground_params.IgnoreWater = true

    local ground_filter = {}
    local axis_pool = {}

    local function ground_below(pos, reach)
        table.clear(ground_filter)
        local n = 0
        local char = target_char
        if char then
            n = n + 1
            ground_filter[n] = char
        end
        local mine = lp.Character
        if mine then
            n = n + 1
            ground_filter[n] = mine
        end
        ground_params.FilterDescendantsInstances = ground_filter
        local res = workspace:Raycast(pos, Vector3.new(0, -reach, 0), ground_params)
        if res then return res.Position.Y end
        return nil
    end

    local function snap_push(now, pos)
        snap_i = snap_i % P.snap + 1
        snap_t[snap_i] = now
        snap_p[snap_i] = pos
        if snap_n < P.snap then snap_n = snap_n + 1 end
    end

    local function snap_get(k)
        local idx = (snap_i - k - 1) % P.snap + 1
        return snap_t[idx], snap_p[idx]
    end

    local function fit_velocity()
        if snap_n < 3 then return nil end
        local newest = snap_get(0)
        local used = 0
        local sum_d = 0
        local win = sample_span() * 4
        for k = 0, snap_n - 1 do
            local t = snap_get(k)
            if newest - t > win then break end
            used = used + 1
            sum_d = sum_d + t - newest
        end
        if used < 3 then return nil end
        local mean_d = sum_d / used
        local num = Vector3.zero
        local den = 0
        for k = 0, used - 1 do
            local t, p = snap_get(k)
            local d = t - newest - mean_d
            num = num + p * d
            den = den + d * d
        end
        if den < 1e-8 then return nil end
        return num / den, -mean_d
    end

    local function recent_velocity()
        if snap_n < 2 then return nil end
        local newest, head = snap_get(0)
        local fallback, fallback_age = nil, nil
        local target_span = sample_span() * 2
        local max_span = target_span * 2
        for k = 1, snap_n - 1 do
            local t, p = snap_get(k)
            local dt = newest - t
            if dt > max_span then break end
            if dt > 0 then
                fallback = (head - p) / dt
                fallback_age = dt * 0.5
                if dt >= target_span then
                    return fallback, fallback_age
                end
            end
        end
        return fallback, fallback_age
    end

    local KIN = {
        ok = false,
        ax = 0,
        az = 0,
        smax = 0,
    }

    local function kin_clear()
        KIN.ok = false
        KIN.ax = 0
        KIN.az = 0
        KIN.smax = 0
    end

    local function fit_kin()
        if snap_n < 5 then return nil end
        local t0 = snap_get(0)
        local win = math.max(sample_span() * 5, 0.12)
        local scale = win
        local n, s1, s2, s3, s4 = 0, 0, 0, 0, 0
        local bx0, bx1, bx2 = 0, 0, 0
        local bz0, bz1, bz2 = 0, 0, 0
        for k = 0, snap_n - 1 do
            local t, p = snap_get(k)
            local age = t0 - t
            if age > win then break end
            local u = -age / scale
            local u2 = u * u
            n = n + 1
            s1 = s1 + u
            s2 = s2 + u2
            s3 = s3 + u2 * u
            s4 = s4 + u2 * u2
            bx0 = bx0 + p.X
            bx1 = bx1 + p.X * u
            bx2 = bx2 + p.X * u2
            bz0 = bz0 + p.Z
            bz1 = bz1 + p.Z * u
            bz2 = bz2 + p.Z * u2
        end
        if n < 5 then return nil end
        local det = n * (s2 * s4 - s3 * s3)
            - s1 * (s1 * s4 - s3 * s2)
            + s2 * (s1 * s3 - s2 * s2)
        if math.abs(det) < 1e-9 then return nil end
        local function solve(b0, b1, b2)
            local d1 = n * (b1 * s4 - s3 * b2)
                - b0 * (s1 * s4 - s3 * s2)
                + s2 * (s1 * b2 - b1 * s2)
            local d2 = n * (s2 * b2 - b1 * s3)
                - s1 * (s1 * b2 - b1 * s2)
                + b0 * (s1 * s3 - s2 * s2)
            return d1 / det, d2 / det
        end
        local cx1, cx2 = solve(bx0, bx1, bx2)
        local cz1, cz2 = solve(bz0, bz1, bz2)
        local vx, vz = cx1 / scale, cz1 / scale
        local ax, az = 2 * cx2 / (scale * scale), 2 * cz2 / (scale * scale)
        if vx ~= vx or vz ~= vz or ax ~= ax or az ~= az then return nil end
        return Vector3.new(vx, 0, vz), Vector3.new(ax, 0, az)
    end

    local function kin_update()
        local kv, ka = fit_kin()
        if not kv then
            KIN.ok = false
            KIN.ax = 0
            KIN.az = 0
            return nil
        end
        KIN.ok = true
        local sp = math.sqrt(kv.X * kv.X + kv.Z * kv.Z)
        if sp > KIN.smax then
            KIN.smax = sp
        else
            KIN.smax = KIN.smax * 0.985 + sp * 0.015
        end
        if ka and not TR.air then
            local am = math.sqrt(ka.X * ka.X + ka.Z * ka.Z)
            local ax, az = ka.X, ka.Z
            if am > P.acc_max and am > 0 then
                ax = ax * P.acc_max / am
                az = az * P.acc_max / am
            end
            KIN.ax = KIN.ax * 0.5 + ax * 0.5
            KIN.az = KIN.az * 0.5 + az * 0.5
        else
            KIN.ax = KIN.ax * 0.5
            KIN.az = KIN.az * 0.5
        end
        return kv
    end

    local function snap_vel(k)
        local t0, p0 = snap_get(k)
        local t1, p1 = snap_get(k + 1)
        local d = t0 - t1
        if d <= 0 then return nil end
        return (p0 - p1) / d, d
    end

    local function vert_accel()
        if snap_n < 3 then return nil end
        local v0, d0 = snap_vel(0)
        local v1, d1 = snap_vel(1)
        if not v0 or not v1 then return nil end
        local span = (d0 + d1) * 0.5
        if span <= 1e-4 then return nil end
        return (v0.Y - v1.Y) / span
    end

    local function air_vy()
        if snap_n < 2 then return nil end
        local edge = TR.air_edge
        if edge <= 0 then return nil end
        local g = grav()
        local newest, head = snap_get(0)
        local want = sample_span() * 2
        local best = nil
        for k = 1, snap_n - 1 do
            local t, p = snap_get(k)
            if t < edge then break end
            local dt = newest - t
            if dt > 1e-4 then
                best = (head.Y - p.Y) / dt - 0.5 * g * dt
                if dt >= want then break end
            end
        end
        return best
    end

    local function body_clearance()
        local part = target_part
        local hum = target_hum
        if not part or not hum then return 0 end
        local ok, value = pcall(function() return part.Size.Y * 0.5 + hum.HipHeight end)
        if ok and type(value) == "number" and value > 0 then return value end
        return 0
    end

    local GC = {
        base = 0,
        seen = false,
    }

    local JL = {
        v = 0,
        seen = false,
    }

    local function stand_clearance()
        if GC.seen then return GC.base end
        return body_clearance()
    end

    local function engine_vel(part)
        local ok, v = pcall(function() return part.AssemblyLinearVelocity end)
        if not ok or typeof(v) ~= "Vector3" then
            ok, v = pcall(function() return part.Velocity end)
        end
        if not ok or typeof(v) ~= "Vector3" then return nil end
        if v.Magnitude ~= v.Magnitude then return nil end
        return v
    end

    local function vel_trust(pv, ev)
        if not pv or not ev then return 0 end
        local ph = Vector3.new(pv.X, 0, pv.Z)
        local eh = Vector3.new(ev.X, 0, ev.Z)
        local pm, em = ph.Magnitude, eh.Magnitude
        if pm < 1 and em < 1 then return 1 end
        if pm < 1 or em < 1 then return 0 end
        local ratio = em / pm
        if ratio > 1.5 or ratio < 0.6 then return 0 end
        local align = ph.Unit:Dot(eh.Unit)
        if align < 0.7 then return 0 end
        local a = math.clamp((align - 0.7) / 0.25, 0, 1)
        local r = 1 - math.clamp(math.abs(ratio - 1) / 0.4, 0, 1)
        return a * r
    end

    local function phase_velocity(v, age, air)
        if not v then return nil end
        local y = 0
        if air then
            y = v.Y - grav() * math.clamp(age or 0, 0, sample_span() * 4)
        end
        return Vector3.new(v.X, y, v.Z)
    end

    local function merge_vel(fit, fit_age, fast, fast_age, engine, engine_age, air)
        local stable = phase_velocity(fit, fit_age, air)
        local instant = phase_velocity(fast, fast_age, air)
        local turn = 0
        if stable and instant then
            local sh = Vector3.new(stable.X, 0, stable.Z)
            local ih = Vector3.new(instant.X, 0, instant.Z)
            if sh.Magnitude > 1 and ih.Magnitude > 1 then
                turn = math.acos(math.clamp(sh.Unit:Dot(ih.Unit), -1, 1)) / math.pi
            end
        end
        local base = instant or stable
        if not base then return Vector3.zero, 0, nil, 0 end
        if stable and instant then
            local agility = math.clamp(turn * 2.2, 0, 1)
            base = stable:Lerp(instant, 0.4 + 0.6 * agility)
        end
        local trust = 0
        if engine then
            local live = phase_velocity(engine, engine_age, air)
            trust = vel_trust(base, live)
            if trust > 0 and air then
                base = Vector3.new(base.X, base.Y, base.Z):Lerp(Vector3.new(base.X, live.Y, base.Z), trust * 0.35)
            end
        end
        return base, turn, instant or stable, trust
    end

    local function vel_push(now, hx, hz)
        SK.vi = SK.vi % P.ring + 1
        SK.vt[SK.vi] = now
        SK.dx[SK.vi] = hx
        SK.dz[SK.vi] = hz
        if SK.vn < P.ring then SK.vn = SK.vn + 1 end
    end

    local function track_clear()
        TR.part = nil
        TR.pos = nil
        TR.vel = Vector3.zero
        TR.gap = 0
        TR.ready = false
        TR.fresh = Vector3.zero
        TR.air = false
        TR.jumping = false
        TR.jump_v = 0
        TR.fresh_ok = false
        TR.turn = 0
        TR.spoof = 0
        TR.clr = 0
        TR.air_edge = 0
        TR.jump_fresh = false
        GC.base = 0
        GC.seen = false
        JL.v = 0
        JL.seen = false
        snap_n, snap_i = 0, 0
        SK.vn, SK.vi = 0, 0
        kin_clear()
    end

    local function track_seed(part, pos, now)
        TR.part = part
        TR.pos = pos
        TR.time = now
        TR.since = now
        TR.vel = Vector3.zero
        TR.fresh = Vector3.zero
        TR.fresh_ok = false
        TR.turn = 0
        TR.jump_v = 0
        TR.gap = 0
        TR.ready = false
        TR.spoof = 0
        TR.air_edge = 0
        TR.jump_fresh = false
        GC.base = 0
        GC.seen = false
        snap_n, snap_i = 0, 0
        kin_clear()
        snap_push(now, pos)
    end

    local function track_fresh(now)
        local part = target_part
        if not part or not part.Parent then
            TR.fresh_ok = false
            return
        end
        local pos = part.Position
        local g = grav()
        local sv = snap_vel(0)
        local vy = sv and sv.Y or 0
        local accel = vert_accel()
        local falling = accel ~= nil and accel < -g * 0.5
        local guess = stand_clearance()
        local reach = guess + 6 + math.abs(vy) * sample_span() * 4
        local air
        local gy = ground_below(pos, reach)
        if gy then
            local clr = pos.Y - gy
            TR.clr = clr
            if math.abs(vy) < 1 and not falling then
                if GC.seen then
                    if clr < GC.base then
                        GC.base = GC.base * 0.7 + clr * 0.3
                    else
                        GC.base = GC.base * 0.98 + clr * 0.02
                    end
                else
                    GC.base = clr
                    GC.seen = true
                end
            end
            local floor = GC.seen and GC.base or guess
            local tol = math.max(floor * 0.35, 1)
            air = clr > floor + tol
            if not air and falling and math.abs(vy) > 4 and clr > floor + 0.35 then
                air = true
            end
        else
            air = true
        end
        if air ~= TR.air then
            TR.air_edge = now
            if air then
                TR.air_since = now
                TR.jump_fresh = true
                TR.jump_v = JL.seen and JL.v or math.max(vy, 0)
            else
                TR.jump_fresh = false
                TR.jump_v = 0
            end
        end
        local model_vy = TR.jump_v - g * math.max(0, now - TR.air_since)
        TR.air = air
        TR.jumping = air and (vy > 1 or model_vy > 1)
    end

    local function track(now)
        local part = target_part
        if not part or not part.Parent then
            if TR.part then track_clear() end
            return
        end
        track_fresh(now)
        local pos = part.Position
        if part ~= TR.part or not TR.pos then
            track_seed(part, pos, now)
            return
        end
        local dt = now - TR.time
        if dt > 0.75 or (pos - TR.pos).Magnitude > 140 then
            track_seed(part, pos, now)
            return
        end
        if dt <= 0 then return end
        if (pos - TR.pos).Magnitude == 0 then
            if TR.gap > 0 and dt >= TR.gap then
                TR.vel = Vector3.zero
                TR.fresh = Vector3.zero
            end
            return
        end
        step_push(dt)
        TR.gap = dt
        snap_push(now, pos)
        TR.pos = pos
        TR.time = now
        local fit, fit_age = fit_velocity()
        local fast, fast_age = recent_velocity()
        local engine = engine_vel(part)
        local fresh, turn, instant, trust = merge_vel(fit, fit_age, fast, fast_age, engine, sample_span() * 0.5, TR.air)
        local kv = kin_update()
        if kv then
            fresh = Vector3.new(kv.X, fresh.Y, kv.Z)
        end
        if engine and trust <= 0 then
            if TR.spoof < 20 then TR.spoof = TR.spoof + 1 end
        elseif TR.spoof > 0 then
            TR.spoof = TR.spoof - 1
        end
        if TR.air then
            local vy = air_vy()
            if vy then
                fresh = Vector3.new(fresh.X, vy, fresh.Z)
                local since = math.max(0, now - TR.air_edge)
                if TR.jump_fresh and since <= 0.2 then
                    local impulse = vy + grav() * since
                    if impulse > 1 then
                        if JL.seen then
                            JL.v = JL.v * 0.7 + impulse * 0.3
                        else
                            JL.v = impulse
                            JL.seen = true
                        end
                        if impulse > TR.jump_v then TR.jump_v = impulse end
                    end
                else
                    TR.jump_fresh = false
                end
            end
        end
        TR.vel = fresh
        TR.ready = fit ~= nil or fast ~= nil
        TR.fresh = TR.vel
        TR.fresh_ok = TR.ready
        TR.turn = turn
        local raw = instant or fresh
        vel_push(now, raw.X, raw.Z)
    end

    local function raw_rtt()
        local a, b
        local ok, ms = pcall(function()
            return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and type(ms) == "number" and ms == ms and ms > 4 and ms < 800 then
            a = ms / 1000
        end
        local fine, value = pcall(function() return lp:GetNetworkPing() end)
        if fine and type(value) == "number" and value == value and value > 0 then
            local rtt = value * 2
            if rtt > 0.004 and rtt < 0.8 then b = rtt end
        end
        if a and b then return (a + b) * 0.5 end
        return a or b
    end

    local function sample_ping()
        local rtt = raw_rtt()
        if not rtt or rtt ~= rtt then return end
        rtt = math.clamp(rtt, 0, 1)
        if EC.seen then
            EC.jitter = EC.jitter * 0.9 + math.abs(rtt - EC.rtt) * 0.1
            EC.rtt = EC.rtt * 0.82 + rtt * 0.18
        else
            EC.rtt = rtt
            EC.jitter = 0
            EC.seen = true
        end
        EC.ping = EC.rtt
    end

    local function lead_time()
        if not EC.seen then return 0 end
        local stale = 0
        if TR.time > 0 and EC.step_seen then
            stale = math.clamp(os.clock() - TR.time, 0, EC.step)
        end
        return math.clamp(EC.rtt + EC.jitter * 0.5 + stale, 0, 1)
    end

    local function rotate_y(v, ang)
        local c, s = math.cos(ang), math.sin(ang)
        return Vector3.new(v.X * c - v.Z * s, v.Y, v.X * s + v.Z * c)
    end

    local function dir_stats(win)
        if SK.vn < 4 then return 1, 0 end
        win = math.max(win, sample_span() * 3)
        local newest = SK.vt[SK.vi]
        local sx, sz, n = 0, 0, 0
        local prev = nil
        local turn, turn_n = 0, 0
        local oldest = newest
        for k = 0, SK.vn - 1 do
            local idx = (SK.vi - k - 1) % P.ring + 1
            local t = SK.vt[idx]
            if newest - t > win then break end
            local hx, hz = SK.dx[idx], SK.dz[idx]
            local m = math.sqrt(hx * hx + hz * hz)
            if m > 0 then
                sx = sx + hx / m
                sz = sz + hz / m
                n = n + 1
                local ang = math.atan2(hz, hx)
                if prev then
                    local d = ang - prev
                    while d > math.pi do d = d - 6.2831853 end
                    while d < -math.pi do d = d + 6.2831853 end
                    turn = turn + d
                    turn_n = turn_n + 1
                end
                prev = ang
                oldest = t
            end
        end
        if n < 2 then return 1, 0 end
        local coh = math.clamp(math.sqrt(sx * sx + sz * sz) / n, 0, 1)
        local omega = 0
        local elapsed = newest - oldest
        if turn_n >= 1 and elapsed > 1e-3 then
            omega = -turn / elapsed
        end
        return coh, omega
    end

    local function predict_from(base, sa, sb, fh, now)
        local span = math.max(0, sa + sb)
        local g = grav()
        local dir = fh
        if dir.Magnitude == 0 then
            dir = Vector3.new(TR.vel.X, 0, TR.vel.Z)
        end
        local x, z
        if span > 0 and KIN.ok then
            local age = math.clamp(now - TR.time, 0, sample_span() * 2)
            local ax, az = KIN.ax, KIN.az
            if TR.air or math.sqrt(ax * ax + az * az) < P.acc_min then ax, az = 0, 0 end
            local vx = dir.X + ax * age
            local vz = dir.Z + az * age
            local ta = math.min(span, P.acc_t)
            local dx = vx * span + 0.5 * ax * ta * ta
            local dz = vz * span + 0.5 * az * ta * ta
            local reach = math.sqrt(dx * dx + dz * dz)
            local cap = math.max(KIN.smax * P.speed_head, P.speed_floor) * span
            if reach > cap and reach > 1e-6 then
                dx = dx * cap / reach
                dz = dz * cap / reach
            end
            x = base.X + dx
            z = base.Z + dz
        else
            local hspan = span
            if span > 0 and dir.Magnitude > 0 and not TR.air then
                local coh, omega = dir_stats(span)
                local conf = math.clamp(coh, 0, 1) * (1 - math.clamp(TR.turn, 0, 1) * 0.5)
                if omega ~= 0 then
                    dir = rotate_y(dir, math.clamp(omega * span * 0.5 * conf, -0.6, 0.6))
                end
                hspan = span * (0.85 + 0.15 * conf)
            end
            x = base.X + dir.X * hspan
            z = base.Z + dir.Z * hspan
        end
        local y = base.Y
        if TR.air and span > 0 then
            local vy = TR.vel.Y
            local phase = math.max(0, now - TR.air_since)
            local modeled = TR.jump_v - g * phase
            if TR.jumping and TR.jump_v > 0 and g > 0 and phase <= TR.jump_v / g and modeled > vy then
                vy = modeled
            end
            y = base.Y + vy * span - 0.5 * g * span * span
            if y < base.Y then
                local clearance = stand_clearance()
                local reach = base.Y - y + clearance
                local gy = ground_below(Vector3.new(x, base.Y, z), reach)
                if gy then
                    local floor = gy + clearance
                    if y < floor then y = floor end
                end
            end
        end
        return Vector3.new(x, y, z)
    end

    local function build_hyps(base, now)
        table.clear(HY.pos)
        table.clear(HY.w)
        local horizon = S.predict and TR.ready and lead_time() or 0
        local fh = Vector3.new(TR.fresh.X, 0, TR.fresh.Z)
        HY.primary = predict_from(base, 0, horizon, fh, now)
        HY.n = 1
        HY.pos[1] = HY.primary
        HY.w[1] = 1
        HY.weight = 1
        HY.stamp = now
    end

    local function score_axis(anchor, axis)
        local covered = 0
        local lo, hi = 0, 0
        for k = 1, HY.n do
            local d = HY.pos[k] - anchor
            local a = d:Dot(axis)
            local perp = (d - axis * a).Magnitude
            if perp <= P.hit_r then
                covered = covered + HY.w[k]
                if a < lo then lo = a end
                if a > hi then hi = a end
            end
        end
        return covered, lo, hi
    end

    local function corridor_axes(anchor)
        table.clear(axis_pool)
        local n = 0
        local function add(v)
            if typeof(v) ~= "Vector3" or v.Magnitude < 1e-4 then return end
            local u = v.Unit
            for k = 1, n do
                if axis_pool[k]:Dot(u) > 0.985 then return end
            end
            n = n + 1
            axis_pool[n] = u
        end
        local fh = Vector3.new(TR.fresh.X, 0, TR.fresh.Z)
        if TR.air then add(TR.fresh) end
        add(fh)
        for k = 1, HY.n do
            add(HY.pos[k] - anchor)
        end
        add(TR.fresh)
        add(Vector3.new(0, 1, 0))
        return n
    end

    local function build_corridor(now)
        local part = target_part
        if not part or not part.Parent then return nil end
        local base = part.Position
        build_hyps(base, now)
        local anchor = HY.primary or base
        local count = corridor_axes(anchor)
        local best_axis, best_cov, best_lo, best_hi = nil, -1, 0, 0
        for k = 1, count do
            local axis = axis_pool[k]
            local cov, lo, hi = score_axis(anchor, axis)
            if cov > best_cov then
                best_axis, best_cov, best_lo, best_hi = axis, cov, lo, hi
            end
        end
        if not best_axis then return nil end
        HY.conf = HY.weight > 0 and best_cov / HY.weight or 0

        local pad = P.pad
        local origin = anchor + best_axis * (best_lo - pad)
        local aim = anchor + best_axis * (best_hi + pad)
        if (aim - origin).Magnitude < 4 then
            origin = anchor - best_axis * 4
            aim = anchor + best_axis * 4
        end
        return origin, aim, HY.conf, anchor
    end

    local pred_off = Vector3.zero
    local pred_stamp = 0

    local function lead_offset()
        local part = target_part
        if not part or not part.Parent then return Vector3.zero end
        if not S.predict or not TR.ready then return Vector3.zero end
        local base = part.Position
        local now = os.clock()
        local fh = Vector3.new(TR.fresh.X, 0, TR.fresh.Z)
        local point = predict_from(base, 0, lead_time(), fh, now)
        local off = point - base
        pred_stamp = now
        pred_off = off
        return pred_off
    end

    local function cloud_confidence()
        local anchor = HY.primary
        if not anchor or HY.n == 0 or HY.weight <= 0 then return 0 end
        local covered = 0
        for k = 1, HY.n do
            if (HY.pos[k] - anchor).Magnitude <= P.hit_r then
                covered = covered + HY.w[k]
            end
        end
        return covered / HY.weight
    end
    local hit_names = {
        "HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "Head",
        "RightUpperArm", "LeftUpperArm", "Right Arm", "Left Arm",
        "RightUpperLeg", "LeftUpperLeg", "Right Leg", "Left Leg",
        "RightLowerLeg", "LeftLowerLeg",
    }

    local hit_parts = {}
    local hit_count = 0
    local hit_char = nil

    local function refresh_parts()
        local char = target_char
        if char == hit_char then return end
        table.clear(hit_parts)
        hit_count = 0
        hit_char = char
        if not char then return end
        for k = 1, #hit_names do
            local part = char:FindFirstChild(hit_names[k])
            if part and part:IsA("BasePart") then
                hit_count = hit_count + 1
                hit_parts[hit_count] = part
            end
        end
    end

    local function los_clear(origin, point)
        if S.wallcheck == false then return true end
        if not origin or not point then return false end
        local delta = point - origin
        local dist = delta.Magnitude
        if dist < 0.5 then return true end
        if dist > MAX_RANGE then return false end
        local hit = trace(origin, delta)
        if not hit then return true end
        local inst = hit.Instance
        local char = target_char
        if inst and char and (inst == char or inst:IsDescendantOf(char)) then return true end
        return (hit.Position - origin).Magnitude >= dist - 0.75
    end

    local function pick_point(origin, strict)
        refresh_parts()
        if hit_count == 0 then return nil end
        local off = lead_offset()
        local first = nil
        for k = 1, hit_count do
            local part = hit_parts[k]
            if not part.Parent then
                hit_char = nil
            else
                local point = part.Position + off
                if not origin then return point end
                if not first then first = point end
                if los_clear(origin, point) then return point end
            end
        end
        if strict then return nil end
        return first
    end

    local force_att = nil
    local force_saved = nil
    local force_stamp = 0

    local function restore_origin()
        local att = force_att
        if not att then return end
        local saved = force_saved
        force_att = nil
        force_saved = nil
        if saved then
            pcall(function()
                if att.Parent then att.CFrame = saved end
            end)
        end
    end

    local function push_origin(cf)
        local att = gun_attachment()
        if not att then return false end
        if force_att and force_att ~= att then restore_origin() end
        if not force_att then
            local ok, saved = pcall(function() return att.CFrame end)
            if not ok or typeof(saved) ~= "CFrame" then return false end
            force_att = att
            force_saved = saved
        end
        force_stamp = os.clock()
        local ok = pcall(function() att.WorldCFrame = cf end)
        if not ok then
            restore_origin()
            return false
        end
        task.defer(restore_origin)
        return true
    end

    local function is_target_hit(inst)
        local char = target_char
        if not inst or not char then return false end
        return inst == char or inst:IsDescendantOf(char)
    end

    local function force_clear(origin, aim)
        local hit = trace(origin, aim - origin)
        if not hit then return false end
        return is_target_hit(hit.Instance)
    end

    local function force_velocity()
        if TR.fresh_ok and TR.fresh.Magnitude > 0.5 then return TR.fresh end
        if TR.ready and TR.vel.Magnitude > 0.5 then return TR.vel end
        return Vector3.zero
    end

    local function resolve_force()
        local part = target_part
        if not part or not part.Parent then return nil end
        local live = part.Position
        local now = os.clock()

        local origin, aim, conf, anchor = build_corridor(now)
        if origin and aim then
            local axis = aim - origin
            local span = axis.Magnitude
            if span > 1e-3 then
                local u = axis / span
                local mark = anchor or live
                local behind = (mark - origin):Dot(u)
                if behind < P.pad then
                    origin = origin - u * (P.pad - behind)
                end
                local ahead = (aim - mark):Dot(u)
                if ahead < P.min_span then
                    aim = mark + u * P.min_span
                end
                local want = S.stand_off
                while want > 0 do
                    local probe = origin - u * want
                    if (aim - probe).Magnitude <= P.max_span
                        and los_clear(probe, mark)
                        and los_clear(probe, live) then
                        origin = probe
                        break
                    end
                    want = want - 3
                end
                if (aim - origin).Magnitude > P.max_span then
                    origin = aim - u * P.max_span
                end
                return CFrame.new(origin, aim), CFrame.new(aim), conf or 0, mark
            end
        end

        local vel = force_velocity()
        local dir = Vector3.new(0, -1, 0)
        if vel.Magnitude > 3 then
            dir = vel.Unit
        else
            local mine = origin_cframe()
            if mine then
                local delta = live - mine.Position
                if delta.Magnitude > 2 then dir = delta.Unit end
            end
        end
        local back = live - dir * 6
        local front = live + dir * math.max(P.min_span, vel.Magnitude * lead_time() + 8)
        if not force_clear(back, front) then
            back = live - dir * 2.5
        end
        return CFrame.new(back, front), CFrame.new(front), 0, live
    end

    local function shot_shift(dt)
        if not S.predict or not TR.ready or dt <= 0 then return Vector3.zero end
        local shift = Vector3.new(TR.vel.X * dt, 0, TR.vel.Z * dt)
        if TR.air then
            local g = grav()
            local horizon = lead_time()
            local vy = TR.vel.Y
            local phase = math.max(0, os.clock() - TR.air_since)
            local modeled = TR.jump_v - g * phase
            if TR.jumping and TR.jump_v > 0 and g > 0 and phase <= TR.jump_v / g and modeled > vy then vy = modeled end
            shift = Vector3.new(shift.X, vy * dt - g * horizon * dt - 0.5 * g * dt * dt, shift.Z)
        end
        return shift
    end

    local function compensate_force(origin_cf, aim_cf, started)
        local shift = shot_shift(math.max(0, os.clock() - started))
        if shift == Vector3.zero then return origin_cf, aim_cf end
        local origin = origin_cf.Position + shift
        local aim = aim_cf.Position + shift
        return CFrame.new(origin, aim), CFrame.new(aim)
    end

    local function resolve_shot()
        if not S.enabled or not S.am_sheriff or not target_alive() then return nil end
        if S.force then
            local started = os.clock()
            local origin_cf, aim_cf = resolve_force()
            if origin_cf and aim_cf then
                origin_cf, aim_cf = compensate_force(origin_cf, aim_cf, started)
                if push_origin(origin_cf) then return aim_cf end
            end
        end
        local cf = origin_cframe()
        local aim = pick_point(cf and cf.Position or nil, false)
        if not aim then return nil end
        return CFrame.new(aim)
    end

    local function compensate_resolve(cf)
        if S.force or typeof(cf) ~= "CFrame" then return cf end
        return CFrame.new(cf.Position + shot_shift(math.max(0, os.clock() - pred_stamp)))
    end

    local weapon_service = nil
    local orig_mouse = nil
    local orig_screen = nil
    local hook_mouse = nil
    local hook_screen = nil

    local function get_weapon_service()
        if weapon_service then return weapon_service end
        local ok, m = pcall(function()
            return require(rs:WaitForChild("ClientServices"):WaitForChild("WeaponService"))
        end)
        if ok and type(m) == "table" then weapon_service = m end
        return weapon_service
    end

    local function install_hooks()
        local m = get_weapon_service()
        if not m then return end
        if not hook_mouse then
            local function knife_aim()
                local fn = getgenv().KNIFE_AIM_RESOLVE
                if type(fn) ~= "function" then return nil end
                local ok, cf = pcall(fn)
                if ok and typeof(cf) == "CFrame" then return cf end
                return nil
            end
            hook_mouse = function(self, ...)
                sample_ping()
                local ok, cf = pcall(resolve_shot)
                if ok and cf then return compensate_resolve(cf) end
                local kcf = knife_aim()
                if kcf then return kcf end
                return orig_mouse(self, ...)
            end
            hook_screen = function(self, x, y, ...)
                sample_ping()
                local ok, cf = pcall(resolve_shot)
                if ok and cf then return compensate_resolve(cf) end
                local kcf = knife_aim()
                if kcf then return kcf end
                return orig_screen(self, x, y, ...)
            end
        end
        pcall(function() setreadonly(m, false) end)
        if type(m.GetMouseTargetCFrame) == "function" and m.GetMouseTargetCFrame ~= hook_mouse then
            orig_mouse = m.GetMouseTargetCFrame
            pcall(function() m.GetMouseTargetCFrame = hook_mouse end)
        end
        if type(m.GetTargetPosition) == "function" and m.GetTargetPosition ~= hook_screen then
            orig_screen = m.GetTargetPosition
            pcall(function() m.GetTargetPosition = hook_screen end)
        end
    end

    local gun_fired_conn = nil
    local last_fire_stamp = 0

    local function on_gun_fired(tool)
        if typeof(tool) ~= "Instance" then return end
        local char = lp.Character
        if not char then return end
        local ok, mine = pcall(function() return tool:IsDescendantOf(char) end)
        if not ok or not mine then return end
        local now = os.clock()
        if last_fire_stamp > 0 and want_since > 0 and want_since <= last_fire_stamp then
            gap_push(now - last_fire_stamp)
        end
        last_fire_stamp = now
    end

    local function connect_gun_fired()
        if gun_fired_conn then return end
        local m = get_weapon_service()
        if not m then return end
        local ev = m.GunFired
        if typeof(ev) ~= "Instance" then return end
        gun_fired_conn = ev.OnClientEvent:Connect(function(tool)
            pcall(on_gun_fired, tool)
        end)
    end

    local function get_gun()
        local char = lp.Character
        if char then
            local g = char:FindFirstChild("Gun")
            if g then return g, true end
        end
        local bp = lp:FindFirstChildOfClass("Backpack")
        if bp then
            local g = bp:FindFirstChild("Gun")
            if g then return g, false end
        end
        return nil, false
    end

    local function fire_gun(gun, start_cf, aim_cf)
        if not gun or not start_cf or not aim_cf then return false end
        local remote = gun:FindFirstChild("Shoot")
        if not remote or not remote:IsA("RemoteEvent") then return false end
        return (pcall(function() remote:FireServer(start_cf, aim_cf) end))
    end

    -- the trigger. a shot needs the target to have settled, not just to exist:
    --   gun out, target visible through the wall checker (force skips it), outside the lobby (both of us),
    --   within range, reaction time since it became visible, predictor warmed up (prediction on), shot delay passed.
    -- a target switch, a wall step or a lost line restarts the reaction timer.
    local arm_since, arm_for, vis_next, vis_ok = 0, nil, 0, false

    local function auto_step(now)
        if not S.auto_on or not S.enabled or not S.am_sheriff or getgenv().AUTOFARM_HOLD or not target_alive() then
            want_since = 0
            arm_since = 0
            return
        end
        local gun, equipped = get_gun()
        if not gun then
            want_since = 0
            arm_since = 0
            return
        end
        if gun ~= gap_gun then
            gap_gun = gun
            gap_reset()
        end
        if not equipped then
            want_since = 0
            arm_since = 0
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:EquipTool(gun) end) end
            return
        end
        if want_since == 0 then want_since = now end

        local cf = origin_cframe()
        if not cf or not target_part or not target_part.Parent then
            arm_since = 0
            return
        end
        -- lobby and range: nobody in the lobby is shot, nothing beyond the range is shot
        if inLobby(cf.Position) or inLobby(target_part.Position) then
            arm_since = 0
            return
        end
        if (cf.Position - target_part.Position).Magnitude > S.range then
            arm_since = 0
            return
        end
        -- visibility: the wall checker decides (checked every 50 ms, and again right before the shot)
        if now >= vis_next then
            vis_next = now + 0.05
            vis_ok = S.force or pick_point(cf.Position, true) ~= nil
        end
        if not vis_ok then
            arm_since = 0
            return
        end
        -- reaction timer: starts when the target becomes valid, restarts when the target changes
        if arm_for ~= target_player then
            arm_for = target_player
            arm_since = 0
        end
        if arm_since == 0 then arm_since = now end
        if now - arm_since < S.react then return end
        -- predictor warm-up: no lead is trusted until the target has been tracked for a moment
        if S.predict and now - TR.since < S.warm then return end

        local hold = S.auto_delay
        if hold < S.fire_gap then hold = S.fire_gap end
        local since = last_fire_stamp > 0 and last_fire_stamp or S.last_shot
        if now - since < hold then return end

        if S.force then
            local started = os.clock()
            local origin_cf, aim_cf = resolve_force()
            if not origin_cf or not aim_cf then return end
            origin_cf, aim_cf = compensate_force(origin_cf, aim_cf, started)
            if fire_gun(gun, origin_cf, aim_cf) then
                S.last_shot = now
            end
            return
        end
        -- fresh wall check at the moment of the shot
        local aim = pick_point(cf.Position, true)
        if not aim then
            arm_since = 0
            return
        end
        local aim_cf = compensate_resolve(CFrame.new(aim))
        if fire_gun(gun, cf, aim_cf) then
            S.last_shot = now
        end
    end

    local watch_conns = {}

    local function clear_watch()
        for k = 1, #watch_conns do
            local conn = watch_conns[k]
            pcall(function() conn:Disconnect() end)
        end
        table.clear(watch_conns)
    end

    local function setup_watch()
        clear_watch()
        local m = get_round()
        if m and m.PlayerDataChanged then
            watch_conns[#watch_conns + 1] = m.PlayerDataChanged.Event:Connect(function()
                pcall(refresh_target)
            end)
        end
        watch_conns[#watch_conns + 1] = lp.CharacterAdded:Connect(function()
            task.wait(0.3)
            pcall(refresh_target)
        end)
    end

    local next_role = 0
    local next_hook = 0

    local function tick()
        if force_att and os.clock() - force_stamp > 0.05 then restore_origin() end
        if not S.enabled then return end
        local now = os.clock()
        if now >= next_role then
            next_role = now + 0.2
            refresh_target()
        end
        sample_ping()
        track(now)
        if now >= next_hook then
            next_hook = now + 1
            install_hooks()
            connect_gun_fired()
        end
        auto_step(now)
    end

    local main_conn = run.Heartbeat:Connect(function()
        pcall(tick)
    end)

    -- card bridge: the suite card drives the engine through this setter (same side effects as the old toggles)
    getgenv().SILENT_SET = function(k, v)
        if k == "enabled" then
            S.enabled = v
            getgenv().SILENT_AIM_ACTIVE = v
            if v then
                task.spawn(function()
                    pcall(install_hooks)
                    pcall(connect_gun_fired)
                    pcall(setup_watch)
                    pcall(refresh_target)
                end)
            else
                clear_watch()
                track_clear()
            end
        elseif k == "predict" then
            S.predict = v
            if not v then track_clear() end
        elseif k == "force" then
            S.force = v
            if not v then restore_origin() end
        elseif k == "wallcheck" then
            S.wallcheck = v
        elseif k == "auto_on" then
            S.auto_on = v
        elseif k == "stand_off" then
            S.stand_off = v
        elseif k == "auto_delay" then
            S.auto_delay = v / 1000
        elseif k == "react" then
            S.react = v / 1000
        elseif k == "range" then
            S.range = v
        end
    end
    getgenv().SILENT_INSTALL_HOOKS = function()
        pcall(install_hooks)
    end

    getgenv().SILENT_DBG = function()
        local coh, omega = dir_stats(lead_time())
        return {
            target = target_player and target_player.Name or "none",
            ping = EC.ping,
            rtt = EC.rtt,
            jitter = EC.jitter,
            step = EC.step,
            lead = lead_time(),
            coherence = coh,
            omega = omega,
            turn = TR.turn,
            spoof = TR.spoof,
            clearance = TR.clr,
            ground = GC.seen and GC.base or 0,
            jump_learned = JL.seen and JL.v or 0,
            jump_v = TR.jump_v,
            fire_gap = S.fire_gap,
            want_since = want_since,
            conf_point = cloud_confidence(),
            conf_ray = HY.conf,
            gap = TR.gap,
            airborne = TR.air,
            vel_fresh = TR.fresh,
            vel_pos = TR.vel,
        }
    end

    task.spawn(function()
        pcall(install_hooks)
        pcall(connect_gun_fired)
    end)

    getgenv().SILENT_UNLOAD = function()
        S.enabled = false
        S.predict = false
        S.force = false
        S.auto_on = false
        getgenv().SILENT_AIM_ACTIVE = false
        restore_origin()
        clear_watch()
        track_clear()
        if gun_fired_conn then
            pcall(function() gun_fired_conn:Disconnect() end)
            gun_fired_conn = nil
        end
        if main_conn then
            pcall(function() main_conn:Disconnect() end)
            main_conn = nil
        end
        local m = weapon_service
        if m then
            pcall(function() setreadonly(m, false) end)
            if orig_mouse then
                pcall(function() m.GetMouseTargetCFrame = orig_mouse end)
            end
            if orig_screen then
                pcall(function() m.GetTargetPosition = orig_screen end)
            end
        end
    end
end
scriptEngine()

-- card -> engine: Settings.Script* are pushed into the engine's state when they change
local scriptLast = {}
task.spawn(function()
    while running do
        pcall(function()
            local set = ENV.SILENT_SET
            if type(set) ~= "function" then return end
            local want = {
                enabled = Settings.ScriptAim,
                predict = Settings.ScriptPredict,
                wallcheck = Settings.ScriptWall,
                auto_on = Settings.ScriptAuto,
                force = Settings.ScriptForce and not Settings.SafeMode, -- origin spoof is a safe-mode lock
                stand_off = Settings.ScriptStandOff,
                auto_delay = Settings.ScriptDelay,
                react = Settings.ScriptReact,
                range = Settings.ScriptRange,
            }
            for k, v in pairs(want) do
                if scriptLast[k] ~= v then
                    scriptLast[k] = v
                    pcall(set, k, v)
                end
            end
        end)
        task.wait(0.2)
    end
end)

---------------------------------------------------------------------
-- kill aura (from the mm2 script). as the murderer with the knife out: stabs every player inside the
-- distance; kill all stabs everyone. one stab per 50 ms. murderer check = the round module's PlayerData.
---------------------------------------------------------------------
local function setupKillAura()
    local round_mod = nil
    local am_murderer = false
    local last_stab = 0

    local function round()
        if round_mod then return round_mod end
        local ok, m = pcall(function()
            return require(RS:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
        end)
        if ok and type(m) == "table" then round_mod = m end
        return round_mod
    end

    local function refresh_murderer()
        local m = round()
        local data = m and m.PlayerData
        if type(data) ~= "table" then
            am_murderer = false
            return
        end
        local me = data[lp.Name]
        am_murderer = me ~= nil and me.Role == "Murderer" and not me.Dead
    end

    -- the knife in hand, or nil. a knife in the backpack gets equipped and the stab waits one frame
    local function knife_out()
        local char = lp.Character
        local equipped = char and char:FindFirstChild("Knife")
        if equipped then return equipped end
        local bp = lp:FindFirstChildOfClass("Backpack")
        local stored = bp and bp:FindFirstChild("Knife")
        if stored then
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:EquipTool(stored) end) end
        end
        return nil
    end

    local function stab(knife)
        local events = knife:FindFirstChild("Events")
        local stabbed = events and events:FindFirstChild("KnifeStabbed")
        if stabbed then pcall(function() stabbed:FireServer() end) end
    end

    local function touch(knife, part)
        local events = knife:FindFirstChild("Events")
        local touched = events and events:FindFirstChild("HandleTouched")
        if touched then pcall(function() touched:FireServer(part) end) end
    end

    task.spawn(function()
        while running do
            task.wait(0.3)
            if Settings.KillAura or Settings.KillAll then pcall(refresh_murderer) end
        end
    end)

    task.spawn(function()
        local victims = {}
        while running do
            task.wait()
            local all = Settings.KillAll and not Settings.SafeMode
            if (Settings.KillAura or all) and am_murderer then
                local knife = knife_out()
                if knife and os.clock() - last_stab >= 0.05 then
                    local char = lp.Character
                    local me = char and char:FindFirstChild("HumanoidRootPart")
                    local range = Settings.KillDistance
                    table.clear(victims)
                    local n = 0
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= lp then
                            local tc = plr.Character
                            local hum = tc and tc:FindFirstChildOfClass("Humanoid")
                            local part = tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Head"))
                            if hum and hum.Health > 0 and part then
                                if all or (Settings.KillAura and me and (part.Position - me.Position).Magnitude <= range) then
                                    n = n + 1
                                    victims[n] = part
                                end
                            end
                        end
                    end
                    if n > 0 then
                        stab(knife)
                        for i = 1, n do touch(knife, victims[i]) end
                        last_stab = os.clock()
                    end
                end
            end
        end
    end)
end

---------------------------------------------------------------------
-- aura (from the mm2 script). a particle aura from the asset library on your character.
-- 8 types, 6 colours. the body is the local character; the fake-model feature of the script is not in this suite.
---------------------------------------------------------------------
local function setupAuras()
    local IDS = {
        angel = "97658130917593",
        starlight = "134645216613107",
        heavenly = "139300897520961",
        ribbon = "132069507632161",
        sakura = "81755778619404",
        wind = "80694081850877",
        flow = "119913533725648",
        star = "73754563740680",
    }
    local ORDER = { "angel", "starlight", "heavenly", "ribbon", "sakura", "wind", "flow", "star" }
    local COLORS = {
        ice = Color3.fromRGB(133, 220, 255),
        pink = Color3.fromRGB(255, 140, 210),
        gold = Color3.fromRGB(255, 210, 110),
        mint = Color3.fromRGB(130, 255, 200),
        violet = Color3.fromRGB(190, 150, 255),
        white = Color3.fromRGB(255, 255, 255),
    }
    local COLOR_ORDER = { "ice", "pink", "gold", "mint", "violet", "white" }

    local GROUPS = {
        head = { "Head" },
        torso = { "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Root" },
        larm = { "Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand" },
        rarm = { "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand" },
        lleg = { "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
        rleg = { "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
    }
    local group_of = {}
    for group, names in pairs(GROUPS) do
        for i = 1, #names do group_of[names[i]] = group end
    end

    local cache = {}                                  -- type -> template model, loaded once
    local live = {}                                   -- particle instances currently on the body
    local bt_stripped = setmetatable({}, { __mode = "k" })
    local st = { on = false, type = "angel", color = "ice", host = nil, conn = nil }

    local function fake_model()
        local rig = _G.FAKE_MODEL_RIG
        if typeof(rig) ~= "Instance" then return nil end
        if not rig:IsA("Model") or not rig.Parent then return nil end
        return rig
    end

    local function center_of(host)
        local primary = host.PrimaryPart
        if primary and primary:IsA("BasePart") then return primary end
        local pick, best = nil, -1
        for _, d in ipairs(host:GetDescendants()) do
            if d:IsA("BasePart") then
                local s = d.Size
                local vol = s.X * s.Y * s.Z
                if vol > best then pick, best = d, vol end
            end
        end
        return pick
    end

    local function slot_of(host, name, center)
        local direct = host:FindFirstChild(name, true)
        if direct and direct:IsA("BasePart") then return direct end
        local group = group_of[name]
        if group then
            for _, alt in ipairs(GROUPS[group]) do
                local part = host:FindFirstChild(alt, true)
                if part and part:IsA("BasePart") then return part end
            end
        end
        return center
    end

    -- backtrack clones of other features keep their own particles: strip them once per change
    local function strip_backtrack()
        local clones = _G.BACKTRACK_CLONES
        if not clones then return end
        for model in pairs(clones) do
            if typeof(model) == "Instance" and model.Parent then
                local desc = model:GetDescendants()
                local n = #desc
                if bt_stripped[model] ~= n then
                    for i = 1, n do
                        local child = desc[i]
                        if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail")
                            or child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                    bt_stripped[model] = #model:GetDescendants()
                end
            end
        end
    end

    local function load_aura(name)
        if cache[name] then return cache[name] end
        local id = IDS[name]
        if not id then return nil end
        local ok, objs = pcall(game.GetObjects, game, "rbxassetid://" .. id)
        if ok and objs and objs[1] then
            cache[name] = objs[1]
            return objs[1]
        end
        return nil
    end

    local function paint(model, color)
        local seq = ColorSequence.new(color)
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("PointLight") then
                d.Color = color
            elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                d.Color = seq
            end
        end
    end

    -- removes aura-looking emitters / lights from a model (the previous aura, or a leftover of it)
    local function clean_model(model)
        if not model then return end
        if _G.BACKTRACK_CLONES and _G.BACKTRACK_CLONES[model] then return end
        if _G.VIEWPORT_CLONE and model == _G.VIEWPORT_CLONE then return end
        for _, part in ipairs(model:GetChildren()) do
            if part:IsA("BasePart") then
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") or child:IsA("PointLight") then
                        local mine = false
                        for name in pairs(IDS) do
                            if child.Name:lower():find(name) or child.Name:find("Aura") or child.Name:find("Effect") then
                                mine = true
                                break
                            end
                        end
                        if mine then pcall(function() child:Destroy() end) end
                    end
                end
            end
        end
    end

    local function clear()
        for i = #live, 1, -1 do
            pcall(function() live[i]:Destroy() end)
            live[i] = nil
        end
        local my_name = lp.Name
        if lp.Character then clean_model(lp.Character) end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name == my_name then clean_model(obj) end
        end
        local folder = workspace:FindFirstChild("Players")
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj.Name == my_name then clean_model(obj) end
            end
        end
    end

    local function real_char()
        local char = lp.Character
        if not char then return nil end
        if _G.BACKTRACK_CLONES and _G.BACKTRACK_CLONES[char] then return nil end
        if _G.VIEWPORT_CLONE and char == _G.VIEWPORT_CLONE then return nil end
        if char:GetAttribute("1") then return nil end
        if char.Parent == workspace then return char end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name == lp.Name then
                if not (_G.BACKTRACK_CLONES and _G.BACKTRACK_CLONES[obj]) and obj ~= _G.VIEWPORT_CLONE and not obj:GetAttribute("1") then
                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:IsA("BasePart") then return obj end
                end
            end
        end
        return nil
    end

    local function resolve_host()
        local fake = fake_model()
        if fake then return fake, true end
        return real_char(), false
    end

    local function apply()
        clear()
        st.host = nil
        local host, is_fake = resolve_host()
        if not host then return end
        local src = load_aura(st.type)
        if not src then return end
        paint(src, COLORS[st.color])
        local center = is_fake and center_of(host) or nil
        local copy = src:Clone()
        for _, part in ipairs(copy:GetChildren()) do
            local target
            if is_fake then
                target = slot_of(host, part.Name, center)
            else
                target = host:FindFirstChild(part.Name)
            end
            if target and target:IsA("BasePart") then
                for _, child in ipairs(part:GetChildren()) do
                    child.Parent = target
                    live[#live + 1] = child
                end
            end
        end
        copy:Destroy()
        st.host = host
    end

    -- re-applies when the body changed or the particles were wiped
    local function sync()
        if not st.on then return end
        local host = resolve_host()
        if host ~= st.host then
            apply()
            return
        end
        if not host then return end
        local first = live[1]
        if first and not first.Parent then apply() end
    end

    local function tick()
        local on = Settings.WorldAura and true or false
        local ty = IDS[Settings.AuraType] and Settings.AuraType or "angel"
        local co = COLORS[Settings.AuraColor] and Settings.AuraColor or "ice"
        if on ~= st.on then
            st.on = on
            st.type, st.color = ty, co
            if on then
                st.conn = lp.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if st.on then pcall(apply) end
                end)
                pcall(apply)
            else
                if st.conn then
                    pcall(function() st.conn:Disconnect() end)
                    st.conn = nil
                end
                pcall(clear)
                st.host = nil
            end
            return
        end
        if not on then return end
        if ty ~= st.type or co ~= st.color then
            st.type, st.color = ty, co
            pcall(apply)
            return
        end
        strip_backtrack()
        pcall(sync)
    end

    task.spawn(function()
        while running do
            pcall(tick)
            task.wait(0.2)
        end
    end)

    local function stop()
        st.on = false
        if st.conn then
            pcall(function() st.conn:Disconnect() end)
            st.conn = nil
        end
        pcall(clear)
        st.host = nil
    end

    return { stop = stop, types = ORDER, colors = COLOR_ORDER }
end

setupKillAura()
local auras = setupAuras()

---------------------------------------------------------------------
-- GUI v13: the reference look. sidebar groups, two-column cards, wireframe backdrop,
-- live watermark, resizable window (corner grip, or the width / height sliders in presets).
-- phones: round launcher on the left edge, one column while the window is narrow.
---------------------------------------------------------------------
---------------------------------------------------------------------
-- fx: visuals ported from the uploaded script + the esp renderer rebuilt here (the source loads it remotely)
-- everything is client side. FX.stop() puts every lighting value back and removes every object it made
---------------------------------------------------------------------
;(function()
    -----------------------------------------------------------------
    -- palette, skyboxes, rig bones, shared numbers
    -----------------------------------------------------------------
    local FXC = {
        white = Color3.fromRGB(255, 255, 255), black = Color3.fromRGB(0, 0, 0),
        red = Color3.fromRGB(255, 70, 80), orange = Color3.fromRGB(255, 150, 40),
        yellow = Color3.fromRGB(255, 214, 10), green = Color3.fromRGB(70, 230, 130),
        cyan = Color3.fromRGB(80, 220, 255), blue = Color3.fromRGB(70, 150, 255),
        violet = Color3.fromRGB(139, 92, 246), pink = Color3.fromRGB(255, 110, 190),
        gray = Color3.fromRGB(150, 150, 160), amber = Color3.fromRGB(245, 158, 11),
        sky = Color3.fromRGB(133, 220, 255), ice = Color3.fromRGB(150, 200, 255),
        silver = Color3.fromRGB(192, 192, 192), dim = Color3.fromRGB(128, 128, 128),
    }
    local function fxc(name) return FXC[name] or FXC.white end

    local MATS = {
        ForceField = Enum.Material.ForceField,
        Flat = Enum.Material.SmoothPlastic,
        Chromatic = Enum.Material.Neon,
    }
    local function faces(bk, dn, ft, lf, rt, up)
        return { SkyboxBk = bk, SkyboxDn = dn, SkyboxFt = ft, SkyboxLf = lf, SkyboxRt = rt, SkyboxUp = up }
    end
    local function one(id)
        local u = "rbxassetid://" .. id
        return faces(u, u, u, u, u, u)
    end
    local SKY = {
        Jungle = faces("http://www.roblox.com/asset/?id=214399891", "http://www.roblox.com/asset/?id=214399887",
            "http://www.roblox.com/asset/?id=214399894", "http://www.roblox.com/asset/?id=214405668",
            "http://www.roblox.com/asset/?id=214399899", "http://www.roblox.com/asset/?id=214399889"),
        Blossom = faces("http://www.roblox.com/asset/?id=271042516", "http://www.roblox.com/asset/?id=271077243",
            "http://www.roblox.com/asset/?id=271042556", "http://www.roblox.com/asset/?id=271042310",
            "http://www.roblox.com/asset/?id=271042467", "http://www.roblox.com/asset/?id=271077958"),
        ["Red night"] = faces("http://www.roblox.com/Asset/?ID=401664839", "http://www.roblox.com/Asset/?ID=401664862",
            "http://www.roblox.com/Asset/?ID=401664960", "http://www.roblox.com/Asset/?ID=401664881",
            "http://www.roblox.com/Asset/?ID=401664901", "http://www.roblox.com/Asset/?ID=401664936"),
        Purple = faces("http://www.roblox.com/asset/?id=13694952867", "http://www.roblox.com/asset/?id=13694968325",
            "http://www.roblox.com/asset/?id=13694980654", "http://www.roblox.com/asset/?id=13694998113",
            "http://www.roblox.com/asset/?id=13695002700", "http://www.roblox.com/asset/?id=13695007103"),
        Foggy = faces("rbxassetid://1370717244", "rbxassetid://1370717336", "rbxassetid://1370717438",
            "rbxassetid://1370717567", "rbxassetid://1370717698", "rbxassetid://1370717782"),
        Galaxy = one("15983996673"), Anime = one("13107361022"), Minecraft = one("2758029221"),
    }

    -- lighting presets (morning / midday / evening / night) generated from the uploaded script's shaders table
        local SHADER_PRESETS = {
        morning = {
            L = { Ambient = Color3.fromRGB(10, 10, 10), Brightness = 1.5, ClockTime = 7.5, ColorShift_Bottom = Color3.fromRGB(0, 0, 0), ColorShift_Top = Color3.fromRGB(200, 200, 200), EnvironmentDiffuseScale = 0.1, EnvironmentSpecularScale = 0.1, OutdoorAmbient = Color3.fromRGB(10, 10, 10), GeographicLatitude = 44, ExposureCompensation = 0.3, GlobalShadows = true },
            CC = { Brightness = -0.02, Contrast = 0.8, Saturation = -0.5, TintColor = Color3.fromRGB(100, 150, 200) },
            BL = { Intensity = 0.2, Size = 5, Threshold = 0.8 },
            BLR = { Size = 2 },
            DOF = { FarIntensity = 0.5, FocusDistance = 15, InFocusRadius = 5, NearIntensity = 0.5 },
            AT = { Density = 0.2, Offset = 0.5, Color = Color3.fromRGB(70, 120, 170), Decay = Color3.fromRGB(10, 50, 100), Glare = 0.3, Haze = 1 },
            CL = { Cover = 0.6, Density = 0.36, Color = Color3.fromRGB(255, 255, 255) },
        },
        midday = {
            L = { Ambient = Color3.fromRGB(2, 2, 2), Brightness = 3.25, ClockTime = 8, ColorShift_Bottom = Color3.fromRGB(0, 0, 0), ColorShift_Top = Color3.fromRGB(255, 247, 237), EnvironmentDiffuseScale = 0.203, EnvironmentSpecularScale = 0.255, OutdoorAmbient = Color3.fromRGB(51, 54, 67), GeographicLatitude = -15.12, ExposureCompensation = 0.85, GlobalShadows = true },
            CC = { Brightness = 0.1, Contrast = 0.5, Saturation = -0.3, TintColor = Color3.fromRGB(242, 243, 243) },
            BL = { Intensity = 0.3, Size = 10, Threshold = 0.8 },
            BLR = { Size = 5 },
            DOF = { FarIntensity = 0.277, FocusDistance = 21.54, InFocusRadius = 16.77, NearIntensity = 0.277 },
            AT = { Density = 0.364, Offset = 0.556, Color = Color3.fromRGB(175, 221, 255), Decay = Color3.fromRGB(13, 105, 172), Glare = 0.36, Haze = 0.72 },
            CL = { Cover = 0.75, Density = 0.26, Color = Color3.fromRGB(255, 255, 255) },
        },
        evening = {
            L = { Ambient = Color3.fromRGB(2, 2, 2), Brightness = 2.25, ClockTime = 16, ColorShift_Bottom = Color3.fromRGB(0, 0, 0), ColorShift_Top = Color3.fromRGB(255, 247, 237), EnvironmentDiffuseScale = 0.203, EnvironmentSpecularScale = 0.215, OutdoorAmbient = Color3.fromRGB(0, 0, 0), GeographicLatitude = 45, ExposureCompensation = 0.65, GlobalShadows = true },
            CC = { Brightness = 0.1, Contrast = 0.5, Saturation = -0.3, TintColor = Color3.fromRGB(255, 205, 185) },
            BL = { Intensity = 0.3234, Size = 10, Threshold = 0.813 },
            BLR = { Size = 5 },
            DOF = { FarIntensity = 0.217, FocusDistance = 21.54, InFocusRadius = 16.77, NearIntensity = 0.277 },
            AT = { Density = 0.364, Offset = 5.556, Color = Color3.fromRGB(199, 175, 166), Decay = Color3.fromRGB(44, 39, 33), Glare = 0.36, Haze = 1.72 },
            CL = { Cover = 0.55, Density = 0.43, Color = Color3.fromRGB(199, 175, 166) },
        },
        night = {
            L = { Ambient = Color3.fromRGB(33, 33, 33), Brightness = 3.25, ClockTime = 20, ColorShift_Bottom = Color3.fromRGB(0, 0, 0), ColorShift_Top = Color3.fromRGB(255, 247, 237), EnvironmentDiffuseScale = 0.203, EnvironmentSpecularScale = 0.255, OutdoorAmbient = Color3.fromRGB(51, 54, 67), GeographicLatitude = -15, ExposureCompensation = 0.85, GlobalShadows = true },
            CC = { Brightness = -0.06, Contrast = -0.02, Saturation = -0.2, TintColor = Color3.fromRGB(242, 243, 243) },
            BL = { Intensity = 0.34, Size = 10, Threshold = 0.813 },
            BLR = { Size = 5 },
            DOF = { FarIntensity = 0.217, FocusDistance = 11.54, InFocusRadius = 16.77, NearIntensity = 0.277 },
            AT = { Density = 0.264, Offset = 0.156, Color = Color3.fromRGB(175, 221, 255), Decay = Color3.fromRGB(13, 105, 172), Glare = 0.36, Haze = 1.72 },
            CL = { Cover = 0.65, Density = 0.33, Color = Color3.fromRGB(255, 255, 255) },
        },
    }

    local ARM = math.rad(45)          -- off-screen chevron: the two arms sit 45 deg either side of the pointer
    local ARROW_MARGIN = 36           -- px from the screen edge the chevron sits at
    local HAT_N = 16                  -- china hat: segments in the brim ring
    local SIGNS = { -1, 1 }
    local FX_SPAN, FX_TALL = 260, 140 -- particle volume (studs), as in the source
    local SOFT = "rbxasset://textures/particles/smoke_main.dds"
    local R15 = {
        { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
    }
    local R6 = {
        { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
        { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
    }
    -- lighting effects of a shader preset: group -> class and where it lives
    local EFF = {
        CC = { class = "ColorCorrectionEffect", cont = "L" },
        BL = { class = "BloomEffect", cont = "L" },
        BLR = { class = "BlurEffect", cont = "L" },
        DOF = { class = "DepthOfFieldEffect", cont = "L" },
        AT = { class = "Atmosphere", cont = "L" },
        CL = { class = "Clouds", cont = "T" },
    }
    local LIGHT_KEYS = {
        "Ambient", "Brightness", "ClockTime", "ColorShift_Bottom", "ColorShift_Top", "EnvironmentDiffuseScale",
        "EnvironmentSpecularScale", "OutdoorAmbient", "GeographicLatitude", "ExposureCompensation", "GlobalShadows",
        "FogStart", "FogEnd", "FogColor",
    }

    local layer, wsFolder = nil, nil
    local P = {}                                   -- [player] = esp records
    local S = { circles = {}, eff = {}, effMade = {}, effOrig = {} }
    local matSaved = setmetatable({}, { __mode = "k" })
    local lighting = game:GetService("Lighting")
    local lightOrig = nil

    local function fxFail(e)
        e = tostring(e)
        if FX.lastErr ~= e then
            FX.lastErr = e
            warn("[MM2 Suite] fx: " .. e)
        end
    end
    local function killObj(o)
        if o then pcall(function() o:Destroy() end) end
    end
    local function hideList(list)
        for _, f in ipairs(list) do f.Visible = false end
    end
    -- screen layer for every 2d drawing (esp frames, crosshair)
    local function fxLayer()
        if layer and layer.Parent then return layer end
        layer = mk("ScreenGui", { Name = rname(), ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 40 }, guiParent)
        return layer
    end
    -- world folder for parts (tracer ends, landing circle, particle volume): parts only render inside workspace
    local function wsRoot()
        if wsFolder and wsFolder.Parent then return wsFolder end
        wsFolder = mk("Folder", { Name = rname() }, workspace)
        return wsFolder
    end
    local function fxFrame(parent, color)
        return mk("Frame", {
            BackgroundColor3 = color, BorderSizePixel = 0, Visible = false, ZIndex = 4,
            AnchorPoint = Vector2.new(0.5, 0.5),
        }, parent)
    end
    -- one thin frame stretched from (x1, y1) to (x2, y2)
    local function segment(f, x1, y1, x2, y2, th)
        local dx, dy = x2 - x1, y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)
        f.Visible = true
        f.Size = UDim2.fromOffset(math.max(len, 1), th)
        f.Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2)
        f.Rotation = math.deg(math.atan2(dy, dx))
    end

    -----------------------------------------------------------------
    -- esp: box, skeleton, off-screen chevrons, name / avatar / distance, glow, material chams, role flags
    -----------------------------------------------------------------
    local function rec(plr)
        local r = P[plr]
        if r then return r end
        local L = fxLayer()
        local root = espRoot()
        r = { box = {}, skel = {}, arr = {}, gradRole = nil, ch = nil }
        for i = 1, 8 do r.box[i] = fxFrame(L, Color3.new(1, 1, 1)) end
        for i = 1, 14 do r.skel[i] = fxFrame(L, Color3.new(1, 1, 1)) end
        for i = 1, 2 do r.arr[i] = fxFrame(L, Color3.new(1, 1, 1)) end
        r.fill = mk("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, BorderSizePixel = 0,
            Visible = false, ZIndex = 3,
        }, L)
        r.hl = mk("Highlight", {
            Name = rname(), DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            FillTransparency = 0.55, OutlineTransparency = 0, Enabled = false,
        }, root)
        r.tag = mk("BillboardGui", {
            Name = rname(), Size = UDim2.fromOffset(160, 36), StudsOffset = Vector3.new(0, 4.4, 0),
            AlwaysOnTop = true, LightInfluence = 0, Enabled = false,
        }, root)
        r.av = mk("ImageLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 5), Size = UDim2.fromOffset(26, 26),
            Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=48&h=48", Visible = false,
        }, r.tag)
        r.name = mk("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left, Text = "", Visible = false,
        }, r.tag)
        r.dist = mk("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 17), Size = UDim2.new(1, 0, 0, 14),
            Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 210),
            TextStrokeTransparency = 0.5, TextXAlignment = Enum.TextXAlignment.Left, Text = "", Visible = false,
        }, r.tag)
        r.flagTag = mk("BillboardGui", {
            Name = rname(), Size = UDim2.fromOffset(120, 18), StudsOffset = Vector3.new(0, 5.8, 0),
            AlwaysOnTop = true, LightInfluence = 0, Enabled = false,
        }, root)
        r.flag = mk("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, TextSize = 12,
            TextStrokeTransparency = 0.4, TextColor3 = Color3.new(1, 1, 1), Text = "",
        }, r.flagTag)
        r.grad = mk("UIGradient", { Enabled = false }, r.flag)
        P[plr] = r
        return r
    end

    local function matRestoreChar(ch)
        if not ch then return end
        pcall(function()
            for _, part in ipairs(ch:GetDescendants()) do
                local s = matSaved[part]
                if s then
                    part.Material = s.m
                    part.Color = s.c
                    matSaved[part] = nil
                end
            end
        end)
    end

    local function dropRec(plr)
        local r = P[plr]
        if not r then return end
        matRestoreChar(r.ch)
        killObj(r.hl); killObj(r.tag); killObj(r.flagTag); killObj(r.fill)
        for _, f in ipairs(r.box) do killObj(f) end
        for _, f in ipairs(r.skel) do killObj(f) end
        for _, f in ipairs(r.arr) do killObj(f) end
        P[plr] = nil
    end

    local function boxRect(cam, ch)
        local cf, size = ch:GetBoundingBox()
        local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
        local any = false
        for _, sx in ipairs(SIGNS) do
            for _, sy in ipairs(SIGNS) do
                for _, sz in ipairs(SIGNS) do
                    local s = cam:WorldToViewportPoint(cf * Vector3.new(sx * size.X / 2, sy * size.Y / 2, sz * size.Z / 2))
                    if s.Z > 0 then
                        any = true
                        if s.X < x0 then x0 = s.X end
                        if s.X > x1 then x1 = s.X end
                        if s.Y < y0 then y0 = s.Y end
                        if s.Y > y1 then y1 = s.Y end
                    end
                end
            end
        end
        if not any then return nil end
        return x0, y0, x1, y1
    end

    local function drawBox(r, cam, ch)
        local x0, y0, x1, y1 = boxRect(cam, ch)
        if not x0 then
            hideList(r.box)
            r.fill.Visible = false
            return
        end
        local w, h = x1 - x0, y1 - y0
        local col = fxc(Settings.FxBoxColor)
        r.fill.Position = UDim2.fromOffset(x0, y0)
        r.fill.Size = UDim2.fromOffset(w, h)
        r.fill.BackgroundColor3 = col
        r.fill.Visible = Settings.FxBoxFill and true or false
        local function put(i, ax, ay, bx, by)
            local f = r.box[i]
            f.BackgroundColor3 = col
            segment(f, ax, ay, bx, by, 1.5)
        end
        if Settings.FxBoxStyle == "Corners" then
            local L = math.min(w, h) * 0.25
            put(1, x0, y0, x0 + L, y0); put(2, x0, y0, x0, y0 + L)
            put(3, x1, y0, x1 - L, y0); put(4, x1, y0, x1, y0 + L)
            put(5, x0, y1, x0 + L, y1); put(6, x0, y1, x0, y1 - L)
            put(7, x1, y1, x1 - L, y1); put(8, x1, y1, x1, y1 - L)
        else
            put(1, x0, y0, x1, y0); put(2, x0, y1, x1, y1)
            put(3, x0, y0, x0, y1); put(4, x1, y0, x1, y1)
            for i = 5, 8 do r.box[i].Visible = false end
        end
    end

    local function drawSkel(r, cam, ch, hum)
        local bones = (hum and hum.RigType == Enum.HumanoidRigType.R15) and R15 or R6
        local col = fxc(Settings.FxSkelColor)
        local n = 0
        for _, b in ipairs(bones) do
            local a, c = ch:FindFirstChild(b[1]), ch:FindFirstChild(b[2])
            if a and c then
                local pa = cam:WorldToViewportPoint(a.Position)
                local pc = cam:WorldToViewportPoint(c.Position)
                if pa.Z > 0 and pc.Z > 0 then
                    n = n + 1
                    local f = r.skel[n]
                    f.BackgroundColor3 = col
                    segment(f, pa.X, pa.Y, pc.X, pc.Y, 1.5)
                end
            end
        end
        for i = n + 1, #r.skel do r.skel[i].Visible = false end
    end

    local function glowColor(role)
        if role == "Murderer" then return fxc(Settings.FxGlowMurder) end
        if role == "Sheriff" then return fxc(Settings.FxGlowSheriff) end
        return fxc(Settings.FxGlowInno)
    end
    local function arrowColor(role)
        if role == "Murderer" then return fxc(Settings.FxArrowMurder) end
        if role == "Sheriff" then return fxc(Settings.FxArrowSheriff) end
        return fxc(Settings.FxArrowInno)
    end

    -- off-screen chevron: the tip sits on the screen edge (inset), the arms point back to the centre
    local function drawArrow(r, cam, hrp, role, dist)
        local vs = cam.ViewportSize
        local s = cam:WorldToViewportPoint(hrp.Position)
        local inside = s.Z > 0 and s.X >= 0 and s.X <= vs.X and s.Y >= 0 and s.Y <= vs.Y
        if inside or dist > Settings.FxArrowRange then
            hideList(r.arr)
            return
        end
        local cx, cy = vs.X / 2, vs.Y / 2
        local dx, dy = s.X - cx, s.Y - cy
        if s.Z < 0 then dx, dy = -dx, -dy end
        local len = math.sqrt(dx * dx + dy * dy)
        local nx, ny = 0, -1
        if len > 0.001 then nx, ny = dx / len, dy / len end
        local k = math.min(
            (vs.X / 2 - ARROW_MARGIN) / math.max(math.abs(nx), 1e-6),
            (vs.Y / 2 - ARROW_MARGIN) / math.max(math.abs(ny), 1e-6))
        local px, py = cx + nx * k, cy + ny * k
        local bx, by = -nx, -ny                      -- back towards the centre
        local c, sn = math.cos(ARM), math.sin(ARM)
        local L = Settings.FxArrowSize
        local col = arrowColor(role)
        local a, b = r.arr[1], r.arr[2]
        segment(a, px, py, px + L * (bx * c - by * sn), py + L * (bx * sn + by * c), 3)
        segment(b, px, py, px + L * (bx * c + by * sn), py + L * (-bx * sn + by * c), 3)
        a.BackgroundColor3 = col
        b.BackgroundColor3 = col
    end

    local function matApply(ch, role)
        local style = Settings.FxMatStyle
        local mat = MATS[style] or Enum.Material.ForceField
        local col = glowColor(role)
        if style == "Chromatic" then col = Color3.fromHSV((os.clock() * 0.2) % 1, 0.8, 1) end
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if not matSaved[part] then matSaved[part] = { m = part.Material, c = part.Color } end
                if part.Material ~= mat then part.Material = mat end
                if part.Color ~= col then part.Color = col end
            end
        end
    end
    local function matRestore()
        for part, s in pairs(matSaved) do
            pcall(function()
                part.Material = s.m
                part.Color = s.c
            end)
            matSaved[part] = nil
        end
    end

    local function espTick()
        local cam = curCam()
        if not cam then return end
        if not Settings.FxEsp then
            for plr in pairs(P) do dropRec(plr) end
            matRestore()
            return
        end
        if not Settings.FxMat then matRestore() end
        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local live = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                local hrp = isAlive(plr)
                if hrp and inRound(plr) then
                    local ch = plr.Character
                    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                    local head = ch and ch:FindFirstChild("Head")
                    if hum and head then
                        live[plr] = true
                        local r = rec(plr)
                        r.ch = ch
                        local role = getRole(plr)
                        local dist = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0

                        if Settings.FxBox then
                            drawBox(r, cam, ch)
                        else
                            hideList(r.box)
                            r.fill.Visible = false
                        end
                        if Settings.FxSkel then drawSkel(r, cam, ch, hum) else hideList(r.skel) end
                        if Settings.FxArrows then drawArrow(r, cam, hrp, role, dist) else hideList(r.arr) end

                        if Settings.FxGlow then
                            if r.hl.Adornee ~= ch then r.hl.Adornee = ch end
                            local c = glowColor(role)
                            if r.hl.FillColor ~= c then
                                r.hl.FillColor = c
                                r.hl.OutlineColor = c
                            end
                            r.hl.Enabled = true
                        else
                            r.hl.Enabled = false
                        end

                        if Settings.FxMat then matApply(ch, role) end

                        local showAv, showName, showDist = Settings.FxAvatar, Settings.FxName, Settings.FxDist
                        local showTag = showAv or showName or showDist
                        r.tag.Enabled = showTag and true or false
                        if showTag then
                            if r.tag.Adornee ~= head then r.tag.Adornee = head end
                            local x = showAv and 32 or 0
                            r.av.Visible = showAv and true or false
                            r.name.Visible = showName and true or false
                            r.dist.Visible = showDist and true or false
                            r.name.Position = UDim2.fromOffset(x, 0)
                            r.name.Size = UDim2.new(1, -x, 0, 16)
                            r.dist.Position = UDim2.fromOffset(x, 17)
                            r.dist.Size = UDim2.new(1, -x, 0, 14)
                            if showName then
                                if r.name.Text ~= plr.DisplayName then r.name.Text = plr.DisplayName end
                                r.name.TextColor3 = fxc(Settings.FxNameColor)
                            end
                            if showDist then
                                local dtxt = string.format("%dm", math.floor(dist + 0.5))
                                if r.dist.Text ~= dtxt then r.dist.Text = dtxt end
                            end
                        end

                        local showFlag = Settings.FxFlags and (role == "Murderer" or role == "Sheriff")
                        r.flagTag.Enabled = showFlag and true or false
                        if showFlag then
                            if r.flagTag.Adornee ~= head then r.flagTag.Adornee = head end
                            local c = COLORS[role]
                            local label = role == "Murderer" and "MURDERER" or "SHERIFF"
                            if r.flag.Text ~= label then r.flag.Text = label end
                            r.flag.TextColor3 = c
                            r.grad.Enabled = Settings.FxFlagsGrad and true or false
                            if Settings.FxFlagsGrad and r.gradRole ~= role then
                                r.gradRole = role
                                r.grad.Color = ColorSequence.new(c, Color3.new(1, 1, 1))
                            end
                        end
                    end
                end
            end
        end
        for plr in pairs(P) do
            if not live[plr] then dropRec(plr) end
        end
    end

    -----------------------------------------------------------------
    -- local: china hat (beams on your head), backtrack ghost, self / tool chams, landing circle
    -----------------------------------------------------------------
    local function hatDrop()
        if not S.hat then return end
        for _, o in ipairs(S.hat.objs) do killObj(o) end
        S.hat = nil
    end
    local function hatBuild(head)
        hatDrop()
        local objs, beams, at = {}, {}, {}
        local ring = 1.05
        for i = 1, HAT_N do
            local a = (i - 1) / HAT_N * math.pi * 2
            at[i] = mk("Attachment", { CFrame = CFrame.new(math.cos(a) * ring, 0.66, math.sin(a) * ring) }, head)
            objs[#objs + 1] = at[i]
        end
        local apex = mk("Attachment", { CFrame = CFrame.new(0, 1.25, 0) }, head)
        objs[#objs + 1] = apex
        local seq = ColorSequence.new(fxc(Settings.FxChinaColor))
        local function beam(a0, a1)
            local b = mk("Beam", {
                Attachment0 = a0, Attachment1 = a1, Width0 = 0.06, Width1 = 0.06, FaceCamera = true,
                LightInfluence = 0, Color = seq, Transparency = NumberSequence.new(0.1),
            }, head)
            objs[#objs + 1] = b
            beams[#beams + 1] = b
        end
        for i = 1, HAT_N do
            beam(at[i], at[i % HAT_N + 1])
            beam(apex, at[i])
        end
        S.hat = { head = head, objs = objs, beams = beams, col = Settings.FxChinaColor }
    end
    local function hatUpdate()
        local h = S.hat
        if not h or h.col == Settings.FxChinaColor then return end
        h.col = Settings.FxChinaColor
        local seq = ColorSequence.new(fxc(h.col))
        for _, b in ipairs(h.beams) do b.Color = seq end
    end

    local function ghostDrop()
        if not S.ghost then return end
        killObj(S.ghost.model)
        S.ghost = nil
    end
    local function ghostBuild(ch)
        ghostDrop()
        local was = ch.Archivable
        ch.Archivable = true
        local ok, m = pcall(function() return ch:Clone() end)
        ch.Archivable = was
        if not ok or not m then return end
        local real = {}
        for _, o in ipairs(ch:GetDescendants()) do
            if o:IsA("BasePart") then real[#real + 1] = o end
        end
        local col = fxc(Settings.FxBacktrackColor)
        local pl, ci = {}, 0
        for _, o in ipairs(m:GetDescendants()) do
            if o:IsA("BasePart") then
                ci = ci + 1
                o.Anchored = true
                o.CanCollide = false
                o.CanQuery = false
                o.CanTouch = false
                o.CastShadow = false
                if o.Name == "HumanoidRootPart" then
                    o.Transparency = 1
                else
                    o.Material = Enum.Material.ForceField
                    o.Color = col
                    o.Transparency = 0.2
                end
                pl[#pl + 1] = { o, real[ci] }
            elseif o:IsA("Script") or o:IsA("LocalScript") or o:IsA("Decal") or o:IsA("Texture")
                or o:IsA("ParticleEmitter") or o:IsA("Beam") or o:IsA("Trail") or o:IsA("PointLight")
                or o:IsA("SpotLight") or o:IsA("SurfaceLight") or o:IsA("Sound") or o:IsA("Humanoid") then
                killObj(o)
            end
        end
        m.Parent = workspace
        S.ghost = { model = m, char = ch, pl = pl, hist = {} }
    end
    local function ghostUpdate(hrp)
        local g = S.ghost
        local now = os.clock()
        local hist = g.hist
        hist[#hist + 1] = { t = now, cf = hrp.CFrame }
        local ping = clamp(tonumber(PING.rtt) or 0.15, 0.05, 0.6)
        local target = now - ping
        local cf = hrp.CFrame
        for i = #hist, 1, -1 do
            if hist[i].t <= target then
                cf = hist[i].cf
                break
            end
        end
        while #hist > 2 and hist[1].t < now - 1.5 do table.remove(hist, 1) end
        local inv = hrp.CFrame:Inverse()
        local col = fxc(Settings.FxBacktrackColor)
        for _, p in ipairs(g.pl) do
            local ghost, real = p[1], p[2]
            if real and ghost.Parent and real.Parent then
                ghost.CFrame = cf * (inv * real.CFrame)
                if ghost.Name ~= "HumanoidRootPart" and ghost.Color ~= col then ghost.Color = col end
            end
        end
    end

    local function hlFor(key)
        local h = S[key]
        if not h or not h.Parent then
            h = mk("Highlight", {
                Name = rname(), DepthMode = Enum.HighlightDepthMode.Occluded, OutlineTransparency = 0.2, Enabled = false,
            }, espRoot())
            S[key] = h
        end
        return h
    end
    local function styleHL(hl, style, col)
        local c = col
        if style == "Chromatic" then c = Color3.fromHSV((os.clock() * 0.2) % 1, 0.8, 1) end
        if hl.FillColor ~= c then
            hl.FillColor = c
            hl.OutlineColor = c
        end
        local ft = (style == "Flat" and 0.1) or (style == "Chromatic" and 0.3) or 0.45
        if hl.FillTransparency ~= ft then hl.FillTransparency = ft end
    end

    local function landingSpawn(ch, hrp)
        local okR, hit = pcall(function()
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { ch }
            return workspace:Raycast(hrp.Position, Vector3.new(0, -14, 0), params)
        end)
        local pos = (okR and hit and hit.Position) or (hrp.Position - Vector3.new(0, 3, 0))
        for _, o in ipairs(S.circles) do killObj(o) end
        S.circles = {}
        local dur = Settings.FxLandDur
        local disc = mk("Part", {
            Name = rname(), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
            CastShadow = false, Massless = true, Material = Enum.Material.Neon, Color = fxc(Settings.FxLandColor),
            Transparency = 1 - clamp(Settings.FxLandOpacity, 0, 1), Shape = Enum.PartType.Cylinder,
            Size = Vector3.new(0.12, 5.5, 5.5),
            CFrame = CFrame.new(pos + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2),
        }, wsRoot())
        S.circles[1] = disc
        pcall(function()
            TweenService:Create(disc, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Transparency = 1 }):Play()
        end)
        task.delay(dur + 0.1, function() killObj(disc) end)
    end

    local function localTick()
        local ch = lp.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local head = ch and ch:FindFirstChild("Head")
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")

        if Settings.FxChina and head then
            if not S.hat or S.hat.head ~= head then hatBuild(head) end
            hatUpdate()
        else
            hatDrop()
        end

        if Settings.FxBacktrack and hrp and hum and hum.Health > 0 then
            if not S.ghost or S.ghost.char ~= ch then ghostBuild(ch) end
            if S.ghost then ghostUpdate(hrp) end
        else
            ghostDrop()
        end

        if Settings.FxSelfChams and ch then
            local hl = hlFor("selfHL")
            if hl.Adornee ~= ch then hl.Adornee = ch end
            styleHL(hl, Settings.FxSelfStyle, fxc(Settings.FxSelfColor))
            hl.Enabled = true
        elseif S.selfHL then
            S.selfHL.Enabled = false
        end

        local tool = nil
        if Settings.FxToolChams and ch then tool = ch:FindFirstChildOfClass("Tool") end
        if tool then
            local hl = hlFor("toolHL")
            if hl.Adornee ~= tool then hl.Adornee = tool end
            styleHL(hl, Settings.FxToolStyle, fxc(Settings.FxToolColor))
            hl.Enabled = true
        elseif S.toolHL then
            S.toolHL.Enabled = false
        end

        if Settings.FxLanding and hum and hrp then
            local air = hum.FloorMaterial == Enum.Material.Air
            if S.air and not air then landingSpawn(ch, hrp) end
            S.air = air
        else
            S.air = false
        end
    end

    -----------------------------------------------------------------
    -- world: one lighting writer (shader < fullbright < ambient < fog < time < exposure), effects, skybox
    -----------------------------------------------------------------
    local function lightSave()
        if lightOrig then return end
        lightOrig = {}
        for _, k in ipairs(LIGHT_KEYS) do
            local ok, v = pcall(function() return lighting[k] end)
            if ok and v ~= nil then lightOrig[k] = v end
        end
    end
    local function lightRestore()
        if not lightOrig then return end
        for k, v in pairs(lightOrig) do pcall(function() lighting[k] = v end) end
        lightOrig = nil
    end
    local function wantLighting()
        local want = {}
        if Settings.FxShader then
            local d = SHADER_PRESETS[Settings.FxShaderType]
            if d and d.L then
                for k, v in pairs(d.L) do want[k] = v end
            end
            want.FogStart = math.huge
            want.FogEnd = math.huge
            want.FogColor = Color3.fromRGB(255, 255, 255)
        end
        if Settings.FxFullbright then
            want.Brightness = 2
            want.ClockTime = 14
            want.GlobalShadows = false
            want.OutdoorAmbient = FXC.dim
            if not Settings.FxFog then want.FogEnd = 100000 end
        end
        if Settings.FxAmbient then
            want.Ambient = fxc(Settings.FxAmbientColor)
            want.OutdoorAmbient = fxc(Settings.FxAmbientColor)
        end
        if Settings.FxFog then
            want.FogColor = fxc(Settings.FxFogColor)
            want.FogStart = Settings.FxFogStart
            want.FogEnd = Settings.FxFogEnd
        end
        if Settings.FxTime then want.ClockTime = Settings.FxClock end
        if Settings.FxExposure then want.ExposureCompensation = Settings.FxExposureValue end
        return want
    end
    local function lightTick()
        local want = wantLighting()
        if next(want) == nil then
            lightRestore()
            return
        end
        lightSave()
        for _, k in ipairs(LIGHT_KEYS) do
            local v = want[k]
            if v == nil and lightOrig then v = lightOrig[k] end
            if v ~= nil then
                local okC, cur = pcall(function() return lighting[k] end)
                if not okC or cur ~= v then pcall(function() lighting[k] = v end) end
            end
        end
    end

    -- one lighting effect of a preset: made when missing (removed again), or an existing one (values put back)
    local function effectApply(g, d)
        local spec = EFF[g]
        local e = S.eff[g]
        if d then
            if not e or not e.Parent then
                local holder = (spec.cont == "T") and workspace.Terrain or lighting
                e = holder:FindFirstChildOfClass(spec.class)
                S.effOrig[g] = nil
                S.effMade[g] = nil
                if not e then
                    e = mk(spec.class, {}, holder)
                    S.effMade[g] = true
                end
                S.eff[g] = e
            end
            if not S.effMade[g] then
                S.effOrig[g] = S.effOrig[g] or {}
                local keys = { "Enabled" }
                for prop in pairs(d) do keys[#keys + 1] = prop end
                for _, prop in ipairs(keys) do
                    if S.effOrig[g][prop] == nil then
                        local okO, ov = pcall(function() return e[prop] end)
                        if okO and ov ~= nil then S.effOrig[g][prop] = ov end
                    end
                end
            end
            for prop, v in pairs(d) do
                pcall(function() if e[prop] ~= v then e[prop] = v end end)
            end
            pcall(function()
                local on = (g ~= "BLR")
                if e.Enabled ~= on then e.Enabled = on end
            end)
        elseif e then
            if S.effMade[g] then
                killObj(e)
            elseif S.effOrig[g] then
                for prop, ov in pairs(S.effOrig[g]) do pcall(function() e[prop] = ov end) end
            end
            S.eff[g] = nil
            S.effMade[g] = nil
            S.effOrig[g] = nil
        end
    end
    local function shaderTick()
        local d = Settings.FxShader and SHADER_PRESETS[Settings.FxShaderType] or nil
        for g in pairs(EFF) do
            effectApply(g, d and d[g] or nil)
        end
    end

    local function skyTick()
        if Settings.FxSky then
            if S.sky and S.skyName ~= Settings.FxSkyName then
                killObj(S.sky)
                S.sky = nil
            end
            if not S.sky then
                if not S.skyHidden then
                    S.skyHidden = {}
                    for _, s in ipairs(lighting:GetChildren()) do
                        if s:IsA("Sky") then
                            S.skyHidden[#S.skyHidden + 1] = s
                            pcall(function() s.Parent = nil end)
                        end
                    end
                end
                S.skyName = Settings.FxSkyName
                S.sky = mk("Sky", SKY[S.skyName] or SKY.Jungle, lighting)
            end
        else
            if S.sky then
                killObj(S.sky)
                S.sky = nil
                S.skyName = nil
            end
            if S.skyHidden then
                for _, s in ipairs(S.skyHidden) do pcall(function() s.Parent = lighting end) end
                S.skyHidden = nil
            end
        end
    end

    local function worldTick()
        lightTick()
        skyTick()
        shaderTick()
    end

    -----------------------------------------------------------------
    -- world effects: snow / sakura volume that follows the camera (the source's emitter, same numbers)
    -----------------------------------------------------------------
    local function partStyle(e, t, col, rate)
        e.Texture = SOFT
        e.LightInfluence = 0
        e.LightEmission = 0.4
        e.ZOffset = 0
        e.Drag = 0
        e.EmissionDirection = Enum.NormalId.Bottom
        e.Rate = rate
        e.Color = ColorSequence.new(col)
        if t == "Snow" then
            e.Lifetime = NumberRange.new(4, 6)
            e.Speed = NumberRange.new(6, 12)
            e.Acceleration = Vector3.new(2, -6, 1)
            e.SpreadAngle = Vector2.new(35, 35)
            e.Rotation = NumberRange.new(0, 360)
            e.RotSpeed = NumberRange.new(-40, 40)
            e.Squash = NumberSequence.new(0)
            e.Size = NumberSequence.new(0.55)
            e.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(0.8, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            })
        else
            e.Lifetime = NumberRange.new(5, 7)
            e.Speed = NumberRange.new(5, 10)
            e.Acceleration = Vector3.new(4, -5, 2)
            e.SpreadAngle = Vector2.new(40, 40)
            e.Rotation = NumberRange.new(0, 360)
            e.RotSpeed = NumberRange.new(-80, 80)
            e.Squash = NumberSequence.new(1.4)
            e.Size = NumberSequence.new(0.5)
            e.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.15),
                NumberSequenceKeypoint.new(0.85, 0.25),
                NumberSequenceKeypoint.new(1, 1),
            })
        end
    end
    local function partBurst(em, rate)
        pcall(function() em:Emit(clamp(math.floor(rate * 0.16), 30, 140)) end)
    end
    local function partTick()
        if not Settings.FxParticles then
            killObj(S.pfxPart)
            S.pfxPart, S.pfxEm, S.pfxType, S.pfxPos, S.pfxLook = nil, nil, nil, nil, nil
            return
        end
        local cam = curCam()
        if not cam then return end
        local part = S.pfxPart
        if not part or not part.Parent then
            part = mk("Part", {
                Name = rname(), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
                CastShadow = false, Transparency = 1, Size = Vector3.new(FX_SPAN, FX_TALL, FX_SPAN),
            }, wsRoot())
            local em = mk("ParticleEmitter", {}, part)
            pcall(function()
                em.Shape = Enum.ParticleEmitterShape.Box
                em.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
            end)
            S.pfxPart, S.pfxEm = part, em
            S.pfxType, S.pfxPos, S.pfxLook = nil, nil, nil
        end
        local em = S.pfxEm
        local rate = Settings.FxParticleRate
        if S.pfxType ~= Settings.FxParticleType or S.pfxColor ~= Settings.FxParticleColor or S.pfxRate ~= rate then
            S.pfxType, S.pfxColor, S.pfxRate = Settings.FxParticleType, Settings.FxParticleColor, rate
            partStyle(em, S.pfxType, fxc(S.pfxColor), rate)
            partBurst(em, rate)
        end
        local cf = cam.CFrame
        local p = cf.Position
        local d = cf.LookVector
        local flat = Vector3.new(d.X, 0, d.Z)
        if flat.Magnitude < 0.05 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
        local pos, look = S.pfxPos, S.pfxLook
        if pos and look and (p - pos).Magnitude < 10 and flat:Dot(look) > 0.95 then return end
        S.pfxPos, S.pfxLook = p, flat
        part.CFrame = CFrame.new(p + flat * (FX_SPAN * 0.22) + Vector3.new(0, FX_TALL * 0.5 - 26, 0))
    end

    -----------------------------------------------------------------
    -- crosshair: four arms round the mouse, outline under each arm, spin, shown only with a gun out
    -----------------------------------------------------------------
    local function crossBuild()
        local L = fxLayer()
        local fr = {}
        for _ = 1, 4 do
            local o = fxFrame(L, FXC.black)
            o.ZIndex = 5
            local l = fxFrame(L, FXC.white)
            l.ZIndex = 6
            fr[#fr + 1] = o
            fr[#fr + 1] = l
        end
        S.crossFr = fr
    end
    local function crossTick(dt)
        local ch = lp.Character
        local show = (Settings.FxCross and ch and ch:FindFirstChild("Gun")) and true or false
        -- hide original: the game's own crosshair, only while ours is on screen
        local pg = lp:FindFirstChild("PlayerGui")
        local top = pg and pg:FindFirstChild("GameTopbar")
        local gc = top and top:FindFirstChild("Crosshair")
        if Settings.FxCrossHide and show and gc and gc:IsA("GuiObject") and not S.gameCross then
            S.gameCross = gc
            S.gameCrossVis = gc.Visible
            gc.Visible = false
        elseif S.gameCross and not (Settings.FxCrossHide and show) then
            local g, v = S.gameCross, S.gameCrossVis
            S.gameCross = nil
            pcall(function() g.Visible = v end)
        end

        if not Settings.FxCross then
            if S.crossFr then
                for _, f in ipairs(S.crossFr) do killObj(f) end
                S.crossFr = nil
            end
            return
        end
        if not show then
            if S.crossFr then hideList(S.crossFr) end
            return
        end
        if not S.crossFr then crossBuild() end
        local fr = S.crossFr
        local mp = UIS:GetMouseLocation()
        if Settings.FxCrossSpin > 0 then
            S.crossRot = ((S.crossRot or 0) + (dt or 0) * Settings.FxCrossSpin * 100) % 360
        else
            S.crossRot = 0
        end
        local rad = math.rad(S.crossRot)
        local g, len, th = Settings.FxCrossGap, Settings.FxCrossLen, Settings.FxCrossThick
        local col, ocol = fxc(Settings.FxCrossColor), fxc(Settings.FxCrossOutline)
        for i = 1, 4 do
            local a = rad + (i - 1) * math.pi / 2
            local c, sn = math.cos(a), math.sin(a)
            local o, l = fr[i * 2 - 1], fr[i * 2]
            segment(o, mp.X + (g - 1) * c, mp.Y + (g - 1) * sn, mp.X + (g + len + 1) * c, mp.Y + (g + len + 1) * sn, th + 2)
            o.BackgroundColor3 = ocol
            segment(l, mp.X + g * c, mp.Y + g * sn, mp.X + (g + len) * c, mp.Y + (g + len) * sn, th)
            l.BackgroundColor3 = col
        end
    end

    -----------------------------------------------------------------
    -- bullet tracer: called from the remote hook on every gun shot (your own shots only: that is what the client sees)
    -----------------------------------------------------------------
    function FX.shot(args)
        if not Settings.FxTracer then return end
        local pts = {}
        for i = 1, (args.n or #args) do
            local v = args[i]
            local t = typeof(v)
            if t == "Vector3" then
                pts[#pts + 1] = v
            elseif t == "CFrame" then
                pts[#pts + 1] = v.Position
            end
        end
        local to = pts[#pts]
        if not to then return end
        local from = nil
        if #pts >= 2 then from = pts[1] end
        if not from then
            local head = lp.Character and lp.Character:FindFirstChild("Head")
            if not head then return end
            from = head.Position
        end
        local dist = (to - from).Magnitude
        if dist < 2 or dist > 2000 then return end
        local col = fxc(Settings.FxTracerColor)
        local folder = wsRoot()
        local a0 = mk("Part", {
            Name = rname(), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
            CastShadow = false, Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2), CFrame = CFrame.new(from),
        }, folder)
        local a1 = mk("Part", {
            Name = rname(), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
            CastShadow = false, Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2), CFrame = CFrame.new(to),
        }, folder)
        local t0 = mk("Attachment", {}, a0)
        local t1 = mk("Attachment", {}, a1)
        mk("Beam", {
            Attachment0 = t0, Attachment1 = t1, Color = ColorSequence.new(col), Width0 = 0.16, Width1 = 0.16,
            FaceCamera = true, LightEmission = 1, LightInfluence = 0, Transparency = NumberSequence.new(0.1),
        }, a0)
        task.delay(Settings.FxTracerDur, function()
            killObj(a0)
            killObj(a1)
        end)
    end

    function FX.stop()
        for plr in pairs(P) do dropRec(plr) end
        matRestore()
        hatDrop()
        ghostDrop()
        killObj(S.selfHL); killObj(S.toolHL)
        S.selfHL, S.toolHL = nil, nil
        for _, o in ipairs(S.circles) do killObj(o) end
        S.circles = {}
        for g in pairs(EFF) do effectApply(g, nil) end
        killObj(S.sky)
        S.sky, S.skyName = nil, nil
        if S.skyHidden then
            for _, s in ipairs(S.skyHidden) do pcall(function() s.Parent = lighting end) end
            S.skyHidden = nil
        end
        lightRestore()
        if S.gameCross then
            local g, v = S.gameCross, S.gameCrossVis
            S.gameCross = nil
            pcall(function() g.Visible = v end)
        end
        killObj(S.pfxPart)
        S.pfxPart, S.pfxEm, S.pfxType = nil, nil, nil
        killObj(wsFolder)
        wsFolder = nil
        killObj(layer)
        layer = nil
        S.crossFr = nil
    end

    -----------------------------------------------------------------
    -- loop: particles and crosshair every frame, esp / local at 30 Hz, world at 4 Hz
    -----------------------------------------------------------------
    local accEsp, accWorld = 0, 0
    connect(RunService.Heartbeat, function(dt)
        if not running then return end
        dt = dt or 1 / 60
        accEsp = accEsp + dt
        accWorld = accWorld + dt
        local okP, eP = pcall(partTick)
        if not okP then fxFail(eP) end
        local okX, eX = pcall(crossTick, dt)
        if not okX then fxFail(eX) end
        if accEsp >= 1 / 30 then
            accEsp = 0
            local ok1, e1 = pcall(espTick)
            if not ok1 then fxFail(e1) end
            local ok2, e2 = pcall(localTick)
            if not ok2 then fxFail(e2) end
        end
        if accWorld >= 0.25 then
            accWorld = 0
            local ok3, e3 = pcall(worldTick)
            if not ok3 then fxFail(e3) end
        end
    end)
end)()

local function buildHub()
    local isTouch = UIS.TouchEnabled and true or false

    local function viewport()
        local cam = workspace.CurrentCamera
        return cam and cam.ViewportSize or Vector2.new(1280, 720)
    end
    local function defaultSize()
        local vp = viewport()
        return math.clamp(math.floor(vp.X * 0.31), 300, 680), math.clamp(math.floor(vp.Y * 0.72), 260, 760)
    end
    local function sidebarWidth(w)
        return math.clamp(math.floor(w * 0.29), 84, 128)
    end
    local function ms(x)
        return tostring(math.floor(x * 1000 + 0.5))
    end

    -----------------------------------------------------------------
    -- palette, icons, helpers
    -----------------------------------------------------------------
    local T = {
        Bg = Color3.fromRGB(10, 10, 12),
        Side = Color3.fromRGB(9, 9, 11),
        Card = Color3.fromRGB(17, 17, 20),
        Row = Color3.fromRGB(26, 26, 31),
        Input = Color3.fromRGB(13, 13, 16),
        Line = Color3.fromRGB(34, 34, 40),
        Under = Color3.fromRGB(180, 180, 190),
        Text = Color3.fromRGB(236, 236, 240),
        Muted = Color3.fromRGB(128, 128, 137),
        Hint = Color3.fromRGB(94, 94, 104),
        Dim = Color3.fromRGB(64, 64, 72),
        Check = Color3.fromRGB(10, 10, 12),
        Accent = Color3.fromRGB(255, 255, 255),
    }
    if type(UI.accent) == "table" then
        T.Accent = Color3.fromRGB(UI.accent[1], UI.accent[2], UI.accent[3])
    end
    local ICONS = {
        Search = "rbxassetid://7733911828", Chevron = "rbxassetid://7733717447",
        Combat = "rbxassetid://7734053426", Visuals = "rbxassetid://7733774602",
        Player = "rbxassetid://7733954760", Misc = "rbxassetid://7734056411",
        Presets = "rbxassetid://7733964719", Vote = "rbxassetid://7733942651",
        Stats = "rbxassetid://7733749837", Clock = "rbxassetid://7733734762",
        Signal = "rbxassetid://7734058495",
    }
    local PALETTE = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(139, 92, 246), Color3.fromRGB(59, 130, 246),
        Color3.fromRGB(16, 185, 129), Color3.fromRGB(244, 63, 94), Color3.fromRGB(245, 158, 11),
    }
    local TOAST_COL = {
        good = Color3.fromRGB(96, 210, 128), warn = Color3.fromRGB(236, 182, 74),
        bad = Color3.fromRGB(236, 94, 98), info = Color3.fromRGB(150, 150, 158),
    }

    local ACC = {}
    local function acc(o, prop)
        local p = prop or "BackgroundColor3"
        ACC[#ACC + 1] = { o, p }
        o[p] = T.Accent
        return o
    end
    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end
    local function corner(o, r)
        return new("UICorner", { CornerRadius = UDim.new(0, r) }, o)
    end
    local function stroke(o, color, th, tr)
        return new("UIStroke", { Color = color, Thickness = th or 1, Transparency = tr or 0 }, o)
    end
    local function pad(o, t, r, b, l)
        return new("UIPadding", {
            PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0),
            PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0),
        }, o)
    end
    local function vlist(o, gap)
        return new("UIListLayout", { Padding = UDim.new(0, gap or 0), SortOrder = Enum.SortOrder.LayoutOrder }, o)
    end
    local function hlist(o, gap)
        return new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, gap or 0),
            SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
        }, o)
    end
    local function txt(parent, text, props)
        local p = {
            BackgroundTransparency = 1, Text = text or "", Font = Enum.Font.Gotham, TextSize = 8,
            TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        }
        for k, v in pairs(props or {}) do p[k] = v end
        return new("TextLabel", p, parent)
    end
    local function tween(o, t, props)
        pcall(function()
            TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
        end)
    end
    local function nextOrder(c)
        local n = (c:GetAttribute("n") or 0) + 1
        c:SetAttribute("n", n)
        return n
    end

    -----------------------------------------------------------------
    -- shared state (declared here, assigned further down)
    -----------------------------------------------------------------
    local W, H = defaultSize()
    if UI.w then W = UI.w end
    if UI.h then H = UI.h end
    local SB = sidebarWidth(W)
    local placed, shown = false, true
    local mainX, mainY = 0, 0
    local curPage = nil
    local alertAt = 0
    local fpsN, fpsT, fpsV = 0, os.clock(), 0
    local navN = 0
    local sliderDrag, hubDrag, gripDrag, launchDrag, keyListen = nil, nil, nil, nil, nil
    local scrollLock = nil -- ScrollingFrame paused while a slider is dragged (a touch drag would scroll the page)
    local function scrollerOf(o)
        local p = o.Parent
        while p do
            if p:IsA("ScrollingFrame") then return p end
            p = p.Parent
        end
        return nil
    end
    local showPage, applySearch, layout, setShown, setSize, saveSize, setAccent
    local navRefresh, navSetActive, refreshHud, refreshAccounts, refreshPlayers
    local REG, ROWS, PG, NAV, SIZE_UI, GROUP_OPEN = {}, {}, {}, {}, {}, {}
    local ACC_TXT, lockRows, mvSlot, mvValue = {}, {}, {}, {}
    local lockBox = nil
    local decorLines, decorDots = {}, {}
    local PAGE_TITLE = {
        game = "game", esp = "visuals / esp", world = "visuals / world", fx = "visuals / fx", lock = "player / target lock",
        perks = "player / local", vote = "map vote", misc = "misc", stats = "live stats", presets = "settings",
    }

    -----------------------------------------------------------------
    -- screen gui + toasts (bottom centre)
    -----------------------------------------------------------------
    for _, nm in ipairs({ "PastaCompleteUI", "ShitaroMM2" }) do
        local old = guiParent and guiParent:FindFirstChild(nm)
        if old then old:Destroy() end
    end
    local gui = new("ScreenGui", {
        Name = "ShitaroMM2", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 60,
    }, guiParent)
    ST.gui = gui

    local toastBox = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.fromOffset(280, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 50,
    }, gui)
    local toastList = vlist(toastBox, 3)
    toastList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    toastList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local toasts, toastN = {}, 0
    ST.toast = function(text, kind)
        toastN = toastN + 1
        local col = TOAST_COL[kind or "info"] or TOAST_COL.info
        local box = new("Frame", {
            Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Bg,
            BorderSizePixel = 0, LayoutOrder = toastN, ZIndex = 50,
        }, toastBox)
        corner(box, 4)
        stroke(box, T.Line, 1, 0)
        new("Frame", {
            Size = UDim2.fromOffset(2, 10), Position = UDim2.fromOffset(6, 5), BackgroundColor3 = col,
            BorderSizePixel = 0, ZIndex = 51,
        }, box)
        local lb = txt(box, tostring(text), {
            Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, TextSize = 8,
            Font = Enum.Font.GothamMedium, ZIndex = 51,
        })
        pad(lb, 0, 10, 0, 12)
        toasts[#toasts + 1] = box
        if #toasts > 3 then
            local old = table.remove(toasts, 1)
            pcall(function() old:Destroy() end)
        end
        task.delay(2.6, function()
            if box.Parent then
                tween(box, 0.25, { BackgroundTransparency = 1 })
                tween(lb, 0.25, { TextTransparency = 1 })
                task.wait(0.3)
                pcall(function() box:Destroy() end)
            end
            for i, h in ipairs(toasts) do
                if h == box then
                    table.remove(toasts, i)
                    break
                end
            end
        end)
    end

    -----------------------------------------------------------------
    -- watermark, top right: brand | user, players, fps, ping, time (+ murderer alert)
    -----------------------------------------------------------------
    local hud = new("Frame", {
        Name = "Watermark", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 44),
        Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 5,
    }, gui)
    local hudList = hlist(hud, 4)
    hudList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    local function capsule(order)
        local f = new("Frame", {
            Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Bg,
            BackgroundTransparency = 0.08, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 5,
        }, hud)
        corner(f, 4)
        stroke(f, T.Line, 1, 0)
        pad(f, 0, 6, 0, 6)
        hlist(f, 4)
        return f
    end
    local function piece(parent, order, text, color, bold)
        return new("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), BackgroundTransparency = 1,
            Text = text or "", Font = bold and Enum.Font.GothamMedium or Enum.Font.Gotham, TextSize = 8,
            TextColor3 = color or T.Text, LayoutOrder = order,
        }, parent)
    end
    local function sep(parent, order)
        new("Frame", {
            Size = UDim2.fromOffset(1, 8), BackgroundColor3 = T.Line, BorderSizePixel = 0, LayoutOrder = order,
        }, parent)
    end
    local function glyph(parent, order, img)
        return new("ImageLabel", {
            Size = UDim2.fromOffset(9, 9), BackgroundTransparency = 1, Image = img,
            ImageColor3 = T.Muted, LayoutOrder = order,
        }, parent)
    end

    local brand = capsule(1)
    piece(brand, 1, "</>", T.Muted)

    local info = capsule(2)
    local logoDot = acc(new("Frame", {
        Size = UDim2.fromOffset(12, 12), BorderSizePixel = 0, LayoutOrder = 1, ZIndex = 5,
    }, info))
    corner(logoDot, 6)
    txt(logoDot, "R", {
        Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, TextSize = 7, TextColor3 = T.Bg,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    piece(info, 2, lp.Name, T.Text, true)
    sep(info, 3)
    glyph(info, 4, ICONS.Player)
    local hudPlayers = piece(info, 5, "0", T.Text, true)
    sep(info, 6)
    glyph(info, 7, ICONS.Stats)
    local hudFps = piece(info, 8, "0", T.Text, true)
    sep(info, 9)
    glyph(info, 10, ICONS.Signal)
    local hudPing = piece(info, 11, "0ms", T.Text, true)
    sep(info, 12)
    glyph(info, 13, ICONS.Clock)
    local hudTime = piece(info, 14, "00:00", T.Text, true)

    local alertBox = capsule(3)
    alertBox.Visible = false
    local alertText = piece(alertBox, 1, "", Color3.fromRGB(244, 92, 96), true)

    -----------------------------------------------------------------
    -- aim overlay (under the hub): fov ring, aim ring, current target dot
    -----------------------------------------------------------------
    local fovCircle = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, Size = UDim2.fromOffset(300, 300), ZIndex = 0,
    }, gui)
    corner(fovCircle, 999)
    local fovStroke = stroke(fovCircle, Color3.fromRGB(255, 255, 255), 1, 0.35)
    local markNow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.2, BorderSizePixel = 0,
        Visible = false, ZIndex = 0,
    }, gui)
    corner(markNow, 3)
    local markAim = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, ZIndex = 0,
    }, gui)
    corner(markAim, 8)
    acc(stroke(markAim, T.Accent, 2, 0), "Color")

    local function hudFrame()
        fpsN = fpsN + 1
        local now = os.clock()
        if now - fpsT >= 0.5 then
            fpsV = math.floor(fpsN / (now - fpsT) + 0.5)
            fpsN, fpsT = 0, now
        end
        local cam = curCam()
        if not cam then
            fovCircle.Visible, markAim.Visible, markNow.Visible = false, false, false
            return
        end
        local role = ST.role or "Innocent"
        local silent = Settings.SilentAim
        if role == "Murderer" then silent = Settings.ThrowSilent end
        local showFov = (Settings.ShowFOV and silent and effectiveMode(role) == "Cursor") and true or false
        fovCircle.Visible = showFov
        if showFov then
            local o = aimOrigin2D()
            fovCircle.Position = UDim2.fromOffset(o.X, o.Y)
            fovCircle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
            fovStroke.Color = A.pos and Color3.fromRGB(96, 210, 128) or Color3.fromRGB(255, 255, 255)
        end
        if Settings.ShowAim and silent and A.pos and A.plr then
            local p1 = cam:WorldToViewportPoint(A.pos)
            markAim.Visible = p1.Z > 0
            markAim.Position = UDim2.fromOffset(p1.X, p1.Y)
            local hrp = A.plr.Character and A.plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p0 = cam:WorldToViewportPoint(hrp.Position)
                markNow.Visible = p0.Z > 0
                markNow.Position = UDim2.fromOffset(p0.X, p0.Y)
            else
                markNow.Visible = false
            end
        else
            markAim.Visible = false
            markNow.Visible = false
        end
    end
    connect(RunService.RenderStepped, function()
        local ok, err = pcall(hudFrame)
        if not ok then ST.lastErr = tostring(err) end
    end)

    -----------------------------------------------------------------
    -- window shell: sidebar (left), content (header, body, grip)
    -----------------------------------------------------------------
    local hub = new("Frame", {
        Name = "Hub", Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.Bg, BorderSizePixel = 0,
        ClipsDescendants = true, Active = true,
    }, gui)
    corner(hub, 6)
    stroke(hub, T.Line, 1, 0)

    local side = new("Frame", {
        Name = "Side", Size = UDim2.new(0, SB, 1, 0), BackgroundColor3 = T.Side, BorderSizePixel = 0,
    }, hub)
    new("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = T.Line,
        BorderSizePixel = 0,
    }, side)
    local logo = new("TextButton", {
        Name = "Logo", Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 4), BackgroundTransparency = 1,
        Text = "R", Font = Enum.Font.GothamBlack, TextSize = 30, TextColor3 = T.Text, AutoButtonColor = false,
    }, side)
    new("Frame", {
        Size = UDim2.new(1, -20, 0, 1), Position = UDim2.fromOffset(10, 46), BackgroundColor3 = T.Line,
        BorderSizePixel = 0,
    }, side)
    local navBox = new("ScrollingFrame", {
        Name = "Nav", Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 1, -100),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, side)
    vlist(navBox, 1)
    pad(navBox, 0, 6, 0, 6)

    local prof = new("Frame", {
        Name = "Profile", Position = UDim2.new(0, 6, 1, -46), Size = UDim2.new(1, -12, 0, 40),
        BackgroundColor3 = T.Card, BorderSizePixel = 0,
    }, side)
    corner(prof, 4)
    stroke(prof, T.Line, 1, 0)
    local avatar = new("ImageLabel", {
        Position = UDim2.fromOffset(6, 8), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = T.Row,
        BorderSizePixel = 0, Image = "",
    }, prof)
    corner(avatar, 12)
    txt(prof, lp.Name, {
        Position = UDim2.fromOffset(36, 8), Size = UDim2.new(1, -42, 0, 10), Font = Enum.Font.GothamMedium,
        TextSize = 8, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    txt(prof, "@" .. lp.Name, {
        Position = UDim2.fromOffset(36, 20), Size = UDim2.new(1, -42, 0, 9), TextSize = 7,
        TextColor3 = T.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and img then avatar.Image = img end
    end)

    local content = new("Frame", {
        Name = "Content", Position = UDim2.fromOffset(SB, 0), Size = UDim2.new(1, -SB, 1, 0),
        BackgroundTransparency = 1,
    }, hub)

    -- wireframe backdrop: normalized nodes, the real positions are set in layout()
    local decor = new("Frame", {
        Name = "Decor", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true,
    }, content)
    local WIRE_NODES = {
        { 0.50, 0.20 }, { 0.62, 0.27 }, { 0.83, 0.09 }, { 0.55, 0.42 }, { 0.77, 0.48 },
        { 0.65, 0.69 }, { 0.97, 0.69 }, { 0.38, 0.62 }, { 0.15, 0.85 }, { 0.12, 0.05 },
    }
    local WIRE_EDGES = {
        { 1, 2 }, { 2, 3 }, { 3, 5 }, { 2, 5 }, { 1, 4 }, { 2, 4 }, { 4, 5 }, { 5, 6 }, { 5, 7 },
        { 6, 7 }, { 4, 6 }, { 4, 8 }, { 8, 9 }, { 9, 6 }, { 10, 1 }, { 3, 7 }, { 10, 8 },
    }
    for _, e in ipairs(WIRE_EDGES) do
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(1, 1), BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(205, 205, 215), BackgroundTransparency = 0.9,
        }, decor)
        decorLines[#decorLines + 1] = { f = f, a = WIRE_NODES[e[1]], b = WIRE_NODES[e[2]] }
    end

    local header = new("Frame", {
        Name = "Header", Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Active = true,
    }, content)
    local pageTitle = txt(header, "game", {
        Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -30, 1, 0), Font = Enum.Font.GothamMedium,
        TextSize = 9, TextColor3 = T.Text,
    })
    new("Frame", {
        Name = "HeaderLine", Size = UDim2.new(1, -8, 0, 1), Position = UDim2.fromOffset(4, 20),
        BackgroundColor3 = T.Line, BorderSizePixel = 0,
    }, content)
    local searchBtn = new("ImageButton", {
        Size = UDim2.fromOffset(11, 11), Position = UDim2.new(1, -18, 0.5, -5), BackgroundTransparency = 1,
        Image = ICONS.Search, ImageColor3 = T.Muted, AutoButtonColor = false,
    }, header)
    local searchBox = new("TextBox", {
        Position = UDim2.fromOffset(6, 3), Size = UDim2.new(1, -30, 0, 14), BackgroundColor3 = T.Input,
        BorderSizePixel = 0, Text = "", PlaceholderText = "search", PlaceholderColor3 = T.Dim,
        TextColor3 = T.Text, Font = Enum.Font.Gotham, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, Visible = false,
    }, header)
    corner(searchBox, 3)
    pad(searchBox, 0, 5, 0, 5)
    searchBtn.MouseButton1Click:Connect(function()
        searchBox.Visible = not searchBox.Visible
        pageTitle.Visible = not searchBox.Visible
        if searchBox.Visible then
            searchBox:CaptureFocus()
        else
            searchBox.Text = ""
        end
    end)

    local body = new("Frame", {
        Name = "Body", Position = UDim2.fromOffset(4, 24), Size = UDim2.new(1, -8, 1, -28),
        BackgroundTransparency = 1,
    }, content)

    -- corner grip: drag to resize the window
    local grip = new("TextButton", {
        Name = "Grip", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -1, 1, -1),
        Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 10,
    }, hub)
    new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(8, 10), Size = UDim2.fromOffset(8, 1),
        Rotation = -45, BackgroundColor3 = T.Dim, BorderSizePixel = 0, ZIndex = 10,
    }, grip)
    new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(4, 1),
        Rotation = -45, BackgroundColor3 = T.Dim, BorderSizePixel = 0, ZIndex = 10,
    }, grip)
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            gripDrag = { start = input.Position, w = W, h = H }
        end
    end)
    local function beginHubDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hubDrag = { start = input.Position, base = Vector2.new(hub.Position.X.Offset, hub.Position.Y.Offset) }
        end
    end
    header.InputBegan:Connect(beginHubDrag)
    logo.InputBegan:Connect(beginHubDrag)

    -----------------------------------------------------------------
    -- wireframe nodes (dots of the backdrop graph)
    -----------------------------------------------------------------
    for _, nd in ipairs(WIRE_NODES) do
        local dot = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Color3.fromRGB(220, 220, 230), BackgroundTransparency = 0.7, BorderSizePixel = 0,
        }, decor)
        corner(dot, 2)
        decorDots[#decorDots + 1] = { f = dot, n = nd }
    end

    -----------------------------------------------------------------
    -- row builders: check rows with a "..." drawer, sliders, dropdowns, buttons, info text
    -----------------------------------------------------------------
    local function rowFrame(parent, h)
        return new("Frame", {
            Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, LayoutOrder = nextOrder(parent),
        }, parent)
    end
    local function registerRow(frame, name, desc, drawer)
        ROWS[#ROWS + 1] = {
            frame = frame, drawer = drawer, page = curPage,
            text = string.lower(name .. " " .. (desc or "")),
        }
    end
    local function lockedBy(opt)
        return opt.risk == "high" and Settings.SafeMode
    end

    local function toggleRow(parent, key, name, desc, opt)
        opt = opt or {}
        local row = rowFrame(parent, desc and 22 or 15)
        local box = new("Frame", {
            Size = UDim2.fromOffset(11, 11), Position = UDim2.fromOffset(1, 2),
            BackgroundColor3 = T.Input, BorderSizePixel = 0,
        }, row)
        corner(box, 2)
        local boxStroke = stroke(box, T.Dim, 1, 0)
        local mark = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }, box)
        new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(4, 6), Size = UDim2.fromOffset(2, 4),
            Rotation = 45, BackgroundColor3 = T.Check, BorderSizePixel = 0,
        }, mark)
        new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(7, 5), Size = UDim2.fromOffset(2, 7),
            Rotation = -45, BackgroundColor3 = T.Check, BorderSizePixel = 0,
        }, mark)
        local label = txt(row, name, {
            Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -40, 0, 14),
            TextSize = 8, TextColor3 = T.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        if desc then
            txt(row, desc, {
                Position = UDim2.fromOffset(18, 12), Size = UDim2.new(1, -40, 0, 9),
                TextSize = 7, TextColor3 = T.Hint, TextTruncate = Enum.TextTruncate.AtEnd,
            })
        end
        local hit = new("TextButton", {
            Size = UDim2.new(1, opt.sub and -18 or 0, 1, 0), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, ZIndex = 2,
        }, row)
        local drawer = nil
        if opt.sub then
            local dots = new("TextButton", {
                Size = UDim2.fromOffset(16, 14), Position = UDim2.new(1, -16, 0, 0),
                BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 3,
            }, row)
            for i = 0, 2 do
                new("Frame", {
                    Size = UDim2.fromOffset(2, 2), Position = UDim2.fromOffset(2 + i * 4, 6),
                    BackgroundColor3 = T.Muted, BorderSizePixel = 0, ZIndex = 4,
                }, dots)
            end
            drawer = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Input,
                BorderSizePixel = 0, Visible = false, LayoutOrder = nextOrder(parent),
            }, parent)
            corner(drawer, 3)
            pad(drawer, 4, 6, 5, 12)
            vlist(drawer, 4)
            dots.MouseButton1Click:Connect(function()
                drawer.Visible = not drawer.Visible
            end)
        end
        local function set(v)
            local on = v and true or false
            box.BackgroundColor3 = on and T.Accent or T.Input
            boxStroke.Color = on and T.Accent or T.Dim
            mark.Visible = on
            label.TextColor3 = on and T.Text or T.Muted
        end
        set(Settings[key])
        REG[key] = { set = set }
        hit.MouseButton1Click:Connect(function()
            local nv = not Settings[key]
            if nv and lockedBy(opt) then
                notify("locked by safe mode (settings)", "warn")
                return
            end
            setSetting(key, nv)
            set(nv)
            if opt.onChange then pcall(opt.onChange, nv) end
        end)
        registerRow(row, name, desc, drawer)
        if opt.sub then opt.sub(drawer) end
        return row
    end

    -- a slider; key = Settings key, or getter / setter for anything else (the window size)
    local function sliderRow(parent, key, name, min, max, step, fmt, onChange, getter, setter)
        local row = rowFrame(parent, 26)
        txt(row, name, {
            Position = UDim2.fromOffset(1, 0), Size = UDim2.new(0.62, 0, 0, 11),
            TextSize = 8, TextColor3 = T.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local val = txt(row, "", {
            Position = UDim2.new(0.62, 0, 0, 0), Size = UDim2.new(0.38, -1, 0, 11),
            Font = Enum.Font.GothamMedium, TextSize = 8, TextColor3 = T.Text,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        local track = new("TextButton", {
            Position = UDim2.fromOffset(1, 11), Size = UDim2.new(1, -2, 0, 15),
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        }, row)
        local bar = new("Frame", {
            Position = UDim2.new(0, 0, 0.5, -1), Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = T.Dim, BorderSizePixel = 0,
        }, track)
        local fill = acc(new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, bar))
        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(7, 7),
            BackgroundColor3 = T.Text, BorderSizePixel = 0, ZIndex = 2,
        }, bar)
        corner(knob, 4)
        local function get()
            if getter then return getter() end
            return Settings[key]
        end
        local function show(v)
            v = v or min
            local rel = math.clamp((v - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            val.Text = string.format(fmt, v)
        end
        local function commit(v)
            if setter then
                setter(v)
            else
                setSetting(key, v)
            end
            show(v)
            if onChange then pcall(onChange, v) end
        end
        local function fromX(x)
            local w = bar.AbsoluteSize.X
            if w <= 0 then return end
            local rel = math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1)
            local v = min + rel * (max - min)
            v = math.floor(v / step + 0.5) * step
            commit(math.clamp(tonumber(string.format("%.4f", v)) or min, min, max))
        end
        show(get())
        if key and not getter then REG[key] = { set = show } end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliderDrag = fromX
                local sc = scrollerOf(track)
                if sc then sc.ScrollingEnabled = false; scrollLock = sc end
                fromX(input.Position.X)
            end
        end)
        registerRow(row, name, nil, nil)
        return row, show
    end

    -- a dropdown: the value box opens the list right under the row
    local function dropRow(parent, key, name, options, onPick)
        local row = rowFrame(parent, 16)
        txt(row, name, {
            Position = UDim2.fromOffset(1, 0), Size = UDim2.new(1, -104, 1, 0),
            TextSize = 8, TextColor3 = T.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local box = new("TextButton", {
            Position = UDim2.new(1, -100, 0, 0), Size = UDim2.fromOffset(100, 16), BackgroundColor3 = T.Input,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        }, row)
        corner(box, 3)
        local val = txt(box, "", {
            Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.GothamMedium,
            TextSize = 8, TextColor3 = T.Text, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        txt(box, "v", {
            Position = UDim2.new(1, -14, 0, 0), Size = UDim2.fromOffset(10, 16), Font = Enum.Font.GothamBold,
            TextSize = 8, TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Center,
        })
        local list = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Input,
            BorderSizePixel = 0, Visible = false, LayoutOrder = nextOrder(parent),
        }, parent)
        corner(list, 3)
        pad(list, 2, 2, 2, 2)
        vlist(list, 1)
        local function show(v)
            val.Text = tostring(v)
        end
        local function build(opts)
            for _, ch in ipairs(list:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            for i, o in ipairs(opts) do
                local it = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = tostring(o),
                    Font = Enum.Font.Gotham, TextSize = 8, TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = i,
                }, list)
                pad(it, 0, 0, 0, 6)
                it.MouseButton1Click:Connect(function()
                    list.Visible = false
                    show(o)
                    if key then setSetting(key, o) end
                    if onPick then pcall(onPick, o) end
                end)
            end
        end
        build(options)
        show(key and Settings[key] or (options[1] or ""))
        box.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
        end)
        if key then REG[key] = { set = show } end
        registerRow(row, name, nil, nil)
        return row, { build = build, show = show }
    end

    local function btnRow(parent, name, fn)
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = T.Row, BorderSizePixel = 0, Text = name,
            Font = Enum.Font.GothamMedium, TextSize = 8, TextColor3 = T.Text, AutoButtonColor = false,
            LayoutOrder = nextOrder(parent),
        }, parent)
        corner(b, 3)
        b.MouseButton1Click:Connect(function() pcall(fn) end)
        registerRow(b, name, nil, nil)
        return b
    end

    -- an action row: a box with ">" and a name, runs fn on click (no state)
    local function actRow(parent, name, fn)
        local row = rowFrame(parent, 15)
        local box = new("Frame", {
            Size = UDim2.fromOffset(11, 11), Position = UDim2.fromOffset(1, 2),
            BackgroundColor3 = T.Input, BorderSizePixel = 0,
        }, row)
        corner(box, 2)
        stroke(box, T.Dim, 1, 0)
        txt(box, ">", {
            Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 8,
            TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Center,
        })
        txt(row, name, {
            Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -20, 1, 0),
            TextSize = 8, TextColor3 = T.Muted, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local hit = new("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 2,
        }, row)
        hit.MouseButton1Click:Connect(function() pcall(fn) end)
        registerRow(row, name, nil, nil)
        return row
    end

    local function infoRow(parent, text)
        return new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = text or "", TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 8,
            TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = nextOrder(parent),
        }, parent)
    end

    local function paletteRow(parent, onPick)
        local row = rowFrame(parent, 14)
        hlist(row, 6)
        for i, c in ipairs(PALETTE) do
            local s = new("TextButton", {
                Size = UDim2.fromOffset(12, 12), BackgroundColor3 = c, BorderSizePixel = 0, Text = "",
                AutoButtonColor = false, LayoutOrder = i,
            }, row)
            corner(s, 6)
            s.MouseButton1Click:Connect(function() pcall(onPick, c) end)
        end
        return row
    end

    -- a card: header (click = fold), an underline, the rows go into the returned body
    local function card(pg, title, column)
        local c = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Card,
            BackgroundTransparency = 0.1, BorderSizePixel = 0, LayoutOrder = #pg.cards + 1,
        }, pg.colL)
        corner(c, 4)
        pad(c, 6, 6, 7, 6)
        vlist(c, 3)
        local head = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
            LayoutOrder = 0,
        }, c)
        txt(head, title, {
            Position = UDim2.fromOffset(1, 0), Size = UDim2.new(1, -14, 1, 0),
            Font = Enum.Font.GothamMedium, TextSize = 9, TextColor3 = T.Text,
        })
        local caret = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(8, 8),
            BackgroundTransparency = 1, Image = ICONS.Chevron, ImageColor3 = T.Muted,
        }, head)
        local under = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Under, BackgroundTransparency = 0.4,
            BorderSizePixel = 0, LayoutOrder = 1,
        }, c)
        local inner = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            LayoutOrder = 2,
        }, c)
        vlist(inner, 2)
        pad(inner, 4, 0, 0, 0)
        local rec = { frame = c, body = inner, side = column or "left", open = true }
        head.MouseButton1Click:Connect(function()
            rec.open = not rec.open
            inner.Visible = rec.open
            under.Visible = rec.open
            tween(caret, 0.15, { Rotation = rec.open and 0 or 180 })
        end)
        pg.cards[#pg.cards + 1] = rec
        return inner
    end

    local function makePage(name)
        local pg = { name = name, cards = {} }
        pg.frame = new("Frame", {
            Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false,
        }, body)
        pg.colL = new("ScrollingFrame", {
            Size = UDim2.new(0.5, -3, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Dim, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
        }, pg.frame)
        pg.colR = new("ScrollingFrame", {
            Size = UDim2.new(0.5, -3, 1, 0), Position = UDim2.new(0.5, 3, 0, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.Dim, CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
        }, pg.frame)
        vlist(pg.colL, 5)
        vlist(pg.colR, 5)
        pad(pg.colL, 0, 4, 6, 0)
        pad(pg.colR, 0, 0, 6, 4)
        PG[name] = pg
        return pg
    end
    for _, n in ipairs({ "game", "esp", "world", "fx", "lock", "perks", "vote", "misc", "stats", "presets" }) do
        makePage(n)
    end

    -----------------------------------------------------------------
    -- sidebar: groups (visuals, player) open into their pages
    -----------------------------------------------------------------
    local function navButton(name, sub, icon, child)
        navN = navN + 1
        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, child and 22 or 32), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, LayoutOrder = navN,
        }, navBox)
        local bar = acc(new("Frame", {
            Size = UDim2.fromOffset(2, child and 12 or 14),
            Position = UDim2.new(0, 0, 0.5, child and -6 or -7),
            BorderSizePixel = 0, Visible = false,
        }, btn))
        local x = child and 22 or 30
        local ic = nil
        if icon and not child then
            ic = new("ImageLabel", {
                Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(10, 10),
                BackgroundTransparency = 1, Image = icon, ImageColor3 = T.Muted,
            }, btn)
        end
        local title = txt(btn, name, {
            Position = UDim2.fromOffset(x, child and 5 or 4), Size = UDim2.new(1, -x - 14, 0, 12),
            Font = Enum.Font.GothamMedium, TextSize = child and 8 or 9, TextColor3 = T.Muted,
        })
        if sub and not child then
            txt(btn, sub, {
                Position = UDim2.fromOffset(x, 16), Size = UDim2.new(1, -x - 14, 0, 10),
                TextSize = 7, TextColor3 = T.Hint,
            })
        end
        local rec = { btn = btn, bar = bar, ic = ic, title = title, child = child, name = name }
        NAV[#NAV + 1] = rec
        return rec
    end

    function navSetActive(page)
        for _, rec in ipairs(NAV) do
            local on = (rec.page == page) or (rec.kidPages ~= nil and rec.kidPages[page] == true)
            rec.bar.Visible = on
            rec.title.TextColor3 = on and T.Text or T.Muted
            if rec.ic then rec.ic.ImageColor3 = on and T.Text or T.Muted end
        end
    end

    function navRefresh()
        for _, rec in ipairs(NAV) do
            if rec.parentName then
                rec.btn.Visible = GROUP_OPEN[rec.parentName] == true
            end
            if rec.chev then
                tween(rec.chev, 0.15, { Rotation = GROUP_OPEN[rec.name] and 180 or 0 })
            end
        end
    end

    local NAV_DEF = {
        { name = "game", sub = "game funcs", icon = ICONS.Combat, page = "game" },
        { name = "visuals", sub = "player visuals", icon = ICONS.Visuals, kids = {
            { name = "esp", page = "esp" }, { name = "world", page = "world" }, { name = "fx", page = "fx" } } },
        { name = "player", sub = "local perks", icon = ICONS.Player, kids = {
            { name = "lock", page = "lock" }, { name = "local", page = "perks" } } },
        { name = "vote", sub = "map vote", icon = ICONS.Vote, page = "vote" },
        { name = "misc", sub = "feedback", icon = ICONS.Misc, page = "misc" },
        { name = "stats", sub = "live stats", icon = ICONS.Stats, page = "stats" },
        { name = "presets", sub = "settings & config", icon = ICONS.Presets, page = "presets" },
    }
    for _, def in ipairs(NAV_DEF) do
        local rec = navButton(def.name, def.sub, def.icon, false)
        if def.kids then
            rec.kidPages = {}
            rec.chev = new("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, Image = ICONS.Chevron,
                ImageColor3 = T.Dim,
            }, rec.btn)
            for _, k in ipairs(def.kids) do
                local kr = navButton(k.name, nil, nil, true)
                kr.page = k.page
                kr.parentName = def.name
                rec.kidPages[k.page] = true
                kr.btn.MouseButton1Click:Connect(function()
                    GROUP_OPEN[def.name] = true
                    navRefresh()
                    showPage(k.page)
                end)
            end
            rec.btn.MouseButton1Click:Connect(function()
                GROUP_OPEN[def.name] = not GROUP_OPEN[def.name]
                navRefresh()
                if GROUP_OPEN[def.name] then showPage(def.kids[1].page) end
            end)
        else
            rec.page = def.page
            rec.btn.MouseButton1Click:Connect(function() showPage(def.page) end)
        end
    end

    function showPage(page)
        curPage = page
        if scrollLock then
            scrollLock.ScrollingEnabled = true
            scrollLock = nil
        end
        for name, pg in pairs(PG) do
            pg.frame.Visible = (name == page)
        end
        navSetActive(page)
        pageTitle.Text = PAGE_TITLE[page] or page
        applySearch()
    end

    -- search: filters the rows of the open page
    function applySearch()
        local q = string.lower(searchBox.Text or "")
        for _, r in ipairs(ROWS) do
            local hit = (r.page == curPage) and (q == "" or string.find(r.text, q, 1, true) ~= nil)
            if r.frame then r.frame.Visible = hit and true or false end
            if r.drawer and not hit then r.drawer.Visible = false end
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

    -----------------------------------------------------------------
    -- game page: sheriff, murder (left) / autos, script aim (right)
    -----------------------------------------------------------------
    local function pageGame()
        curPage = "game"
        local S = card(PG.game, "sheriff", "left")
        toggleRow(S, "SilentAim", "silent", nil, {
            sub = function(d)
                dropRow(d, "TargetMode", "target", OPTS.TargetMode)
                dropRow(d, "AimPart", "aim part", OPTS.AimPart)
                sliderRow(d, "FOV", "fov (cursor mode)", 30, 400, 10, "%.0f px")
                sliderRow(d, "MaxDist", "max distance", 50, 500, 10, "%.0f st")
                sliderRow(d, "AimHeight", "aim height", -3, 3, 0.1, "%+.1f")
                toggleRow(d, "VisibleOnly", "visible targets only")
                toggleRow(d, "AvoidInnocents", "avoid players on the line")
            end,
        })
        toggleRow(S, "Prediction", "prediction", nil, {
            sub = function(d)
                dropRow(d, "AimMode", "mode", OPTS.AimMode)
                sliderRow(d, "PredStrength", "lead multiplier", 0.5, 2, 0.05, "%.2fx")
                sliderRow(d, "Interp", "interp delay", 0, 200, 5, "%.0f ms")
                sliderRow(d, "HitRadius", "hit radius", 0.8, 3, 0.1, "%.1f st")
                sliderRow(d, "Overshoot", "overshoot", 0, 8, 0.5, "%.1f st")
                toggleRow(d, "Calibrate", "self-calibrate (experimental, max 30 ms)")
                toggleRow(d, "AutoTune", "auto tune (ping)", "tests lead scales on the murderer, keeps the one that hits")
                btnRow(d, "reset learning", function() resetLearning() end)
            end,
        })
        actRow(S, "force shoot", function() task.spawn(forceShoot) end)
        toggleRow(S, "AutoShoot", "auto shoot", "fires when the models agree", {
            risk = "mid",
            sub = function(d)
                dropRow(d, "FireMode", "fire when", OPTS.FireMode)
                toggleRow(d, "SmartShot", "wait for a calm moment")
                sliderRow(d, "ShotCooldown", "cooldown", 0.8, 6, 0.1, "%.1f s")
                sliderRow(d, "Reaction", "reaction time", 0, 500, 10, "%.0f ms")
                sliderRow(d, "MaxShootDist", "max range", 30, 400, 10, "%.0f st")
            end,
        })
        toggleRow(S, "WallBypass", "wall bypass", "moves the shot origin next to the target", {
            risk = "high",
            sub = function(d)
                toggleRow(d, "SmartOrigin", "shoot along its path")
                sliderRow(d, "OriginMax", "max origin offset", 10, 150, 5, "%.0f st")
            end,
        })

        local M = card(PG.game, "murder", "left")
        toggleRow(M, "KillAura", "kill aura", "stabs everyone inside the distance as the murderer", {
            sub = function(d)
                sliderRow(d, "KillDistance", "distance", 5, 60, 1, "%.0f st")
            end,
        })
        toggleRow(M, "KillAll", "kill all", "stabs every player, no distance", { risk = "high" })
        toggleRow(M, "ThrowSilent", "throw silent", nil, {
            sub = function(d)
                toggleRow(d, "KnifeFlight", "knife flight time")
                sliderRow(d, "KnifeSpeed", "knife speed", 30, 400, 5, "%.0f st/s")
            end,
        })
        toggleRow(M, "PredMurder", "prediction")

        local AU = card(PG.game, "autos", "right")
        toggleRow(AU, "AutoGun", "grab gun", "remote touch from where you stand", {
            risk = "mid",
            sub = function(d)
                dropRow(d, "GrabMode", "mode", OPTS.GrabMode)
            end,
        })
        actRow(AU, "grab now", function() task.spawn(grabGun, true) end)

        local SA = card(PG.game, "script aim", "right")
        toggleRow(SA, "ScriptAim", "script aim", "mm2 script engine: leads the murderer, checks walls, shoots", {
            sub = function(d)
                toggleRow(d, "ScriptPredict", "prediction (lead from velocity + ping)")
                toggleRow(d, "ScriptWall", "wall checker (shoot only with a clear line)")
                toggleRow(d, "ScriptAuto", "auto shoot")
                toggleRow(d, "ScriptForce", "force (origin spoof, ignores the wall checker)", nil, { risk = "high" })
                sliderRow(d, "ScriptStandOff", "origin stand-off", 0, 40, 1, "%.0f st")
                sliderRow(d, "ScriptReact", "reaction", 0, 500, 10, "%.0f ms")
                sliderRow(d, "ScriptRange", "max range", 30, 400, 10, "%.0f st")
                sliderRow(d, "ScriptDelay", "shot delay", 0, 600, 10, "%.0f ms")
                infoRow(d, "fires only after: reaction, prediction warm-up, both outside the lobby, in range, a clear line. force skips the wall checker.")
            end,
        })

        local F = card(PG.game, "fling", "left")
        actRow(F, "fling", function() FLING.action(nil) end)
        actRow(F, "fling sheriff", function() FLING.action("Sheriff") end)
        actRow(F, "fling murder", function() FLING.action("Murderer") end)
        sliderRow(F, "FlingTime", "fling time", 0.2, 2, 0.1, "%.1f s")
        infoRow(F, "fling = locked player, else the nearest. the spin runs for the fling time, then you go back to your spot and stay there. needs safe mode off.")
    end

    -----------------------------------------------------------------
    -- visuals pages: esp (+ legend) and world (overlay, aura)
    -----------------------------------------------------------------
    local function pageEsp()
        curPage = "esp"
        local e = card(PG.esp, "esp", "left")
        toggleRow(e, "ESP", "role esp")
        toggleRow(e, "ESPInfo", "distance + health")
        toggleRow(e, "ESPGun", "dropped gun marker")
        toggleRow(e, "ESPHideLobby", "hide dead + lobby players", "dead ones and anyone back at the spawn lose their marker")
        toggleRow(e, "ESPPulse", "pulse murderer + gun")
        local lg = card(PG.esp, "legend", "right")
        local items = {
            { "murderer", COLORS.Murderer }, { "sheriff", COLORS.Sheriff },
            { "innocent", COLORS.Innocent }, { "dropped gun", COLORS.GunDrop },
        }
        for _, it in ipairs(items) do
            local r = rowFrame(lg, 13)
            new("Frame", {
                Size = UDim2.fromOffset(6, 6), Position = UDim2.new(0, 4, 0.5, -3),
                BackgroundColor3 = it[2], BorderSizePixel = 0,
            }, r)
            txt(r, it[1], {
                Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -16, 1, 0),
                TextSize = 8, TextColor3 = T.Muted,
            })
        end
    end

    -----------------------------------------------------------------
    -- visuals / fx: player esp, local, world, crosshair and tracer (ported from the uploaded script)
    -----------------------------------------------------------------
    local function pageFx()
        curPage = "fx"
        local pe = card(PG.fx, "player esp", "left")
        toggleRow(pe, "FxEsp", "player esp", "master switch of this card", {
            sub = function(d)
                toggleRow(d, "FxBox", "box", nil, {
                    sub = function(s)
                        toggleRow(s, "FxBoxFill", "fill")
                        dropRow(s, "FxBoxColor", "color", FX_COLORS)
                        dropRow(s, "FxBoxStyle", "style", OPTS.FxBoxStyle)
                    end,
                })
                toggleRow(d, "FxSkel", "skeleton", nil, {
                    sub = function(s) dropRow(s, "FxSkelColor", "color", FX_COLORS) end,
                })
                toggleRow(d, "FxArrows", "off-screen arrows", "chevron on the screen edge, pointing at the player", {
                    sub = function(s)
                        sliderRow(s, "FxArrowSize", "size", 10, 60, 1, "%.0f px")
                        sliderRow(s, "FxArrowRange", "range", 40, 520, 10, "%.0f st")
                        dropRow(s, "FxArrowInno", "innocent", FX_COLORS)
                        dropRow(s, "FxArrowMurder", "murderer", FX_COLORS)
                        dropRow(s, "FxArrowSheriff", "sheriff", FX_COLORS)
                    end,
                })
                toggleRow(d, "FxName", "name", nil, {
                    sub = function(s) dropRow(s, "FxNameColor", "color", FX_COLORS) end,
                })
                toggleRow(d, "FxAvatar", "avatar", "headshot next to the name")
                toggleRow(d, "FxDist", "distance", "metres to the player")
                toggleRow(d, "FxGlow", "glow", "highlight over the whole body", {
                    sub = function(s)
                        dropRow(s, "FxGlowInno", "innocent", FX_COLORS)
                        dropRow(s, "FxGlowMurder", "murderer", FX_COLORS)
                        dropRow(s, "FxGlowSheriff", "sheriff", FX_COLORS)
                    end,
                })
                toggleRow(d, "FxMat", "material chams", "body material swap, colours from the glow", {
                    sub = function(s) dropRow(s, "FxMatStyle", "style", OPTS.FxMatStyle) end,
                })
                toggleRow(d, "FxFlags", "role flags", "MURDERER / SHERIFF label over the head", {
                    sub = function(s) toggleRow(s, "FxFlagsGrad", "gradient") end,
                })
            end,
        })

        local lc = card(PG.fx, "local", "right")
        toggleRow(lc, "FxChina", "china hat", "beam ring on your head", {
            sub = function(s) dropRow(s, "FxChinaColor", "color", FX_COLORS) end,
        })
        toggleRow(lc, "FxBacktrack", "backtrack ghost", "copy of you at the ping-delayed spot", {
            sub = function(s) dropRow(s, "FxBacktrackColor", "color", FX_COLORS) end,
        })
        toggleRow(lc, "FxSelfChams", "self chams", nil, {
            sub = function(s)
                dropRow(s, "FxSelfStyle", "style", OPTS.FxSelfStyle)
                dropRow(s, "FxSelfColor", "color", FX_COLORS)
            end,
        })
        toggleRow(lc, "FxToolChams", "tool chams", nil, {
            sub = function(s)
                dropRow(s, "FxToolStyle", "style", OPTS.FxToolStyle)
                dropRow(s, "FxToolColor", "color", FX_COLORS)
            end,
        })
        toggleRow(lc, "FxLanding", "landing circle", "ring on the floor when you land", {
            sub = function(s)
                dropRow(s, "FxLandColor", "color", FX_COLORS)
                sliderRow(s, "FxLandOpacity", "opacity", 0, 1, 0.05, "%.2f")
                sliderRow(s, "FxLandDur", "duration", 0.1, 3, 0.05, "%.2f s")
            end,
        })

        local wc = card(PG.fx, "world", "left")
        toggleRow(wc, "FxFullbright", "fullbright", "brighter light, shadows off")
        toggleRow(wc, "FxAmbient", "ambient", nil, {
            sub = function(s) dropRow(s, "FxAmbientColor", "color", FX_COLORS) end,
        })
        toggleRow(wc, "FxFog", "custom fog", nil, {
            sub = function(s)
                sliderRow(s, "FxFogStart", "start", 0, 1000, 5, "%.0f")
                sliderRow(s, "FxFogEnd", "end", 0, 1000, 5, "%.0f")
                dropRow(s, "FxFogColor", "color", FX_COLORS)
            end,
        })
        toggleRow(wc, "FxTime", "time changer", nil, {
            sub = function(s) sliderRow(s, "FxClock", "time", 0, 24, 0.5, "%.1f h") end,
        })
        toggleRow(wc, "FxExposure", "exposure", nil, {
            sub = function(s) sliderRow(s, "FxExposureValue", "range", -5, 5, 0.05, "%.2f") end,
        })
        toggleRow(wc, "FxSky", "skybox", nil, {
            sub = function(s) dropRow(s, "FxSkyName", "preset", OPTS.FxSkyName) end,
        })
        toggleRow(wc, "FxShader", "shaders", "lighting + colour correction + bloom + dof presets", {
            sub = function(s) dropRow(s, "FxShaderType", "preset", OPTS.FxShaderType) end,
        })
        toggleRow(wc, "FxParticles", "world effects", "snow / sakura volume around the camera", {
            sub = function(s)
                dropRow(s, "FxParticleType", "preset", OPTS.FxParticleType)
                dropRow(s, "FxParticleColor", "color", FX_COLORS)
                sliderRow(s, "FxParticleRate", "range", 20, 900, 10, "%.0f")
            end,
        })

        local cc = card(PG.fx, "crosshair & tracer", "right")
        toggleRow(cc, "FxCross", "crosshair", "drawn while a gun is in your hand", {
            sub = function(s)
                toggleRow(s, "FxCrossHide", "hide original", "hides the game's crosshair while ours is up")
                sliderRow(s, "FxCrossGap", "gap", 0, 20, 1, "%.0f px")
                sliderRow(s, "FxCrossLen", "line", 2, 30, 1, "%.0f px")
                sliderRow(s, "FxCrossThick", "thickness", 1, 5, 1, "%.0f px")
                sliderRow(s, "FxCrossSpin", "rotation", 0, 10, 0.5, "%.1f")
                dropRow(s, "FxCrossColor", "line", FX_COLORS)
                dropRow(s, "FxCrossOutline", "outline", FX_COLORS)
            end,
        })
        toggleRow(cc, "FxTracer", "bullet tracer", "your shots, drawn to where they land", {
            sub = function(s)
                dropRow(s, "FxTracerColor", "color", FX_COLORS)
                sliderRow(s, "FxTracerDur", "duration", 0.2, 3, 0.1, "%.1f s")
            end,
        })
    end

    local function pageWorld()
        curPage = "world"
        local ov = card(PG.world, "overlay", "left")
        toggleRow(ov, "ShowFOV", "fov circle")
        toggleRow(ov, "ShowAim", "aim marker", "white dot = target now, ring = where the shot goes")
        toggleRow(ov, "HUD", "top info bar", "watermark: brand, user, players, fps, ping, time")
        toggleRow(ov, "MurdererAlert", "murderer alert", nil, {
            sub = function(d)
                sliderRow(d, "AlertDist", "alert distance", 10, 120, 5, "%.0f st")
            end,
        })
        local au = card(PG.world, "aura", "right")
        toggleRow(au, "WorldAura", "aura", "particle aura on your own character", {
            sub = function(d)
                dropRow(d, "AuraType", "type", auras.types)
                dropRow(d, "AuraColor", "color", auras.colors)
            end,
        })
    end

    -----------------------------------------------------------------
    -- player / target lock: every player of the server, one tap to lock
    -----------------------------------------------------------------
    local function makeLockRow(plr)
        local f = new("Frame", {
            Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = T.Row, BorderSizePixel = 0,
            LayoutOrder = nextOrder(lockBox),
        }, lockBox)
        corner(f, 3)
        txt(f, plr.DisplayName, {
            Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -112, 1, 0), TextSize = 8,
            TextColor3 = T.Text, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local role = txt(f, "", {
            Position = UDim2.new(1, -106, 0, 0), Size = UDim2.fromOffset(44, 20),
            Font = Enum.Font.GothamMedium, TextSize = 7, TextXAlignment = Enum.TextXAlignment.Center,
        })
        local dist = txt(f, "", {
            Position = UDim2.new(1, -62, 0, 0), Size = UDim2.fromOffset(24, 20), TextSize = 7,
            TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Right,
        })
        local lockBtn = new("TextButton", {
            Size = UDim2.fromOffset(32, 13), Position = UDim2.new(1, -36, 0.5, -6), BackgroundColor3 = T.Input,
            BorderSizePixel = 0, Text = "lock", Font = Enum.Font.GothamMedium, TextSize = 7,
            TextColor3 = T.Muted, AutoButtonColor = false,
        }, f)
        corner(lockBtn, 3)
        lockBtn.MouseButton1Click:Connect(function()
            if ST.forced == plr then
                ST.forced = nil
                notify("target lock released", "info")
            else
                ST.forced = plr
                notify("locked: " .. plr.DisplayName, "good")
            end
        end)
        return { f = f, role = role, dist = dist, lock = lockBtn }
    end

    local function pageLock()
        curPage = "lock"
        local b = card(PG.lock, "target lock", "left")
        infoRow(b, "tap lock to force the target (works with silent aim and auto shoot). tap again to release.")
        lockBox = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            LayoutOrder = nextOrder(b),
        }, b)
        vlist(lockBox, 2)
    end

    function refreshPlayers()
        if not lockBox then return end
        local seen = {}
        local me = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                seen[plr] = true
                local r = lockRows[plr]
                if not r then
                    r = makeLockRow(plr)
                    lockRows[plr] = r
                end
                local hrp = isAlive(plr)
                local role = getRole(plr)
                r.role.Text = hrp and string.lower(role) or "dead"
                r.role.TextColor3 = hrp and (COLORS[role] or T.Muted) or T.Hint
                r.dist.Text = (hrp and me) and (math.floor((hrp.Position - me.Position).Magnitude + 0.5) .. "m") or "-"
                local locked = ST.forced == plr
                r.lock.Text = locked and "locked" or "lock"
                r.lock.BackgroundColor3 = locked and T.Accent or T.Input
                r.lock.TextColor3 = locked and T.Bg or T.Muted
            end
        end
        for plr, r in pairs(lockRows) do
            if not seen[plr] then
                pcall(function() r.f:Destroy() end)
                lockRows[plr] = nil
            end
        end
    end

    -----------------------------------------------------------------
    -- player / local: protection and auto tune
    -----------------------------------------------------------------
    local function pagePerks()
        curPage = "perks"
        local p = card(PG.perks, "protection", "left")
        toggleRow(p, "SafeMode", "safe mode", "locks teleport / origin-spoof features, adds rate limits")
        infoRow(p, "turn it off to unlock the high-risk switches (wall bypass, kill all, map vote, force).")
        local a = card(PG.perks, "auto tune", "right")
        toggleRow(a, "AutoProfile", "auto profile", "re-tunes aim for your role when it changes", {
            sub = function(d)
                btnRow(d, "apply gun profile", function() applyProfile("gun") end)
                btnRow(d, "apply knife profile", function() applyProfile("knife") end)
            end,
        })
    end

    -----------------------------------------------------------------
    -- vote page: map vote + four priority picks (the first open pick wins)
    -----------------------------------------------------------------
    local function mvOptions()
        local out = { "none" }
        for _, n in ipairs(mvList("MapVoteSeen")) do out[#out + 1] = n end
        return out
    end
    local function mvWriteAll()
        local picks = {}
        for i = 1, 4 do
            local v = mvValue[i]
            if type(v) == "string" and v ~= "none" and v ~= "" then picks[#picks + 1] = v end
        end
        mvSave("MapVotePicks", picks)
    end
    local function pageVote()
        curPage = "vote"
        local mv = card(PG.vote, "map vote", "left")
        toggleRow(mv, "MapVote", "map vote", "walks you into the vote zone of your first open pick and holds you there", {
            risk = "high",
            sub = function(d)
                toggleRow(d, "MapVoteDie", "die first (reset to lobby, then walk in)")
                btnRow(d, "scan maps", function()
                    local n = mvScan()
                    notify(n > 0 and ("map vote: " .. n .. " new map(s)") or "map vote: no new maps on the pads",
                        n > 0 and "good" or "warn")
                    for i = 1, 4 do mvSlot[i].build(mvOptions()) end
                end)
                btnRow(d, "clear picks", function()
                    for i = 1, 4 do
                        mvValue[i] = "none"
                        mvSlot[i].show("none")
                    end
                    mvWriteAll()
                end)
                local picks = mvList("MapVotePicks")
                for i = 1, 4 do
                    mvValue[i] = picks[i] or "none"
                    local _, slot = dropRow(d, nil, "pick " .. i, mvOptions(), function(v)
                        mvValue[i] = v
                        mvWriteAll()
                    end)
                    mvSlot[i] = slot
                    slot.show(mvValue[i])
                end
                infoRow(d, "priority = pick order, the first open pick wins. scan maps while standing in the lobby.")
            end,
        })
    end

    -----------------------------------------------------------------
    -- misc: feedback switches, unload
    -----------------------------------------------------------------
    local function pageMisc()
        curPage = "misc"
        local f = card(PG.misc, "feedback", "left")
        toggleRow(f, "ShotToast", "shot feedback", "toast for every redirected shot")
        toggleRow(f, "Debug", "debug log", "print shot redirects + unknown shot remotes (learn mode)")
        local u = card(PG.misc, "unload", "right")
        btnRow(u, "unload", function() unload() end)
    end

    -----------------------------------------------------------------
    -- live stats: profile, connection, target, learning, system
    -----------------------------------------------------------------
    local function pageStats()
        curPage = "stats"
        ACC_TXT.profile = infoRow(card(PG.stats, "profile", "left"), "")
        ACC_TXT.conn = infoRow(card(PG.stats, "connection", "left"), "")
        ACC_TXT.target = infoRow(card(PG.stats, "target", "right"), "")
        local le = card(PG.stats, "learning", "right")
        ACC_TXT.learn = infoRow(le, "")
        btnRow(le, "reset learning", function() resetLearning() end)
        ACC_TXT.sys = infoRow(card(PG.stats, "system", "left"), "")
    end

    function refreshAccounts()
        local h = PING.hist
        local hist = {}
        for i = math.max(1, #h - 11), #h do hist[#hist + 1] = tostring(math.floor(h[i] * 1000 + 0.5)) end
        ACC_TXT.profile.Text = string.format("user  %s (%s)\nrole  %s\nprofile  %s\nsafe mode  %s",
            lp.Name, lp.DisplayName, string.lower(getRole(lp)), ST.profile, Settings.SafeMode and "on" or "off")
        ACC_TXT.conn.Text = string.format("ping %d ms\njitter +-%d ms (%s)\nlead %d ms\nlast: %s",
            math.floor(PING.rtt * 1000 + 0.5), math.floor(PING.jitter * 1000 + 0.5),
            PING.stable and "stable" or "unstable", math.floor(A.lead * 1000 + 0.5), table.concat(hist, " "))
        if A.name then
            local st = A.lagging and "lagging" or (A.stable and "steady" or "strafing")
            ACC_TXT.target.Text = string.format("%s%s\n%s | %s\ncover %d%% | model %s", A.name,
                ST.forced and " (locked)" or "", st, A.visible and "visible" or "behind wall",
                math.floor(A.cover * 100), tostring(A.model))
        else
            ACC_TXT.target.Text = "no target"
        end
        local ranked = {}
        for n, w in pairs(A.weights) do ranked[#ranked + 1] = { n, w } end
        table.sort(ranked, function(a, b) return a[2] > b[2] end)
        local lines = {
            string.format("calibration %+d ms", math.floor(lag.bias * 1000 + 0.5)),
            string.format("hits %d / %d", calib.hits, calib.shots),
            tuneLine(),
        }
        for i = 1, math.min(4, #ranked) do
            lines[#lines + 1] = string.format("%s  %d%%", ranked[i][1], math.floor(ranked[i][2] * 100 + 0.5))
        end
        ACC_TXT.learn.Text = table.concat(lines, "\n")
        local function yn(v) return v and "yes" or "no" end
        ACC_TXT.sys.Text = string.format("hook  %s\nrole data  %s\ncheckcaller %s  touch %s\nprompt %s  files %s\nerrors  %d",
            hookStatus, dataOk and "server" or "tools", yn(CAP.caller), yn(CAP.touch), yn(CAP.prompt), yn(CAP.fs), ST.errCount)
    end

    -----------------------------------------------------------------
    -- accent, refresh, watermark
    -----------------------------------------------------------------
    function setAccent(c)
        T.Accent = c
        for _, e in ipairs(ACC) do
            pcall(function() e[1][e[2]] = T.Accent end)
        end
        UI.accent = {
            math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5),
        }
        markDirty()
        refreshAll()
    end

    -- pushes Settings into every row (after a profile change, a reset or an import); no callbacks
    refreshAll = function()
        for key, r in pairs(REG) do
            pcall(r.set, Settings[key])
        end
    end

    function refreshHud()
        hud.Visible = Settings.HUD and true or false
        hudPlayers.Text = tostring(#Players:GetPlayers())
        hudFps.Text = tostring(fpsV)
        hudPing.Text = ms(PING.rtt) .. "ms"
        hudTime.Text = os.date("%H:%M")
        local role = getRole(lp)
        local alertOn = false
        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if Settings.MurdererAlert and role ~= "Murderer" and myHrp then
            local nearest
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and getRole(plr) == "Murderer" then
                    local h = isAlive(plr)
                    if h then
                        local d = (h.Position - myHrp.Position).Magnitude
                        if not nearest or d < nearest then nearest = d end
                    end
                end
            end
            if nearest and nearest <= Settings.AlertDist then
                alertOn = true
                alertText.Text = "murderer " .. math.floor(nearest + 0.5) .. "m"
                if os.clock() - alertAt > 8 then
                    alertAt = os.clock()
                    notify("murderer close: " .. math.floor(nearest + 0.5) .. "m", "bad")
                end
            end
        end
        alertBox.Visible = alertOn and (Settings.HUD and true or false)
    end

    -----------------------------------------------------------------
    -- presets: appearance, window size, keybinds, config
    -----------------------------------------------------------------
    local function pagePresets()
        curPage = "presets"
        local ap = card(PG.presets, "appearance", "left")
        infoRow(ap, "accent colour (saved with the config)")
        paletteRow(ap, function(c) setAccent(c) end)
        btnRow(ap, "reset accent", function() setAccent(PALETTE[1]) end)

        local sz = card(PG.presets, "window size", "right")
        local _, showW = sliderRow(sz, nil, "width", 260, 900, 10, "%.0f px", nil,
            function() return W end, function(v) setSize(v, H); saveSize() end)
        local _, showH = sliderRow(sz, nil, "height", 220, 800, 10, "%.0f px", nil,
            function() return H end, function(v) setSize(W, v); saveSize() end)
        SIZE_UI.w = showW
        SIZE_UI.h = showH
        btnRow(sz, "reset size", function()
            local dw, dh = defaultSize()
            UI.w, UI.h = nil, nil
            setSize(dw, dh)
            markDirty()
        end)
        infoRow(sz, "the corner grip does the same by drag. sizes are saved with the config.")

        local hk = card(PG.presets, "hub key", "left")
        if isTouch then
            infoRow(hk, "on a phone the round button on the left edge opens and closes the hub")
        else
            local kbBtn
            kbBtn = btnRow(hk, "hub key: " .. UI.binds.menu .. "  (press to change)", function()
                kbBtn.Text = "press a key (esc cancels)"
                keyListen = function(name)
                    if name == "Escape" then
                        kbBtn.Text = "hub key: " .. UI.binds.menu
                        return
                    end
                    UI.binds.menu = name
                    markDirty()
                    kbBtn.Text = "hub key: " .. name
                    notify("hub key: " .. name, "good")
                end
            end)
            local sbBtn
            sbBtn = btnRow(hk, "force shoot key: " .. (UI.binds.shoot ~= "" and UI.binds.shoot or "none"), function()
                sbBtn.Text = "press a key (esc clears)"
                keyListen = function(name)
                    UI.binds.shoot = (name == "Escape") and "" or name
                    markDirty()
                    sbBtn.Text = "force shoot key: " .. (UI.binds.shoot ~= "" and UI.binds.shoot or "none")
                end
            end)
        end

        local cfg = card(PG.presets, "config", "right")
        infoRow(cfg, "autosaved to " .. CFG_FILE .. (CAP.fs and "" or " (no file functions: settings reset on re-execute)"))
        btnRow(cfg, "save now", function()
            local ok = saveConfig()
            notify(ok and "config saved" or "save failed", ok and "good" or "bad")
        end)
        btnRow(cfg, "copy config to clipboard", function()
            local clip = setclipboard or toclipboard
            if not clip then
                notify("executor has no clipboard function", "warn")
                return
            end
            local ok = pcall(function() clip(HttpService:JSONEncode(buildConfigData())) end)
            notify(ok and "config copied" or "copy failed", ok and "good" or "bad")
        end)
        local paste = new("TextBox", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = T.Input, BorderSizePixel = 0, Text = "",
            PlaceholderText = "paste a config string here", PlaceholderColor3 = T.Dim, TextColor3 = T.Text,
            Font = Enum.Font.Gotham, TextSize = 8, ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(cfg),
        }, cfg)
        corner(paste, 3)
        pad(paste, 0, 6, 0, 6)
        btnRow(cfg, "import config", function()
            local ok, data = pcall(function() return HttpService:JSONDecode(paste.Text) end)
            if not ok or type(data) ~= "table" or type(data.settings) ~= "table" then
                notify("invalid config string", "bad")
                return
            end
            applyConfigData(data, true)
            markDirty()
            if type(UI.accent) == "table" then
                setAccent(Color3.fromRGB(UI.accent[1], UI.accent[2], UI.accent[3]))
            end
            if UI.w then W = UI.w end
            if UI.h then H = UI.h end
            layout()
            refreshAll()
            paste.Text = ""
            notify("config imported (safe mode stays on)", "good")
        end)
        btnRow(cfg, "reset all settings", function()
            for k, v in pairs(DEFAULTS) do Settings[k] = v end
            resetLearning()
            markDirty()
            refreshAll()
            notify("settings reset", "warn")
        end)
    end

    -----------------------------------------------------------------
    -- layout: the window size (W, H) decides the sidebar, the columns and the backdrop
    -----------------------------------------------------------------
    local function applyLimits()
        local vp = viewport()
        W = math.clamp(math.floor(W), 260, math.max(260, vp.X - 8))
        H = math.clamp(math.floor(H), 220, math.max(220, vp.Y - 8))
    end

    function layout()
        applyLimits()
        local vp = viewport()
        local X, Y
        if not placed then
            X = math.floor((vp.X - W) / 2)
            Y = math.floor((vp.Y - H) / 2)
            placed = true
        else
            X, Y = hub.Position.X.Offset, hub.Position.Y.Offset
        end
        X = math.clamp(X, 0, math.max(0, vp.X - W))
        Y = math.clamp(Y, 40, math.max(40, vp.Y - H))
        hub.Size = UDim2.fromOffset(W, H)
        hub.Position = UDim2.fromOffset(X, Y)
        mainX, mainY = X, Y
        SB = sidebarWidth(W)
        side.Size = UDim2.new(0, SB, 1, 0)
        content.Position = UDim2.fromOffset(SB, 0)
        content.Size = UDim2.new(1, -SB, 1, 0)

        -- wireframe backdrop follows the content size
        local cw, ch = W - SB, H
        for _, e in ipairs(decorLines) do
            local ax, ay = e.a[1] * cw, e.a[2] * ch
            local bx, by = e.b[1] * cw, e.b[2] * ch
            local dx, dy = bx - ax, by - ay
            e.f.Position = UDim2.fromOffset((ax + bx) / 2, (ay + by) / 2)
            e.f.Size = UDim2.fromOffset(math.max(1, math.sqrt(dx * dx + dy * dy)), 1)
            e.f.Rotation = math.deg(math.atan2(dy, dx))
        end
        for _, d in ipairs(decorDots) do
            d.f.Position = UDim2.fromOffset(d.n[1] * cw, d.n[2] * ch)
        end

        -- two columns when the body is wide enough, one column otherwise
        local twoCols = (cw - 8) >= 230
        for _, pg in pairs(PG) do
            if twoCols then
                pg.colL.Size = UDim2.new(0.5, -3, 1, 0)
                pg.colR.Size = UDim2.new(0.5, -3, 1, 0)
                pg.colR.Position = UDim2.new(0.5, 3, 0, 0)
                pg.colR.Visible = true
            else
                pg.colL.Size = UDim2.new(1, 0, 1, 0)
                pg.colR.Visible = false
            end
            for _, cd in ipairs(pg.cards) do
                local want = (twoCols and cd.side == "right") and pg.colR or pg.colL
                if cd.frame.Parent ~= want then cd.frame.Parent = want end
            end
        end
        if SIZE_UI.w then pcall(SIZE_UI.w, W) end
        if SIZE_UI.h then pcall(SIZE_UI.h, H) end
    end

    function setSize(w, h)
        W, H = w, h
        layout()
    end
    function saveSize()
        UI.w = W
        UI.h = H
        markDirty()
    end

    function setShown(v)
        shown = v and true or false
        if shown then
            hub.Visible = true
            hub.Position = UDim2.fromOffset(mainX, mainY + 16)
            tween(hub, 0.25, { Position = UDim2.fromOffset(mainX, mainY) })
        else
            tween(hub, 0.25, { Position = UDim2.fromOffset(mainX, mainY + 16) })
            task.delay(0.27, function()
                if not shown then hub.Visible = false end
            end)
        end
    end

    -- phones: a round button on the left edge opens and closes the hub (drag it, tap it)
    local launcher = new("TextButton", {
        Name = "Launcher", AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0, 10, 0.5, 0), BackgroundColor3 = T.Bg, Text = "R",
        Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = T.Text, AutoButtonColor = false,
        Visible = isTouch, ZIndex = 40,
    }, gui)
    corner(launcher, 20)
    stroke(launcher, T.Line, 1, 0)
    launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local base = launcher.AbsolutePosition
            launchDrag = { start = input.Position, base = base, moved = 0 }
            launcher.AnchorPoint = Vector2.new(0, 0)
            launcher.Position = UDim2.fromOffset(base.X, base.Y)
        end
    end)

    -----------------------------------------------------------------
    -- inputs: drag hub / grip / sliders / launcher, hub key, force shoot key, viewport changes
    -----------------------------------------------------------------
    connect(UIS.InputChanged, function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
        if hubDrag then
            local d = input.Position - hubDrag.start
            hub.Position = UDim2.fromOffset(hubDrag.base.X + d.X, hubDrag.base.Y + d.Y)
        end
        if gripDrag then
            local d = input.Position - gripDrag.start
            setSize(gripDrag.w + d.X, gripDrag.h + d.Y)
        end
        if sliderDrag then sliderDrag(input.Position.X) end
        if launchDrag then
            local d = input.Position - launchDrag.start
            launchDrag.moved = math.max(launchDrag.moved, math.abs(d.X) + math.abs(d.Y))
            launcher.Position = UDim2.fromOffset(launchDrag.base.X + d.X, launchDrag.base.Y + d.Y)
        end
    end)

    connect(UIS.InputEnded, function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        if hubDrag then
            hubDrag = nil
            mainX, mainY = hub.Position.X.Offset, hub.Position.Y.Offset
        end
        if gripDrag then
            gripDrag = nil
            saveSize()
        end
        sliderDrag = nil
        if scrollLock then
            scrollLock.ScrollingEnabled = true
            scrollLock = nil
        end
        if launchDrag then
            local tap = launchDrag.moved < 8
            launchDrag = nil
            if tap then setShown(not shown) end
        end
    end)

    connect(UIS.InputBegan, function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local name = input.KeyCode.Name
        if keyListen then
            local f = keyListen
            keyListen = nil
            pcall(f, name)
            return
        end
        if processed then return end
        if name == UI.binds.menu then
            setShown(not shown)
        elseif UI.binds.shoot ~= "" and name == UI.binds.shoot then
            task.spawn(forceShoot)
        end
    end)

    local cam0 = workspace.CurrentCamera
    if cam0 then
        connect(cam0:GetPropertyChangedSignal("ViewportSize"), function() pcall(layout) end)
    end

    -- status loop: watermark every 0.25 s, live stats every 0.5 s, the player list every second
    task.spawn(function()
        local n = 0
        while running do
            task.wait(0.25)
            n = n + 1
            pcall(refreshHud)
            if n % 2 == 0 then pcall(refreshAccounts) end
            if n % 4 == 0 then pcall(refreshPlayers) end
        end
    end)

    -----------------------------------------------------------------
    -- build the pages, lay out, start on the game page
    -----------------------------------------------------------------
    GROUP_OPEN.visuals = true
    GROUP_OPEN.player = true
    local function buildPage(name, fn)
        local ok, err = pcall(fn)
        if not ok then warn("[MM2 Suite] page " .. name .. " failed: " .. tostring(err)) end
    end
    buildPage("game", pageGame)
    buildPage("esp", pageEsp)
    buildPage("world", pageWorld)
    buildPage("fx", pageFx)
    buildPage("lock", pageLock)
    buildPage("perks", pagePerks)
    buildPage("vote", pageVote)
    buildPage("misc", pageMisc)
    buildPage("stats", pageStats)
    buildPage("presets", pagePresets)
    layout()
    navRefresh()
    showPage("game")
    refreshAll()
    refreshHud()
    notify("ShitaroMM2 " .. VERSION .. " loaded", "good")
end

local okHub, errHub = pcall(buildHub)
if not okHub then warn("[MM2 Suite] gui failed: " .. tostring(errHub)) end
---------------------------------------------------------------------
-- unload
---------------------------------------------------------------------
unload = function()
    if not running then return end
    running = false
    pcall(mvStop)
    pcall(function() auras.stop() end)
    pcall(function() local f = ENV.SILENT_UNLOAD if f then f() end end)
    pcall(saveConfig)
    ENV.MM2Dispatch = nil -- the persistent hook turns into a plain pass-through
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, L in pairs(life) do
        if L.conn then pcall(function() L.conn:Disconnect() end) end
    end
    pcall(espClearAll)
    pcall(function() FX.stop() end)
    pcall(function() if ESP.root then ESP.root:Destroy() end end)
    pcall(function() if ST.gui then ST.gui:Destroy() end end)
    ST.toast = nil
    if ENV.MM2SuiteUnload == unload then ENV.MM2SuiteUnload = nil end
end
ENV.MM2SuiteUnload = unload

print(string.format("[MM2 Suite %s] loaded | hook: %s | role data: %s | files: %s",
    VERSION, hookStatus, dataOk and "server" or "tools", CAP.fs and "yes" or "no"))
