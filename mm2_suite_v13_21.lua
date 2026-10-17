--[[
    MM2 Suite v12  (Roblox Luau, executor script, Murder Mystery 2)

    Needs:    getnamecallmethod + (hookmetamethod OR getrawmetatable/setreadonly)   -> silent aim
    Optional: checkcaller, firetouchinterest / fireproximityprompt, writefile / readfile / isfile, gethui

    v13.21: silent aim = the silent_aim module only. the PULSE silent aim is cut out (its own engine, its __namecall hook,
            the V2 / V3 / V4 shot rewrite, flick, fake position, resolver, wallbang, point blank, auto gun, gun esp, and the
            "silent aim (pulse)" page). script aim (sheriff engine) and the rest are unchanged
    v13.20: aim = the silent_aim module (target cloud, shot line, wall check, hook, auto shoot, role profiles),
            pasted as it is. the old silent aim (cover line, auto tune, force shoot, wall bypass, throw silent)
            is gone. pulse aim, script aim and the rest are unchanged
    v13.19: pulse aim: the silent part of the PULSE hub as its own page (V2, V3, V4 shot rewrite, fov, auto shoot, flick, fake position, auto gun). camera lerp aimbot is not included. turning it on turns the old silent aim off
    v13.18: skins: knives and guns with a MeshPart no longer render oversized (mesh sized from its MeshSize), showcase fire is left off the held weapon; holster: gun skin on the back and knife skin on the belt while not in hand (toggle)
    v13.17: skin changer: own page with every knife and gun skin from the shitaro list, worn on the tool you hold (client side)
    v13.16: nova Aura: orbs, trails and sparks around your character (Cosmic, Halo, Gyro, Flames), its own card under aura
    v13.15: drone: after a flight the camera gets back the view it had before it (it kept the drone's zoom and sat on
            your head), the target cam follows the target while you fly (it was a frozen box), and the body keeps the
            transparency it had when the flight ends (first person and occlusion no longer break)
    v13.14: radar: a round 2d map of the living players around you, on visuals / radar. drag the circle to move it,
            the corner grip resizes it, pin locks both. role dots, rotate with the view or north up, edge markers,
            rings, sweep. the circle stays up with the hub closed
    v13.13: local movement on the local page: walk speed, jump power, fly, noclip, infinite jump, bhop, ctrl + click
            teleport, unstuck. fly, noclip and click teleport are safe-mode locked. the drone and the fling take the body
            while they run, the movement waits; every value goes back when its switch goes off, on respawn and on unload
    v13.12: aura: with the vote duper a life is ~0.4 s, and the aura came 0.1-0.2 s after each spawn and was applied
            again 0.5 s after it, on a body that was already dead. now it attaches the frame the root and head exist.
            colour is rgb (three sliders + quick picks, default ice) like the reference. older configs keep their colour
    v13.11: silent aim rebuilt on the reference's method. the shot starts at the real muzzle (GunRaycastAttachment)
            and aims at a body part it can see: the cover line when it is clear, else the first clear part. no
            overshoot on guns; lead = round trip + jitter / 2 + the age of the position (interp is an extra, 0 by
            default). auto tune keeps five lead scales (0.7x to 1.3x) and tries another one only after a miss. wall bypass = the reference's force: the shot
            starts behind the target on its path with a stand-off, used only when the direct line is walled. force
            shoot and auto shoot take the same origin as the real shot
    v13.10: vote duper tab (was vote): the uploaded script's duper on our helpers. three map cards with the game's
            pictures, names and live votes, a click picks the map (saved by name), a stand time slider. it stands on
            the picked pad while the window is open, dies there and comes back until the window closes. map vote and
            the duper switch each other off, safe mode locks both, unload stops the duper
    v13.9: fling = the rock hub's sequence: the root goes around the target with a huge velocity, the launch check,
           then the character is pivoted back. the fling time slider is gone, the window is 2 s
    v13.8: drone tab from the rock hub: shahed-136 / fpv, kill (knife) or fling impact, target cam with a replay
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

local VERSION = "v13.21"
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

    -- aim keys (SilentAim, TargetMode, AimPart, FOV, PredStrength, AutoShoot, ...) belong to the silent aim
    -- module: they are merged into this table right after the module (see SilentAim below)

    AutoGun = true, GrabMode = "Remote only",

    MapVote = false, MapVoteDie = false, MapVotePicks = "", MapVoteSeen = "",
    VoteDuper = false, VoteDuperMap = "", VoteDuperDelay = 0.38,
    ScriptAim = false, ScriptPredict = true, ScriptWall = true, ScriptAuto = true, ScriptForce = false,
    ScriptStandOff = 15, ScriptDelay = 0, ScriptReact = 180, ScriptRange = 160,
    KillAura = false, KillAll = false, KillDistance = 30,
    WorldAura = false, AuraType = "angel", AuraR = 133, AuraG = 220, AuraB = 255,
    NovaAura = false, NovaAuraStyle = "Cosmic", NovaAuraColor = "rainbow", NovaAuraSize = 3.5, NovaAuraSpeed = 1,
    SkinChanger = false, SkinKnife = "", SkinGun = "", SkinHolster = true,

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
    DroneKind = "Shahed", DroneImpact = "Fling",
    LmSpeedOn = false, LmSpeed = 50, LmJumpOn = false, LmJump = 90,
    LmFly = false, LmFlySpeed = 60, LmNoclip = false, LmInfJump = false,
    LmBhop = false, LmBhopCap = 60, LmClickTp = false,
    RadarOn = false, RadarPin = false, RadarRotate = true, RadarEdge = true, RadarRings = true, RadarSweep = true,
    RadarRange = 120, RadarSize = 200, RadarAlpha = 0.85, RadarX = 24, RadarY = 220,
}

local FX_COLORS = { "white", "black", "red", "orange", "yellow", "green", "cyan", "blue", "violet", "pink", "gray", "amber", "sky", "ice", "silver", "dim" }
local OPTS = {
    GrabMode = { "Remote only", "Remote + hop" },
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
    DroneKind = { "Shahed", "FPV" }, DroneImpact = { "Kill", "Fling" },
    NovaAuraStyle = { "Cosmic", "Halo", "Gyro", "Flames" },
    NovaAuraColor = { "rainbow", "white", "black", "red", "orange", "yellow", "green", "cyan", "blue", "violet", "pink", "gray", "amber", "sky", "ice", "silver", "dim" },
}

local RANGES = {
    AlertDist = { 10, 120 },
    ScriptStandOff = { 0, 40 }, ScriptDelay = { 0, 600 }, ScriptReact = { 0, 500 }, ScriptRange = { 30, 400 },
    KillDistance = { 5, 60 }, VoteDuperDelay = { 0.1, 1.5 },
    FxArrowSize = { 10, 60 }, FxArrowRange = { 40, 520 }, FxLandOpacity = { 0, 1 }, FxLandDur = { 0.1, 3 },
    FxClock = { 0, 24 }, FxExposureValue = { -5, 5 }, FxFogStart = { 0, 1000 }, FxFogEnd = { 0, 1000 },
    FxParticleRate = { 20, 900 }, FxCrossGap = { 0, 20 }, FxCrossLen = { 2, 30 }, FxCrossThick = { 1, 5 },
    FxCrossSpin = { 0, 10 }, FxTracerDur = { 0.2, 3 },
    AuraR = { 0, 255 }, AuraG = { 0, 255 }, AuraB = { 0, 255 },
    NovaAuraSize = { 2, 7 }, NovaAuraSpeed = { 0.3, 3 },
    LmSpeed = { 16, 300 }, LmJump = { 50, 400 }, LmFlySpeed = { 10, 250 }, LmBhopCap = { 16, 200 },
    RadarRange = { 40, 400 }, RadarSize = { 120, 420 }, RadarAlpha = { 0.2, 1 }, RadarX = { 0, 6000 }, RadarY = { 0, 4000 },
}

-- the six aura colour names of v12.9 - v13.11: a config from those versions maps onto the rgb settings
local AURA_NAMED = {
    ice = { 133, 220, 255 }, pink = { 255, 140, 210 }, gold = { 255, 210, 110 },
    mint = { 130, 255, 200 }, violet = { 190, 150, 255 }, white = { 255, 255, 255 },
}

local ACCENTS = {
    { "violet", Color3.fromRGB(139, 92, 246) },
    { "blue", Color3.fromRGB(59, 130, 246) },
    { "mint", Color3.fromRGB(16, 185, 129) },
    { "rose", Color3.fromRGB(244, 63, 94) },
    { "amber", Color3.fromRGB(245, 158, 11) },
}

-- silent aim: the module from silent_aim.lua, pasted as it is (target cloud, shot line, wall check, the
-- __namecall hook, auto shoot, role profiles). it keeps its own settings table; the suite takes that table as
-- Settings, so the GUI and the config read the same values. the hook is installed on load
--[[
    silent_aim.lua  -  silent aim for Murder Mystery 2 (Roblox Luau, executor), cut out of mm2_suite_v13_1

    inside: the aim engine (target cloud, shot line, wall check), the __namecall hook, auto shoot,
    role profiles and a small API at the bottom. the shared parts it reads (role detection, lobby,
    raycast params, ping, connections) are copied from the suite, so the file runs on its own.
    it draws nothing: the fov circle, the aim markers and the GUI cards are not in here.

    needs:     getnamecallmethod + (hookmetamethod OR getrawmetatable / setreadonly)
    optional:  checkcaller (own calls are not redirected), newcclosure, setnamecallmethod

    use:
        the whole file is one statement, local SilentAim = (function() ... end)(). paste it into your script.
        SilentAim.Settings.SilentAim = true               -- read every frame, change them any time
        SilentAim.Settings.TargetMode = "Auto"            -- Auto / Murderer / Cursor / Nearest
        SilentAim.Settings is a plain table: save / load it with your own config code
        SilentAim.state.toast = function(text, kind) end  -- optional notifications, kind = good / warn / bad / info
        SilentAim.lock(somePlayer)                        -- force a target, SilentAim.lock(nil) releases it
        print(SilentAim.hookStatus())                     -- "hookmetamethod", "rawmetatable" or "none"
        SilentAim.unload()                                -- disconnects everything, the hook turns into a pass-through

    do not run it next to the suite's silent aim: both would set ENV.MM2Dispatch.
]]
local SilentAim = (function()

local ENV = (getgenv and getgenv()) or _G

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer

local running = true
local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    connections[#connections + 1] = c
    return c
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
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

-----------------------------------------------------------------------
-- settings: the aim keys of the suite (same names, same defaults)
-----------------------------------------------------------------------
local DEFAULTS = {
    SafeMode = true,        -- locks teleport / origin-spoof features, adds rate limits (auto shoot cooldown >= 1.8 s)
    AutoProfile = true,     -- re-tunes aim for your role every time it changes (profiles below)
    Debug = false,
    ShotToast = true,       -- small toast per redirected shot

    ESPHideLobby = true,    -- role detection: lobby and dead players do not count as in the round
    ShowFOV = true, ShowAim = true,   -- switches for your own GUI, the module draws nothing

    SilentAim = true, TargetMode = "Auto", AimPart = "Auto", AimHeight = 0,
    FOV = 150, MaxDist = 250, VisibleOnly = false, AvoidInnocents = true,

    PredStrength = 1, Interp = 90, HitRadius = 1.1, Overshoot = 2.5,

    WallCheck = "Strict",   -- Strict: only perfectly clear lines are redirected. Normal: grazing / disputed lines too. Off.
    KnifeSpeed = 110,

    AutoShoot = false,      -- fires by itself, only when the confidence is high (sheriff only, only at the murderer)
    AutoConf = 75, AutoRange = 160, AutoCooldown = 2.0, AutoEquip = true,
}

local OPTS = {
    TargetMode = { "Auto", "Murderer", "Cursor", "Nearest" },
    AimPart = { "Auto", "Chest", "Head", "Body" },
    WallCheck = { "Strict", "Normal", "Off" },
}

local RANGES = {
    AimHeight = { -3, 3 }, FOV = { 30, 400 }, MaxDist = { 50, 500 },
    PredStrength = { 0.5, 2 }, Interp = { 0, 200 }, HitRadius = { 0.8, 3 }, Overshoot = { 0, 8 },
    KnifeSpeed = { 30, 400 }, AutoConf = { 50, 95 }, AutoRange = { 30, 400 }, AutoCooldown = { 1, 6 },
}

local Settings = {}
for k, v in pairs(DEFAULTS) do Settings[k] = v end

-- module state. ST.toast = function(text, kind) receives the notifications
local ST = {
    forced = nil,        -- player locked as the target (SilentAim.lock)
    role = "Innocent",   -- local role, refreshed by the aim update
    profile = "none",    -- last applied profile
    shape = {}, lastShotT = 0, ownRemote = nil, ownUntil = 0,
    toast = nil,
    dirtyAt = nil,       -- set by profile changes and resets
    errCount = 0, lastErr = nil,
}

local function markDirty() ST.dirtyAt = os.clock() end

local function notify(text, kind)
    if ST.toast then pcall(ST.toast, text, kind) end
end

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
-- same filter, but parts that cannot collide count too: a hit here that RP does not see is a "disputed" line
local RP2 = RaycastParams.new()
RP2.FilterType = Enum.RaycastFilterType.Exclude
RP2.RespectCanCollide = false
local charDirty, charAt = true, 0

local function markChars() charDirty = true end
local function getRP()
    if charDirty or os.clock() - charAt > 2 then
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then list[#list + 1] = plr.Character end
        end
        RP.FilterDescendantsInstances = list
        RP2.FilterDescendantsInstances = list
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
    model = "-", weights = {}, T = 0.2, lead = 0.2, t = 0, guard = "-", pass = false, conf = 0,
}
local FR = nil        -- last frame context (used to re-solve at the exact moment of the shot)
local statesByPlr = setmetatable({}, { __mode = "k" })

local function clearAim()
    A.pos, A.plr, A.name, A.mean = nil, nil, nil, nil
    A.blocked, A.cover, A.visible, A.lagging, A.stable = false, 0, false, false, true
    A.model, A.weights, A.guard, A.pass, A.conf = "-", {}, "-", false, 0
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
-- Aim engine (v13)
--   what the target does : Kalman filters + model ensemble + its own rhythm (turn events replayed from its
--                          history) + jump hazard
--   what the server sees : a cloud of positions around "now + ping + interp", spread by the time uncertainty
--   the shot line        : the densest spot of that cloud - bearing and elevation are solved separately, so
--                          movement along the line (which cannot make a hitscan miss) is free
--   wall check           : the chosen line is verified with a fan of rays and for players standing on it;
--                          if it is not clear a nearby clear line is searched, otherwise the shot is left alone
---------------------------------------------------------------------
local PRED = { "window", "inst", "input", "avg", "blend", "damped", "accel", "flip", "stop", "kfs", "kfa", "seq", "boot" }
local PRIOR = { inst = 1, window = 1.5, kfs = 1.6, kfa = 1.4, blend = 2, input = 3, accel = 3, damped = 3,
    avg = 3, flip = 3, stop = 6, seq = 2.2, boot = 2.4 }

local stats = { hits = 0, shots = 0, redirected = 0, passed = 0, auto = 0 }
local shotLog = {}
local FRlast = nil

local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
local function angDiff(a, b)
    local d = a - b
    while d > math.pi do d = d - 2 * math.pi end
    while d < -math.pi do d = d + 2 * math.pi end
    return d
end
local function rotY(v, a)
    local c, s = math.cos(a), math.sin(a)
    return Vector3.new(v.X * c - v.Z * s, 0, v.X * s + v.Z * c)
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
        hist = {}, err = err, queue = {}, flips = {}, takeoffs = {}, turns = {},
        lastDir = nil, lastPush = 0, lastMoveT = os.clock(), lastPos = nil,
        prevState = nil, vPrev = Vector3.zero, tPrev = nil, acc = Vector3.zero,
        hrpH = 3, kf = nil, refAng = nil, refT = 0, turnRun = 0,
        stands = {}, moves = {}, trans = {}, moving = nil, slowRun = 0, fastRun = 0,
    }
end

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

-- one horizontal displacement over the horizon T for every simple model
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

---------------------------------------------------------------------
-- The target's own rhythm: heading changes ("turns") are recorded; a repeating pattern is replayed (seq),
-- otherwise every recorded interval is replayed as one possible future (boot)
---------------------------------------------------------------------
local TURN_MIN = 0.87 -- 50 degrees
local TURN_LAG = 0.053 -- a heading read from a 0.07 s window of displayed positions shows a turn about this late
                         -- (counted from the first frame that sees it, so the frame rate does not matter)

-- headings come from the displayed POSITIONS (what is on the screen), not from the velocity property whose
-- timing relative to the picture is unknown
local function trackTurns(S, now)
    local hist = S.hist
    local n = #hist
    if n < 3 then return end
    local cur, old = hist[n], hist[n - 1]
    for i = n - 1, 1, -1 do
        old = hist[i]
        if cur.t - old.t >= 0.07 then break end
    end
    local dt = cur.t - old.t
    if dt < 0.05 then return end
    local d = flat(cur.p - old.p)
    S.curSpeed, S.curVel = d.Magnitude / dt, d / dt
    if S.curSpeed < 4 then
        S.turnRun = 0
        return
    end
    local ang = atan2(d.Z, d.X)
    S.curAng = ang
    if not S.refAng then
        S.refAng, S.refT = ang, now - TURN_LAG
        return
    end
    local da = angDiff(ang, S.refAng)
    if math.abs(da) > TURN_MIN then
        S.turnRun = S.turnRun + 1
        if S.turnRun == 1 then S.turnT0 = now end
        local te = (S.turnT0 or now) - TURN_LAG
        if S.turnRun >= 2 and te - S.refT > 0.1 then
            S.turns[#S.turns + 1] = { t = te, dth = da, I = te - S.refT }
            if #S.turns > 8 then table.remove(S.turns, 1) end
            S.refAng, S.refT, S.turnRun = ang, te, 0
        end
    else
        S.turnRun = 0
        S.refAng = S.refAng + da * 0.08 -- slow drift: a curved run is not a series of turns
    end
end

-- stand / go episodes: a player who stops and starts again. The durations of his stops are remembered; while
-- he stands, they tell how likely he is to run off within the horizon, and where to
local STAND_V, GO_V = 2.0, 5.0
local function trackMotion(S, now)
    local sp = S.curSpeed
    if not sp then return end
    if S.moving == nil then
        S.moving = sp > GO_V
        if S.moving then S.lastMoveV, S.lastMoveAng, S.moveSince = S.curVel, S.curAng, now end
        return
    end
    if S.moving then
        if sp > STAND_V then S.lastMoveV = S.curVel end
        if S.curAng and sp > GO_V then S.lastMoveAng = S.curAng end
        if sp < STAND_V then
            S.slowRun = S.slowRun + 1
            if S.slowRun >= 3 then
                if S.moveSince then
                    local md = (now - 0.08) - S.moveSince
                    if md > 0.05 and md < 15 then
                        S.moves[#S.moves + 1] = { d = md }
                        if #S.moves > 6 then table.remove(S.moves, 1) end
                    end
                end
                S.moving, S.standSince, S.slowRun = false, now - 0.08, 0
                S.trans[#S.trans + 1] = now
            end
        else
            S.slowRun = 0
        end
    else
        if sp > GO_V then
            S.fastRun = S.fastRun + 1
            if S.fastRun >= 2 then
                local dur = (now - 0.07) - (S.standSince or now)
                if S.standSince and dur > 0.05 and dur < 10 then
                    S.stands[#S.stands + 1] = { d = dur, dth = (S.lastMoveAng and S.curAng) and angDiff(S.curAng, S.lastMoveAng) or 0 }
                    if #S.stands > 6 then table.remove(S.stands, 1) end
                end
                S.moving, S.fastRun, S.moveSince = true, 0, now - 0.07
                S.trans[#S.trans + 1] = now
            end
        else
            S.fastRun = 0
        end
    end
    while #S.trans > 10 do table.remove(S.trans, 1) end
end

-- does the target repeat itself? find a period k (1..3 turns) that explains the last turns, then fit the
-- rhythm by least squares over the recent turns (one slope = duration of a cycle, one offset per turn of the
-- cycle): the timing noise of single turns averages out and the next turns are known much better
local function seqEvents(S, now, maxT)
    local turns = S.turns
    local n = #turns
    if n < 3 then return nil end
    local k
    for kk = 1, math.min(3, n - 2) do
        local ok = true
        for j = n, n - 1, -1 do
            local a, b = turns[j], turns[j - kk]
            if not b or math.abs(a.I - b.I) > math.max(0.09, 0.28 * a.I)
                or math.abs(angDiff(a.dth, b.dth)) > 0.7 then
                ok = false
                break
            end
        end
        if ok then
            k = kk
            break
        end
    end
    if not k then return nil end
    local j0 = math.max(1, n - 5)
    local cls = {}
    for j = j0, n do
        local r = j % k
        local c = (j - r) / k
        local cl = cls[r]
        if not cl then
            cl = { st = 0, sc = 0, n = 0, items = {}, ds = 0, dc = 0 }
            cls[r] = cl
        end
        cl.items[#cl.items + 1] = { c = c, t = turns[j].t }
        cl.st, cl.sc, cl.n = cl.st + turns[j].t, cl.sc + c, cl.n + 1
        cl.ds, cl.dc = cl.ds + math.sin(turns[j].dth), cl.dc + math.cos(turns[j].dth)
    end
    local num, den = 0, 0
    for _, cl in pairs(cls) do
        cl.mt, cl.mc = cl.st / cl.n, cl.sc / cl.n
        cl.dth = atan2(cl.ds, cl.dc)
        for _, it in ipairs(cl.items) do
            num = num + (it.c - cl.mc) * (it.t - cl.mt)
            den = den + (it.c - cl.mc) ^ 2
        end
    end
    if den < 1e-6 then return nil end
    local C = num / den
    local lastC = 0
    for j = n - k + 1, n do lastC = lastC + turns[j].I end
    if C < 0.15 or math.abs(C - lastC) > math.max(0.12, 0.3 * lastC) then return nil end
    local ev = {}
    for q = 1, 12 do
        local idx = n + q
        local r = idx % k
        local cl = cls[r]
        if not cl then return nil end
        local c = (idx - r) / k
        local tau = cl.mt + C * (c - cl.mc) - now
        if q == 1 and tau < -0.12 then return nil end -- the beat was missed: the rhythm is over
        if tau < 0.02 then tau = 0.02 end
        if tau > maxT then break end
        ev[#ev + 1] = { tau = tau, dth = cl.dth }
    end
    return ev
end

-- every recorded interval, replayed from "now", is one possible future (only intervals longer than the
-- time already spent on this heading can still be running)
local function bootFutures(S, now, maxT)
    local turns = S.turns
    local n = #turns
    if n < 2 then return nil end
    local e = now - turns[n].t
    local futures, weights = {}, {}
    local m = math.min(n, 6)
    for j = n, n - m + 1, -1 do
        local I1 = turns[j].I
        if I1 > e then
            local tt = I1 - e
            local ev = { { tau = math.max(tt, 0.02), dth = turns[j].dth } }
            local idx = j
            while #ev < 8 and tt < maxT do
                idx = idx + 1
                if idx > n then idx = n - m + 1 + ((idx - n - 1) % m) end
                tt = tt + turns[idx].I
                ev[#ev + 1] = { tau = tt, dth = turns[idx].dth }
            end
            futures[#futures + 1] = ev
            weights[#weights + 1] = 0.82 ^ (n - j)
        end
    end
    if #futures == 0 then return nil end
    return futures, weights
end

-- Regime switch hazard. A target that stands may run off, one that runs may stop. How long his stops / runs last
-- is modelled from his own history (log-normal fitted to the remembered durations), which gives the chance that the
-- current regime ends inside the horizon - also when he has been in it longer than ever before. That chance is an
-- explicit share of the cloud that moves to the other regime. It is NOT left to the ensemble, whose weights come
-- from past errors and therefore never see a switch coming.
-- returns share, list of { weight, events }
local function erf(x)
    local sg = (x < 0) and -1 or 1
    x = math.abs(x)
    local t = 1 / (1 + 0.3275911 * x)
    local y = 1 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592)
        * t * math.exp(-x * x)
    return sg * y
end
local function ncdf(x) return 0.5 * (1 + erf(x / 1.41421356)) end

local function regimeBranch(S, now, hmax)
    if S.moving == nil then return nil end
    local list, since
    if S.moving == false then
        list, since = S.stands, S.standSince
        if not (since and S.lastMoveV) then return nil end
    else
        list, since = S.moves, S.moveSince
        if not since then return nil end
    end
    local n = #list
    if n < 2 then return nil end
    -- log-normal fit of the durations
    local sm, cnt = 0, 0
    for j = 1, n do sm, cnt = sm + math.log(list[j].d), cnt + 1 end
    local mu = sm / cnt
    local sv = 0
    for j = 1, n do sv = sv + (math.log(list[j].d) - mu) ^ 2 end
    local sg = math.max(math.sqrt(sv / cnt), 0.3)
    local e = math.max(now - since, 0.01)
    local F0 = ncdf((math.log(e) - mu) / sg)
    if 1 - F0 < 0.03 then return nil end -- longer than anything this player does: no information
    local F1 = ncdf((math.log(e + hmax) - mu) / sg)
    local p = (F1 - F0) / (1 - F0)
    if p < 0.06 then return nil end
    -- when does it end inside the horizon: three quantiles of the conditional distribution
    local taus = {}
    for qi = 1, 3 do
        local target = F0 + (F1 - F0) * (qi - 0.5) / 3
        local lo, hi = e, e + hmax
        for _ = 1, 18 do
            local mid = 0.5 * (lo + hi)
            if ncdf((math.log(mid) - mu) / sg) < target then lo = mid else hi = mid end
        end
        taus[qi] = math.max(0.5 * (lo + hi) - e, 0.02)
    end
    local futures = {}
    if S.moving == false then
        -- where he runs off to: every remembered direction change is one possibility
        local nd = math.min(n, 6)
        local wsum = 0
        for j = n, n - nd + 1, -1 do wsum = wsum + 0.82 ^ (n - j) end
        for j = n, n - nd + 1, -1 do
            local hw = 0.82 ^ (n - j) / wsum
            local v = rotY(S.lastMoveV, list[j].dth or 0)
            for qi = 1, 3 do
                futures[#futures + 1] = { w = hw / 3, ev = { { tau = taus[qi], setv = v } } }
            end
        end
    else
        for qi = 1, 3 do
            futures[#futures + 1] = { w = 1 / 3, ev = { { tau = taus[qi], setv = Vector3.zero } } }
        end
    end
    return math.min(p, 0.9), futures
end

-- displacement at the horizons hs (ascending) of a run that starts with velocity v0 and turns at the given times
local function pathDisp(v0, evs, hs)
    local out = {}
    local pos, v, t, ei = Vector3.zero, v0, 0, 1
    for k, h in ipairs(hs) do
        while ei <= #evs and evs[ei].tau < h do
            local e = evs[ei]
            pos = pos + v * (e.tau - t)
            t = e.tau
            v = e.setv or rotY(v, e.dth)
            ei = ei + 1
        end
        out[k] = pos + v * (h - t)
    end
    return out
end

-- reads everything the replication gives us about the target this frame
local function updateState(S, hrp, hum, now, params, rtt)
    local cur = hrp.Position
    local lastH = S.hist[#S.hist]
    if lastH and (cur - lastH.p).Magnitude > 12 then
        S.hist, S.queue, S.flips, S.takeoffs, S.turns = {}, {}, {}, {}, {}
        S.stands, S.moves, S.trans, S.moving = {}, {}, {}, nil
        S.lastDir, S.lastPos, S.kf, S.refAng = nil, nil, nil, nil
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

    -- direction reversals (A/D strafe, juke rhythm) and general turns
    local h = flat(vInst)
    trackTurns(S, now)
    trackMotion(S, now)
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

    local airborne = hum.FloorMaterial == Enum.Material.Air
    if airborne then S.airStart = S.airStart or now else S.airStart = nil end

    -- ground below (for landing prediction)
    local groundY
    local hit = workspace:Raycast(cur, Vector3.new(0, -200, 0), params)
    if hit then
        if not airborne then S.hrpH = clamp(cur.Y - hit.Position.Y, 1.5, 6) end
        groundY = hit.Position.Y + S.hrpH
    end

    -- ballistic fit of the height: in a jump only the takeoff moment is unknown, so the vertical speed is fitted
    -- from the last displayed heights (y + g/2 dt^2 is a straight line of dt) instead of trusting a stale property.
    -- The window starts after the last touch of the ground (every bhop bounce is a new parabola)
    local vyFit, yFit
    if airborne then
        local g = workspace.Gravity
        local w0 = math.max(now - 0.3, (S.airStart or now) + 0.03)
        if groundY then
            for i = #S.hist, 1, -1 do
                local hh = S.hist[i]
                if hh.t < w0 then break end
                if hh.p.Y <= groundY + 0.25 then
                    w0 = hh.t + 0.02
                    break
                end
            end
        end
        local sx, sz, sxx, sxz, szz, cnt = 0, 0, 0, 0, 0, 0
        for i = #S.hist, 1, -1 do
            local hh = S.hist[i]
            if hh.t < w0 then break end
            local x = hh.t - now
            local z = hh.p.Y + 0.5 * g * x * x
            sx, sz, sxx, sxz, szz, cnt = sx + x, sz + z, sxx + x * x, sxz + x * z, szz + z * z, cnt + 1
        end
        if cnt >= 5 then
            local det = cnt * sxx - sx * sx
            if det > 1e-6 then
                local vf = (cnt * sxz - sx * sz) / det
                local yf = (sz - vf * sx) / cnt
                -- residual of the fit: if the window is not one clean parabola the fit is not used
                local rss = szz - 2 * yf * sz - 2 * vf * sxz + cnt * yf * yf + 2 * yf * vf * sx + vf * vf * sxx
                if rss / cnt < 0.09 then vyFit, yFit = vf, yf end
            end
        end
    end

    -- humanoid state: takeoffs and bhop rhythm
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Jumping and S.prevState ~= Enum.HumanoidStateType.Jumping then
        S.takeoffs[#S.takeoffs + 1] = now
        if #S.takeoffs > 8 then table.remove(S.takeoffs, 1) end
    end
    S.prevState = state
    local bhop = false
    local n = #S.takeoffs
    if n >= 3 and now - S.takeoffs[n] < 0.7
        and S.takeoffs[n] - S.takeoffs[n - 1] < 0.9
        and S.takeoffs[n - 1] - S.takeoffs[n - 2] < 0.9 then
        bhop = true
    end

    -- lag: replicated velocity says "moving" but the position stopped updating
    if S.lastPos and (cur - S.lastPos).Magnitude > 0.05 then S.lastMoveT = now end
    S.lastPos = cur
    local lagging = (now - S.lastMoveT > (0.1 + rtt * 0.6)) and vInst.Magnitude > 3

    return {
        now = now, vWin = vWin, vLong = vLong, vInst = vInst, vInput = vInput, vKS = vKS, vKA = vKA,
        acc = S.acc, flips = S.flips, airborne = airborne, state = state,
        groundY = groundY, bhop = bhop, lagging = lagging, maxSpeed = hum.WalkSpeed * 1.1,
        vyFit = vyFit, yFit = yFit,
    }
end

-- score finished predictions against where the player really went. A model that gives several futures is
-- scored by the mixture likelihood of what happened (a model that hedges is not rewarded for hedging)
local NLL = 0.9
local function mixCost(list, actual)
    local acc = 0
    for _, d in ipairs(list) do
        local ex, ez = actual.X - d.X, actual.Z - d.Z
        acc = acc + math.exp(-(ex * ex + ez * ez) / NLL)
    end
    acc = acc / #list
    return math.min(-NLL * math.log(acc + 1e-10), 100)
end

local function evaluate(S, cur, now)
    local q = S.queue
    while q[1] and q[1].due <= now do
        local e = table.remove(q, 1)
        local actual = cur - e.base
        local k = math.min((0.2 / math.max(e.T or 0.2, 0.05)) ^ 2, 16) -- error scaled to a 0.2 s horizon
        for _, n in ipairs(PRED) do
            local list = e.disp[n]
            if list then
                S.err[n] = S.err[n] * 0.85 + mixCost(list, actual) * k * 0.15
            end
        end
    end
end

local function pushQueue(S, base, disp, due, now, T)
    if now - S.lastPush < 0.05 or #S.queue > 40 then return end
    S.lastPush = now
    S.queue[#S.queue + 1] = { due = due, base = base, disp = disp, T = T }
end

---------------------------------------------------------------------
-- Time: how far ahead of what you see the server looks, and how sure we are about it
---------------------------------------------------------------------
-- round trip + interpolation delay + jitter margin
local function pingHorizon()
    local T = (PING.rtt + Settings.Interp / 1000 + PING.jitter * 0.5) * Settings.PredStrength
    return clamp(T, 0.02, 0.9)
end

-- the server looks at the target at T +- sigma: ping jitter, plus what nobody knows exactly (the interpolation
-- delay of the game), plus a share of the ping itself
local function timeSigma()
    local j = PING.jitter * 0.7
    local r = PING.rtt * 0.05
    return clamp(math.sqrt(j * j + 0.045 * 0.045 + r * r), 0.04, 0.16)
end

local HF = { 0.12, 0.23, 0.30, 0.23, 0.12 }
local function horizons(T, sigma)
    return {
        math.max(T - 1.5 * sigma, 0.01), math.max(T - 0.75 * sigma, 0.01), T,
        T + 0.75 * sigma, T + 1.5 * sigma,
    }
end

-- vertical hypotheses (shared by every horizontal model): ballistic when already in the air,
-- otherwise "stays on the ground" plus a few "jumps at some moment" branches weighted by its jump rate
local function buildVertical(S, ctx, hum, hrp, Hs)
    local nh = #Hs
    local y0 = ctx.yFit or hrp.Position.Y
    local vy = ctx.vyFit or ctx.vInst.Y
    if ctx.airborne and not ctx.vyFit and math.abs(vy) < 0.1 then vy = ctx.vWin.Y end
    local g = workspace.Gravity
    local jumpV = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * g * hum.JumpHeight)
    local jumping = ctx.state == Enum.HumanoidStateType.Jumping
    if jumping and not ctx.vyFit then
        -- the first moments of a jump: the velocity property is stale (it still shows the fall before the
        -- takeoff) and there is not enough history for a fit. Energy gives the speed from the height alone:
        -- vy^2 = v0^2 - 2 g h (h = height above where the jump started)
        local h = ctx.groundY and (y0 - ctx.groundY) or 0
        vy = math.sqrt(math.max(jumpV * jumpV - 2 * g * math.max(h, 0), 0))
    end
    local nearGround = ctx.groundY and (y0 - ctx.groundY) < 0.6
    local needSim = (ctx.airborne and not nearGround) or jumping or ctx.bhop
    if needSim then
        local dys = {}
        local yd = hrp.Position.Y
        for k, h in ipairs(Hs) do
            dys[k] = clamp(simY(y0, vy, h, ctx.groundY, ctx.bhop and jumpV or nil) - yd, -7, 7)
        end
        return { { w = 1, dys = dys } }
    end
    local zero = {}
    for k = 1, nh do zero[k] = 0 end
    local cnt = 0
    for _, tk in ipairs(S.takeoffs) do
        if ctx.now - tk < 8 then cnt = cnt + 1 end
    end
    local hmax = Hs[nh]
    local p = 1 - math.exp(-((cnt + 0.25) / 8) * hmax)
    if p < 0.07 then return { { w = 1, dys = zero } } end
    local hyps = { { w = 1 - p, dys = zero } }
    for q = 1, 3 do
        local tau = hmax * q / 4
        local dys = {}
        for k, h in ipairs(Hs) do
            dys[k] = (h > tau) and clamp(simY(0, jumpV, h - tau, 0, nil), 0, 8) or 0
        end
        hyps[#hyps + 1] = { w = p / 3, dys = dys }
    end
    return hyps
end

-- scale a path down when a wall is in its way
local function clipPath(basePos, disps, params)
    local c, far = disps[3], disps[5]
    local ray = (far.Magnitude > c.Magnitude) and far or c
    if ray.Magnitude < 0.3 then return end
    local hit = workspace:Raycast(basePos, ray, params)
    if not hit then return end
    local cut = math.max((hit.Position - basePos).Magnitude - 0.6, 0)
    for k = 1, #disps do
        local d = disps[k]
        if d.Magnitude > cut and d.Magnitude > 0 then disps[k] = d.Unit * cut end
    end
end

-- the cloud: weighted positions the target may have when the server looks at it
local function buildCloud(F, T, sigma)
    local S, ctx, hum, hrp, basePos, params = F.S, F.ctx, F.hum, F.hrp, F.basePos, F.params
    local Hs = horizons(T, sigma)
    local nh = #Hs
    local vert = buildVertical(S, ctx, hum, hrp, Hs)
    local maxSp = ctx.maxSpeed or 17.6
    local v0 = flat(ctx.vInst)
    if v0.Magnitude > maxSp then v0 = v0.Unit * maxSp end

    local entries, dispAll, total = {}, {}, 0
    local function push(name, w, disps)
        for k = 1, nh do
            local d = disps[k]
            local lim = 52 * Hs[k]
            if d.Magnitude > lim then disps[k] = d.Unit * lim end
        end
        clipPath(basePos, disps, params)
        entries[#entries + 1] = { name = name, w = w, disps = disps }
        total = total + w
        local list = dispAll[name]
        if not list then
            list = {}
            dispAll[name] = list
        end
        list[#list + 1] = disps[3]
    end

    for _, n in ipairs(PRED) do
        local w = 1 / ((0.3 + S.err[n]) ^ 2)
        if ctx.lagging then w = (n == "stop") and 1 or 0 end
        -- MoveDirection of other players may not replicate: a fast target with zero input means the input models are blind
        if (n == "input" or n == "blend") and ctx.vInst.Magnitude > 6 and ctx.vInput.Magnitude < 0.5 then w = 0 end
        if w > 0 then
            if n == "seq" then
                local ev = seqEvents(S, ctx.now, Hs[nh] + 0.05)
                if ev then push(n, w, pathDisp(v0, ev, Hs)) end
            elseif n == "boot" then
                local futs, ws = bootFutures(S, ctx.now, Hs[nh] + 0.05)
                if futs then
                    local sw = 0
                    for _, x in ipairs(ws) do sw = sw + x end
                    for i, ev in ipairs(futs) do push(n, w * ws[i] / sw, pathDisp(v0, ev, Hs)) end
                end
            else
                local disps = {}
                for k = 1, nh do disps[k] = DISP[n](ctx, Hs[k]) end
                push(n, w, disps)
            end
        end
    end
    if total <= 0 then return nil end

    local pReg, regs = regimeBranch(S, ctx.now, Hs[nh] + 0.05)
    local shareEns = pReg and (1 - pReg) or 1
    if pReg then
        local v0r = (S.moving == false) and Vector3.zero or v0
        for _, h in ipairs(regs) do
            local disps = pathDisp(v0r, h.ev, Hs)
            for k = 1, nh do
                local d = disps[k]
                local lim = 52 * Hs[k]
                if d.Magnitude > lim then disps[k] = d.Unit * lim end
            end
            clipPath(basePos, disps, params)
            entries[#entries + 1] = { name = "regime", w = h.w * pReg * total / shareEns, disps = disps, hazard = true }
        end
        total = total / shareEns
    end

    -- merge positions into 0.5 stud cells
    local cells, order = {}, {}
    local byName = {}
    for _, en in ipairs(entries) do
        local ew = en.w / total
        if not en.hazard then byName[en.name] = (byName[en.name] or 0) + ew end
        for k = 1, nh do
            for _, vh in ipairs(vert) do
                local w = ew * HF[k] * vh.w
                local d = en.disps[k]
                local dy = vh.dys[k]
                local key = ((math.floor(d.X * 2) + 1024) * 2048 + (math.floor(d.Z * 2) + 1024)) * 512
                    + (math.floor(dy * 2) + 256)
                local c = cells[key]
                if c then
                    c.x, c.y, c.z, c.w = c.x + d.X * w, c.y + dy * w, c.z + d.Z * w, c.w + w
                else
                    c = { x = d.X * w, y = dy * w, z = d.Z * w, w = w }
                    cells[key] = c
                    order[#order + 1] = c
                end
            end
        end
    end
    local cloud = {}
    for i, c in ipairs(order) do
        cloud[i] = { pos = basePos + Vector3.new(c.x / c.w, c.y / c.w, c.z / c.w), w = c.w }
    end
    local bestW, bestN = 0, "-"
    local ensSum = 0
    for _, w in pairs(byName) do ensSum = ensSum + w end
    for n, w in pairs(byName) do
        byName[n] = (ensSum > 0) and (w / ensSum) or w
        if w > bestW then bestW, bestN = w, n end
    end
    return cloud, byName, dispAll, bestN, pReg
end

local function cloudMean(cloud)
    local m = Vector3.zero
    for _, s in ipairs(cloud) do m = m + s.pos * s.w end
    return m
end

---------------------------------------------------------------------
-- Shot line: bearing and elevation are solved separately. A line from the shooter is described by
-- b (sideways studs per stud of range) and e (height studs per stud of range); a point of the cloud is hit when
-- it is within the hit radius sideways AND within the (taller) radius vertically. Movement along the line does
-- not matter for a hitscan, so it is not part of the problem at all.
---------------------------------------------------------------------
local function edge(m, rho) -- 1 inside 60 % of the radius, fading to 0 at the radius
    local x = (rho - m) / (0.4 * rho)
    if x >= 1 then return 1 end
    if x <= 0 then return 0 end
    return x
end

local function solveLine(origin, cloud, rhoU, rhoV)
    local n = #cloud
    if n == 0 then return nil end
    local mean = cloudMean(cloud)
    local hv = flat(mean - origin)
    local rng = hv.Magnitude
    if rng < 1 then return nil end
    local d0 = hv / rng
    local perp = Vector3.new(-d0.Z, 0, d0.X)
    local Rg, Tb, Te, W = {}, {}, {}, {}
    local bMean, eMean = 0, 0
    for i = 1, n do
        local rel = cloud[i].pos - origin
        local r = rel.X * d0.X + rel.Z * d0.Z
        if r < 1 then r = 1 end
        Rg[i] = r
        Tb[i] = (rel.X * perp.X + rel.Z * perp.Z) / r
        Te[i] = rel.Y / r
        W[i] = cloud[i].w
        bMean = bMean + Tb[i] * W[i]
        eMean = eMean + Te[i] * W[i]
    end
    local function mass(b, e)
        local s = 0
        for i = 1, n do
            local mu = math.abs(Tb[i] - b) * Rg[i]
            if mu < rhoU then
                local mv = math.abs(Te[i] - e) * Rg[i]
                if mv < rhoV then s = s + W[i] * edge(mu, rhoU) * edge(mv, rhoV) end
            end
        end
        return s
    end
    local idx = {}
    for i = 1, n do idx[i] = i end
    table.sort(idx, function(a, b) return W[a] > W[b] end)
    local K = math.min(n, 20)

    local b, e = bMean, eMean
    local function bestB()
        local bb, bs = b, mass(b, e) - 0.002 * math.abs(b - bMean)
        for q = 1, K do
            local c = Tb[idx[q]]
            local sc = mass(c, e) - 0.002 * math.abs(c - bMean)
            if sc > bs then bb, bs = c, sc end
        end
        b = bb
    end
    local function bestE()
        local ee, es = e, mass(b, e) - 0.002 * math.abs(e - eMean)
        for q = 1, K do
            local c = Te[idx[q]]
            local sc = mass(b, c) - 0.002 * math.abs(e - eMean)
            if sc > es then ee, es = c, sc end
        end
        e = ee
    end
    bestB()
    bestE()
    bestB()

    -- range along the line: mass-weighted
    local sr, sw = 0, 0
    for i = 1, n do
        local mu = math.abs(Tb[i] - b) * Rg[i]
        local mv = math.abs(Te[i] - e) * Rg[i]
        local k = (mu < rhoU and mv < rhoV) and (W[i] * edge(mu, rhoU) * edge(mv, rhoV)) or 0
        sr, sw = sr + Rg[i] * k, sw + k
    end
    local Rm = (sw > 0) and (sr / sw) or rng
    return { b = b, e = e, mass = mass(b, e), massFn = mass, d0 = d0, perp = perp, Rm = Rm, mean = mean }
end

local function pointOnLine(origin, sol, b, e, extra)
    local dir = sol.d0 + sol.perp * b + Vector3.new(0, e, 0)
    return origin + dir * (sol.Rm + extra)
end

---------------------------------------------------------------------
-- Wall check
---------------------------------------------------------------------
-- parts that cannot collide only count as "disputed" when they are visible things (decoration, fences); invisible
-- triggers / zones (transparency >= 0.9) are skipped and the ray goes on
local function disputedGeometry(origin, seg)
    local from, rest = origin, seg
    for _ = 1, 4 do
        local hit = workspace:Raycast(from, rest, RP2)
        if not hit then return false end
        local ok, visible = pcall(function() return (hit.Instance.Transparency or 0) < 0.9 end)
        if not ok or visible then return true end
        local used = (hit.Position - from).Magnitude + 0.05
        local len = rest.Magnitude
        if used >= len then return false end
        from = from + rest.Unit * used
        rest = rest.Unit * (len - used)
    end
    return false
end

-- 1 = clear, 0.65 = grazing (a ray of the 4-ray fan touches geometry), 0.5 = disputed (only parts that cannot
-- collide are in the way: the game may or may not count them), 0 = blocked
local function clearance(origin, P, range)
    local dir = P - origin
    local len = dir.Magnitude
    if len < 1 then return 1, "close" end
    local d = dir / len
    local stop = math.max(math.min(range, len) - 0.9, 0.3) -- stop just before the target itself
    local seg = d * stop
    local p1 = getRP()
    if workspace:Raycast(origin, seg, p1) then return 0, "wall" end
    local side = d:Cross(Vector3.new(0, 1, 0))
    if side.Magnitude < 0.05 then side = Vector3.new(1, 0, 0) else side = side.Unit end
    local up = side:Cross(d).Unit
    local o1, o2 = side * 0.4, up * 0.4
    local blocked = 0
    if workspace:Raycast(origin + o1, seg, p1) then blocked = blocked + 1 end
    if workspace:Raycast(origin - o1, seg, p1) then blocked = blocked + 1 end
    if workspace:Raycast(origin + o2, seg, p1) then blocked = blocked + 1 end
    if workspace:Raycast(origin - o2, seg, p1) then blocked = blocked + 1 end
    if blocked >= 3 then return 0, "wall" end
    local f, why = 1, "clear"
    if blocked > 0 then f, why = 0.65, "grazing" end
    if disputedGeometry(origin, seg) then f, why = math.min(f, 0.5), "disputed" end
    return f, why
end

-- is another player standing on the segment origin -> (range along the line)?
local function playerOnSegment(origin, P, range, exclude)
    local dir = P - origin
    local len = dir.Magnitude
    if len < 1 then return false end
    local d = dir / len
    local stop = math.min(range, len) - 0.6
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr ~= exclude then
            local hrp = isAlive(plr)
            if hrp then
                local c = hrp.Position
                for h = -2, 2, 1 do
                    local p = c + Vector3.new(0, h, 0)
                    local t = (p - origin):Dot(d)
                    if t > 0.8 and t < stop then
                        local q = origin + d * t
                        local dx, dz = p.X - q.X, p.Z - q.Z
                        if dx * dx + dz * dz < 1.4 * 1.4 and math.abs(p.Y - q.Y) < 1.6 then return true end
                    end
                end
            end
        end
    end
    return false
end

local function evalLine(F, sol, from, b, e, role, mode)
    local P = pointOnLine(from, sol, b, e, Settings.Overshoot)
    local range = sol.Rm * math.sqrt(1 + b * b + e * e)
    local f, why = 1, "clear"
    if mode ~= "Off" then f, why = clearance(from, P, range) end
    if f > 0 and Settings.AvoidInnocents and role ~= "Murderer" and playerOnSegment(from, P, range, F.plr) then
        f, why = 0, "player"
    end
    return P, f, why
end

-- the plan for one shot: the densest line, replaced by a nearby clear one when the wall check asks for it
local function makePlan(F, cloud, from, role, T, budget)
    local rhoU = Settings.HitRadius
    local rhoV = rhoU * 2.2
    local sol = solveLine(from, cloud, rhoU, rhoV)
    if not sol then return nil end
    local mode = Settings.WallCheck
    local function usable(f)
        if mode == "Strict" then return f >= 0.99 end
        return f > 0
    end
    local P, f, why = evalLine(F, sol, from, sol.b, sol.e, role, mode)
    local best = { aim = P, cover = sol.mass, factor = f, why = why }
    if f < 0.99 then
        -- nearby lines through the same cloud (sideways studs x height studs: a line over a low wall,
        -- around a pillar). best-first by how much of the cloud they cover; a candidate that covers less than the
        -- best score found so far cannot win
        local cands = {}
        for _, db in ipairs({ 0, -0.5, 0.5, -1.0, 1.0 }) do
            for _, de in ipairs({ 0, 0.8, -0.8, 1.6, -1.6, 2.2, -2.2 }) do
                if db ~= 0 or de ~= 0 then
                    local b2, e2 = sol.b + db / sol.Rm, sol.e + de / sol.Rm
                    local m = sol.massFn(b2, e2)
                    if m > 0.03 then cands[#cands + 1] = { b = b2, e = e2, m = m } end
                end
            end
        end
        table.sort(cands, function(x, y) return x.m > y.m end)
        local bestScore = usable(f) and (sol.mass * f) or -1
        for i = 1, math.min(#cands, budget or 24) do
            local c = cands[i]
            if c.m <= bestScore then break end
            local P2, f2, why2 = evalLine(F, sol, from, c.b, c.e, role, mode)
            if usable(f2) and c.m * f2 > bestScore then
                bestScore = c.m * f2
                best = { aim = P2, cover = c.m, factor = f2, why = why2 .. " (moved)" }
            end
        end
    end
    best.pass = not usable(best.factor)
    best.T = T
    best.Rm = sol.Rm
    return best
end

-- Confidence = estimated chance that the shot hits. Fitted on simulated shots (predicted 0.80 -> hit 0.80).
-- "cover" alone overstates it: when every model agrees the cloud is tiny, yet the player may do something else.
-- So the recent error of the models (the player is hard to read), the horizon (a long ping looks further ahead)
-- and a target in between standing and full speed (mid-turn, starting, stopping) are part of it.
local function confidence(plan, F, byName)
    local S, ctx = F.S, F.ctx
    local werr, wsum = 0, 0
    for n, w in pairs(byName) do
        werr, wsum = werr + w * (S.err[n] or 3), wsum + w
    end
    werr = (wsum > 0) and (werr / wsum) or 3
    local ws = math.max(F.hum.WalkSpeed, 8)
    local sp = flat(ctx.vInst).Magnitude
    local trans = (sp >= 0.12 * ws and sp < 0.8 * ws) and 1 or 0
    local z = 2.8 + 2.3 * (plan.cover or 0) - 1.0 * math.log(1 + werr) - 7.5 * (plan.T or 0.2) - 2.3 * trans
    return 1 / (1 + math.exp(-z))
end

-- plan for the moment of the shot: fresh time offset, knife flight time, the real origin of the shot
local function planAt(F, kind, from, now)
    local sigma = timeSigma()
    local T0 = pingHorizon() + clamp(now - F.t, 0, 0.12)
    local cloud, byName, dispAll, bestN, pReg = buildCloud(F, T0, sigma)
    if not cloud then return nil end
    local T = T0
    if kind == "knife" then
        local sp = math.max(Settings.KnifeSpeed, 20)
        for _ = 1, 2 do
            T = T0 + (cloudMean(cloud) - from).Magnitude / sp
            cloud, byName, dispAll, bestN, pReg = buildCloud(F, T, sigma)
            if not cloud then return nil end
        end
    end
    local plan = makePlan(F, cloud, from, F.role, T)
    if plan then
        plan.plr, plan.model, plan.weights, plan.dispAll = F.plr, bestN, byName, dispAll
        plan.pReg = pReg
        plan.conf = confidence(plan, F, byName)
    end
    return plan
end

---------------------------------------------------------------------
-- Shot statistics. Nothing is learned from shots: without the server's answer a miss says nothing about the
-- server timing (a script that "calibrates" itself on the displayed trail only confirms its own arithmetic).
-- A shot counts as a hit when the target dies within a second.
---------------------------------------------------------------------
local function registerShot(from, plan, plr)
    stats.redirected = stats.redirected + 1
    if not plr then return end
    shotLog[#shotLog + 1] = { t = os.clock(), plr = plr }
    if #shotLog > 6 then table.remove(shotLog, 1) end
end

local function updateShots(now)
    for i = #shotLog, 1, -1 do
        local sh = shotLog[i]
        if now - sh.t > 1.0 then
            table.remove(shotLog, i)
            if sh.plr.Parent then
                stats.shots = stats.shots + 1
                local hum = sh.plr.Character and sh.plr.Character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then stats.hits = stats.hits + 1 end
            end
        end
    end
end

local function resetLearning()
    for k in pairs(statesByPlr) do statesByPlr[k] = nil end
    stats.hits, stats.shots, stats.redirected, stats.passed, stats.auto = 0, 0, 0, 0, 0
    for i = #shotLog, 1, -1 do shotLog[i] = nil end
    markDirty()
end

---------------------------------------------------------------------
-- Per-frame update (always inside pcall: an error never leaves a stale aim point)
---------------------------------------------------------------------
local function myHead()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    return hrp.Position + Vector3.new(0, 1.5, 0), hrp
end

local lastPlanT = 0
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

    local basePos
    if Settings.AimPart == "Head" then
        local head = ch:FindFirstChild("Head")
        basePos = head and head.Position or (hrp.Position + Vector3.new(0, 1.5, 0))
    elseif Settings.AimPart == "Body" then
        basePos = hrp.Position
    else
        -- "Chest" and "Auto": the wall check moves the line by itself when a part of the body is covered
        local chest = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
        basePos = chest and chest.Position or (hrp.Position + Vector3.new(0, 0.9, 0))
    end
    basePos = basePos + Vector3.new(0, Settings.AimHeight, 0)

    local F = { S = S, ctx = ctx, hum = hum, hrp = hrp, basePos = basePos, plr = m, t = now,
        params = params, role = role }
    FR, FRlast = F, F

    -- the heavy part (cloud + line + wall check) runs ~16 times a second; a shot recomputes it exactly
    if now - lastPlanT < 0.06 and A.plr == m then
        A.t = now
        return
    end
    lastPlanT = now

    local from = myHead()
    local sigma = timeSigma()
    local T = pingHorizon()
    local cloud, byName, dispAll, bestN = buildCloud(F, T, sigma)
    if not cloud then
        clearAim()
        return
    end
    evaluate(S, hrp.Position, now)
    if not ctx.lagging then pushQueue(S, hrp.Position, dispAll, now + T, now, T) end

    local plan = from and makePlan(F, cloud, from, role, T, 10) or nil
    A.plr, A.name, A.t = m, m.DisplayName, now
    A.lead, A.T = T, T
    A.model, A.weights = bestN, byName
    A.lagging = ctx.lagging
    A.stable = (#S.turns == 0 or now - S.turns[#S.turns].t > 0.6) and ctx.acc.Magnitude < 25
    A.mean = cloudMean(cloud)
    if plan then
        plan.conf = confidence(plan, F, byName)
        A.pos, A.cover, A.guard, A.pass, A.conf = plan.aim, plan.cover, plan.why, plan.pass, plan.conf
        A.blocked = plan.pass
    else
        A.pos, A.cover, A.guard, A.pass, A.conf = A.mean, 0, "no line", false, 0
        A.blocked = false
    end
    A.visible = (A.guard == "clear" or A.guard == "close")
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

-- plan for a shot that is being fired right now (nil = no target)
local function shotPlan(kind, from)
    local F = FR or FRlast
    local now = os.clock()
    if not F or now - F.t > 0.4 or not (F.plr.Parent and F.hrp.Parent) then return nil end
    return planAt(F, kind, from, now)
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
-- origin (optional) replaces the position of the first CFrame
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

-- where the remote of a real shot sits inside the Gun tool (names from the tool down): the tool is cloned on
-- every respawn, the path is what stays the same
local function remotePath(remote)
    local names, p = {}, remote
    while p and p.Name ~= "Gun" and #names < 8 do
        table.insert(names, 1, p.Name)
        p = p.Parent
    end
    if p and p.Name == "Gun" then return names end
    return nil
end

local function handleShot(kind, remote, ...)
    if Settings.Debug then logCall(remote, ...) end
    -- the real shape of a shot (it differs between game versions): auto shoot replays it
    ST.shape[kind] = table.pack(...)
    if kind == "gun" then
        ST.lastShotT = os.clock()
        ST.gunPath = remotePath(remote)
    end
    if not Settings.SilentAim then return nil end

    -- the line is planned again for this exact moment: fresh ping, the real origin of the shot, knife flight time
    local from = firstCFramePos(...) or myHead()
    if not from then return nil end
    local plan = shotPlan(kind, from)
    if not plan then
        shotNote("no target: shot unchanged", "warn")
        if Settings.Debug then print("[MM2 Suite] shot NOT redirected: no target") end
        return nil
    end
    if plan.pass then
        -- the wall check refused every line (wall, grazing edge, player in the way): the game gets your own shot
        stats.passed = stats.passed + 1
        shotNote("wall check: " .. plan.why .. " - shot unchanged", "warn")
        if Settings.Debug then
            print(string.format("[MM2 Suite] shot NOT redirected: %s (cover %d%%)", plan.why, math.floor(plan.cover * 100)))
        end
        return nil
    end
    if kind == "gun" then registerShot(from, plan, plan.plr) end
    shotNote(string.format("%s -> %s  lead %dms  cover %d%%  %s", kind, tostring(A.name),
        math.floor((plan.T or 0) * 1000), math.floor((plan.cover or 0) * 100), plan.why), "good")
    if Settings.Debug then
        print(string.format("[MM2 Suite] redirect %s -> %s | dist %.1f | lead %dms | cover %d%% | %s | model %s",
            kind, tostring(A.name), (plan.aim - from).Magnitude, math.floor((plan.T or 0) * 1000),
            math.floor((plan.cover or 0) * 100), plan.why, tostring(plan.model)))
    end
    return buildArgs(plan.aim, nil, ...)
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
        if kind and not own then
            local ok, res = pcall(handleShot, kind, self, ...)
            if ok and res then
                setNC(method)
                return oldNC(self, table.unpack(res, 1, res.n))
            elseif not ok and Settings.Debug then
                warn("[MM2 Suite] redirect failed, shot sent unchanged: " .. tostring(res))
            end
        end
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
    warn("[MM2 Suite] Executor can't hook __namecall - silent aim needs it and cannot work in this executor.")
end

---------------------------------------------------------------------
-- Auto shoot. It fires by itself, but only when the engine is sure: the confidence (estimated chance to hit) is
-- above the threshold for a moment, the wall check has a clear line, and the target is the murderer. There is no
-- "fire anyway after a while" fallback: when the shot is not good it simply waits for a better one.
---------------------------------------------------------------------
local auto = { holdSince = nil, busy = false, equipT = 0, lastFire = 0, cooldown = 2, state = "off" }

local function findGunRemote(gun)
    -- the remote your own last shot went through (it may differ between game versions)
    if ST.gunPath then
        local cur = gun
        for _, n in ipairs(ST.gunPath) do cur = cur and cur:FindFirstChild(n) end
        if cur and (cur:IsA("RemoteEvent") or cur:IsA("RemoteFunction")) then return cur end
    end
    local r = gun:FindFirstChild("Shoot", true)
    if r then return r end
    for _, d in ipairs(gun:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and classify(d) == "gun" then return d end
    end
    return gun:FindFirstChild("RemoteFunction", true)
end

-- sends one shot through the gun's remote. The origin is always the CURRENT one (the shape of an old shot
-- carries the position you had back then)
local function fireGun(plan, from)
    local char = lp.Character
    local gun = char and char:FindFirstChild("Gun")
    if not gun then return false, "no gun in hand" end
    local remote = findGunRemote(gun)
    if not remote then return false, "shoot remote not found" end
    local shape = ST.shape.gun
    local args
    if shape then
        args = buildArgs(plan.aim, from, table.unpack(shape, 1, shape.n))
    elseif remote:IsA("RemoteFunction") then
        args = { 1, plan.aim, "AH2", n = 3 }
    else
        args = { lookCF(from, plan.aim), CFrame.new(plan.aim), n = 2 }
    end
    -- our own call must not be redirected a second time
    ST.ownRemote, ST.ownUntil = remote, os.clock() + 0.05
    if remote:IsA("RemoteFunction") then
        task.spawn(function()
            ST.ownRemote, ST.ownUntil = remote, os.clock() + 0.05
            pcall(function() remote:InvokeServer(table.unpack(args, 1, args.n)) end)
        end)
    else
        pcall(function() remote:FireServer(table.unpack(args, 1, args.n)) end)
    end
    return true
end

local function autoCooldown()
    local c = Settings.AutoCooldown
    if Settings.SafeMode and c < 1.8 then c = 1.8 end
    return c + math.random() * 0.3
end

local function autoStep(now)
    auto.state = "off"
    if not (Settings.AutoShoot and Settings.SilentAim) or auto.busy then
        auto.holdSince = nil
        return
    end
    if ST.role == "Murderer" then auto.state = "you are the murderer" auto.holdSince = nil return end
    if not isAlive(lp) or not hasTool(lp, "Gun") then auto.state = "no gun" auto.holdSince = nil return end
    local plr = A.plr
    if not plr or not A.pos then auto.state = "no target" auto.holdSince = nil return end
    -- never at anyone but the murderer, whatever the target mode says
    if getRole(plr) ~= "Murderer" then auto.state = "target is not the murderer" auto.holdSince = nil return end
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local thrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    local dist = (myHrp and thrp) and (myHrp.Position - thrp.Position).Magnitude or math.huge
    if dist > Settings.AutoRange then auto.state = "out of range" auto.holdSince = nil return end
    if A.pass then auto.state = "wall check: " .. tostring(A.guard) auto.holdSince = nil return end
    if A.lagging then auto.state = "target lagging" auto.holdSince = nil return end
    if now - math.max(auto.lastFire, ST.lastShotT) < auto.cooldown then
        auto.state = "cooldown"
        auto.holdSince = nil
        return
    end
    local char = lp.Character
    if not char:FindFirstChild("Gun") then
        -- equip ahead of time, while there is something worth shooting at, so the shot itself is instant
        auto.state = "equipping"
        if Settings.AutoEquip and now - auto.equipT > 1.5 then
            auto.equipT = now
            local bp = lp:FindFirstChild("Backpack")
            local g = bp and bp:FindFirstChild("Gun")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if g and hum then pcall(function() hum:EquipTool(g) end) end
        end
        auto.holdSince = nil
        return
    end
    local need = Settings.AutoConf / 100
    local conf = A.conf or 0
    if conf < need then
        auto.state = string.format("waiting for a surer shot (%d%% < %d%%)", math.floor(conf * 100), math.floor(need * 100))
        auto.holdSince = nil
        return
    end
    auto.holdSince = auto.holdSince or now
    auto.state = "aiming"
    if now - auto.holdSince < 0.07 then return end -- the confidence has to hold for a few frames, not a single one

    -- the exact plan of this very moment decides (fresh ping, real origin)
    auto.busy = true
    local from = myHead()
    local plan = from and shotPlan("gun", from) or nil
    if plan and not plan.pass and (plan.conf or 0) >= need * 0.94
        and not playerOnSegment(from, plan.aim, math.max((plan.aim - from).Magnitude - Settings.Overshoot, 1), plan.plr) then
        local ok = fireGun(plan, from)
        if ok then
            auto.lastFire, auto.cooldown = now, autoCooldown()
            stats.auto = stats.auto + 1
            registerShot(from, plan, plan.plr)
            auto.state = "fired"
            shotNote(string.format("auto shot -> %s  confidence %d%%  %s", tostring(A.name),
                math.floor((plan.conf or 0) * 100), plan.why), "good")
            if Settings.Debug then
                print(string.format("[MM2 Suite] auto shot -> %s | conf %d%% | cover %d%% | lead %dms | %s",
                    tostring(A.name), math.floor((plan.conf or 0) * 100), math.floor((plan.cover or 0) * 100),
                    math.floor((plan.T or 0) * 1000), plan.why))
            end
        end
    end
    auto.holdSince = nil
    auto.busy = false
end

task.spawn(function()
    while running do
        task.wait(0.04)
        local ok, err = pcall(autoStep, os.clock())
        if not ok then
            auto.busy = false
            ST.lastErr = tostring(err)
            if Settings.Debug then warn("[MM2 Suite] auto shoot: " .. tostring(err)) end
        end
    end
end)

---------------------------------------------------------------------
-- Role profiles: the script re-tunes itself when your role changes
---------------------------------------------------------------------
local refreshAll -- assigned by the GUI

local PROFILES = {
    -- sheriff, or an innocent who is about to pick the gun up: hit the murderer
    gun = {
        AimPart = "Auto", AvoidInnocents = true, VisibleOnly = false, HitRadius = 1.1, Overshoot = 2.5,
    },
    -- murderer: knife throw at whoever is closest to the cursor
    knife = {
        AimPart = "Auto", AvoidInnocents = false, VisibleOnly = false, HitRadius = 1.3, Overshoot = 2,
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

-----------------------------------------------------------------------
-- public API: the host talks to the module only through this table
-----------------------------------------------------------------------
local SA = {}
SA.Settings = Settings          -- live settings, read every frame: SA.Settings.AimPart = "Head"
SA.DEFAULTS = DEFAULTS          -- defaults of the keys above
SA.OPTS = OPTS                  -- allowed values of the text keys (dropdowns)
SA.RANGES = RANGES              -- min / max of the number keys (sliders)
SA.state = ST                   -- ST.toast = function(text, kind) gets the notifications
SA.aim = A                      -- live aim: A.plr target, A.name, A.pos aim point, A.conf chance to hit, A.guard wall line
SA.stats = stats                -- hits, shots, redirected, passed, auto
SA.auto = auto                  -- auto shoot; auto.state is the readable reason it waits
function SA.hookStatus() return hookStatus end        -- "hookmetamethod", "rawmetatable" or "none"
function SA.lock(plr) ST.forced = plr end             -- force the target, SA.lock(nil) releases it
function SA.applyProfile(name) applyProfile(name) end -- "gun" or "knife"
function SA.resetLearning() resetLearning() end
function SA.setRefresh(fn) refreshAll = fn end        -- called after a profile is applied: refresh your GUI there
function SA.unload()
    if not running then return end
    running = false
    ENV.MM2Dispatch = nil
    ST.toast = nil
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for _, L in pairs(life) do
        if L.conn then pcall(function() L.conn:Disconnect() end) end
    end
end
return SA
end)()
for k, v in pairs(SilentAim.DEFAULTS) do DEFAULTS[k] = v end
for k, v in pairs(SilentAim.OPTS) do OPTS[k] = v end
for k, v in pairs(SilentAim.RANGES) do RANGES[k] = v end
local Settings = SilentAim.Settings
for k, v in pairs(DEFAULTS) do if Settings[k] == nil then Settings[k] = v end end
local A = SilentAim.aim -- live aim of the module: A.plr target, A.pos aim point, A.conf chance to hit, A.guard wall line

local UI = {
    accent = nil,                              -- { r, g, b } once the colour picker was used (nil = default)
    binds = { menu = "RightShift", shoot = "" },   -- hub key / force shoot key ("" = none)
}

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
    -- v17: radar switches and place (Radar*); older files keep the defaults (radar off)
    -- v18: nova Aura keys (NovaAura, NovaAuraStyle, NovaAuraColor, NovaAuraSize, NovaAuraSpeed)
    -- v19: skin changer keys (SkinChanger, SkinKnife, SkinGun: the skin sig, an unknown sig shows as none)
    -- v20: SkinHolster (gun on the back, knife on the belt while not in hand)
    -- v22: the silent aim module (its tuning keys are reset once, see applyConfigData)
    return { app = "mm2suite", v = 22, settings = Settings, ui = UI }
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
    -- v22: the aim is the silent_aim module: its tuning values come back to its defaults once (switches stay as saved)
    if (tonumber(data.v) or 0) < 22 then
        for _, k in ipairs({ "AimPart", "AimHeight", "FOV", "MaxDist", "VisibleOnly", "AvoidInnocents", "PredStrength",
            "Interp", "HitRadius", "Overshoot", "WallCheck", "KnifeSpeed", "AutoConf", "AutoRange", "AutoCooldown", "AutoEquip" }) do
            Settings[k] = DEFAULTS[k]
        end
    end
    -- v15: the aura colour is rgb now (it was one of six names)
    if (tonumber(data.v) or 0) < 15 and type(data.settings) == "table" then
        local named = AURA_NAMED[data.settings.AuraColor]
        if named then Settings.AuraR, Settings.AuraG, Settings.AuraB = named[1], named[2], named[3] end
    end
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
local function hopGrabOn() return Settings.GrabMode == "Remote + hop" and not Settings.SafeMode end
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
-- Targeting
---------------------------------------------------------------------
local function aimOrigin2D()
    if UIS.TouchEnabled and not UIS.MouseEnabled then
        return curCam().ViewportSize / 2
    end
    return UIS:GetMouseLocation()
end

local function effectiveMode(role)
    local mode = Settings.TargetMode
    if mode == "Auto" then
        -- murderer: whoever is closest to the cursor. everyone else: the murderer
        return role == "Murderer" and "Cursor" or "Murderer"
    end
    return mode
end

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
-- fling: the rock hub's sequence (the ultimate fling gui). every frame the root is put around the target with a
-- huge linear and spin velocity; the target counts as launched once it leaves its spot or drops out of the map.
-- the window is FLING.window seconds, then the character is pivoted back to where it stood.
-- target = the locked player, else the nearest one in the round; or the sheriff / the murderer.
---------------------------------------------------------------------
local FLING = { busy = false, window = 2 }

function FLING.pick(kind)
    if kind == nil then
        local locked = SilentAim.state.forced
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

-- gives the character back: the hold goes, seating and the fall limit come back, the character is pivoted to
-- the saved spot (up to 6 tries) and the humanoid is restored. st may be half filled (the setup can fail)
function FLING.restore(st)
    if st.hold and st.hold.Parent then pcall(function() st.hold:Destroy() end) end
    if st.seated ~= nil then pcall(st.hum.SetStateEnabled, st.hum, Enum.HumanoidStateType.Seated, st.seated) end
    if st.pivot and lp.Character == st.char and st.root.Parent and st.hum.Health > 0 then
        pcall(function()
            for _ = 1, 6 do
                st.char:PivotTo(st.pivot * CFrame.new(0, 0.5, 0))
                for _, part in ipairs(st.char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
                if (st.root.Position - st.pivot.Position).Magnitude < 25 then break end
                RunService.Heartbeat:Wait()
            end
            st.hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if st.autoRotate ~= nil then pcall(function() st.hum.AutoRotate = st.autoRotate end) end
    if st.fallen ~= nil then pcall(function() workspace.FallenPartsDestroyHeight = st.fallen end) end
end

-- returns true when the target was launched
function FLING.run(plr)
    if FLING.busy then
        notify("fling: another fling is running", "warn")
        return false
    end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tchar = plr and plr.Character
    local thum = tchar and tchar:FindFirstChildOfClass("Humanoid")
    local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
    if not (root and hum and hum.Health > 0 and troot and thum and thum.Health > 0) then
        notify("fling: no target", "warn")
        return false
    end
    if thum.Sit then
        notify("fling: " .. plr.DisplayName .. " is sitting", "warn")
        return false
    end
    FLING.busy = true

    local st = { char = char, hum = hum, root = root }
    local launched = false
    local started = os.clock()
    local ok, err = pcall(function()
        st.pivot = char:GetPivot()
        st.autoRotate = hum.AutoRotate
        st.fallen = workspace.FallenPartsDestroyHeight
        st.seated = hum:GetStateEnabled(Enum.HumanoidStateType.Seated)
        st.hold = mk("BodyVelocity", { Velocity = Vector3.zero, MaxForce = Vector3.new(9e9, 9e9, 9e9) }, root)
        -- the fall limit goes to nan so the kill plane cannot take the character during the sequence
        pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
        hum.AutoRotate = false
        pcall(hum.SetStateEnabled, hum, Enum.HumanoidStateType.Seated, false)
        if sethiddenproperty then
            pcall(sethiddenproperty, lp, "SimulationRadius", math.huge)
        end

        local targetPart = troot
        local launchOrigin = troot.Position
        local floorY = st.fallen or -500
        local function escaped()
            if not targetPart.Parent then return false end
            local pos = targetPart.Position
            local distance = (pos - launchOrigin).Magnitude
            local speed = targetPart.AssemblyLinearVelocity.Magnitude
            return pos.Y <= floorY + 30 or distance > 350 or distance > 120 and speed > 200
        end
        local function place(pos, angle)
            local cf = CFrame.new(targetPart.Position) * pos * angle
            root.CFrame = cf
            char:PivotTo(cf)
            root.Velocity = Vector3.new(9e7, 9e8, 9e7)
            root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local angle = 0
        while os.clock() - started < FLING.window and running do
            if not (root.Parent and hum.Health > 0 and targetPart.Parent and thum.Health > 0) then break end
            if escaped() then launched = true break end
            local speed = targetPart.AssemblyLinearVelocity.Magnitude
            angle = angle + 100
            local steps
            if speed < 50 then
                local lead = thum.MoveDirection * speed / 1.25
                local rotation = CFrame.Angles(math.rad(angle), 0, 0)
                steps = {
                    { CFrame.new(0, 1.5, 0) + lead, rotation },
                    { CFrame.new(0, -1.5, 0) + lead, rotation },
                    { CFrame.new(0, 1.5, 0) + lead, rotation },
                    { CFrame.new(0, -1.5, 0) + lead, rotation },
                    { CFrame.new(0, 1.5, 0) + thum.MoveDirection, rotation },
                    { CFrame.new(0, -1.5, 0) + thum.MoveDirection, rotation },
                }
            else
                local flat, quarter = CFrame.new(), CFrame.Angles(math.rad(90), 0, 0)
                steps = {
                    { CFrame.new(0, 1.5, thum.WalkSpeed), quarter },
                    { CFrame.new(0, -1.5, -thum.WalkSpeed), flat },
                    { CFrame.new(0, 1.5, thum.WalkSpeed), quarter },
                    { CFrame.new(0, -1.5, 0), quarter },
                    { CFrame.new(0, -1.5, 0), flat },
                    { CFrame.new(0, -1.5, 0), quarter },
                    { CFrame.new(0, -1.5, 0), flat },
                }
            end
            for _, step in ipairs(steps) do
                place(step[1], step[2])
                task.wait()
                if not running then break end
                if escaped() then launched = true break end
            end
            if launched then break end
        end
    end)
    FLING.restore(st)
    FLING.busy = false
    if not ok then
        notify("fling failed: " .. tostring(err), "warn")
        return false
    end
    if launched then
        notify("fling " .. plr.DisplayName .. ": flung down", "good")
    else
        notify("fling " .. plr.DisplayName .. ": resisted", "warn")
    end
    return launched
end

function FLING.action(kind)
    if Settings.SafeMode then notify("locked by safe mode (settings)", "warn") return end
    local plr = FLING.pick(kind)
    if not plr then
        notify(kind and ("no " .. string.lower(kind) .. " in the round") or "no player in range", "warn")
        return
    end
    notify("fling " .. plr.DisplayName, "info")
    task.spawn(FLING.run, plr)
end

local refreshAll -- assigned by the GUI
SilentAim.setRefresh(function() if refreshAll then refreshAll() end end) -- the module refreshes the GUI after a profile change

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
            local on = Settings.MapVote and not Settings.SafeMode and not Settings.VoteDuper
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

---------------------------------------------------------------------
-- vote duper (vote tab): the uploaded script's duper on our helpers. while the window of the picked map is open it
-- stands on that pad, waits VoteDuperDelay, dies on the pad, respawns and does it again until the window closes.
-- the pick is saved by map name (it comes back with the config). map vote and the duper switch each other off.
---------------------------------------------------------------------
local VD = { gen = 0, busy = false, padsAt = -100, pads = {} }

-- the pad models: the lobby's VotePad1..3, else the children of the lobby's VotePads folder (the reference script's order)
function VD.models()
    local out = {}
    local lobby = workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("SummerLobby") or workspace:FindFirstChild("Lobby")
    if lobby then
        for i = 1, 3 do
            local m = lobby:FindFirstChild("VotePad" .. i)
            if m then out[#out + 1] = m end
        end
        if #out == 0 then
            local folder = lobby:FindFirstChild("VotePads")
            if folder then
                for _, m in ipairs(folder:GetChildren()) do out[#out + 1] = m end
            end
        end
    end
    return out
end

function VD.text(o)
    if o and (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) then
        return tostring(o.Text or "")
    end
    return ""
end

-- one pad: the pad part, the map name and the votes from VoteInfoGui, the map picture from MapInfoGui
function VD.read(model)
    local pad = model:FindFirstChild("Pad", true)
    local info = model:FindFirstChild("MapInfoGui", true)
    local vote = model:FindFirstChild("VoteInfoGui", true)
    if not (pad and pad:IsA("BasePart") and info and vote) then return nil end
    local icon = info:FindFirstChild("MapIcon", true)
    local image = ""
    if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
        image = tostring(icon.Image or "")
    end
    return {
        model = model, pad = pad, image = image,
        name = VD.text(vote:FindFirstChild("MapName", true)),
        votes = VD.text(vote:FindFirstChild("Votes", true)),
    }
end

-- the pads as they read now (cached for a second; force = read again)
function VD.list(force)
    if not force and os.clock() - VD.padsAt < 1 then return VD.pads end
    VD.padsAt = os.clock()
    local out = {}
    for _, m in ipairs(VD.models()) do
        local e = VD.read(m)
        if e then out[#out + 1] = e end
    end
    VD.pads = out
    return out
end

-- the window of a pad: VoteInfoGui enabled (LayerCollector) or visible (GuiObject)
function VD.open(model)
    if not model or not model.Parent then return false end
    local gui = model:FindFirstChild("VoteInfoGui", true)
    if not gui then return false end
    local on = false
    pcall(function()
        if gui:IsA("LayerCollector") then
            on = gui.Enabled == true
        elseif gui:IsA("GuiObject") then
            on = gui.Visible == true
        else
            on = gui.Enabled == true
        end
    end)
    return on
end

-- the card of the saved map name, when that map is on the pads right now
function VD.pick(force)
    local name = Settings.VoteDuperMap
    if type(name) ~= "string" or name == "" then return nil end
    for _, e in ipairs(VD.list(force)) do
        if e.name == name then return e end
    end
    return nil
end

function VD.alive(gen)
    return running and VD.gen == gen and Settings.VoteDuper and not Settings.SafeMode
end

-- a stop bumps the generation: the running session sees it and ends (unload calls this)
function VD.stop()
    VD.gen = VD.gen + 1
    VD.busy = false
end

-- the uploaded duper's kill: health to 0 and the joints broken, the character comes back from the lobby
function VD.kill(char, hum)
    pcall(function() hum.Health = 0 end)
    pcall(function() char:BreakJoints() end)
end

-- after a death: waits for the next character (12 s at most)
function VD.respawn(gen, before)
    local t0 = os.clock()
    while VD.alive(gen) and os.clock() - t0 < 12 do
        local c = lp.Character
        if c and c ~= before and c:FindFirstChild("HumanoidRootPart") then return end
        task.wait(0.1)
    end
end

function VD.session(gen)
    while VD.alive(gen) do
        local e = VD.pick(true)
        if not e or not VD.open(e.model) then return end -- window closed or the pick is gone: the poll re-arms
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local stand = e.pad.CFrame * CFrame.new(0, 1.5, 0)
            if not pcall(function() char:PivotTo(stand) end) then hrp.CFrame = stand end
            task.wait(Settings.VoteDuperDelay or 0.38)
            if VD.alive(gen) and VD.open(e.model) and hum.Health > 0 then
                VD.kill(char, hum)
                VD.respawn(gen, char)
                task.wait(0.05)
            end
        else
            task.wait(0.1)
        end
    end
end

function VD.poll()
    while running do
        pcall(function()
            local on = Settings.VoteDuper and not Settings.SafeMode
            if not on then
                if VD.busy then VD.stop() end
                return
            end
            if VD.busy or MV.busy then return end -- one session at a time: map vote uses the same pads
            local e = VD.pick()
            if not e or not VD.open(e.model) then return end
            VD.busy = true
            VD.gen = VD.gen + 1
            local gen = VD.gen
            task.spawn(function()
                local ok, err = pcall(VD.session, gen)
                if not ok then warn("[vote duper] " .. tostring(err)) end
                if VD.gen == gen then VD.busy = false end
            end)
        end)
        task.wait(0.25)
    end
end
task.spawn(VD.poll)

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
local KNIFE = {}   -- the kill aura's knife helpers (the drone's kill impact uses them)
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
    KNIFE.knife_out, KNIFE.stab, KNIFE.touch = knife_out, stab, touch

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
-- 8 types, any colour (rgb). the body is the local character; the fake-model feature of the script is not in this suite.
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
    local st = { on = false, type = "angel", r = 133, g = 220, b = 255, host = nil, retryAt = 0, stripAt = 0 }

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

    -- the colour from the three settings, whole numbers 0-255
    local function rgb_now()
        local function byte(v, dv)
            return clamp(math.floor((tonumber(v) or dv) + 0.5), 0, 255)
        end
        return byte(Settings.AuraR, 133), byte(Settings.AuraG, 220), byte(Settings.AuraB, 255)
    end

    local function apply()
        clear()
        st.host = nil
        st.retryAt = os.clock() + 2
        local host, is_fake = resolve_host()
        if not host then return end
        local src = load_aura(st.type)
        if not src then
            st.host = host -- no template (yet): sync() tries again after the retry time
            return
        end
        paint(src, Color3.fromRGB(st.r, st.g, st.b))
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
        if live[1] then st.retryAt = math.huge end
    end

    -- runs every frame while the aura is on. a new body gets the particles the frame its root and head exist:
    -- the vote duper's lives are about 0.4 s, so a fixed wait after the spawn landed on a dead body
    local function sync()
        local host, is_fake = resolve_host()
        if host ~= st.host then
            if host and not is_fake and not (host:FindFirstChild("HumanoidRootPart") and host:FindFirstChild("Head")) then
                return
            end
            apply()
            return
        end
        if not host then return end
        local first = live[1]
        if first then
            if not first.Parent then apply() end
        elseif os.clock() >= st.retryAt then
            apply()
        end
    end

    local function tick()
        local on = Settings.WorldAura and true or false
        local ty = IDS[Settings.AuraType] and Settings.AuraType or "angel"
        local r, g, b = rgb_now()
        if on ~= st.on then
            st.on = on
            st.type, st.r, st.g, st.b = ty, r, g, b
            if on then
                apply()
            else
                clear()
                st.host = nil
            end
            return
        end
        if not on then return end
        if ty ~= st.type or r ~= st.r or g ~= st.g or b ~= st.b then
            st.type, st.r, st.g, st.b = ty, r, g, b
            apply()
        end
    end

    task.spawn(function()
        while running do
            pcall(tick)
            if st.on then
                pcall(sync)
                local now = os.clock()
                if now - st.stripAt >= 0.2 then
                    st.stripAt = now
                    pcall(strip_backtrack)
                end
                task.wait()
            else
                task.wait(0.2)
            end
        end
    end)

    local function stop()
        st.on = false
        pcall(clear)
        st.host = nil
    end

    return { stop = stop, types = ORDER }
end

-- ============ nova Aura (ported from NOVA: orbs, trails, sparks, fire) ============
-- own card and own settings (NovaAura*), own folder in workspace; the particle aura above stays as it is
;(function()
    local function setupNovaAura()
        local TAU = math.pi * 2
        local container = nil
        local orbs, emitters = {}, {}
        local anchor = nil
        local state = { hrp = nil, style = nil }

        -- the real character only, same clone rules as the particle aura
        local function realChar()
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

        local function clear()
            for _, o in ipairs(orbs) do pcall(function() o.part:Destroy() end) end
            if anchor then pcall(function() anchor:Destroy() end) end
            orbs, emitters, anchor = {}, {}, nil
            state.hrp, state.style = nil, nil
        end

        local function addOrb(size, life, width, fn)
            local p = mk("Part", {
                Shape = Enum.PartType.Ball, Size = Vector3.one * size, Material = Enum.Material.Neon, Anchored = true,
                CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Massless = true,
            }, container)
            local a0 = mk("Attachment", { Position = Vector3.new(0, width / 2, 0) }, p)
            local a1 = mk("Attachment", { Position = Vector3.new(0, -width / 2, 0) }, p)
            local tr = mk("Trail", {
                Attachment0 = a0, Attachment1 = a1, Lifetime = life, LightEmission = 1, MinLength = 0.02, FaceCamera = true,
                WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
                Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) }),
            }, p)
            orbs[#orbs + 1] = { part = p, trail = tr, fn = fn }
        end

        local function addEmitter(parent, props)
            local e = mk("ParticleEmitter", props, parent)
            emitters[#emitters + 1] = e
            return e
        end

        -- the anchor is an invisible part that follows the root every frame and holds the emitters,
        -- so nothing is parented under the character itself
        local function build(hrp, style)
            if not container or not container.Parent then
                container = mk("Folder", { Name = rname() }, workspace)
            end
            anchor = mk("Part", {
                Size = Vector3.one * 0.2, Transparency = 1, Anchored = true, CanCollide = false, CanQuery = false,
                CanTouch = false, CastShadow = false, CFrame = CFrame.new(hrp.Position),
            }, container)
            addEmitter(anchor, {
                Texture = "rbxasset://textures/particles/sparkles_main.dds", Rate = 22, Lifetime = NumberRange.new(1, 1.8),
                Speed = NumberRange.new(0.5, 2), SpreadAngle = Vector2.new(180, 180), LightEmission = 1,
                Acceleration = Vector3.new(0, 2.2, 0), RotSpeed = NumberRange.new(-90, 90),
                Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.5), NumberSequenceKeypoint.new(1, 0) }),
                Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.1), NumberSequenceKeypoint.new(1, 1) }),
            })
            if style == "Cosmic" then
                for i = 0, 5 do
                    addOrb(0.3, 0.9, 0.7, function(t, rp)
                        local R, V = Settings.NovaAuraSize, Settings.NovaAuraSpeed
                        local a = t * V * 2.2 + i * TAU / 6
                        local y = math.sin(t * 1.3 + i * 1.05) * 2.2
                        return rp + Vector3.new(math.cos(a) * R, y, math.sin(a) * R)
                    end)
                end
                for i = 0, 2 do
                    addOrb(0.22, 1.4, 0.35, function(t, rp)
                        local R, V = Settings.NovaAuraSize, Settings.NovaAuraSpeed
                        local a = -t * V * 1.1 + i * TAU / 3
                        local r = R + 1.2
                        return rp + Vector3.new(math.cos(a) * r, -2.8 + math.sin(t * 2 + i) * 0.15, math.sin(a) * r)
                    end)
                end
            elseif style == "Halo" then
                for i = 0, 2 do
                    addOrb(0.25, 1.1, 0.25, function(t, rp)
                        local V = Settings.NovaAuraSpeed
                        local a = t * V * 3 + i * TAU / 3
                        return rp + Vector3.new(math.cos(a) * 1.3, 3.1, math.sin(a) * 1.3)
                    end)
                end
                for i = 0, 3 do
                    addOrb(0.3, 1.6, 0.5, function(t, rp)
                        local R, V = Settings.NovaAuraSize, Settings.NovaAuraSpeed
                        local a = -t * V * 2 + i * TAU / 4
                        return rp + Vector3.new(math.cos(a) * R, -2.9, math.sin(a) * R)
                    end)
                end
            elseif style == "Gyro" then
                local rings = {
                    function(t) return CFrame.Angles(t * 0.6, 0, math.rad(25)) end,
                    function(t) return CFrame.Angles(math.rad(70), t * 0.8, 0) end,
                    function(t) return CFrame.Angles(0, t * 0.5, math.rad(-60)) end,
                }
                for k, rf in ipairs(rings) do
                    for j = 0, 1 do
                        addOrb(0.28, 1.0, 0.45, function(t, rp)
                            local R, V = Settings.NovaAuraSize, Settings.NovaAuraSpeed
                            local a = t * V * 2.4 * (k % 2 == 0 and -1 or 1) + j * math.pi
                            local v = Vector3.new(math.cos(a) * R, 0, math.sin(a) * R)
                            return rp + rf(t * V):VectorToWorldSpace(v)
                        end)
                    end
                end
            else -- Flames
                addEmitter(anchor, {
                    Texture = "rbxasset://textures/particles/fire_main.dds", Rate = 55, Lifetime = NumberRange.new(0.6, 1.1),
                    Speed = NumberRange.new(2, 4), SpreadAngle = Vector2.new(25, 25), EmissionDirection = Enum.NormalId.Top,
                    LightEmission = 1, Acceleration = Vector3.new(0, 3, 0),
                    Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.8), NumberSequenceKeypoint.new(1, 0) }),
                    Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) }),
                })
                for i = 0, 3 do
                    addOrb(0.3, 1.3, 0.6, function(t, rp)
                        local R, V = Settings.NovaAuraSize, Settings.NovaAuraSpeed
                        local a = t * V * 2.6 + i * TAU / 4
                        return rp + Vector3.new(math.cos(a) * R, -2.6 + math.sin(t * 3 + i) * 0.3, math.sin(a) * R)
                    end)
                end
            end
        end

        -- same colour rule as NOVA: rainbow hue, second colour shifted; a named colour and its lerp to white
        local function colorsAt(t)
            if Settings.NovaAuraColor == "rainbow" then
                return Color3.fromHSV((t * 0.2) % 1, 0.7, 1), Color3.fromHSV((t * 0.2 + 0.25) % 1, 0.7, 1)
            end
            local c1 = (ST.fxColor and ST.fxColor(Settings.NovaAuraColor)) or Color3.new(1, 1, 1)
            return c1, c1:Lerp(Color3.new(1, 1, 1), 0.5)
        end

        local function update()
            if not running then return end
            local char = Settings.NovaAura and realChar() or nil
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not (hum and hum.Health > 0 and hrp and hrp:IsA("BasePart")) then
                if anchor or #orbs > 0 then clear() end
                return
            end
            local style = Settings.NovaAuraStyle
            if style ~= "Halo" and style ~= "Gyro" and style ~= "Flames" then style = "Cosmic" end
            if state.hrp ~= hrp or state.style ~= style or not anchor or not anchor.Parent then
                clear()
                build(hrp, style)
                state.hrp, state.style = hrp, style
            end
            local t = os.clock()
            local rp = hrp.Position
            local c1, c2 = colorsAt(t)
            local seq = ColorSequence.new(c1, c2)
            anchor.CFrame = CFrame.new(rp)
            for _, o in ipairs(orbs) do
                o.part.CFrame = CFrame.new(o.fn(t, rp))
                o.part.Color = c1
                o.trail.Color = seq
            end
            for _, e in ipairs(emitters) do e.Color = seq end
        end

        local function stop()
            clear()
            if container then pcall(function() container:Destroy() end) end
            container = nil
        end

        connect(RunService.RenderStepped, function() pcall(update) end)
        return { stop = stop }
    end
    ST.novaAura = setupNovaAura()
end)()

-- ============ skin changer (knife and gun skins from the shitaro list; client side) ============
-- own page (skins) and own settings (SkinChanger, SkinKnife, SkinGun, SkinHolster).
-- in hand: the skin is welded to the held Handle, the stock tool parts are hidden (not removed); tool grip, icon, sounds and anims follow the skin.
-- holster: the gun skin sits on the back and the knife skin on the belt while that weapon is not in hand.
-- MeshPart size: rendered size = native * Size / MeshSize, so a MeshPart is sized only once the engine has read its mesh (makeMesh).
-- showcase fire is not copied onto the held weapon. nothing is sent to the server.
;(function()
    local SKIN_BLOB = [==[[{"s":"101086719|101086650||","k":"Gun","nm":"Sugar","m":["Sugar","Godly","2015","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.7686,0.1569,0.1098],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1,1.9],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[-1,0,0],"CFrame":[-0.1,0.2823,0.3072,-1,0,0,0,-0.0871,-0.9962,0,-0.9962,0.0871],"SecondaryAxis":[0,-0.0871,-0.9962]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://101086719","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.5,0.5,0.5],"TextureId":"rbxassetid://101086650","VertexColor":[1,1,1]}]]}},{"s":"103838505|103838996||","k":"Knife","nm":"Nightblade","m":["Nightblade","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.3882,0.3725,0.3843],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,3.1,0.6],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,-0.003,0.0025],"CFrame":[0.0061,0.151,0.0465,1,0.0028,-0.0027,-0.003,0.9962,-0.0871,0.0025,0.0871,0.9962],"SecondaryAxis":[0.0028,0.9962,0.0871]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://103838505","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.7,0.45,0.5],"TextureId":"rbxassetid://103838996","VertexColor":[0.4,0.4,0.4]}]]}},{"s":"105329941|105978218||","k":"Knife","nm":"Chill","m":["Chill","Godly","2015","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0,0.1255,0.3765],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,2.9,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://105329941","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.5,0.5,0.5],"TextureId":"rbxassetid://105978218","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"105333894|105334003||","k":"Knife","nm":"Heat","m":["Heat","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.7686,0.1569,0.1098],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,2.9,0.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://105333894","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.3,0.3,0.3],"TextureId":"rbxassetid://105334003","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1.2,0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://3187444758","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"108253816085047|116621225933096||","k":"Gun","nm":"Flora","m":["Flora","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.5608,0.1333,0.1333],"DoubleSided":true,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://108253816085047","MeshSize":[12.8883,34.2864,50],"Reflectance":0,"Size":[0.5891,1.5671,2.2852],"TextureID":"rbxassetid://116621225933096","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.2,0.0899,1,0,0,0,0.6428,0.7661,0,-0.7661,0.6428],"SecondaryAxis":[0,0.6428,-0.7661]}]]}},{"s":"11158364935|11274360089||","k":"Gun","nm":"Makeshift","m":["Makeshift","Godly","2022","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://11158364935","MeshSize":[10.7692,22.8857,50],"Reflectance":0,"Size":[0.5883,1.25,2.7314],"TextureID":"rbxassetid://11274360089","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.2,0.0899,1,0,0,0,0.6428,0.7661,0,-0.7661,0.6428],"SecondaryAxis":[0,0.6428,-0.7661]}]]}},{"s":"11165536294|11165715120||","k":"Gun","nm":"Spectre2022","m":["Spectre","Godly","2022","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://11165536294","MeshSize":[6.3998,18.7847,50],"Reflectance":0,"Size":[0.3326,0.9761,2.5981],"TextureID":"rbxassetid://11165715120","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}]]}},{"s":"11182796403|11192090515||","k":"Knife","nm":"ZombieBat","m":["Bat","Godly","2022","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://11182796403","MeshSize":[10.5566,50,10.5805],"Reflectance":0,"Size":[0.782,3.7031,0.7837],"TextureID":"rbxassetid://11192090515","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"11238166013|11238176757||","k":"Knife","nm":"ElderwoodKnife","m":["Elderwood Blade","Godly","2022","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://11238166013","MeshSize":[3.9042,50,14.741],"Reflectance":0,"Size":[0.2757,3.5313,1.041],"TextureID":"rbxassetid://11238176757","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"11238166013|11254938322|11254962088|","k":"Knife","nm":"ElderwoodKnifeChroma","m":["Elderwood Blade","Godly","2022","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.276,3.531,1.041],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Decal","Chroma","",{"Color3":[1,0,0.1675],"Face":"Enum.NormalId.Right","Texture":"rbxassetid://11254962088","Transparency":0,"ZIndex":1}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://11238166013","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.07,0.07,0.07],"TextureId":"rbxassetid://11254938322","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"116657254|445884341||","k":"Gun","nm":"Amerilaser","m":["Amerilaser","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.6,1,1.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Sound","Charge","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":0.65,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://93186995","TimeLength":1.2137,"Volume":1}],["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.1,-0.2703,0.2438,1,0,0,0,0.2079,0.9782,0,-0.9782,0.2079],"SecondaryAxis":[0,0.2079,-0.9782]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://116657254","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.7,0.7,0.7],"TextureId":"rbxassetid://445884341","VertexColor":[1,1,1]}],["Sound","Shoot","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":0.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://106018135","TimeLength":1.7445,"Volume":1}]]}},{"s":"117500241|117500388||","k":"Knife","nm":"Fang","m":["Fang","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.3882,0.3725,0.3843],"Massless":true,"Material":"Enum.Material.Concrete","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.94,3.09,0.75],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[-0.0396,0.0177,0.9991],"CFrame":[0,0,0,-0.0396,-0.0005,-0.9992,0.0177,0.9998,-0.0012,0.9991,-0.0177,-0.0396],"SecondaryAxis":[-0.0005,0.9998,-0.0177]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://117500241","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.4,0.37,0.37],"TextureId":"rbxassetid://117500388","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"11868991644|11869075814||","k":"Gun","nm":"Icepiercer","m":["Icepiercer","Ancient","2022","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://11868991644","MeshSize":[45.089,13.7425,50],"Reflectance":0,"Size":[2.4694,0.7526,2.7384],"TextureID":"rbxassetid://11869075814","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Sound","AltSound","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.4,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://7808472682","TimeLength":1.1823,"Volume":1}],["Attachment","CustomAttachment","",{"Axis":[0,1,-0.0001],"CFrame":[0.1299,0,0.075,0,-0.5,-0.866,1,0,0,-0.0001,-0.866,0.5],"SecondaryAxis":[-0.5,0,-0.866]}]]}},{"s":"121944778|1133317743||","k":"Knife","nm":"MagmaK","m":["Magma","Rare","2017","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Fire","Fire","",{"Color":[0.9255,0.5451,0.2745],"Enabled":true,"Heat":7,"SecondaryColor":[0.5451,0.3137,0.2157],"Size":2}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://1133317743","VertexColor":[1,1,1]}]]}},{"s":"121944778|121944805||","k":"Knife","nm":"DefaultKnife","m":["Default Knife","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://121944805","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://584555920","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"121944778|157019835||","k":"Knife","nm":"Rainbow","m":["Rainbow","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://157019835","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"121944778|159546779||","k":"Knife","nm":"8bit","m":["8bit","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Fire","Fire","",{"Color":[0.9255,0.5451,0.2745],"Enabled":true,"Heat":7,"SecondaryColor":[0.5451,0.3137,0.2157],"Size":2}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://159546779","VertexColor":[1,1,1]}]]}},{"s":"121944778|161369273||","k":"Knife","nm":"Plasmite","m":["Plasmite","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://161369273","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"121944778|161495171||","k":"Knife","nm":"Clan","m":["Clan","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://161495171","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.2588,0.2902,0.4431],"t":0},{"c":[0.2588,0.2902,0.4431],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0.2}],["ParticleEmitter","bigstar","",{"Acceleration":[0,0,0],"Brightness":7.825,"Color":[{"c":[0.6118,0.9686,1],"t":0},{"c":[0.6118,0.9686,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.125}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://129877481098887","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","frontsmoke","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0824,0.0118,0.1765],"t":0},{"c":[0.0824,0.0118,0.1765],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[8.7,8.7],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,2],"LightEmission":0,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.9375},{"t":1,"v":1.25}],"Speed":[0,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://18888997125","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.193,"v":0.7188},{"t":0.5355,"v":0.6187},{"t":0.8481,"v":0.7625},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","megastar","",{"Acceleration":[0,0,0],"Brightness":3.625,"Color":[{"c":[0.6549,0.7922,1],"t":0},{"c":[0.6549,0.7922,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.4,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.3},{"t":1,"v":0.3}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.075,"t":0,"v":2.025},{"e":0.075,"t":0.0884,"v":-0.3},{"e":0.1125,"t":0.1743,"v":0.15},{"e":0.1125,"t":0.345,"v":-0.1125},{"t":1,"v":0.15}],"Texture":"rbxassetid://128498931653047","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.1694,"v":0.275},{"t":0.1968,"v":0.5187},{"t":0.2403,"v":0.225},{"t":0.3076,"v":0.3875},{"t":0.3587,"v":0.2937},{"t":0.3998,"v":0.525},{"t":0.4483,"v":0.425},{"t":0.4969,"v":0.4375},{"t":0.594,"v":0.625},{"t":0.6301,"v":0.5125},{"t":0.6663,"v":0.575},{"t":0.6999,"v":0.4},{"t":0.7609,"v":0.275},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","outersmoke","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0824,0.0118,0.1765],"t":0},{"c":[0.0824,0.0118,0.1765],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[8.7,8.7],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,2],"LightEmission":0,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":1.5},{"t":1,"v":2.125}],"Speed":[0,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://18888997125","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.1955,"v":0.8125},{"t":0.5367,"v":0.7312},{"t":0.863,"v":0.875},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","smoke","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0471,0.0157,0.1176],"t":0},{"c":[0.0471,0.0157,0.1176],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[8.7,8.7],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,2],"LightEmission":0,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.9375},{"t":1,"v":1.25}],"Speed":[0,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://18888997125","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.1905,"v":0.6625},{"t":0.5293,"v":0.6062},{"t":0.8518,"v":0.7812},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","stars1blue","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.6824,0.9569,1],"t":0},{"c":[0.6824,0.9569,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.05,"RotSpeed":[-1,1],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","stars1blue","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.6824,0.9569,1],"t":0},{"c":[0.6824,0.9569,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.6,"RotSpeed":[-3,3],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0.1,0.3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.1955,"v":0.5688},{"t":0.2466,"v":0},{"t":0.3599,"v":0.4563},{"t":0.4421,"v":0},{"t":0.5791,"v":0.3125},{"t":0.7111,"v":0},{"t":0.8032,"v":0.25},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","stars1whit","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.9608,1,0.8235],"t":0},{"c":[0.9608,1,0.8235],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.6,"RotSpeed":[-3,3],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0.1,0.3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.1955,"v":0.5688},{"t":0.2466,"v":0},{"t":0.3599,"v":0.4563},{"t":0.4421,"v":0},{"t":0.5791,"v":0.3125},{"t":0.7111,"v":0},{"t":0.8032,"v":0.25},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","stars1whit","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.9608,1,0.8235],"t":0},{"c":[0.9608,1,0.8235],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.05,"RotSpeed":[-1,1],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]}},{"s":"121944778|191784815||","k":"Knife","nm":"Whiteout","m":["Whiteout","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://191784815","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://191788694","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"121944778|192367012||","k":"Knife","nm":"Galaxy","m":["Galaxy","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://192367012","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"121944778|192482160||","k":"Knife","nm":"Adurite","m":["Adurite","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://192482160","VertexColor":[1,1,1]}]]}},{"s":"121944778|192527236||","k":"Knife","nm":"Love","m":["Love","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://192527236","VertexColor":[1,1,1]}]]}},{"s":"121944778|199611278||","k":"Knife","nm":"PredatorKnife","m":["Predator","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://199611278","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://235372015","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"121944778|241077941||","k":"Knife","nm":"Elite","m":["Elite","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://241077941","VertexColor":[1,1,1]}]]}},{"s":"121944778|314921929||","k":"Knife","nm":"Hive","m":["Hive","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://314921929","VertexColor":[1,1,1]}]]}},{"s":"121944778|3183401534||","k":"Knife","nm":"Copper","m":["Copper","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://3183401534","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0.2,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,50],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.6125},{"t":0.0797,"v":-0.3},{"t":0.1295,"v":0.2625},{"t":0.2354,"v":-0.3375},{"t":0.3811,"v":-0.0375},{"t":0.9303,"v":-0.075},{"t":0.9701,"v":-0.4125},{"t":0.9963,"v":1.725},{"t":1,"v":1.8}],"Texture":"rbxassetid://103186751172617","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0.2}],["ParticleEmitter","b","",{"Acceleration":[0,0.4,0],"Brightness":1,"Color":[{"c":[0.4392,0.4392,0.4392],"t":0},{"c":[0.4392,0.4392,0.4392],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":7,"RotSpeed":[-20,20],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":0.6875}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.075},{"t":0.0286,"v":-0.225},{"t":0.0697,"v":0},{"t":0.1507,"v":-0.075},{"t":0.3786,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://11238241427","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0773,"v":0.3438},{"t":0.207,"v":0},{"t":0.2594,"v":0},{"t":0.3067,"v":0},{"t":0.5162,"v":0.525},{"t":0.6334,"v":0.85},{"t":0.7569,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.2}]]}},{"s":"121944778|3183403069||","k":"Knife","nm":"CamoKnife","m":["Camo","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://3183403069","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://3183606225","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"121944778|3183403283||","k":"Knife","nm":"Tiger","m":["Tiger","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://3183403283","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"121944778|3183404423||","k":"Knife","nm":"Rune","m":["Rune","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://3183404423","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"121944778|365566400||","k":"Knife","nm":"Lucky","m":["Lucky","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://365566400","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"121944778|473621136||","k":"Knife","nm":"Snoop","m":["Red","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://473621136","VertexColor":[1,1,1]}]]}},{"s":"121944778|473621267||","k":"Knife","nm":"Dew","m":["Black","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://473621267","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1.5,2],"LightEmission":0,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.5},{"t":1,"v":0.5}],"Speed":[3,3],"SpreadAngle":[10,10],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://346658692","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":1,"v":0}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://473626646","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"121944778|473623765||","k":"Knife","nm":"MLG","m":["Shiny","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://121944778","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://473623765","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"12921221200|12921231088||","k":"Gun","nm":"Rainbow_G","m":["Rainbow Gun","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://12921221200","MeshSize":[8.2578,23.5079,50],"Reflectance":0,"Size":[0.4284,1.2199,2.5946],"TextureID":"rbxassetid://12921231088","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.2,0.0899,1,0,0,0,0.6428,0.7661,0,-0.7661,0.6428],"SecondaryAxis":[0,0.6428,-0.7661]}]]}},{"s":"12921240966|12921241867||","k":"Knife","nm":"Rainbow_K","m":["Rainbow","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://12921240966","MeshSize":[4.0081,50,15.4691],"Reflectance":0,"Size":[0.2614,3.2611,1.0089],"TextureID":"rbxassetid://12921241867","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"135790480817772|nil||","k":"Gun","nm":"Treat","m":["Treat","Godly","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://135790480817772","MeshSize":[8.3216,24.9434,35.2414],"Reflectance":0,"Size":[0.4485,1.3444,1.8995],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.2,0.0899,1,0,0,0,0.6428,0.7661,0,-0.7661,0.6428],"SecondaryAxis":[0,0.6428,-0.7661]}],["SurfaceAppearance","SurfaceAppearance","",{"AlphaMode":"Enum.AlphaMode.Overlay","ColorMap":"rbxassetid://108067764674565"}]]}},{"s":"136619680236977|113651973865393||","k":"Knife","nm":"XenoKnife","m":["Xenoknife","Godly","2025","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://136619680236977","MeshSize":[2.6041,50,9.4802],"Reflectance":0,"Size":[0.2041,3.9191,0.7431],"TextureID":"rbxassetid://113651973865393","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.2588,0.2902,0.4431],"t":0},{"c":[0.2588,0.2902,0.4431],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0.2}],["ParticleEmitter","bigstar","",{"Acceleration":[0,0,0],"Brightness":7.825,"Color":[{"c":[0.6118,0.9686,1],"t":0},{"c":[0.6118,0.9686,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.125}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://129877481098887","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","frontsmoke","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0824,0.0118,0.1765],"t":0},{"c":[0.0824,0.0118,0.1765],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[8.7,8.7],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,2],"LightEmission":0,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.9375},{"t":1,"v":1.25}],"Speed":[0,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://18888997125","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.193,"v":0.7188},{"t":0.5355,"v":0.6187},{"t":0.8481,"v":0.7625},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","megastar","",{"Acceleration":[0,0,0],"Brightness":3.625,"Color":[{"c":[0.6549,0.7922,1],"t":0},{"c":[0.6549,0.7922,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.4,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.3},{"t":1,"v":0.3}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.075,"t":0,"v":2.025},{"e":0.075,"t":0.0884,"v":-0.3},{"e":0.1125,"t":0.1743,"v":0.15},{"e":0.1125,"t":0.345,"v":-0.1125},{"t":1,"v":0.15}],"Texture":"rbxassetid://128498931653047","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.1694,"v":0.275},{"t":0.1968,"v":0.5187},{"t":0.2403,"v":0.225},{"t":0.3076,"v":0.3875},{"t":0.3587,"v":0.2937},{"t":0.3998,"v":0.525},{"t":0.4483,"v":0.425},{"t":0.4969,"v":0.4375},{"t":0.594,"v":0.625},{"t":0.6301,"v":0.5125},{"t":0.6663,"v":0.575},{"t":0.6999,"v":0.4},{"t":0.7609,"v":0.275},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","outersmoke","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0824,0.0118,0.1765],"t":0},{"c":[0.0824,0.0118,0.1765],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[8.7,8.7],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,2],"LightEmission":0,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":1.5},{"t":1,"v":2.125}],"Speed":[0,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://18888997125","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.1955,"v":0.8125},{"t":0.5367,"v":0.7312},{"t":0.863,"v":0.875},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","smoke","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0471,0.0157,0.1176],"t":0},{"c":[0.0471,0.0157,0.1176],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[8.7,8.7],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,2],"LightEmission":0,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.9375},{"t":1,"v":1.25}],"Speed":[0,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://18888997125","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.1905,"v":0.6625},{"t":0.5293,"v":0.6062},{"t":0.8518,"v":0.7812},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","stars1blue","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.6824,0.9569,1],"t":0},{"c":[0.6824,0.9569,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.05,"RotSpeed":[-1,1],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","stars1blue","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.6824,0.9569,1],"t":0},{"c":[0.6824,0.9569,1],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.6,"RotSpeed":[-3,3],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0.1,0.3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.1955,"v":0.5688},{"t":0.2466,"v":0},{"t":0.3599,"v":0.4563},{"t":0.4421,"v":0},{"t":0.5791,"v":0.3125},{"t":0.7111,"v":0},{"t":0.8032,"v":0.25},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","stars1whit","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.9608,1,0.8235],"t":0},{"c":[0.9608,1,0.8235],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.05,"RotSpeed":[-1,1],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","stars1whit","",{"Acceleration":[0,0,0],"Brightness":4.785,"Color":[{"c":[0.9608,1,0.8235],"t":0},{"c":[0.9608,1,0.8235],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.6,"RotSpeed":[-3,3],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.7},{"e":0.125,"t":1,"v":0.7}],"Speed":[0.1,0.3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://113890997280910","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.1955,"v":0.5688},{"t":0.2466,"v":0},{"t":0.3599,"v":0.4563},{"t":0.4421,"v":0},{"t":0.5791,"v":0.3125},{"t":0.7111,"v":0},{"t":0.8032,"v":0.25},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}]]}},{"s":"13916938702|13916939964||","k":"Knife","nm":"Waves_K","m":["Waves","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://13916938702","MeshSize":[3.843,50,15.9656],"Reflectance":0,"Size":[0.3045,3.962,1.2656],"TextureID":"rbxassetid://13916939964","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","b","",{"Acceleration":[0,0,0],"Brightness":1.985,"Color":[{"c":[0.2784,0.0275,0.4588],"t":0},{"c":[0.2784,0.0275,0.4588],"t":1}],"Drag":10,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":20,"RotSpeed":[-10,10],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.25},{"t":0.7581,"v":1.5},{"t":1,"v":2.375}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1538950131","TimeScale":0.4,"Transparency":[{"t":0,"v":1},{"t":0.042,"v":0.5875},{"t":0.1068,"v":0},{"t":0.2514,"v":0},{"t":0.3835,"v":0.2125},{"t":0.5396,"v":1},{"t":0.6992,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-2}],["ParticleEmitter","b","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0,0,0],"t":0},{"c":[0,0,0],"t":1}],"Drag":10,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,5],"LightEmission":0,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":12,"RotSpeed":[-10,10],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.25},{"t":0.7556,"v":1.125},{"t":1,"v":1.25}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1538950131","TimeScale":0.4,"Transparency":[{"t":0,"v":1},{"t":0.042,"v":0.5875},{"t":0.1068,"v":0},{"t":0.2514,"v":0},{"t":0.3835,"v":0.2125},{"t":0.5396,"v":1},{"t":0.6992,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","c","",{"Acceleration":[0,1,0],"Brightness":1.21,"Color":[{"c":[0.8157,0.349,0.9686],"t":0},{"c":[0.8157,0.349,0.9686],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,3],"LightEmission":0.95,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":25,"RotSpeed":[-200,200],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.0625},{"t":1,"v":0.0625}],"Speed":[1,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0769,"v":0.7688},{"t":0.1986,"v":0.0312},{"t":0.2893,"v":0.9937},{"t":0.4041,"v":1},{"t":0.5878,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]}},{"s":"156092238|156092253||","k":"Knife","nm":"TheSeer","m":["Seer","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.5,3.1,1],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://156092238","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.7,0.91,1],"TextureId":"rbxassetid://156092253","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.061,-1,0.2,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://3184139765","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"156092238|3184063317||","k":"Knife","nm":"PurpleSeer","m":["Purple Seer","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.5,3.1,1],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://156092238","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.7,0.91,1],"TextureId":"rbxassetid://3184063317","VertexColor":[1,1,1]}]]}},{"s":"156092238|3184063623||","k":"Knife","nm":"YellowSeer","m":["Yellow Seer","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.5,3.1,1],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://156092238","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.7,0.91,1],"TextureId":"rbxassetid://3184063623","VertexColor":[1,1,1]}],["ParticleEmitter","candy","",{"Acceleration":[0,-1,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.5],"LightEmission":0.3,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":4.04,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.5,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.975},{"t":0.0736,"v":-0.4125},{"t":0.1471,"v":0.225},{"t":0.3466,"v":-0.15},{"t":0.6995,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://120133907443226","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.1035,"v":0},{"t":0.4396,"v":0},{"t":0.7073,"v":0.3187},{"t":0.8219,"v":0.6125},{"t":0.9016,"v":1},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":0}],["ParticleEmitter","candy","",{"Acceleration":[0,-1,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.5],"LightEmission":0.3,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.5,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.975},{"t":0.0736,"v":-0.4125},{"t":0.1471,"v":0.225},{"t":0.3466,"v":-0.15},{"t":0.6995,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://120133907443226","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.1035,"v":0},{"t":0.4396,"v":0},{"t":0.7073,"v":0.3187},{"t":0.8219,"v":0.6125},{"t":0.9016,"v":1},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.061,-1,0.2,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://3184139648","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"1626714161|3183577898|3183578044|","k":"Knife","nm":"GemstoneChroma","m":["Gemstone","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3.15,0.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Decal","Chroma","",{"Color3":[0.5615,1,0],"Face":"Enum.NormalId.Left","Texture":"rbxassetid://3183578044","Transparency":0,"ZIndex":1}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://1626714161","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[25,25,25],"TextureId":"rbxassetid://3183577898","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0.2,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,50],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.6125},{"t":0.0797,"v":-0.3},{"t":0.1295,"v":0.2625},{"t":0.2354,"v":-0.3375},{"t":0.3811,"v":-0.0375},{"t":0.9303,"v":-0.075},{"t":0.9701,"v":-0.4125},{"t":0.9963,"v":1.725},{"t":1,"v":1.8}],"Texture":"rbxassetid://103186751172617","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0.2}],["ParticleEmitter","b","",{"Acceleration":[0,0.4,0],"Brightness":1,"Color":[{"c":[0.4392,0.4392,0.4392],"t":0},{"c":[0.4392,0.4392,0.4392],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":7,"RotSpeed":[-20,20],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":0.6875}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.075},{"t":0.0286,"v":-0.225},{"t":0.0697,"v":0},{"t":0.1507,"v":-0.075},{"t":0.3786,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://11238241427","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0773,"v":0.3438},{"t":0.207,"v":0},{"t":0.2594,"v":0},{"t":0.3067,"v":0},{"t":0.5162,"v":0.525},{"t":0.6334,"v":0.85},{"t":0.7569,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.2}]]}},{"s":"1626714161|3183579677||","k":"Knife","nm":"Gemstone","m":["Gemstone","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3.15,0.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://1626714161","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[25,25,25],"TextureId":"rbxassetid://3183579677","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"179155055|1132750758||","k":"Knife","nm":"HallowsBlade","m":["Hallow's Blade","Godly","2017","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://179155055","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.55,0.55,0.555],"TextureId":"rbxassetid://1132750758","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"18276861801|18276866373||","k":"Knife","nm":"Pearl_K","m":["Pearl","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://18276861801","MeshSize":[3.1571,50,11.5845],"Reflectance":0,"Size":[0.2201,3.486,0.8077],"TextureID":"rbxassetid://18276866373","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"19040337|19040326||","k":"Knife","nm":"Candy","m":["Candy","Godly","2015","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.8039,0.8039,0.8039],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.6],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://19040337","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.1,1.4,1.1],"TextureId":"rbxassetid://19040326","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0.2,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,50],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.6125},{"t":0.0797,"v":-0.3},{"t":0.1295,"v":0.2625},{"t":0.2354,"v":-0.3375},{"t":0.3811,"v":-0.0375},{"t":0.9303,"v":-0.075},{"t":0.9701,"v":-0.4125},{"t":0.9963,"v":1.725},{"t":1,"v":1.8}],"Texture":"rbxassetid://103186751172617","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0.2}],["ParticleEmitter","b","",{"Acceleration":[0,0.4,0],"Brightness":1,"Color":[{"c":[0.4392,0.4392,0.4392],"t":0},{"c":[0.4392,0.4392,0.4392],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":7,"RotSpeed":[-20,20],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":0.6875}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.075},{"t":0.0286,"v":-0.225},{"t":0.0697,"v":0},{"t":0.1507,"v":-0.075},{"t":0.3786,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://11238241427","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0773,"v":0.3438},{"t":0.207,"v":0},{"t":0.2594,"v":0},{"t":0.3067,"v":0},{"t":0.5162,"v":0.525},{"t":0.6334,"v":0.85},{"t":0.7569,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.2}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.0771,0.7943,0,0,0,1,-0.0419,-0.9991,0,0.9991,-0.0419,0],"RequiresHandle":true,"TextureId":"rbxassetid://332021011","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"2397016406|2513526862||","k":"Knife","nm":"BattleAxe2","m":["BattleAxe II","Godly","2018","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://2397016406","MeshSize":[0.5149,4.9688,2.2701],"Reflectance":0,"Size":[0.3788,3.6555,1.6701],"TextureID":"rbxassetid://2513526862","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["Attachment","RightGripAttachment","",{"Axis":[1,0,0],"CFrame":[0,-1.2154,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1.0273,0,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://2513535503","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"262027449|445805934||","k":"Knife","nm":"AmericaSword","m":["Old Glory","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.25,0.6,3.05],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0.9992,-0.0404,0.0042],"CFrame":[0.0177,0.0807,-0.1248,0.9992,0.0077,0.0399,-0.0404,0.0867,0.9954,0.0042,-0.9962,0.087],"SecondaryAxis":[0.0077,0.0867,-0.9962]}],["Sound","Explosion","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://12221984","TimeLength":1,"Volume":1}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://262027449","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.6,0.6,0.6],"TextureId":"rbxassetid://445805934","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["Sound","Slash","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.69,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://12222216","TimeLength":0.5622,"Volume":1}],["Sound","Unsheath","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.25,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://12222225","TimeLength":0.6531,"Volume":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.0548,0.1796,1.2459,1,0,0,0,0,1,0,-1,0],"RequiresHandle":true,"TextureId":"rbxassetid://446047742","ToolTip":""},"n":[["Sound","Explosion","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://12221984","TimeLength":1,"Volume":1}],["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Sound","Slash","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.69,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://12222216","TimeLength":0.5622,"Volume":1}],["Sound","Unsheath","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.25,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://12222225","TimeLength":0.6531,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"283709822|3171107559|3171107715|","k":"Knife","nm":"SlasherChroma","m":["Slasher","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Decal","Chroma","",{"Color3":[0.9692,0,1],"Face":"Enum.NormalId.Back","Texture":"rbxassetid://3171107715","Transparency":0,"ZIndex":1}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://283709822","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.45,0.45,0.45],"TextureId":"rbxassetid://3171107559","VertexColor":[1,1,1]}]]}},{"s":"305826272|2511673515||","k":"Knife","nm":"Scythe","m":["Batwing","Ancient","2018","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.25,2.9,1.6],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://305826272","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://2511673515","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"3132923779|4488374804||","k":"Knife","nm":"EternalCane","m":["Eternalcane","Godly","2019","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3.15,0.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Fire","Fire","",{"Color":[0.9255,0.5451,0.2745],"Enabled":true,"Heat":7,"SecondaryColor":[0.5451,0.3137,0.2157],"Size":2}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://3132923779","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.95,0.95,0.95],"TextureId":"rbxassetid://4488374804","VertexColor":[1,1,1]}]]}},{"s":"3183449780|2279588369||","k":"Knife","nm":"Icewing","m":["Icewing","Ancient","2018","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,4.05,1.8],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[-0.9998,0.0204,-0.0076],"CFrame":[0.0031,-0.0095,0.2059,-0.9998,0.0167,0.0139,0.0204,0.9442,0.3288,-0.0076,0.329,-0.9443],"SecondaryAxis":[0.0167,0.9442,0.329]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://3183449780","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.085,0.085,0.085],"TextureId":"rbxassetid://2279588369","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1.5,2],"LightEmission":0,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.5},{"t":1,"v":0.5}],"Speed":[3,3],"SpreadAngle":[10,10],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://346658692","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":1,"v":0}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"4210029922|4210038158||","k":"Gun","nm":"ElderwoodGun","m":["Elderwood Revolver","Godly","2019","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://4210029922","MeshSize":[50,37.9881,12.0369],"Reflectance":0,"Size":[1.49,1.132,0.3587],"TextureID":"rbxassetid://4210038158","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,1],"CFrame":[-0.2299,0.0982,0.1,0,0.9848,-0.1736,0,0.1736,0.9848,1,0,0],"SecondaryAxis":[0.9848,0.1736,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[-0.6329,-0.2355,0,0,0,-1,0,1,0,1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://4468571736","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":0,"Volume":1}]]}},{"s":"4217523241|4210044808||","k":"Knife","nm":"ElderwoodScythe","m":["Elderwood Scythe","Ancient","2019","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://4217523241","MeshSize":[3.769,50,34.2153],"Reflectance":0,"Size":[0.2881,3.8218,2.6153],"TextureID":"rbxassetid://4210044808","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0.999,0.04,0.0201],"CFrame":[0.1016,0.1596,0.1561,0.999,-0.0298,-0.0334,0.04,0.9293,0.3673,0.0201,-0.3682,0.9295],"SecondaryAxis":[-0.0298,0.9293,-0.3682]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.0798,-0.919,0.5779,1,0,0,0,0.9948,0.1022,0,-0.1022,0.9948],"RequiresHandle":true,"TextureId":"rbxassetid://4468593654","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"4217554208|4210531490||","k":"Knife","nm":"Ghostblade","m":["Ghostblade","Godly","2019","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://4217554208","MeshSize":[6.6274,50,11.7548],"Reflectance":0,"Size":[0.3543,2.6727,0.6283],"TextureID":"rbxassetid://4210531490","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":7.115,"Color":[{"c":[0,0.9843,1],"t":0},{"c":[0,0.9843,1],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.7,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[3,3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.0884,"v":1},{"t":0.1883,"v":0.7437},{"t":0.2629,"v":0.55},{"t":0.3341,"v":0.3812},{"t":0.4879,"v":0.0687},{"t":0.6762,"v":0.075},{"t":0.8002,"v":0.2},{"t":0.899,"v":0.4187},{"t":0.9575,"v":0.6125},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":7.115,"Color":[{"c":[0.9176,0,1],"t":0},{"c":[0.9176,0,1],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.7,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[3,3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.0884,"v":1},{"t":0.1883,"v":0.7437},{"t":0.2629,"v":0.55},{"t":0.3341,"v":0.3812},{"t":0.4879,"v":0.0687},{"t":0.6762,"v":0.075},{"t":0.8002,"v":0.2},{"t":0.899,"v":0.4187},{"t":0.9575,"v":0.6125},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":7.115,"Color":[{"c":[0.2667,1,0],"t":0},{"c":[0.2667,1,0],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.7,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[3,3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.0884,"v":1},{"t":0.1883,"v":0.7437},{"t":0.2629,"v":0.55},{"t":0.3341,"v":0.3812},{"t":0.4879,"v":0.0687},{"t":0.6762,"v":0.075},{"t":0.8002,"v":0.2},{"t":0.899,"v":0.4187},{"t":0.9575,"v":0.6125},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":7.115,"Color":[{"c":[1,0.251,0],"t":0},{"c":[1,0.251,0],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.7,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[3,3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.0884,"v":1},{"t":0.1883,"v":0.7437},{"t":0.2629,"v":0.55},{"t":0.3341,"v":0.3812},{"t":0.4879,"v":0.0687},{"t":0.6762,"v":0.075},{"t":0.8002,"v":0.2},{"t":0.899,"v":0.4187},{"t":0.9575,"v":0.6125},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","g2","",{"Acceleration":[0,0.1,0],"Brightness":0,"Color":[{"c":[0.7412,0.749,0.2078],"t":0},{"c":[0.7412,0.749,0.2078],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[30,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.PingPong","FlipbookStartRandom":false,"Lifetime":[3,7.2],"LightEmission":1,"LightInfluence":1.02,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.33,"RotSpeed":[-10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4},{"t":1,"v":0.4}],"Speed":[2,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.1875},{"t":0.0536,"v":-0.2625},{"t":0.1372,"v":0.2625},{"t":0.4214,"v":-0.6},{"t":0.8167,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://18281837822","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0511,"v":0.2188},{"t":0.1247,"v":0},{"t":0.4938,"v":0},{"t":0.8192,"v":0.2188},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","g2","",{"Acceleration":[0,0.1,0],"Brightness":0,"Color":[{"c":[0.1961,0.749,0.1882],"t":0},{"c":[0.1961,0.749,0.1882],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.PingPong","FlipbookStartRandom":false,"Lifetime":[3,7.1],"LightEmission":1,"LightInfluence":1.02,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.15,"RotSpeed":[-10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4},{"t":1,"v":0.4}],"Speed":[2,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.1875},{"t":0.0536,"v":-0.2625},{"t":0.1372,"v":0.2625},{"t":0.4214,"v":-0.6},{"t":0.8167,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://18281837822","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0511,"v":0.2188},{"t":0.1247,"v":0},{"t":0.4938,"v":0},{"t":0.8192,"v":0.2188},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","g2","",{"Acceleration":[0,0.1,0],"Brightness":0,"Color":[{"c":[0.4941,0.1804,0.749],"t":0},{"c":[0.4941,0.1804,0.749],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.PingPong","FlipbookStartRandom":false,"Lifetime":[3,6.8],"LightEmission":1,"LightInfluence":1.02,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.35,"RotSpeed":[-10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4},{"t":1,"v":0.4}],"Speed":[2,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.1875},{"t":0.0536,"v":-0.2625},{"t":0.1372,"v":0.2625},{"t":0.4214,"v":-0.6},{"t":0.8167,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://18281837822","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0511,"v":0.2188},{"t":0.1247,"v":0},{"t":0.4938,"v":0},{"t":0.8192,"v":0.2188},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","g2","",{"Acceleration":[0,0.1,0],"Brightness":0,"Color":[{"c":[0.1647,0.749,0.651],"t":0},{"c":[0.1647,0.749,0.651],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.PingPong","FlipbookStartRandom":false,"Lifetime":[3,7.4],"LightEmission":1,"LightInfluence":1.02,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.3,"RotSpeed":[-10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4},{"t":1,"v":0.4}],"Speed":[2,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.1875},{"t":0.0536,"v":-0.2625},{"t":0.1372,"v":0.2625},{"t":0.4214,"v":-0.6},{"t":0.8167,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://18281837822","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0511,"v":0.2188},{"t":0.1247,"v":0},{"t":0.4938,"v":0},{"t":0.8192,"v":0.2188},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","g2","",{"Acceleration":[0,0.1,0],"Brightness":0,"Color":[{"c":[0.749,0.2039,0.1529],"t":0},{"c":[0.749,0.2039,0.1529],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.PingPong","FlipbookStartRandom":false,"Lifetime":[3,7.05],"LightEmission":1,"LightInfluence":1.02,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":0.25,"RotSpeed":[-10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4},{"t":1,"v":0.4}],"Speed":[2,2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.1875},{"t":0.0536,"v":-0.2625},{"t":0.1372,"v":0.2625},{"t":0.4214,"v":-0.6},{"t":0.8167,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://18281837822","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0511,"v":0.2188},{"t":0.1247,"v":0},{"t":0.4938,"v":0},{"t":0.8192,"v":0.2188},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]}},{"s":"4528435571|4528435630||","k":"Knife","nm":"Frostbite","m":["Frostbite","Godly","2019","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://4528435571","MeshSize":[0.194,2.6311,0.695],"Reflectance":0,"Size":[0.2219,3.0097,0.795],"TextureID":"rbxassetid://4528435630","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"4535643726|4535641077||","k":"Knife","nm":"Logchopper","m":["Logchopper","Ancient","2019","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://4535643726","MeshSize":[0.4855,3.3064,1.552],"Reflectance":0,"Size":[0.4855,3.3064,1.552],"TextureID":"rbxassetid://4535641077","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.0059,-0.8247,0.35,1,-0.0066,0.0066,0.0066,1,0,-0.0066,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://4528268775","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"4662600017|4751538400||","k":"Knife","nm":"Bioblade","m":["Bioblade","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://4662600017","MeshSize":[4.9786,50,16.4827],"Reflectance":0,"Size":[0.3106,3.421,1.0878],"TextureID":"rbxassetid://4751538400","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"4730813852|4728487789||","k":"Gun","nm":"Lightbringer","m":["Lightbringer","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://4730813852","MeshSize":[10.1226,41.246,50],"Reflectance":0,"Size":[0.3976,1.6201,1.9639],"TextureID":"rbxassetid://4728487789","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.1866,0.1232,1,0,0,0,0.1736,0.9848,0,-0.9848,0.1736],"SecondaryAxis":[0,0.1736,-0.9848]}]]}},{"s":"4730813852|4728494788|4751498862|","k":"Gun","nm":"ChromaDarkbringer","m":["Darkbringer","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.398,1.62,1.964],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Decal","Chroma","",{"Color3":[1,0.9719,0],"Face":"Enum.NormalId.Right","Texture":"rbxassetid://4751498862","Transparency":0,"ZIndex":1}],["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.1866,0.1232,1,0,0,0,0.1736,0.9848,0,-0.9848,0.1736],"SecondaryAxis":[0,0.1736,-0.9848]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://4730813852","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.039,0.039,0.039],"TextureId":"rbxassetid://4728494788","VertexColor":[1,1,1]}]]}},{"s":"4730813852|4728494788||","k":"Gun","nm":"Darkbringer","m":["Darkbringer","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://4730813852","MeshSize":[10.1226,41.246,50],"Reflectance":0,"Size":[0.3976,1.6201,1.9639],"TextureID":"rbxassetid://4728494788","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.1866,0.1232,1,0,0,0,0.1736,0.9848,0,-0.9848,0.1736],"SecondaryAxis":[0,0.1736,-0.9848]}]]}},{"s":"51682254|51941734||","k":"Knife","nm":"BloodKnife","m":["Blood","Classic","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"Massless":true,"Material":"Enum.Material.DiamondPlate","Reflectance":0.01,"Shape":"Enum.PartType.Block","Size":[0.6,0.4,2.4],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0.9978,-0.0657,-0.0066],"CFrame":[0.0034,-0.2037,0.2846,0.9978,0.0009,-0.066,-0.0657,-0.0862,-0.9941,-0.0066,0.9963,-0.0859],"SecondaryAxis":[0.0009,-0.0862,0.9963]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://51682254","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.5,0.5,0.3],"TextureId":"rbxassetid://51941734","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"5355753728|5355747943||","k":"Knife","nm":"Prismatic","m":["Prismatic","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://5355753728","MeshSize":[5.3792,50,17.8941],"Reflectance":0,"Size":[0.2199,3.2733,0.9641],"TextureID":"rbxassetid://5355747943","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}]]}},{"s":"5841866437|5841868338||","k":"Gun","nm":"Hallowgun","m":["Hallowgun","Godly","2020","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://5841866437","MeshSize":[50,26.468,9.116],"Reflectance":0,"Size":[2.04,1.0799,0.3719],"TextureID":"rbxassetid://5841868338","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,1],"CFrame":[-0.2249,0.0447,0,0,0.9962,-0.0872,0,0.0872,0.9962,1,0,0],"SecondaryAxis":[0.9962,0.0872,0]}]]}},{"s":"5841877975|5841879647||","k":"Knife","nm":"Hallowscythe","m":["Hallowscythe","Ancient","2020","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://5841877975","MeshSize":[5.5435,50,41.5425],"Reflectance":0,"Size":[0.3924,3.5416,2.9425],"TextureID":"rbxassetid://5841879647","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[-0.9987,0.0457,-0.0233],"CFrame":[0.0082,0.0546,0.6241,-0.9987,0.0469,0.0208,0.0457,0.9975,-0.0537,-0.0233,-0.0527,-0.9983],"SecondaryAxis":[0.0469,0.9975,-0.0527]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]}},{"s":"5841895234|5842343736||","k":"Knife","nm":"VampiresEdge","m":["Vampire's Edge","Godly","2020","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://5841895234","MeshSize":[5.9006,50,15.1339],"Reflectance":0,"Size":[0.3955,3.3514,1.0144],"TextureID":"rbxassetid://5842343736","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"6085025295|6074789360||","k":"Knife","nm":"Peppermint","m":["Peppermint","Godly","2020","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://6085025295","MeshSize":[4.33,50,18.6241],"Reflectance":0,"Size":[0.257,2.964,1.104],"TextureID":"rbxassetid://6074789360","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0.2},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[0.1961,0.1961,0.1961],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,3],"LightEmission":0,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":4,"RotSpeed":[0,0],"Rotation":[-30,10],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.2},{"t":1,"v":0.3}],"Speed":[1,1],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://415983101","TimeScale":1,"Transparency":[{"t":0,"v":0.5},{"t":0.2993,"v":0.5},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"6124173614|6124173821||","k":"Knife","nm":"DefaultKnife","m":["Default Knife","Common","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://6124173614","MeshSize":[0.424,3.1743,2.019],"Reflectance":0,"Size":[0.4106,3.0743,1.9554],"TextureID":"rbxassetid://6124173821","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1.5,2],"LightEmission":0,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[10,10],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.5},{"t":1,"v":0.5}],"Speed":[3,3],"SpreadAngle":[10,10],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://346658692","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":1,"v":0}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.95,0,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://6121572723","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"6125828567|6120563948||","k":"Gun","nm":"Icebeam","m":["Icebeam","Godly","2021","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://6125828567","MeshSize":[0.4432,1.93,1.0238],"Reflectance":0,"Size":[0.4432,1.93,1.0238],"TextureID":"rbxassetid://6120563948","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Attachment","Forward","",{"Axis":[1,0,0],"CFrame":[0,1,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Attachment","Up","",{"Axis":[1,0,0],"CFrame":[0,0,1,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[-0.0085,-0.7,-0.546,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://6121579464","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6125843704|6125843755||","k":"Gun","nm":"Jinglegun","m":["Jinglegun","Godly","2020","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://6125843704","MeshSize":[0.7515,1.799,1.1753],"Reflectance":0,"Size":[0.7515,1.799,1.1753],"TextureID":"rbxassetid://6125843755","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Attachment","Forward","",{"Axis":[1,0,0],"CFrame":[0,1,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Attachment","Up","",{"Axis":[1,0,0],"CFrame":[0,0,1,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.55,-0.6,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://6121678262","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":0,"Volume":1}]]}},{"s":"62275962|192567360||","k":"Knife","nm":"Deathshard","m":["Deathshard","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.3882,0.3725,0.3843],"Massless":true,"Material":"Enum.Material.Concrete","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.55,2.39,0.2],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[-0.0446,0.0355,0.9984],"CFrame":[0,0,0,-0.0446,-0.0003,-0.999,0.0355,0.9994,-0.0019,0.9984,-0.0355,-0.0446],"SecondaryAxis":[-0.0003,0.9994,-0.0355]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://62275962","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.75,0.75,0.75],"TextureId":"rbxassetid://192567360","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"6404140078|6413074818||","k":"Knife","nm":"Heartblade","m":["Heartblade","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://6404140078","MeshSize":[0.254,2.99,1.042],"Reflectance":0,"Size":[0.2795,3.29,1.1465],"TextureID":"rbxassetid://6413074818","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","c","",{"Acceleration":[0,0,0],"Brightness":0.515,"Color":[{"c":[0.1843,0.0314,0.098],"t":0},{"c":[0.1843,0.0314,0.098],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[4,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[10,100],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.8125},{"t":0.8703,"v":2},{"t":1,"v":3.1875}],"Speed":[1,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1223,"v":0.0312},{"t":0.1998,"v":0.0437},{"t":0.3215,"v":0.5437},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","feather","",{"Acceleration":[0,0,0],"Brightness":1.565,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1.2,1.2],"LightEmission":0.3,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.5125},{"e":0.1125,"t":0.0823,"v":-0.225},{"e":0.0375,"t":0.1347,"v":0.1875},{"e":0.075,"t":0.2332,"v":-0.3},{"e":0.15,"t":0.3811,"v":-0.0375},{"e":0.15,"t":1,"v":0}],"Texture":"rbxassetid://115966735527782","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","flamingo","",{"Acceleration":[0,0,0],"Brightness":1.565,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1.2,1.8],"LightEmission":0.3,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1.5,"RotSpeed":[-20,20],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.1,0.2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.5125},{"t":0.0823,"v":-0.225},{"t":0.1347,"v":0.1875},{"t":0.2332,"v":-0.3},{"t":0.3811,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://97614465751485","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","flamingo","",{"Acceleration":[0,0,0],"Brightness":1.565,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":1,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1.2,1.8],"LightEmission":0.3,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1.5,"RotSpeed":[-20,20],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.1,0.2],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.5125},{"t":0.0823,"v":-0.225},{"t":0.1347,"v":0.1875},{"t":0.2332,"v":-0.3},{"t":0.3811,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://110033681035937","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.0177,-1.4174,0.02,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://6413214382","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"6600901997|100126905908262||","k":"Knife","nm":"Neopolitan_K_2026","m":["Neopolitan","Uncommon","2026","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://100126905908262","VertexColor":[1,1,1]}]]}},{"s":"15374602183|15409041564||15374679651","k":"Gun","nm":"Gingerscope","m":["Gingerscope","Ancient","2023","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.5608,0.1333,0.1333],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://15374602183","MeshSize":[3.2041,14.9427,50],"Reflectance":0,"Size":[0.2697,1.2582,4.2087],"TextureID":"rbxassetid://15409041564","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Sound","AltSound","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://15666290706","TimeLength":1.4096,"Volume":1}],["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.1299,0,0.075,1,0,0,0,0.7071,0.7071,0,-0.7071,0.7071],"SecondaryAxis":[0,0.7071,-0.7071]}],["MeshPart","Scope","",{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.5059,0.7098,0.8],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Glass","MeshId":"rbxassetid://15374679651","MeshSize":[6.3849,6.3849,50],"Reflectance":1,"Size":[0.1871,0.1871,1.4135],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0.35}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.4,0.9,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://15666596216","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Animation","CustomHold","",{"AnimationId":"rbxassetid://15666234025"}],["Sound","AltSound","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://15666290706","TimeLength":1.4096,"Volume":1}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}],["Sound","Gunshot","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}]]}},{"s":"6600901997|101965621704869||","k":"Knife","nm":"Snowball_K_2025","m":["Snowball","Common","2025","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://101965621704869","VertexColor":[1,1,1]}]]}},{"s":"6600901997|104875261384354||","k":"Knife","nm":"Bunnies_K_2025","m":["Bunnies","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://104875261384354","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://90549252812333","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"6600901997|105940775587606||","k":"Knife","nm":"HotChocolate_K_2024","m":["Hot Chocolate","Common","2024","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://105940775587606","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"6600901997|11802560347||","k":"Knife","nm":"Gingerbread_K_2022","m":["Gingerbread","Rare","2022","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://11802560347","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"6600901997|124090504714382||","k":"Knife","nm":"Leaves_K_2025","m":["Leaves","Common","2025","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://124090504714382","VertexColor":[1,1,1]}]]}},{"s":"6600901997|125699146017319||","k":"Knife","nm":"Constellation_K_2024","m":["Nightstar","Legendary","2024","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://125699146017319","VertexColor":[1,1,1]}]]}},{"s":"6600901997|125701297884016||","k":"Knife","nm":"Turtles_K_2026","m":["Turtles","Uncommon","2026","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://125701297884016","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"6600901997|132791933859175||","k":"Knife","nm":"Bubbles_K_2026","m":["Bubbles","Legendary","2026","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://132791933859175","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://138388933477235","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"6600901997|133476959535888||","k":"Knife","nm":"Aquarium_K_2025","m":["Aquarium","Legendary","2025","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://133476959535888","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"6600901997|138096730619443||","k":"Knife","nm":"Skyline_K_2025","m":["Skyline","Common","2025","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://138096730619443","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"6600901997|139596499078847||","k":"Knife","nm":"Blossom_K_2026","m":["Blossom","Uncommon","2026","Valentines"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://139596499078847","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"6600901997|15029785979||","k":"Knife","nm":"Ghastly_K_2023","m":["Ghastly","Rare","2023","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://15029785979","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"6600901997|16846003250||","k":"Knife","nm":"Wavy_K_2024","m":["Wavy","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://16846003250","VertexColor":[1,1,1]}]]}},{"s":"6600901997|18351264716||","k":"Knife","nm":"Palms_K_2024","m":["Palms","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://18351264716","VertexColor":[1,1,1]}]]}},{"s":"6600901997|75445127360563||","k":"Knife","nm":"Retro_K_2025","m":["Retro","Uncommon","2025","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://75445127360563","VertexColor":[1,1,1]}]]}},{"s":"6600901997|75968382870233||","k":"Knife","nm":"Strawberries_K_2026","m":["Strawberries","Common","2026","Valentines"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://75968382870233","VertexColor":[1,1,1]}],["ParticleEmitter","a","",{"Acceleration":[0,0,0],"Brightness":0.515,"Color":[{"c":[1,0.4235,0.0118],"t":0},{"c":[1,0.4235,0.0118],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-20,20],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Inward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.6875},{"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.15},{"t":0.5175,"v":-0.4125},{"t":1,"v":-0.075}],"Texture":"rbxassetid://18276926698","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1223,"v":0.0312},{"t":0.1998,"v":0.0437},{"t":0.3215,"v":0.5437},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.25}],["ParticleEmitter","a","",{"Acceleration":[0,0,0],"Brightness":0.515,"Color":[{"c":[1,0.7725,0.3843],"t":0},{"c":[1,0.7725,0.3843],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[5,6],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[-20,20],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.InAndOut","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.6875},{"t":1,"v":1.5}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.15},{"t":0.5175,"v":-0.4125},{"t":1,"v":-0.075}],"Texture":"rbxassetid://18276926698","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1223,"v":0.0312},{"t":0.1998,"v":0.0437},{"t":0.3215,"v":0.5437},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.25}],["ParticleEmitter","c","",{"Acceleration":[0,0,0],"Brightness":0.2,"Color":[{"c":[1,0.8196,0.4039],"t":0},{"c":[1,0.8196,0.4039],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[4,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[10,100],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.8772,"v":2.625},{"t":1,"v":4.5625}],"Speed":[1,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1372,"v":0.4625},{"t":0.212,"v":0.4312},{"t":0.3354,"v":0.25},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.25}]]}},{"s":"6600901997|77551638357810||","k":"Knife","nm":"Gingercookie_K_2025","m":["Gingercookie","Rare","2025","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://77551638357810","VertexColor":[1,1,1]}],["ParticleEmitter","bigheart","",{"Acceleration":[0,0,0],"Brightness":2.725,"Color":[{"c":[1,0.4588,0.9725],"t":0},{"c":[1,0.4588,0.9725],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[30,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.2],"LightEmission":1,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.2},{"t":0.0287,"v":0.375},{"t":0.0661,"v":0.3125},{"t":0.2132,"v":0.3125},{"t":0.5137,"v":0.3125},{"t":1,"v":0}],"Speed":[0,1],"SpreadAngle":[360,360],"Squash":[{"e":0.3375,"t":0,"v":0.825},{"e":0.225,"t":0.0212,"v":-0.675},{"e":0.0375,"t":0.0761,"v":0.1875},{"e":0.0375,"t":0.2092,"v":-0.1125},{"t":0.3067,"v":-0.075},{"t":1,"v":0}],"Texture":"rbxassetid://136767343466804","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.081,"v":0.2188},{"t":0.2182,"v":0},{"t":0.7406,"v":0.3062},{"t":0.8529,"v":0.6625},{"t":0.8741,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","glow","",{"Acceleration":[0,0,0],"Brightness":0.515,"Color":[{"c":[0.2902,0.1333,0.3333],"t":0},{"c":[0.2902,0.1333,0.3333],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[4,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[10,100],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.5},{"t":0.8703,"v":2},{"t":1,"v":3.1875}],"Speed":[1,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1223,"v":0.0312},{"t":0.1998,"v":0.0437},{"t":0.3215,"v":0.5437},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","smallheart","",{"Acceleration":[0,0,0],"Brightness":2.725,"Color":[{"c":[1,0.4588,0.9725],"t":0},{"c":[1,0.4588,0.9725],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[30,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.2],"LightEmission":1,"LightInfluence":1,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[0,1],"SpreadAngle":[360,360],"Squash":[{"e":0.3375,"t":0,"v":0.825},{"e":0.225,"t":0.0212,"v":-0.675},{"e":0.1875,"t":0.0761,"v":0.1875},{"e":0.1875,"t":0.2095,"v":-0.15},{"t":0.3067,"v":-0.075},{"t":1,"v":0}],"Texture":"rbxassetid://136767343466804","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.081,"v":0.2188},{"t":0.2182,"v":0},{"t":0.7406,"v":0.3062},{"t":0.8529,"v":0.6625},{"t":0.8741,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallhearttrail","",{"Acceleration":[0,0,0],"Brightness":2.725,"Color":[{"c":[1,0.4588,0.9725],"t":0},{"c":[1,0.4588,0.9725],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[30,30],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.2],"LightEmission":1,"LightInfluence":1,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[0,1],"SpreadAngle":[360,360],"Squash":[{"e":0.3375,"t":0,"v":0.825},{"e":0.225,"t":0.0212,"v":-0.675},{"e":0.1875,"t":0.0761,"v":0.1875},{"e":0.1875,"t":0.2095,"v":-0.15},{"t":0.3067,"v":-0.075},{"t":1,"v":0}],"Texture":"rbxassetid://136767343466804","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.081,"v":0.2188},{"t":0.2182,"v":0},{"t":0.7406,"v":0.3062},{"t":0.8529,"v":0.6625},{"t":0.8741,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]}},{"s":"6600901997|8275035798||","k":"Knife","nm":"Snowman_K_2021","m":["Snowman","Uncommon","2021","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://8275035798","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"6600901997|89105172362040||","k":"Knife","nm":"Bones_K_2024","m":["Bones","Uncommon","2024","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://89105172362040","VertexColor":[1,1,1]}]]}},{"s":"6600901997|91124699102770||","k":"Knife","nm":"Cupid_K_2026","m":["Cupid","Legendary","2026","Valentines"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://91124699102770","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"6600901997|91672438499477||","k":"Knife","nm":"StickersH_K_2025","m":["Stickers","Common","2025","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://91672438499477","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://100461386281007","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"6600901997|98589370896149||","k":"Knife","nm":"Sand_K_2026","m":["Sand","Common","2026","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://98589370896149","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"6600901997|98911990727243||","k":"Knife","nm":"Starry_K_2026","m":["Starry","Uncommon","2026","Valentines"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6600901997","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://98911990727243","VertexColor":[1,1,1]}]]}},{"s":"6600918074|100185145262613||","k":"Gun","nm":"Plaid_G_2026","m":["Plaid","Common","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://100185145262613","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|102957418708034||","k":"Gun","nm":"Heartbreak_G_2026","m":["Heartbreak","Rare","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://102957418708034","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|103202994163470||","k":"Gun","nm":"Strawberries_G_2026","m":["Strawberries","Common","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://103202994163470","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://128646835922561","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|105937622090347||","k":"Gun","nm":"Sunny_G_2025","m":["Sunny","Rare","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://105937622090347","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://93906279038399","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|105991246402157||","k":"Gun","nm":"Striped_G_2025","m":["Striped","Common","2025","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://105991246402157","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|108504597564281||","k":"Gun","nm":"Paws_G_2026","m":["Paws","Uncommon","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://108504597564281","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|112196863510306||","k":"Gun","nm":"Gingercookie_G_2025","m":["","","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://112196863510306","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://99160839686845","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|114741314080418||","k":"Gun","nm":"Forest_G_2024","m":["Forest","Uncommon","2024","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://114741314080418","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://78199422065424","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|118189428777054||","k":"Gun","nm":"Sunset_G_2026","m":["Sunset","Rare","2026","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://118189428777054","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|123572826899313||","k":"Gun","nm":"StickersX_G_2025","m":["Stickers","Common","2025","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://123572826899313","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|124763121225655||","k":"Gun","nm":"Butterflies_G_2025","m":["Butterflies","Rare","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://124763121225655","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|138251429150159||","k":"Gun","nm":"Duckies_G_2026","m":["Duckies","Common","2026","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://138251429150159","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://124567820488562","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|139997450438464||","k":"Gun","nm":"Stickers_X_G_2024","m":["Stickers","Common","2024","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://139997450438464","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|72308464511333||","k":"Gun","nm":"Stickers_G_2025","m":["Stickers","Common","2025","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://72308464511333","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6600918074|73839340981831||","k":"Gun","nm":"Neon_G_2025","m":["Neon","Rare","2025","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://73839340981831","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://134429631587448","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|74173043698427||","k":"Gun","nm":"Cherries_G_2026","m":["Cherries","Common","2026","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://74173043698427","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://96164363513384","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|78638638337831||","k":"Gun","nm":"Floral_G_2026","m":["Floral","Uncommon","2026","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://78638638337831","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://107508982214346","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|87079980851460||","k":"Gun","nm":"Frozen_G_2025","m":["Frozen","Legendary","2025","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://87079980851460","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0.6997,-0.306,0.0011,0,0,1,0,1,0,-1,0,0],"RequiresHandle":true,"TextureId":"rbxassetid://90622014285727","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"6600918074|91632676208966||","k":"Gun","nm":"","m":["","","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Slate","MeshId":"rbxassetid://6600918074","MeshSize":[47.5985,24.4541,8.8155],"Reflectance":0,"Size":[1.83,0.95,0.325],"TextureID":"rbxassetid://91632676208966","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[0,0,-1],"CFrame":[0,-0.15,-0.05,0,-0.7661,0.6428,0,0.6428,0.7661,-1,0,0],"SecondaryAxis":[-0.7661,0.6428,0]}]]}},{"s":"6769675268|73593137081664||","k":"Knife","nm":"Tourist_K_2026","m":["Tourist","Common","2026","Summer"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://6769675268","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://73593137081664","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0.2,0],"Brightness":1,"Color":[{"c":[1,1,1],"t":0},{"c":[1,1,1],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[20,50],"FlipbookLayout":"Enum.ParticleFlipbookLayout.Grid8x8","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":3,"RotSpeed":[0,0],"Rotation":[-20,20],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.1875,"t":0,"v":0.1875},{"e":0.125,"t":1,"v":0.25}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.6125},{"t":0.0797,"v":-0.3},{"t":0.1295,"v":0.2625},{"t":0.2354,"v":-0.3375},{"t":0.3811,"v":-0.0375},{"t":0.9303,"v":-0.075},{"t":0.9701,"v":-0.4125},{"t":0.9963,"v":1.725},{"t":1,"v":1.8}],"Texture":"rbxassetid://103186751172617","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.2254,"v":0.4},{"t":0.4396,"v":0},{"t":0.8954,"v":0.4375},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0.2}],["ParticleEmitter","b","",{"Acceleration":[0,0.4,0],"Brightness":1,"Color":[{"c":[0.4392,0.4392,0.4392],"t":0},{"c":[0.4392,0.4392,0.4392],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":7,"RotSpeed":[-20,20],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":0.6875}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0.075},{"t":0.0286,"v":-0.225},{"t":0.0697,"v":0},{"t":0.1507,"v":-0.075},{"t":0.3786,"v":-0.0375},{"t":1,"v":0}],"Texture":"rbxassetid://11238241427","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0773,"v":0.3438},{"t":0.207,"v":0},{"t":0.2594,"v":0},{"t":0.3067,"v":0},{"t":0.5162,"v":0.525},{"t":0.6334,"v":0.85},{"t":0.7569,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-0.2}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1,-0.1,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://135606903872678","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"73266355643345|103489229144925||","k":"Knife","nm":"Bloom","m":["Bloom","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.5608,0.1333,0.1333],"DoubleSided":true,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://73266355643345","MeshSize":[6.2338,50,14.0322],"Reflectance":0,"Size":[0.4614,3.7,1.0385],"TextureID":"rbxassetid://103489229144925","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}]]}},{"s":"77738838473091|76246633927299||","k":"Knife","nm":"HeartWand","m":["Heart Wand","Godly","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.5608,0.1333,0.1333],"DoubleSided":true,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://77738838473091","MeshSize":[5.5367,42.9744,24.5492],"Reflectance":0,"Size":[0.4327,3.3587,1.9187],"TextureID":"rbxassetid://76246633927299","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["SurfaceAppearance","SurfaceAppearance","",{"AlphaMode":"Enum.AlphaMode.Overlay","ColorMap":"rbxassetid://76246633927299"}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}]]}},{"s":"7775027413|7775245551||","k":"Gun","nm":"Harvester","m":["Harvester","Ancient","2021","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://7775027413","MeshSize":[44.2533,12.9111,56.8141],"Reflectance":0,"Size":[2.2448,0.6549,2.88],"TextureID":"rbxassetid://7775245551","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Sound","AltSound","",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.4,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://7808472682","TimeLength":1.1823,"Volume":1}],["Attachment","CustomAttachment","",{"Axis":[0,1,-0.0001],"CFrame":[0.1299,0,0.075,0,-0.5,-0.866,1,0,0,-0.0001,-0.866,0.5],"SecondaryAxis":[-0.5,0,-0.866]}]]}},{"s":"7791364860|7806078587|7806088865|","k":"Knife","nm":"CandleflameChroma","m":["Candleflame","Godly","2021","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.45,3.338,1.109],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Decal","Chroma","",{"Color3":[0,0.0397,1],"Face":"Enum.NormalId.Right","Texture":"rbxassetid://7806088865","Transparency":0,"ZIndex":1}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://7791364860","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.065,0.065,0.065],"TextureId":"rbxassetid://7806078587","VertexColor":[1,1,1]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":7.115,"Color":[{"c":[0,0.9843,1],"t":0},{"c":[0,0.9843,1],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.7,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[3,3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.0884,"v":1},{"t":0.1883,"v":0.7437},{"t":0.2629,"v":0.55},{"t":0.3341,"v":0.3812},{"t":0.4879,"v":0.0687},{"t":0.6762,"v":0.075},{"t":0.8002,"v":0.2},{"t":0.899,"v":0.4187},{"t":0.9575,"v":0.6125},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":7.115,"Color":[{"c":[0.9176,0,1],"t":0},{"c":[0.9176,0,1],"t":1}],"Drag":5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.7,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[0,0],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.1},{"t":1,"v":0}],"Speed":[3,3],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.35,"Transparency":[{"t":0,"v":1},{"t":0.0884,"v":1},{"t":0.1883,"v":0.7437},{"t":0.2629,"v":0.55},{"t":0.3341,"v":0.3812},{"t":0.4879,"v":0.0687},{"t":0.6762,"v":0.075},{"t":0.8002,"v":0.2},{"t":0.899,"v":0.4187},{"t":0.9575,"v":0.6125},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","c","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0,1,0.9686],"t":0},{"c":[0,1,0.9686],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[10,100],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.8772,"v":2.625},{"t":1,"v":4.5625}],"Speed":[1,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1223,"v":0.0312},{"t":0.1998,"v":0.0437},{"t":0.3215,"v":0.5437},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","c","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.7843,0,1],"t":0},{"c":[0.7843,0,1],"t":1}],"Drag":12,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[2,4],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[10,100],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.8772,"v":2.625},{"t":1,"v":4.5625}],"Speed":[1,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0866,"v":1},{"t":0.1223,"v":0.0312},{"t":0.1998,"v":0.0437},{"t":0.3215,"v":0.5437},{"t":0.4756,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}]]}},{"s":"79401392|11810420546||","k":"Gun","nm":"Gingerbread_G_2022","m":["Gingerbread","Rare","2022","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://11810420546","VertexColor":[1,1,1]}]]}},{"s":"79401392|12937562728||","k":"Gun","nm":"Chromatic_G_2023","m":["Chromatic","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://12937562728","VertexColor":[1,1,1]}]]}},{"s":"79401392|156263287||","k":"Gun","nm":"Imbued","m":["Imbued","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://156263287","VertexColor":[1,1,1]}]]}},{"s":"79401392|159991281||","k":"Gun","nm":"Viper","m":["Viper","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://159991281","VertexColor":[1,1,1]}]]}},{"s":"79401392|161309663||","k":"Gun","nm":"Cold","m":["Cold","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://161309663","VertexColor":[1,1,1]}]]}},{"s":"79401392|161976144||","k":"Gun","nm":"Sketch","m":["Sketch","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://161976144","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://203808108","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","GunKill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://296102734","TimeLength":0,"Volume":5}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|173912996||","k":"Gun","nm":"Galactic","m":["Galactic","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://173912996","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://173913533","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|181689885||","k":"Gun","nm":"HL2","m":["HL2","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://181689885","VertexColor":[1,1,1]}]]}},{"s":"79401392|183053133||","k":"Gun","nm":"Wooden","m":["Wooden","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://183053133","VertexColor":[1,1,1]}]]}},{"s":"79401392|18321971106||","k":"Gun","nm":"Palms_G_2024","m":["Palms","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://18321971106","VertexColor":[1,1,1]}]]}},{"s":"79401392|18321972013||","k":"Gun","nm":"Floatie_G_2024","m":["Floatie","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://18321972013","VertexColor":[1,1,1]}]]}},{"s":"79401392|18323742549||","k":"Gun","nm":"Floral_G_2024","m":["Floral","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://18323742549","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://18323751219","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|18323743340||","k":"Gun","nm":"Sandy_G_2024","m":["Sandy","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://18323743340","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://18323752709","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|198413638||","k":"Gun","nm":"Hacker","m":["Hacker","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://198413638","VertexColor":[1,1,1]}]]}},{"s":"79401392|202773960||","k":"Gun","nm":"Predator","m":["Predator","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.6,1.6,1.6],"TextureId":"rbxassetid://202773960","VertexColor":[1,1,1]}]]}},{"s":"79401392|238542777||","k":"Gun","nm":"Universe","m":["Universe","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://238542777","VertexColor":[1,1,1]}]]}},{"s":"79401392|2669622216||","k":"Gun","nm":"Holly_G_2018","m":["Holly","Uncommon","2018","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://2669622216","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://2669786261","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|3183407395||","k":"Gun","nm":"Pirate","m":["Pirate","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://3183407395","VertexColor":[1,1,1]}]]}},{"s":"79401392|4210409812||","k":"Gun","nm":"Monster","m":["Monster","Rare","2019","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://4210409812","VertexColor":[1,1,1]}]]}},{"s":"79401392|4659576260||","k":"Gun","nm":"Splash_G","m":["Splash","Legendary","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://4659576260","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://4659626370","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|4659577665||","k":"Gun","nm":"Nightfire","m":["Nightfire","Rare","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://4659577665","VertexColor":[1,1,1]}]]}},{"s":"79401392|4659589763||","k":"Gun","nm":"Biogun","m":["Biogun","Uncommon","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://4659589763","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://4659627458","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|4663058089||","k":"Gun","nm":"Clown_G","m":["Clown","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://4663058089","VertexColor":[1,1,1]}]]}},{"s":"79401392|83300450889998||","k":"Gun","nm":"Clown_G_2024","m":["Clown","Uncommon","2024","Halloween"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.5,1.5,1.5],"TextureId":"rbxassetid://83300450889998","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://71982363966070","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"79401392|91723031||","k":"Gun","nm":"DefaultGun","m":["Default Gun","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.SmoothPlastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1.83,1.03],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://79401392","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.6,1.6,1.6],"TextureId":"rbxassetid://91723031","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://197518111","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":true,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"82044527712515|nil||","k":"Knife","nm":"Icecream","m":["Icecream","Godly","2026","Summer"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://82044527712515","MeshSize":[1.326,5.5812,1.6112],"Reflectance":0,"Size":[0.8022,3.3766,0.9748],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SurfaceAppearance","SurfaceAppearance","",{"AlphaMode":"Enum.AlphaMode.Overlay","ColorMap":"rbxassetid://133533169721039"}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-1.0341,-0.0461,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://87189663191639","ToolTip":""},"n":[["Sound","Kill","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://142247768","TimeLength":0.5486,"Volume":1}],["Animation","Downstab","KnifeClient",{"AnimationId":"rbxassetid://109717378649651"}],["Animation","DualSlash","KnifeClient/Dual",{"AnimationId":"rbxassetid://2467577524"}],["Animation","DualStab","KnifeClient/Dual",{"AnimationId":"rbxassetid://2470501967"}],["Animation","Slash","KnifeClient",{"AnimationId":"rbxassetid://115592970007001"}],["Animation","ThrowCharge","KnifeClient",{"AnimationId":"rbxassetid://1957618848"}],["Animation","ThrowHold","KnifeClient",{"AnimationId":"rbxassetid://15478370930"}],["Animation","ThrowKnife","KnifeClient",{"AnimationId":"rbxassetid://112035104498952"}],["Animation","DownstabOG","KnifeServer",{"AnimationId":"rbxassetid://1957890538"}],["Animation","SlashOG","KnifeServer",{"AnimationId":"rbxassetid://2467567750"}],["Sound","Throw","Sounds",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1.5,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.InverseTapered","SoundId":"rbxasset://sounds/action_jump.mp3","TimeLength":0.3396,"Volume":0.4}]]}},{"s":"8231045240|8231046270||","k":"Knife","nm":"Iceflake","m":["Iceflake","Godly","2021","Christmas"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://8231045240","MeshSize":[2.7314,50,12.2258],"Reflectance":0,"Size":[0.1845,3.3769,0.8258],"TextureID":"rbxassetid://8231046270","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"8310908064|8231066536||","k":"Gun","nm":"","m":["","","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://8310908064","MeshSize":[0.328,2.199,1.0898],"Reflectance":0,"Size":[0.328,2.199,1.0898],"TextureID":"rbxassetid://8231066536","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}]]}},{"s":"8310911339|8320249073|8320260092|","k":"Gun","nm":"SwirlyGunChroma","m":["Swirly Gun","Godly","2021","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.469,2.539,1.151],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["Decal","Chroma","",{"Color3":[0.5722,0,1],"Face":"Enum.NormalId.Right","Texture":"rbxassetid://8320260092","Transparency":0,"ZIndex":2}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://8310911339","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://8320249073","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.7,-0.3,1,0,0,0,0,-1,0,1,0],"RequiresHandle":true,"TextureId":"rbxassetid://8311453396","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"88250692342609|75844398224824||","k":"Knife","nm":"Sweet","m":["Sweet","Godly","2026","Valentines"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Plastic","MeshId":"rbxassetid://88250692342609","MeshSize":[5.8477,50,14.5951],"Reflectance":0,"Size":[0.4039,3.4534,1.0081],"TextureID":"rbxassetid://75844398224824","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}],["SurfaceAppearance","SurfaceAppearance","",{"AlphaMode":"Enum.AlphaMode.Overlay","ColorMap":"rbxassetid://102552849874873"}]]}},{"s":"92656610|386269992||","k":"Gun","nm":"Blaster","m":["Blaster","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Inlet","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0,0.5608,0.6118],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.2,1,1.9],"TopSurface":"Enum.SurfaceType.Studs","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.15,0.0549,0.2049,1,0,0,0,0.1736,0.9848,0,-0.9848,0.1736],"SecondaryAxis":[0,0.1736,-0.9848]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://92656610","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.4,0.45,0.5],"TextureId":"rbxassetid://386269992","VertexColor":[1,1,1]}]]}},{"s":"93108071|93112631||","k":"Knife","nm":"WintersEdge","m":["Winter's Edge","Godly","2017","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0157,0.6863,0.9255],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0.4,"Shape":"Enum.PartType.Block","Size":[0.66,3,0.38],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[-0.0348,0.0347,0.9988],"CFrame":[-0.0511,0.086,-0.0005,-0.0348,-0.0018,-0.9994,0.0347,0.9994,-0.003,0.9988,-0.0348,-0.0347],"SecondaryAxis":[-0.0018,0.9994,-0.0348]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://93108071","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[0.45,0.45,0.45],"TextureId":"rbxassetid://93112631","VertexColor":[1,1,1]}],["ParticleEmitter","bigbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.076,"v":0.2732},{"t":0.9364,"v":0.2732},{"t":1,"v":0.6557}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":false,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":1,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}],["ParticleEmitter","smallbubble","",{"Acceleration":[0,0,0],"Brightness":1.28,"Color":[{"c":[0.9176,0.9961,0.9961],"t":0},{"c":[0.9176,0.9961,0.9961],"t":1}],"Drag":3,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[25.8,25.8],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1.8],"LightEmission":0.4,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":2.5,"RotSpeed":[-100,100],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.0409,"v":0},{"t":0.0783,"v":0.0546},{"t":0.9296,"v":0.1093},{"t":1,"v":0.3825}],"Speed":[0.5,1],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":2.069},{"t":0.0196,"v":-1.6034},{"t":0.0351,"v":1.8621},{"e":0.0033,"t":0.0526,"v":-0.3879},{"e":0.0259,"t":0.133,"v":0.0259},{"e":0.0206,"t":0.2794,"v":0.1293},{"e":0.0206,"t":0.5897,"v":-0.0776},{"e":0.0204,"t":0.8464,"v":0},{"e":0.0252,"t":0.9804,"v":-0.0259},{"e":0.0254,"t":0.9928,"v":-0.5172},{"e":0.0259,"t":1,"v":0.6724}],"Texture":"rbxassetid://85879634295003","TimeScale":1,"Transparency":[{"t":0,"v":1},{"t":0.0124,"v":0},{"t":0.0402,"v":0},{"e":0.0239,"t":0.6598,"v":0.1196},{"t":1,"v":1}],"VelocityInheritance":1,"ZOffset":1}]]}},{"s":"95356090|126534866||","k":"Gun","nm":"RedLuger","m":["Red Luger","Godly","2015","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Inlet","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0,0.5608,0.6118],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.51,1.18,1.35],"TopSurface":"Enum.SurfaceType.Studs","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.15,0.0384,0.3332,1,0,0,0,0,1,0,-1,0],"SecondaryAxis":[0,0,-1]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://95356090","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.8,1.8,1.8],"TextureId":"rbxassetid://126534866","VertexColor":[1,1,1]}]]},"t":{"p":{"CanBeDropped":false,"Enabled":true,"Grip":[0,-0.206,0.5,1,0,0,0,1,0,0,0,1],"RequiresHandle":true,"TextureId":"rbxassetid://3187399148","ToolTip":""},"n":[["Animation","Reload","Animations",{"AnimationId":"rbxassetid://123606547020560"}],["Animation","Shoot","Animations",{"AnimationId":"rbxassetid://134826825394657"}],["Sound","Gunshot","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://10209803","TimeLength":2.351,"Volume":0.7}],["Sound","Reload","Handle",{"Looped":false,"PlayOnRemove":false,"PlaybackSpeed":1,"Playing":false,"RollOffMaxDistance":10000,"RollOffMinDistance":10,"RollOffMode":"Enum.RollOffMode.Inverse","SoundId":"rbxassetid://4753414199","TimeLength":2.5078,"Volume":1}]]}},{"s":"95356090|2674981863||","k":"Gun","nm":"GingerLuger","m":["Ginger Luger","Godly","2018","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Inlet","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0,0.5608,0.6118],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.51,1.18,1.35],"TopSurface":"Enum.SurfaceType.Studs","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.15,0.0384,0.3332,1,0,0,0,0,1,0,-1,0],"SecondaryAxis":[0,0,-1]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://95356090","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.8,1.8,1.8],"TextureId":"rbxassetid://2674981863","VertexColor":[1,1,1]}]]}},{"s":"95356090|4535479829||","k":"Gun","nm":"Lugercane","m":["Lugercane","Godly","2019","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Inlet","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.0667,0.0667,0.0667],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.51,1.18,1.35],"TopSurface":"Enum.SurfaceType.Studs","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.15,0.0384,0.3332,1,0,0,0,0,1,0,-1,0],"SecondaryAxis":[0,0,-1]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://95356090","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.8,1.8,1.8],"TextureId":"rbxassetid://4535479829","VertexColor":[1,1,1]}]]}},{"s":"95356090|nil|3171206966|","k":"Gun","nm":"LugerChroma","m":["Luger","Godly","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Inlet","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0,0.5608,0.6118],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.51,1.18,1.35],"TopSurface":"Enum.SurfaceType.Studs","Transparency":0},"n":[["Decal","Chroma","",{"Color3":[0,0.0397,1],"Face":"Enum.NormalId.Back","Texture":"rbxassetid://3171206966","Transparency":0,"ZIndex":1}],["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.15,0.0384,0.3332,1,0,0,0,0,1,0,-1,0],"SecondaryAxis":[0,0,-1]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://95356090","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1.8,1.8,1.8],"VertexColor":[1,1,1]}]]}},{"s":"957726558|4534823003||","k":"Knife","nm":"Aurora_K_2019","m":["Aurora","Rare","2019","Christmas"],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://957726558","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://4534823003","VertexColor":[1,1,1]}],["ParticleEmitter","b","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.0784,0.1255,0.4235],"t":0},{"c":[0.0784,0.1255,0.4235],"t":1}],"Drag":10,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1],"LightEmission":0,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":20,"RotSpeed":[-10,10],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.25},{"t":0.7556,"v":1.125},{"t":1,"v":1.25}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1538950131","TimeScale":0.4,"Transparency":[{"t":0,"v":1},{"t":0.042,"v":0.5875},{"t":0.1185,"v":0.0062},{"t":0.2631,"v":0},{"t":0.3653,"v":0.3187},{"t":0.4214,"v":0.575},{"t":0.5396,"v":1},{"t":0.6992,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-1}],["ParticleEmitter","b","",{"Acceleration":[0,0,0],"Brightness":6.6,"Color":[{"c":[0.2588,0.4745,0.6157],"t":0},{"c":[0.2588,0.4745,0.6157],"t":1}],"Drag":10,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[1,1],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":20,"RotSpeed":[-10,10],"Rotation":[0,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.25},{"t":0.7581,"v":1.5},{"t":1,"v":2.375}],"Speed":[0.5,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1538950131","TimeScale":0.4,"Transparency":[{"t":0,"v":1},{"t":0.0424,"v":0.4563},{"t":0.1068,"v":0},{"t":0.2514,"v":0},{"t":0.409,"v":0.5375},{"t":0.5396,"v":1},{"t":0.6992,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":-2}]]}},{"s":"957726558|4659572197||","k":"Knife","nm":"Lovely","m":["Lovely","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://957726558","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://4659572197","VertexColor":[1,1,1]}]]}},{"s":"957726558|4659588788||","k":"Knife","nm":"Leaf","m":["Leaf","Common","",""],"d":{"c":"Part","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.6392,0.6353,0.6471],"Massless":true,"Material":"Enum.Material.Plastic","Reflectance":0,"Shape":"Enum.PartType.Block","Size":[0.4,3,0.7],"TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["SpecialMesh","Mesh","",{"MeshId":"rbxassetid://957726558","MeshType":"Enum.MeshType.FileMesh","Offset":[0,0,0],"Scale":[1,1,1],"TextureId":"rbxassetid://4659588788","VertexColor":[1,1,1]}],["ParticleEmitter","Smoke","",{"Acceleration":[0,1,0],"Brightness":1,"Color":[{"c":[0,1,0],"t":0},{"c":[0,0.4588,0],"t":1}],"Drag":0,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.2,1],"LightEmission":0.8,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":80,"RotSpeed":[15,25],"Rotation":[0,45],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"t":0.793,"v":0.5},{"t":1,"v":0}],"Speed":[-1,0],"SpreadAngle":[0,0],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxasset://textures/particles/fire_main.dds","TimeScale":1,"Transparency":[{"t":0,"v":0},{"t":0.7007,"v":0.1062},{"t":1,"v":0.9937}],"VelocityInheritance":0,"ZOffset":0.1}]]}},{"s":"96867436912658|103568875118220||","k":"Gun","nm":"XenoGun","m":["Xenoshot","Godly","2025","Halloween"],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":true,"Color":[0.5608,0.1333,0.1333],"DoubleSided":true,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://96867436912658","MeshSize":[5.2774,24.711,50],"Reflectance":0,"Size":[0.2816,1.3183,2.6675],"TextureID":"rbxassetid://103568875118220","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0,-0.2,0.0899,1,0,0,0,0.6428,0.7661,0,-0.7661,0.6428],"SecondaryAxis":[0,0.6428,-0.7661]}]]}},{"s":"9702732853|10015130416||","k":"Knife","nm":"Plasmablade","m":["Plasmablade","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":false,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://9702732853","MeshSize":[191.116,2240.9543,489.4247],"Reflectance":0,"Size":[0.3381,3.6228,0.8484],"TextureID":"rbxassetid://10015130416","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","Attachment","",{"Axis":[1,0,0],"CFrame":[0,0,0,1,0,0,0,1,0,0,0,1],"SecondaryAxis":[0,1,0]}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":10,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":0.5042}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"e":0.181,"t":0,"v":0.4138},{"e":0.0776,"t":1,"v":0.1552}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":5.88,"Color":[{"c":[0.7333,0.498,0.851],"t":0},{"c":[0.7333,0.498,0.851],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"e":0.125,"t":0,"v":0.125},{"e":0.0625,"t":1,"v":1.625}],"Speed":[0,0],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":1.3707},{"t":1,"v":-1.1897}],"Texture":"rbxassetid://117969652716920","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.1071,"v":0.05},{"t":0.198,"v":1},{"t":0.3724,"v":1},{"t":0.4545,"v":1},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","ParticleEmitter","",{"Acceleration":[0,0,0],"Brightness":2.625,"Color":[{"c":[0.851,0,0.0157],"t":0},{"c":[0.3686,0,0.8157],"t":0.3616},{"c":[0.6431,0.0941,0.7137],"t":0.5415},{"c":[0.0353,0.0824,0.7451],"t":0.6834},{"c":[0.0196,0.5608,0.7922],"t":0.8515},{"c":[0.0784,0.6392,0.6118],"t":1}],"Drag":4.5,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[0.5,3],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[0,0],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0.4375},{"t":1,"v":1.3125}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://1539332776","TimeScale":0.55,"Transparency":[{"t":0,"v":1},{"t":0.0835,"v":0.5875},{"t":0.2531,"v":0.2562},{"t":0.5137,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.4588,0.1137,0.7059],"t":0},{"c":[0.4588,0.1137,0.7059],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0685,"v":0.4062},{"t":0.127,"v":0.325},{"t":0.9078,"v":0.35},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":1}],["ParticleEmitter","smallstartrail","",{"Acceleration":[0,0,0],"Brightness":1,"Color":[{"c":[0.6471,0.3451,0.8196],"t":0},{"c":[0.6471,0.3451,0.8196],"t":1}],"Drag":2,"EmissionDirection":"Enum.NormalId.Top","Enabled":true,"FlipbookFramerate":[1,1],"FlipbookLayout":"Enum.ParticleFlipbookLayout.None","FlipbookMode":"Enum.ParticleFlipbookMode.Loop","FlipbookStartRandom":false,"Lifetime":[3,5],"LightEmission":1,"LightInfluence":0,"LockedToPart":true,"Orientation":"Enum.ParticleOrientation.FacingCamera","Rate":5,"RotSpeed":[-200,200],"Rotation":[-360,360],"Shape":"Enum.ParticleEmitterShape.Box","ShapeInOut":"Enum.ParticleEmitterShapeInOut.Outward","ShapePartial":1,"ShapeStyle":"Enum.ParticleEmitterShapeStyle.Volume","Size":[{"t":0,"v":0},{"e":0.0625,"t":1,"v":0.0625}],"Speed":[0.1,0.5],"SpreadAngle":[360,360],"Squash":[{"t":0,"v":0},{"t":1,"v":0}],"Texture":"rbxassetid://2346141109","TimeScale":0.65,"Transparency":[{"t":0,"v":1},{"t":0.0536,"v":0.075},{"t":0.1122,"v":0},{"t":0.9015,"v":0},{"t":1,"v":1}],"VelocityInheritance":0,"ZOffset":0}]]}},{"s":"9702755186|10015208201||","k":"Gun","nm":"Plasmabeam","m":["Plasmabeam","Godly","",""],"d":{"c":"MeshPart","p":{"Anchored":false,"BottomSurface":"Enum.SurfaceType.Smooth","CanCollide":false,"CanQuery":false,"CanTouch":false,"CastShadow":false,"Color":[0.0667,0.0667,0.0667],"DoubleSided":false,"Massless":true,"Material":"Enum.Material.Brick","MeshId":"rbxassetid://9702755186","MeshSize":[8.3783,24.8794,50],"Reflectance":0,"Size":[0.3648,1.0832,2.1769],"TextureID":"rbxassetid://10015208201","TopSurface":"Enum.SurfaceType.Smooth","Transparency":0},"n":[["Attachment","CustomAttachment","",{"Axis":[1,0,0],"CFrame":[0.0643,0.0565,0.1919,1,0,0,0,0.2923,0.9563,0,-0.9563,0.2923],"SecondaryAxis":[0,0.2923,-0.9563]}]]}}]]==]

    local function setupSkins()
        local DATA = nil
        local VIS = {
            Part = true, MeshPart = true, SpecialMesh = true, SurfaceAppearance = true, Decal = true,
            Attachment = true, ParticleEmitter = true, Beam = true,
        }
        local TOOL_PROP = { Animation = "AnimationId", Sound = "SoundId" }

        -- the list: decoded once, knives first, one label per skin
        local function data()
            if DATA then return DATA end
            DATA = { list = {}, bySig = {} }
            local ok, raw = pcall(function() return HttpService:JSONDecode(SKIN_BLOB) end)
            if not ok or type(raw) ~= "table" then return DATA end
            for _, rec in ipairs(raw) do
                if type(rec) == "table" and type(rec.s) == "string" and type(rec.d) == "table" then
                    local m = rec.m or {}
                    local name = m[1] or ""
                    if name == "" then name = rec.nm or "" end
                    if name == "" then name = string.sub(rec.s, 1, 12) end
                    rec.name = name
                    rec.kindWord = rec.k == "Knife" and "knife" or "gun"
                    DATA.list[#DATA.list + 1] = rec
                end
            end
            table.sort(DATA.list, function(a, b)
                if a.k ~= b.k then return a.k == "Knife" end
                return string.lower(a.name) < string.lower(b.name)
            end)
            local used = {}
            for _, rec in ipairs(DATA.list) do
                local m = rec.m or {}
                local label = rec.kindWord .. " | " .. rec.name
                if m[2] and m[2] ~= "" then label = label .. " | " .. m[2] end
                used[label] = (used[label] or 0) + 1
                if used[label] > 1 then label = label .. " #" .. used[label] end
                rec.label = label
                DATA.bySig[rec.s] = rec
            end
            return DATA
        end

        local function get(sig)
            if type(sig) ~= "string" or sig == "" then return nil end
            return data().bySig[sig]
        end

        -- keypoint times: inside [0, 1], the first at 0 and the last at 1 (the roblox rule for sequences)
        local function keyTime(i, n, t)
            if i == 1 then return 0 end
            if i == n then return 1 end
            return math.min(1, math.max(0, t or 0))
        end

        -- a stored value to a roblox value; the live property (cur) says which type a plain number list is
        local function toValue(cur, v)
            if type(v) == "string" then
                local a, b = string.match(v, "^Enum%.(%w+)%.(%w+)$")
                if a then return Enum[a][b] end
                return v
            end
            if type(v) ~= "table" then return v end
            local n = #v
            if type(v[1]) == "table" then
                local kps = {}
                if v[1].c then
                    for i, k in ipairs(v) do
                        kps[i] = ColorSequenceKeypoint.new(keyTime(i, n, k.t), Color3.new(k.c[1], k.c[2], k.c[3]))
                    end
                    return ColorSequence.new(kps)
                end
                for i, k in ipairs(v) do
                    kps[i] = NumberSequenceKeypoint.new(keyTime(i, n, k.t), k.v, k.e or 0)
                end
                return NumberSequence.new(kps)
            end
            local t = typeof(cur)
            if t == "NumberRange" then return NumberRange.new(v[1], v[2]) end
            if t == "Vector2" then return Vector2.new(v[1], v[2]) end
            if t == "Vector3" then return Vector3.new(v[1], v[2], v[3]) end
            if t == "Color3" then return Color3.new(v[1], v[2], v[3]) end
            if t == "CFrame" then
                return CFrame.new(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12])
            end
            return nil
        end

        -- a MeshPart gets its Size from makeMesh, so its size props are skipped here (MeshSize is read-only anyway)
        local function applyProps(inst, props)
            if type(props) ~= "table" then return end
            local isMesh = inst:IsA("MeshPart")
            for k, v in pairs(props) do
                local skip = k == "MeshSize" or (isMesh and (k == "MeshId" or k == "Size"))
                if not skip then
                    pcall(function()
                        local val = toValue(inst[k], v)
                        if val ~= nil then inst[k] = val end
                    end)
                end
            end
        end

        local function near(a, b)
            for i = 1, 3 do
                local x, y = a[i], b[i]
                if math.abs(x - y) > math.max(0.001, math.abs(y) * 0.02) then return false end
            end
            return true
        end

        local function meshSizeOf(p)
            local ok, ms = pcall(function() return p.MeshSize end)
            if ok and typeof(ms) == "Vector3" then return { ms.X, ms.Y, ms.Z } end
            return nil
        end

        -- rendered size = native * Size / MeshSize. native is the data MeshSize, so Size = design * MeshSize / native
        local function sizeMesh(p, design, native)
            local ms = meshSizeOf(p) or { 1, 1, 1 }
            local out = {}
            for i = 1, 3 do
                local ref = native and native[i] or 0
                if ref > 0 and ms[i] > 0 then
                    out[i] = design[i] * ms[i] / ref
                else
                    out[i] = design[i]
                end
            end
            pcall(function() p.Size = Vector3.new(out[1], out[2], out[3]) end)
        end

        -- a MeshPart: the asset service hands back a loaded one first; else MeshId is set and the engine gets time to read the mesh
        local function makeMesh(meshId, design, native)
            if type(meshId) ~= "string" or meshId == "" then return nil end
            local okA, got = pcall(function()
                return game:GetService("AssetService"):CreateMeshPartAsync(meshId)
            end)
            if okA and got then
                sizeMesh(got, design, native)
                return got
            end
            local okP, p = pcall(Instance.new, "MeshPart")
            if not okP or not p then return nil end
            if not pcall(function() p.MeshId = meshId end) then
                pcall(function() p:Destroy() end)
                return nil
            end
            local waited = 0
            while waited < 3 do
                local ms = meshSizeOf(p)
                if ms and native and near(ms, native) then break end
                task.wait(0.05)
                waited = waited + 0.05
            end
            sizeMesh(p, design, native)
            return p
        end

        -- longest axis index, and the thinnest of the other two
        local function axisIdx(size)
            local iL = 1
            for i = 2, 3 do if size[i] > size[iL] then iL = i end end
            local iT = nil
            for i = 1, 3 do
                if i ~= iL and (iT == nil or size[i] < size[iT]) then iT = i end
            end
            return iL, iT
        end

        local function cross(a, b)
            return { a[2] * b[3] - a[3] * b[2], a[3] * b[1] - a[1] * b[3], a[1] * b[2] - a[2] * b[1] }
        end

        -- row-major rotation (9 numbers): the part's longest axis lies on lon, its thinnest on thin (lon and thin are unit and orthogonal)
        local function rotFor(size, lon, thin)
            local iL, iT = axisIdx(size)
            local iM = 6 - iL - iT
            local cols = {}
            cols[iL] = lon
            cols[iT] = thin
            if iM == 3 then
                cols[3] = cross(cols[1], cols[2])
            elseif iM == 1 then
                cols[1] = cross(cols[2], cols[3])
            else
                cols[2] = cross(cols[3], cols[1])
            end
            return {
                cols[1][1], cols[2][1], cols[3][1],
                cols[1][2], cols[2][2], cols[3][2],
                cols[1][3], cols[2][3], cols[3][3],
            }
        end

        -- the skin's display model as instances, not yet in the world
        local function buildVisual(rec)
            local d = rec.d
            local dp = d.p or {}
            local root
            if d.c == "MeshPart" then
                root = makeMesh(dp.MeshId, dp.Size or { 1, 1, 1 }, dp.MeshSize)
            else
                local ok, made = pcall(Instance.new, d.c or "Part")
                root = ok and made or nil
            end
            if not root then return nil end
            applyProps(root, dp)
            root.Name = "SkinVisual"
            local byPath = {}
            for _, n in ipairs(d.n or {}) do
                local cls, name, parent, props = n[1], n[2], n[3], n[4]
                if VIS[cls] then
                    local inst
                    if cls == "MeshPart" then
                        inst = makeMesh(props and props.MeshId, (props and props.Size) or { 1, 1, 1 }, props and props.MeshSize)
                    else
                        local ok, made = pcall(Instance.new, cls)
                        inst = ok and made or nil
                    end
                    if inst then
                        inst.Name = name
                        applyProps(inst, props)
                        local pinst = (parent ~= "" and byPath[parent]) or root
                        pcall(function() inst.Parent = pinst end)
                        byPath[parent ~= "" and (parent .. "/" .. name) or name] = inst
                    end
                end
            end
            return root
        end

        local function torsoOf(char, belt)
            local name
            if belt then
                name = char:FindFirstChild("LowerTorso") and "LowerTorso" or "Torso"
            else
                name = char:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
            end
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then return p end
            return nil
        end

        -- where a weapon sits when it is not in hand: the gun on the back (long axis up the spine),
        -- the knife on the right hip (blade down, flat side out)
        local function holsterCF(kind, size, torso)
            local tx, ty, tz = torso.Size.X, torso.Size.Y, torso.Size.Z
            local iL, iT = axisIdx(size)
            local long, thin = size[iL], size[iT]
            if kind == "Gun" then
                local r = rotFor(size, { 0, 1, 0 }, { 0, 0, 1 })
                return CFrame.new(0, 0.2, tz / 2 + thin / 2 + 0.05, r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9])
            end
            local r = rotFor(size, { 0, -1, 0 }, { 1, 0, 0 })
            return CFrame.new(tx / 2 + thin / 2 + 0.05, -ty / 2 - long / 2 + 0.5, 0,
                r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9])
        end

        -- sets the pose, parents the visual and welds it to the host; false if the executor refuses any step
        local function attachTo(visual, host, parentTo, cf)
            return pcall(function()
                visual.CFrame = cf
                visual.Parent = parentTo
                local w = Instance.new("WeldConstraint")
                w.Part0 = host
                w.Part1 = visual
                w.Parent = visual
            end)
        end

        -- one slot per weapon kind: what it shows (sig, mode "hand" or "holster"), where (char, tool, handle), its visual and its undo list
        local SLOT = { Knife = { token = 0 }, Gun = { token = 0 } }
        local stopped = false

        local function kindOf(tool)
            if tool:GetAttribute("IsKnife") then return "Knife" end
            if tool:GetAttribute("IsGun") then return "Gun" end
            local n = string.lower(tool.Name)
            if string.find(n, "knife", 1, true) then return "Knife" end
            if string.find(n, "gun", 1, true) then return "Gun" end
            return nil
        end

        local function realChar()
            local char = lp.Character
            if not char then return nil end
            if _G.BACKTRACK_CLONES and _G.BACKTRACK_CLONES[char] then return nil end
            if _G.VIEWPORT_CLONE and char == _G.VIEWPORT_CLONE then return nil end
            if char:GetAttribute("1") then return nil end
            return char
        end

        local function heldOf(char, kind)
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Tool") and kindOf(c) == kind then return c end
            end
            return nil
        end

        local function restoreUndo(undo)
            for i = #undo, 1, -1 do
                local u = undo[i]
                pcall(function() u[1][u[2]] = u[3] end)
            end
        end

        -- drops the slot: destroys its visual, puts the stock values back, and bumps the token so a build still running is dropped
        local function clearSlot(kind)
            local s = SLOT[kind]
            s.token = s.token + 1
            if s.visual then pcall(function() s.visual:Destroy() end) end
            restoreUndo(s.undo or {})
            SLOT[kind] = { token = s.token }
        end

        local function setUndo(undo, inst, prop, value)
            local ok, old = pcall(function() return inst[prop] end)
            if not ok then return end
            if pcall(function() inst[prop] = value end) then
                undo[#undo + 1] = { inst, prop, old }
            end
        end

        local function override(undo, inst, prop, raw)
            local ok, val = pcall(function() return toValue(inst[prop], raw) end)
            if ok and val ~= nil then setUndo(undo, inst, prop, val) end
        end

        local function findPath(root, path)
            local cur = root
            for seg in string.gmatch(path, "[^/]+") do
                if not cur then return nil end
                cur = cur:FindFirstChild(seg)
            end
            return cur
        end

        local function dropVisual(visual)
            if visual then pcall(function() visual:Destroy() end) end
        end

        -- in hand: the visual sits on the held Handle; the stock parts go invisible, the tool takes the skin's grip, icon and sound/anim ids
        local function applyHand(kind, token, tool, handle, rec)
            local visual = buildVisual(rec)
            local s = SLOT[kind]
            if token ~= s.token then
                dropVisual(visual)
                return
            end
            if not visual or not handle.Parent or not tool.Parent then
                dropVisual(visual)
                notify("skin " .. rec.label .. " could not be built", "warn")
                return
            end
            if not attachTo(visual, handle, tool, handle.CFrame) then
                dropVisual(visual)
                notify("skin " .. rec.label .. " could not be welded", "warn")
                return
            end
            local undo = {}
            for _, d in ipairs(tool:GetDescendants()) do
                if d ~= visual and not d:IsDescendantOf(visual) and (d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture")) then
                    setUndo(undo, d, "Transparency", 1)
                end
            end
            local t = rec.t
            if t then
                local p = t.p or {}
                if p.Grip ~= nil then override(undo, tool, "Grip", p.Grip) end
                if type(p.TextureId) == "string" and p.TextureId ~= "" then override(undo, tool, "TextureId", p.TextureId) end
                if type(p.ToolTip) == "string" and p.ToolTip ~= "" then override(undo, tool, "ToolTip", p.ToolTip) end
                for _, n in ipairs(t.n or {}) do
                    local cls, name, parent, props = n[1], n[2], n[3], n[4]
                    local prop = TOOL_PROP[cls]
                    if prop and props and props[prop] ~= nil then
                        local path = parent ~= "" and (parent .. "/" .. name) or name
                        local target = findPath(tool, path)
                        if target and target:IsA(cls) then override(undo, target, prop, props[prop]) end
                    end
                end
            end
            s.visual, s.undo = visual, undo
        end

        -- not in hand: the visual is welded to the torso (gun on the back, knife on the belt); the stock tool is not touched
        local function applyHolster(kind, token, char, rec)
            local visual = buildVisual(rec)
            local s = SLOT[kind]
            local torso = torsoOf(char, kind == "Knife")
            if token ~= s.token or not torso or not torso.Parent then
                dropVisual(visual)
                return
            end
            if not visual then
                notify("skin " .. rec.label .. " could not be built", "warn")
                return
            end
            local cf = torso.CFrame * holsterCF(kind, rec.d.p.Size or { 1, 1, 1 }, torso)
            if not attachTo(visual, torso, char, cf) then
                dropVisual(visual)
                notify("skin " .. rec.label .. " could not be welded", "warn")
                return
            end
            s.visual = visual
        end

        -- the held tool decides: a knife slot follows the knife, a gun slot the gun; the one not in hand goes to the holster
        local function sync()
            local char = realChar()
            for _, kind in ipairs({ "Knife", "Gun" }) do
                local sig = nil
                if char and Settings.SkinChanger then
                    local pick
                    if kind == "Knife" then pick = Settings.SkinKnife else pick = Settings.SkinGun end
                    if type(pick) == "string" and pick ~= "" then sig = pick end
                end
                local rec = sig and get(sig) or nil
                local mode, tool, handle = nil, nil, nil
                if char and rec then
                    tool = heldOf(char, kind)
                    handle = tool and tool:FindFirstChild("Handle") or nil
                    if handle and handle:IsA("BasePart") then
                        mode = "hand"
                    else
                        tool, handle = nil, nil
                        if Settings.SkinHolster then mode = "holster" end
                    end
                end
                local s = SLOT[kind]
                local same = s.mode == mode and s.sig == sig and s.char == char and s.tool == tool and s.handle == handle
                if not same then
                    clearSlot(kind)
                    s = SLOT[kind]
                    s.mode, s.sig, s.char, s.tool, s.handle = mode, sig, char, tool, handle
                    if mode then
                        local token = s.token
                        if mode == "hand" then
                            task.spawn(function() pcall(applyHand, kind, token, tool, handle, rec) end)
                        else
                            task.spawn(function() pcall(applyHolster, kind, token, char, rec) end)
                        end
                    end
                end
            end
        end

        local function stop()
            stopped = true
            clearSlot("Knife")
            clearSlot("Gun")
        end

        task.spawn(function()
            while running and not stopped do
                pcall(sync)
                task.wait(0.2)
            end
        end)

        return {
            stop = stop,
            sync = function() pcall(sync) end,
            list = function() return data().list end,
            get = get,
        }
    end
    ST.skins = setupSkins()
end)()

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
    ST.fxColor = fxc

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

---------------------------------------------------------------------
-- drone: shahed-136 or fpv kamikaze, ported from the rock hub's drone tab. the camera is the drone's eye, the
-- character stays put (frozen, hidden). impact: kill = the kill aura's knife stabs the target (KNIFE), fling =
-- FLING.run on the target. both impacts are locked by safe mode; the flight itself works in safe mode.
-- the target cam keeps the last 3.2 s and replays them after a hit. the rock hub's desync is not here.
---------------------------------------------------------------------
local DRONE = (function()
    local ContentProvider = game:GetService("ContentProvider")
    local SoundService = game:GetService("SoundService")
    local Debris = game:GetService("Debris")

    local ACCENT = Color3.fromRGB(255, 255, 255)
    local FLIGHT_SECS = 45      -- fuel: the drone detonates by itself after this
    local REPLAY_SECS = 3.2     -- the target cam keeps this many seconds of the flight
    local SHAHED_IDS = { 120141614672192, 111443745475294, 16531510943 }
    local SHAHED_FLIP = { [120141614672192] = -1 }
    local FPV_IDS = { 124994246147928, 129274863429961, 79445961621887 }
    local FPV_FLIP = {}
    local SOUND_IDS = {
        engine = { 106621472307027, 117678889994053, 86747216998490 },
        boom = { 125127520917980, 7157159568, 9126102254 },
        rumble = { 1843024924, 9846227426, 138432031406888 },
        static = { 96891705634188, 83265726239905, 128865910652923 },
        fpv = { 114037851906101, 78411105609654, 122096583027065 },
    }

    local models = {}            -- kind -> drone model (never parented, cloned per flight)
    local loadingModel = false
    local soundCache = {}        -- key -> rbxassetid string
    local loadingSounds = false
    local overlayGui = nil       -- one screen gui for a flight (hud, crosshair, osd, pip, signal lost)
    local flying = nil           -- the running flight: { abort = fn, bind = name, drone = instance }
    local busy = false           -- a launch is loading or flying
    local preFlightCf = nil     -- the camera's pose before the flight, handed back after it

    local function overlay()
        if overlayGui and overlayGui.Parent then return overlayGui end
        overlayGui = mk("ScreenGui", { Name = rname(), ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 45 }, guiParent)
        return overlayGui
    end

    -- hrp, humanoid, character of a player that is alive (nothing otherwise)
    local function droneAlive(p)
        local c = p and p.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp and hum and hum.Health > 0 then return hrp, hum, c end
    end

    -- every other living player with the distance to origin (lobby players included, as in the rock hub)
    local function droneTargets(origin)
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local hrp = droneAlive(p)
                if hrp then
                    list[#list + 1] = { p = p, hrp = hrp, d = (hrp.Position - origin).Magnitude }
                end
            end
        end
        return list
    end

    -- what each part had before a flight hid it (the engine sets some: first person, occlusion)
    local ltmBefore = setmetatable({}, { __mode = "k" })

    local function hideChar(char, on)
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("Decal") then
                if on then
                    if ltmBefore[d] == nil then ltmBefore[d] = d.LocalTransparencyModifier end
                    d.LocalTransparencyModifier = 1
                else
                    d.LocalTransparencyModifier = ltmBefore[d] or 0
                    ltmBefore[d] = nil
                end
            end
        end
    end

    -- hands the camera back to the default controls in the pose it had before the flight. switching from
    -- scriptable keeps the drone's last zoom and angle otherwise, and the camera ends up on your head
    local function handBackCamera(cam, preCf, oldType, hum)
        cam.CameraType = Enum.CameraType.Scriptable
        if preCf then cam.CFrame = preCf end
        cam.CameraType = oldType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or oldType
        if hum and hum.Parent then cam.CameraSubject = hum end
    end

    -- the target cam follows the target while the drone flies: the clone takes the live parts, the camera
    -- sits behind the target on the far side from the drone (the replay's framing)
    local function pipFollow(p, dronePos, droneCf)
        local tp = p.hrp.Position
        for _, l in ipairs(p.links) do
            l[2].CFrame = l[1].CFrame
        end
        if p.drone then p.drone:PivotTo(droneCf) end
        local dl = dronePos - tp
        local flat = Vector3.new(dl.X, 0, dl.Z)
        flat = flat.Magnitude > 0.1 and flat.Unit or Vector3.zAxis
        p.vcam.CFrame = CFrame.lookAt(tp - flat * 11 + Vector3.new(0, 5, 0), tp + Vector3.new(0, 1, 0))
    end

    local function getParts(m)
        local parts = {}
        for _, x in ipairs(m:GetDescendants()) do
            if x:IsA("BasePart") then table.insert(parts, x) end
        end
        return parts
    end

    -- procedural shahed (used when the uploaded model does not load)
    local function buildShahed()
        local m = Instance.new("Model")
        local col = Color3.fromRGB(92, 96, 100)

        local function part(className, size, cf, color, shape)
            local p = Instance.new(className)
            p.Size, p.CFrame = size, cf
            p.Color = color or col
            p.Material = Enum.Material.SmoothPlastic
            if shape then p.Shape = shape end
            p.Parent = m
            return p
        end

        local rot90 = CFrame.Angles(0, math.rad(90), 0)
        part("Part", Vector3.new(9.6, 1.3, 1.3), CFrame.new(0, 0, 0.2) * rot90, nil, Enum.PartType.Cylinder)
        part("Part", Vector3.new(1.3, 1.3, 1.3), CFrame.new(0, 0, -4.6), nil, Enum.PartType.Ball)
        part("Part", Vector3.new(0.5, 0.9, 0.9), CFrame.new(0, 0, 5.2) * rot90, Color3.fromRGB(40, 40, 40), Enum.PartType.Cylinder)
        part("Part", Vector3.new(0.12, 3.2, 0.3), CFrame.new(0, 0, 5.5), Color3.fromRGB(30, 30, 30)).Name = "Prop"
        part("WedgePart", Vector3.new(0.25, 4.9, 7.5), CFrame.fromMatrix(Vector3.new(3.05, 0, 0.75), Vector3.new(0, -1, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1)))
        part("WedgePart", Vector3.new(0.25, 4.9, 7.5), CFrame.fromMatrix(Vector3.new(-3.05, 0, 0.75), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1)))
        part("Part", Vector3.new(0.2, 1.8, 1.4), CFrame.new(5.45, 0.4, 3.9))
        part("Part", Vector3.new(0.2, 1.8, 1.4), CFrame.new(-5.45, 0.4, 3.9))
        m.WorldPivot = CFrame.new()
        return m
    end

    -- pivot on the body axis (CFrame.lookAt: the nose is -axis * sign). returns the length for scaling
    local function orientShahed(m, parts, id)
        local lo, hi = Vector3.one * math.huge, -Vector3.one * math.huge
        local boxes = {}
        for _, p in ipairs(parts) do
            local cf, h = p.CFrame, p.Size / 2
            local r = Vector3.new(
                math.abs(cf.RightVector.X) * h.X + math.abs(cf.UpVector.X) * h.Y + math.abs(cf.LookVector.X) * h.Z,
                math.abs(cf.RightVector.Y) * h.X + math.abs(cf.UpVector.Y) * h.Y + math.abs(cf.LookVector.Y) * h.Z,
                math.abs(cf.RightVector.Z) * h.X + math.abs(cf.UpVector.Z) * h.Y + math.abs(cf.LookVector.Z) * h.Z)
            lo, hi = lo:Min(cf.Position - r), hi:Max(cf.Position + r)
            table.insert(boxes, { cf.Position, r })
        end
        local size, center = hi - lo, (lo + hi) / 2
        local axis, sidebar2 = Vector3.xAxis, Vector3.zAxis
        if size.Z > size.X then
            axis, sidebar2 = Vector3.zAxis, Vector3.xAxis
        end
        local moment = 0
        for _, b in ipairs(boxes) do
            local a = b[2]:Dot(axis) * b[2]:Dot(sidebar2)
            moment = moment + (b[1] - center):Dot(axis) * a
        end
        local sign = moment >= 0 and 1 or -1
        if SHAHED_FLIP[id] then sign = SHAHED_FLIP[id] end
        m.WorldPivot = CFrame.lookAt(center, center - axis * sign)
        return math.max(size.X, size.Z)
    end

    -- procedural fpv (used when the uploaded model does not load)
    local function buildFpv()
        local m = Instance.new("Model")

        local function part(size, cf, color, shape, mat)
            local p = Instance.new("Part")
            p.Size, p.CFrame = size, cf
            p.Color = color
            p.Material = mat or Enum.Material.SmoothPlastic
            if shape then p.Shape = shape end
            p.Parent = m
            return p
        end

        local dark = Color3.fromRGB(28, 28, 30)
        part(Vector3.new(0.9, 0.25, 1.5), CFrame.new(), dark)
        for _, a in ipairs({ 45, 135, 225, 315 }) do
            local r = math.rad(a)
            local tip2 = Vector3.new(math.sin(r) * 1.45, 0, math.cos(r) * 1.45)
            part(Vector3.new(0.18, 0.1, 2.9), CFrame.lookAt(Vector3.zero, tip2) * CFrame.new(0, 0, -1.45), dark)
            part(Vector3.new(0.3, 0.32, 0.32), CFrame.new(tip2 + Vector3.new(0, 0.18, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 120, 70), Enum.PartType.Cylinder, Enum.Material.Metal)
            local prop = part(Vector3.new(0.04, 1.3, 1.3), CFrame.new(tip2 + Vector3.new(0, 0.36, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(20, 20, 20), Enum.PartType.Cylinder)
            prop.Transparency = 0.55
            prop.Name = "Prop"
        end
        part(Vector3.new(0.6, 0.45, 1.1), CFrame.new(0, 0.38, 0.1), Color3.fromRGB(40, 90, 170))
        part(Vector3.new(0.35, 0.3, 0.3), CFrame.new(0, 0.25, -0.75), Color3.fromRGB(15, 15, 15))
        part(Vector3.new(2.2, 0.55, 0.55), CFrame.new(0, -0.4, -0.7) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(110, 90, 55), Enum.PartType.Cylinder, Enum.Material.Metal)
        part(Vector3.new(0.5, 0.5, 0.5), CFrame.new(0, -0.4, -1.8), Color3.fromRGB(200, 200, 190), Enum.PartType.Ball)
        m.WorldPivot = CFrame.new()
        return m
    end

    local function orientFpv(m, parts, id)
        local lo, hi = Vector3.one * math.huge, -Vector3.one * math.huge
        for _, p in ipairs(parts) do
            local cf, h = p.CFrame, p.Size / 2
            local r = Vector3.new(
                math.abs(cf.RightVector.X) * h.X + math.abs(cf.UpVector.X) * h.Y + math.abs(cf.LookVector.X) * h.Z,
                math.abs(cf.RightVector.Y) * h.X + math.abs(cf.UpVector.Y) * h.Y + math.abs(cf.LookVector.Y) * h.Z,
                math.abs(cf.RightVector.Z) * h.X + math.abs(cf.UpVector.Z) * h.Y + math.abs(cf.LookVector.Z) * h.Z)
            lo, hi = lo:Min(cf.Position - r), hi:Max(cf.Position + r)
        end
        local size, center = hi - lo, (lo + hi) / 2
        local best, bestScore, axis = nil, 0, Vector3.zAxis
        for _, p in ipairs(parts) do
            local sz = p.Size
            local longest = math.max(sz.X, sz.Y, sz.Z)
            local shortest = math.min(sz.X, sz.Y, sz.Z)
            local score = longest * longest * shortest / math.max(shortest, 0.05)
            if longest / math.max(shortest, 0.05) > 2.2 and score > bestScore then
                local cf = p.CFrame
                local longAxis = sz.X == longest and cf.RightVector or sz.Y == longest and cf.UpVector or cf.LookVector
                if math.abs(longAxis.Y) < 0.5 then
                    best, bestScore = p, score
                end
            end
        end
        local sign = 1
        if best then
            local sz, cf = best.Size, best.CFrame
            local longAxis = sz.X == math.max(sz.X, sz.Y, sz.Z) and cf.RightVector or sz.Y == math.max(sz.X, sz.Y, sz.Z) and cf.UpVector or cf.LookVector
            axis = math.abs(longAxis.X) > math.abs(longAxis.Z) and Vector3.xAxis or Vector3.zAxis
            local half = math.max(sz.X, sz.Y, sz.Z) / 2
            local c = (cf.Position - center):Dot(axis)
            local endA, endB = c + half * math.abs(longAxis:Dot(axis)), c - half * math.abs(longAxis:Dot(axis))
            sign = math.abs(endA) >= math.abs(endB) and -1 or 1
        end
        if FPV_FLIP[id] then sign = FPV_FLIP[id] end
        m.WorldPivot = CFrame.lookAt(center, center - axis * sign)
        return math.max(size.X, size.Z)
    end

    local function pickSound(list)
        for _, id in ipairs(list) do
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. id
            s.Volume = 0
            s.Parent = SoundService
            local loaded = false
            local ok = pcall(function()
                ContentProvider:PreloadAsync({ s }, function(_, status)
                    loaded = status == Enum.AssetFetchStatus.Success
                end)
            end)
            s:Destroy()
            if ok and loaded then return "rbxassetid://" .. id end
        end
        return "rbxassetid://" .. list[1]
    end

    local function ensureSounds()
        while loadingSounds do task.wait() end
        for key in pairs(SOUND_IDS) do
            if not soundCache[key] then
                loadingSounds = true
                for nextKey, list in pairs(SOUND_IDS) do
                    if not soundCache[nextKey] then
                        local ok, id = pcall(pickSound, list)
                        if ok then soundCache[nextKey] = id end
                    end
                end
                loadingSounds = false
                break
            end
        end
    end

    -- the uploaded model when it loads (game:GetObjects), the procedural one otherwise
    local function buildModel(kind)
        ensureSounds()
        local isFpv = kind == "FPV"
        local m, usedId
        for _, id in ipairs(isFpv and FPV_IDS or SHAHED_IDS) do
            usedId = id
            local ok, objs = pcall(function()
                return game:GetObjects("rbxassetid://" .. id)
            end)
            if ok and objs and #objs > 0 then
                m = Instance.new("Model")
                for _, o in ipairs(objs) do o.Parent = m end
                for _, x in ipairs(m:GetDescendants()) do
                    if x:IsA("LuaSourceContainer") or x:IsA("Sound") or x:IsA("ClickDetector") or x:IsA("ProximityPrompt") or x:IsA("Humanoid") or x:IsA("BillboardGui") then
                        x:Destroy()
                    end
                end
                if m:FindFirstChildWhichIsA("BasePart", true) then break end
                m:Destroy()
                m = nil
            end
        end
        local extent
        if m then
            extent = (isFpv and orientFpv or orientShahed)(m, getParts(m), usedId)
        elseif isFpv then
            m = buildFpv()
            extent = 4
        else
            m = buildShahed()
            extent = 11
        end
        pcall(function()
            m:ScaleTo(m:GetScale() * (isFpv and 3 or 5) / math.max(extent, 0.1))
        end)
        m.Archivable = true
        for _, x in ipairs(m:GetDescendants()) do x.Archivable = true end
        for _, p in ipairs(getParts(m)) do
            p.Anchored = true
            p.CanCollide = false
            p.CanQuery = false
            p.CanTouch = false
        end
        m.Name = rname()
        return m
    end

    local function loadDrone(kind)
        while loadingModel do task.wait(0.1) end
        if models[kind] then return models[kind] end
        loadingModel = true
        local ok, m = pcall(buildModel, kind)
        loadingModel = false
        if not ok then error(m, 0) end
        models[kind] = m
        return m
    end

    local function playSound(key, parent, props)
        local soundId = soundCache[key]
        if not soundId then return end
        local s = Instance.new("Sound")
        s.SoundId = soundId
        for k, v in pairs(props) do s[k] = v end
        s.Parent = parent
        s:Play()
        if not s.IsLoaded then
            task.spawn(function()
                local deadline = os.clock() + 3
                while s.Parent and not s.IsLoaded and os.clock() < deadline do
                    task.wait(0.05)
                end
                if s.Parent and not s.IsPlaying then s:Play() end
            end)
        end
        return s
    end

    -- camera shake that fades out over hideAfter seconds (the offset is undone when it ends)
    local function shakeCamera(intensity, hideAfter)
        local name = rname()
        local t0, last = os.clock(), CFrame.new()
        RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, function()
            local cam = workspace.CurrentCamera
            local k = 1 - (os.clock() - t0) / hideAfter
            if k <= 0 then
                cam.CFrame = cam.CFrame * last:Inverse()
                RunService:UnbindFromRenderStep(name)
                return
            end
            local a = intensity * k * k
            local offset = CFrame.Angles((math.random() - 0.5) * a, (math.random() - 0.5) * a, (math.random() - 0.5) * a * 0.5)
            cam.CFrame = cam.CFrame * last:Inverse() * offset
            last = offset
        end)
    end

    local function explode(pos)
        local fx = mk("Part", {
            Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
            Transparency = 1, Size = Vector3.one, Position = pos,
        }, workspace.CurrentCamera)
        local e = mk("Explosion", {
            Position = pos, BlastPressure = 0, BlastRadius = 0,
            DestroyJointRadiusPercent = 0, ExplosionType = Enum.ExplosionType.NoCraters,
        }, workspace)

        local function emit(props, n)
            local emitter = mk("ParticleEmitter", { Enabled = false }, fx)
            for k, v in pairs(props) do emitter[k] = v end
            emitter:Emit(n)
        end

        emit({
            Texture = "rbxasset://textures/particles/fire_main.dds",
            Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 80, 20)),
            LightEmission = 1,
            Lifetime = NumberRange.new(0.35, 0.7),
            Speed = NumberRange.new(25, 55),
            SpreadAngle = Vector2.new(180, 180),
            Drag = 6,
            Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 14) }),
            Transparency = NumberSequence.new(0.1, 1),
        }, 60)
        emit({
            Texture = "rbxasset://textures/particles/smoke_main.dds",
            Color = ColorSequence.new(Color3.fromRGB(60, 55, 50), Color3.fromRGB(25, 25, 25)),
            Lifetime = NumberRange.new(2.5, 4.5),
            Speed = NumberRange.new(8, 22),
            SpreadAngle = Vector2.new(180, 180),
            Drag = 2,
            Acceleration = Vector3.new(0, 6, 0),
            Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 22) }),
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }),
            RotSpeed = NumberRange.new(-40, 40),
            Rotation = NumberRange.new(0, 360),
        }, 35)
        emit({
            Texture = "rbxasset://textures/particles/sparkles_main.dds",
            Color = ColorSequence.new(Color3.fromRGB(255, 190, 90)),
            LightEmission = 1,
            Lifetime = NumberRange.new(0.6, 1.4),
            Speed = NumberRange.new(60, 110),
            SpreadAngle = Vector2.new(180, 180),
            Acceleration = Vector3.new(0, -60, 0),
            Size = NumberSequence.new(0.6, 0),
        }, 80)
        local light = mk("PointLight", { Color = Color3.fromRGB(255, 160, 70), Brightness = 10, Range = 60 }, fx)
        TweenService:Create(light, TweenInfo.new(0.8), { Brightness = 0 }):Play()
        playSound("boom", fx, { Volume = 2, RollOffMinDistance = 20, RollOffMaxDistance = 1500 })
        playSound("rumble", fx, { Volume = 1.2, RollOffMinDistance = 60, RollOffMaxDistance = 3000 })
        local cam = workspace.CurrentCamera
        local d = (cam.CFrame.Position - pos).Magnitude
        if d < 200 then
            shakeCamera(0.06 * (1 - d / 200) + 0.01, 0.7)
        end
        Debris:AddItem(fx, 7)
        Debris:AddItem(e, 3)
    end

    -- the signal lost screen: static, then the box and the corners. status = what the hit did
    local function showSignalLost(targetName, flightTime, isFpv, status)
        local font = Enum.Font.Code
        local root = mk("CanvasGroup", {
            Name = rname(), Position = UDim2.fromOffset(0, -100), Size = UDim2.new(1, 0, 1, 200),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 50,
        }, overlay())
        local content2 = mk("Frame", {
            Position = UDim2.fromOffset(0, 100), Size = UDim2.new(1, 0, 1, -200), BackgroundTransparency = 1, ZIndex = 52,
        }, root)
        local function label(props)
            local o = {
                BackgroundTransparency = 1, Font = font, TextColor3 = Color3.fromRGB(235, 235, 235),
                ZIndex = 53, Parent = content2,
            }
            for k, v in pairs(props) do o[k] = v end
            return mk("TextLabel", o)
        end

        local bars = {}
        for i = 1, 42 do
            bars[i] = mk("Frame", {
                Position = UDim2.new(0, 0, (i - 1) / 42, 0), Size = UDim2.new(1.3, 0, 0.023809523809523808, 1),
                BorderSizePixel = 0, ZIndex = 51, Visible = false,
            }, root)
        end
        for i = 0, 59 do
            mk("Frame", {
                Position = UDim2.new(0, 0, i / 60, 0), Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0, ZIndex = 55,
            }, root)
        end
        local box = mk("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 92),
            BackgroundTransparency = 1, Visible = false, ZIndex = 53,
        }, content2)
        mk("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2 }, box)
        local titleLabel = label({ Size = UDim2.fromScale(1, 1), Text = "SIGNAL LOST", TextSize = 46, Parent = box })
        local noVideoLabel = label({
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.5, -58), Size = UDim2.fromOffset(300, 20),
            Text = "/!\\  NO VIDEO", TextSize = 16, TextColor3 = Color3.fromRGB(255, 60, 50), Visible = false,
        })
        local subtitle = label({
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 58), Size = UDim2.fromOffset(500, 20),
            TextSize = 15, Visible = false,
            Text = targetName and ("TARGET  " .. targetName:upper() .. "  -  " .. (status or "HIT")) or "NO TARGET",
            TextColor3 = targetName and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(170, 170, 170),
        })
        local secs = math.floor(flightTime)
        local corners = {
            label({
                Position = UDim2.fromOffset(28, 22), Size = UDim2.fromOffset(300, 18), TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = isFpv and "FPV KAMIKAZE   CAM 1" or "SHAHED-136   CAM 1",
            }),
            label({
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -28, 0, 22), Size = UDim2.fromOffset(300, 18),
                TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right,
                Text = ("REC  00:%02d:%02d"):format(secs // 60, secs % 60), TextColor3 = Color3.fromRGB(255, 60, 50),
            }),
            label({
                Position = UDim2.new(0, 28, 1, -40), Size = UDim2.fromOffset(300, 18), TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left, Text = "CH 5.8G   RSSI  0%",
            }),
            label({
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -28, 1, -40), Size = UDim2.fromOffset(300, 18),
                TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right, Text = "LINK  --.-  dB",
            }),
        }
        for _, c in ipairs(corners) do c.Visible = false end
        local staticSound = playSound("static", workspace.CurrentCamera, { Volume = 0.8 })
        local t0 = os.clock()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local t = os.clock() - t0
            if t < 0.07 then
                return
            elseif t < 0.6 then
                root.BackgroundColor3 = Color3.new(0, 0, 0)
                for _, b in ipairs(bars) do
                    local g = math.random()
                    b.Visible = true
                    b.BackgroundColor3 = Color3.new(g, g, g)
                    b.BackgroundTransparency = math.random() * 0.35
                    b.Position = UDim2.new(-math.random() * 0.3, 0, b.Position.Y.Scale, 0)
                end
            else
                if staticSound and staticSound.IsPlaying then staticSound:Stop() end
                box.Visible = true
                noVideoLabel.Visible = true
                subtitle.Visible = true
                for _, c in ipairs(corners) do c.Visible = true end
                for _, b in ipairs(bars) do
                    b.Visible = math.random() < 0.03
                    if b.Visible then
                        local g = math.random() * 0.5
                        b.BackgroundColor3 = Color3.new(g, g, g)
                        b.BackgroundTransparency = 0.6
                    end
                end
                local on = t * 2.2 % 1 < 0.62
                titleLabel.TextTransparency = on and 0 or 0.85
                noVideoLabel.TextTransparency = on and 0 or 0.6
                box.Position = UDim2.new(0.5, math.random() < 0.06 and math.random(-6, 6) or 0, 0.5, 0)
            end
        end)
        task.delay(2.15, function()
            TweenService:Create(root, TweenInfo.new(0.3), { GroupTransparency = 1 }):Play()
            task.wait(0.32)
            conn:Disconnect()
            root:Destroy()
            if staticSound then staticSound:Destroy() end
        end)
    end

    -- the kill impact: the knife from the kill aura stabs the target (two rounds, like the aura's stab + touch)
    local function killTarget(p)
        if not KNIFE.stab then return end
        local hrp, _, char = droneAlive(p)
        local part = hrp or (char and char:FindFirstChild("Head"))
        if not part then return end
        local knife
        for _ = 1, 20 do
            knife = KNIFE.knife_out()
            if knife then break end
            RunService.Heartbeat:Wait()
        end
        if not knife then return end
        for _ = 1, 2 do
            KNIFE.stab(knife)
            KNIFE.touch(knife, part)
            RunService.Heartbeat:Wait()
        end
    end

    -- one flight: setup, osd, hud, the target cam. p3 holds the pilot, the impact and the end of the flight
    local function flight(kind, impact, template)
        local hrp, hum, char = droneAlive(lp)
        if not hrp then return end
        local cam = workspace.CurrentCamera
        local isFpv = kind == "FPV"
        local function impactOn()
            return not Settings.SafeMode
        end

        pcall(function() hum:UnequipTools() end)
        local controls, ended = nil, false
        task.spawn(function()
            pcall(function()
                local c = require(lp.PlayerScripts:WaitForChild("PlayerModule", 1)):GetControls()
                c:Disable()
                controls = c
            end)
            if ended and controls then pcall(function() controls:Enable() end) end
        end)
        local oldWalkSpeed, oldJumpPower = hum.WalkSpeed, hum.JumpPower
        hum.WalkSpeed, hum.JumpPower = 0, 0
        preFlightCf = cam.CFrame
        local oldCamType = cam.CameraType
        cam.CameraType = Enum.CameraType.Scriptable
        local oldMouse, oldIcon = UIS.MouseBehavior, UIS.MouseIconEnabled

        local ignoreList = { cam, char }
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.IgnoreWater = true
        rp.FilterDescendantsInstances = ignoreList
        local groundParams = RaycastParams.new()
        groundParams.FilterType = Enum.RaycastFilterType.Exclude
        groundParams.FilterDescendantsInstances = { cam, char }

        local look = cam.CFrame.LookVector
        local turn = math.atan2(-look.X, -look.Z)
        local pitch = 0.12
        local pos = hrp.Position + Vector3.new(0, 1.5, 0)
        local bank = 0
        local velocity = Vector3.zero
        local t0 = os.clock()
        local done = false
        local connections2 = {}
        local fpView, vWasDown = false, false
        local bindName = rname()
        local pip

        hideChar(char, true)
        local drone = template:Clone()
        local basePart = drone:FindFirstChildWhichIsA("BasePart", true)
        drone.Parent = cam
        local props = {}
        for _, d in ipairs(drone:GetDescendants()) do
            if d:IsA("BasePart") then
                local n = d.Name:lower()
                if n:find("prop") or n:find("blade") then table.insert(props, d) end
            end
        end
        local engine = playSound(isFpv and "fpv" or "engine", basePart, { Looped = true, Volume = 1, RollOffMinDistance = 15, RollOffMaxDistance = 700 })

        local osd, osdLabels
        if isFpv then
            osd = mk("Frame", { Name = rname(), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, overlay())
            osdLabels = {}
            local function o(key, anchor, pos2, align)
                osdLabels[key] = mk("TextLabel", {
                    AnchorPoint = anchor, Position = pos2, Size = UDim2.fromOffset(200, 18), BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextStrokeTransparency = 0.3, TextXAlignment = align, Text = "",
                }, osd)
            end
            o("bat", Vector2.new(0, 0), UDim2.fromOffset(30, 70), Enum.TextXAlignment.Left)
            o("time", Vector2.new(1, 0), UDim2.new(1, -30, 0, 70), Enum.TextXAlignment.Right)
            o("alt", Vector2.new(0, 1), UDim2.new(0, 30, 1, -80), Enum.TextXAlignment.Left)
            o("spd", Vector2.new(1, 1), UDim2.new(1, -30, 1, -80), Enum.TextXAlignment.Right)
            o("mode", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 70), Enum.TextXAlignment.Center)
            osdLabels.mode.Text = impact:upper() .. "   ACRO"
            osdLabels.mode.TextColor3 = impact == "Kill" and Color3.fromRGB(255, 80, 70) or Color3.fromRGB(110, 190, 255)
        end

        local hud = mk("Frame", {
            Name = rname(), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24),
            Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(14, 14, 18), BackgroundTransparency = 0.25,
        }, overlay())
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, hud)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, hud)
        local hint = mk("TextLabel", {
            Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Color3.fromRGB(235, 235, 240), Text = "",
        }, hud)
        local crosshair = mk("Frame", {
            Name = rname(), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Color3.fromRGB(255, 70, 60),
        }, overlay())
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, crosshair)

        local preferredTouch = false
        pcall(function() preferredTouch = UIS.PreferredInput == Enum.PreferredInput.Touch end)
        local touchDevice = UIS.TouchEnabled and (preferredTouch or not UIS.KeyboardEnabled)
        local mobileInput = { throttle = 0, yaw = 0, lookDelta = Vector2.zero, boost = false, up = false, down = false }
        local mobileRoot

        -----------------------------------------------------------------
        -- target cam: a viewport with the target, the nearby parts and the drone; records 3.2 s, replays on a hit
        -----------------------------------------------------------------
        local function closePip()
            if not pip then return end
            pip.frame:Destroy()
            if pip.rec then pip.rec:Destroy() end
            pip = nil
        end

        local function safeClone(obj)
            local old = obj.Archivable
            obj.Archivable = true
            local ok, c = pcall(function() return obj:Clone() end)
            obj.Archivable = old
            return ok and c or nil
        end

        local function openPip(p)
            closePip()
            local th, _, targetChar = droneAlive(p)
            if not th then return end
            local frame = mk("Frame", {
                Name = rname(), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20),
                Size = UDim2.fromOffset(300, 190), BackgroundColor3 = Color3.fromRGB(10, 10, 12),
                BorderSizePixel = 0, Visible = false,
            }, overlay())
            mk("UICorner", { CornerRadius = UDim.new(0, 8) }, frame)
            mk("UIStroke", { Color = Color3.fromRGB(255, 70, 60), Thickness = 1.5, Transparency = 0.2 }, frame)
            local viewport = mk("ViewportFrame", {
                Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8),
                BackgroundColor3 = Color3.fromRGB(28, 32, 40), BorderSizePixel = 0,
                Ambient = Color3.fromRGB(150, 150, 155), LightColor = Color3.fromRGB(255, 250, 240),
                LightDirection = Vector3.new(-0.6, -1, -0.4),
            }, frame)
            mk("UICorner", { CornerRadius = UDim.new(0, 6) }, viewport)
            local vpCam = mk("Camera", { FieldOfView = 62 }, viewport)
            viewport.CurrentCamera = vpCam

            local function text(props2)
                local o = {
                    Parent = frame, TextSize = 13, Font = Enum.Font.Code, BackgroundTransparency = 1,
                    TextStrokeTransparency = 0.4, ZIndex = 4,
                }
                for k, v in pairs(props2) do o[k] = v end
                return mk("TextLabel", o)
            end

            text({
                Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = "TARGET CAM  " .. p.DisplayName:upper(),
            })
            local stampLabel = text({
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -8), Size = UDim2.new(1, -24, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 80, 70), Text = "",
            })
            local flash = mk("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
                BorderSizePixel = 0, ZIndex = 3,
            }, frame)
            mk("UICorner", { CornerRadius = UDim.new(0, 8) }, flash)
            local lostLabel = text({
                Size = UDim2.fromScale(1, 1), TextSize = 22, TextColor3 = Color3.fromRGB(235, 235, 235),
                BackgroundColor3 = Color3.new(0, 0, 0), Text = "SIGNAL LOST", Visible = false,
            })
            lostLabel.BackgroundTransparency = 0
            mk("UICorner", { CornerRadius = UDim.new(0, 8) }, lostLabel)

            local scene = Instance.new("Model")
            local overlapParams = OverlapParams.new()
            overlapParams.FilterType = Enum.RaycastFilterType.Exclude
            local excludeList = { cam }
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character then table.insert(excludeList, pl.Character) end
            end
            overlapParams.FilterDescendantsInstances = excludeList
            local gotParts = 0
            for _, part in ipairs(workspace:GetPartBoundsInRadius(th.Position, 80, overlapParams)) do
                if gotParts >= 600 then break end
                if part.Transparency < 0.95 and not part:IsA("Terrain") then
                    local c = safeClone(part)
                    if c then
                        for _, d in ipairs(c:GetDescendants()) do
                            if not (d:IsA("Decal") or d:IsA("Texture") or d:IsA("SpecialMesh") or d:IsA("SurfaceAppearance")) then
                                d:Destroy()
                            end
                        end
                        c.Anchored = true
                        c.Parent = scene
                        gotParts = gotParts + 1
                    end
                end
            end
            scene.Parent = viewport

            local links = {}
            local charClone = safeClone(targetChar)
            if charClone then
                for _, d in ipairs(charClone:GetDescendants()) do
                    if d:IsA("LuaSourceContainer") or d:IsA("Sound") then
                        d:Destroy()
                    elseif d:IsA("BasePart") then
                        d.Anchored = true
                    end
                end
                local function linkParts(a, b)
                    for _, ca in ipairs(a:GetChildren()) do
                        local cb = b:FindFirstChild(ca.Name)
                        if cb then
                            if ca:IsA("BasePart") and cb:IsA("BasePart") then
                                table.insert(links, { ca, cb })
                            end
                            linkParts(ca, cb)
                        end
                    end
                end
                linkParts(targetChar, charClone)
                charClone.Parent = viewport
            end

            local droneCopy = template:Clone()
            droneCopy.Parent = viewport
            local recLabel = mk("TextLabel", {
                Name = rname(), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14),
                Size = UDim2.fromOffset(220, 18), BackgroundTransparency = 1, Font = Enum.Font.Code,
                TextSize = 15, TextColor3 = Color3.fromRGB(255, 70, 60), TextStrokeTransparency = 0.5,
                Text = "● REC  TARGET CAM",
            }, overlay())
            pip = {
                frame = frame, vf = viewport, p = p, hrp = th, vcam = vpCam, links = links,
                drone = droneCopy, stamp = stampLabel, flash = flash, lost = lostLabel, rec = recLabel, frames = {},
            }
        end

        local function recordFrame(droneCf)
            if not pip then return end
            if not droneAlive(pip.p) then
                closePip()
                return
            end
            local now = os.clock()
            local cfs = table.create(#pip.links)
            for i, l in ipairs(pip.links) do
                cfs[i] = l[1].CFrame
            end
            table.insert(pip.frames, { t = now, drone = droneCf, cfs = cfs, tp = pip.hrp.Position })
            while #pip.frames > 2 and now - pip.frames[1].t > REPLAY_SECS do
                table.remove(pip.frames, 1)
            end
            pip.rec.TextTransparency = now * 2 % 1 < 0.6 and 0 or 0.7
        end

        local function playReplay(clip)
            if clip.rec then clip.rec:Destroy() end
            local frameList = clip.frames
            if #frameList < 2 then
                clip.frame:Destroy()
                return
            end

            local function applyFrame(f)
                for i, l in ipairs(clip.links) do
                    if f.cfs[i] then l[2].CFrame = f.cfs[i] end
                end
                clip.drone:PivotTo(f.drone)
                local delta = f.drone.Position - f.tp
                local flatDist = Vector3.new(delta.X, 0, delta.Z)
                flatDist = flatDist.Magnitude > 0.1 and flatDist.Unit or Vector3.zAxis
                local camPos = f.tp - flatDist * 11 + Vector3.new(0, 5, 0)
                return CFrame.lookAt(camPos, f.tp + delta.Unit * 6 + Vector3.new(0, 1, 0))
            end

            local frame = clip.frame
            frame.Visible = true
            frame.Size = UDim2.fromOffset(0, 0)
            TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(300, 190) }):Play()
            local startT = frameList[1].t
            local len = frameList[#frameList].t - startT
            local camCf
            local cur = 1
            local playStart = os.clock()
            while true do
                local t = os.clock() - playStart
                if t > len then break end
                while cur < #frameList and frameList[cur + 1].t - startT <= t do
                    cur = cur + 1
                end
                local want = applyFrame(frameList[cur])
                camCf = camCf and camCf:Lerp(want, 0.25) or want
                clip.vcam.CFrame = camCf
                clip.stamp.Text = ("● REC  00:00:%05.2f   REPLAY"):format(t)
                RunService.RenderStepped:Wait()
            end
            local last = frameList[#frameList]
            clip.drone:Destroy()
            local fireball = mk("Part", {
                Shape = Enum.PartType.Ball, Size = Vector3.one * 2, Anchored = true, Material = Enum.Material.Neon,
                Color = Color3.fromRGB(255, 150, 50), CFrame = CFrame.new(last.drone.Position),
            }, clip.vf)
            clip.flash.BackgroundTransparency = 0
            TweenService:Create(clip.flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(fireball, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * 22, Color = Color3.fromRGB(70, 60, 55), Transparency = 0.4 }):Play()
            local shakeStart = os.clock()
            while os.clock() - shakeStart < 0.6 do
                local k = 1 - (os.clock() - shakeStart) / 0.6
                local base = camCf or clip.vcam.CFrame
                clip.vcam.CFrame = base * CFrame.Angles((math.random() - 0.5) * 0.08 * k, (math.random() - 0.5) * 0.08 * k, 0)
                RunService.RenderStepped:Wait()
            end
            clip.lost.Visible = true
            task.wait(0.9)
            TweenService:Create(frame, TweenInfo.new(0.2), { Size = UDim2.fromOffset(0, 0) }):Play()
            task.wait(0.22)
            frame:Destroy()
        end

        local camCf = cam.CFrame

        -----------------------------------------------------------------
        -- end of the flight: restores the character, the camera, the mouse and the controls
        -----------------------------------------------------------------
        local function endFlight(exploded)
            ended = true
            for _, c in ipairs(connections2) do c:Disconnect() end
            RunService:UnbindFromRenderStep(bindName)
            if engine then engine:Stop() end
            drone:Destroy()
            hud:Destroy()
            if mobileRoot then mobileRoot:Destroy() end
            closePip()
            crosshair:Destroy()
            if osd then osd:Destroy() end
            UIS.MouseBehavior, UIS.MouseIconEnabled = oldMouse, oldIcon
            local t = os.clock()
            while exploded and os.clock() - t < 2.45 do
                if char.Parent then hideChar(char, true) end
                RunService.Heartbeat:Wait()
            end
            if char.Parent then hideChar(char, false) end
            if controls then pcall(function() controls:Enable() end) end
            hum.WalkSpeed, hum.JumpPower = oldWalkSpeed, oldJumpPower
            handBackCamera(cam, preFlightCf, oldCamType, hum)
            preFlightCf = nil
            flying = nil
            busy = false
        end

        -- the nearest living player within 16 studs of the blast gets the impact and the replay
        local function detonate(at)
            if done then return end
            done = true
            local best, bestDist = nil, 16
            for _, e in ipairs(droneTargets(at)) do
                if e.d < bestDist then
                    best, bestDist = e.p, e.d
                end
            end
            if pip and best and pip.p == best then
                local clip = pip
                pip = nil
                local last = clip.frames[#clip.frames]
                table.insert(clip.frames, { t = os.clock(), drone = CFrame.new(at), cfs = last and last.cfs or {}, tp = clip.hrp.Position })
                task.delay(2.5, playReplay, clip)
            end
            local hit = (best and impactOn()) or false
            if hit and impact == "Kill" then
                task.spawn(killTarget, best)
            end
            showSignalLost(best and best.DisplayName, os.clock() - t0, isFpv, hit and "HIT" or "SAFE MODE")
            explode(at)
            if hit and impact == "Fling" then
                endFlight(false)
                task.spawn(FLING.run, best)
            else
                task.spawn(endFlight, true)
            end
        end

        local function abort()
            if done then return end
            done = true
            task.spawn(endFlight, false)
        end

        table.insert(connections2, UIS.InputBegan:Connect(function(input, gp)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not gp and os.clock() - t0 > 0.5 then detonate(pos) end
            elseif input.KeyCode == Enum.KeyCode.X then
                abort()
            end
        end))
        table.insert(connections2, hum.Died:Connect(abort))

        -----------------------------------------------------------------
        -- touch: stick (fly), drag pad (aim), buttons
        -----------------------------------------------------------------
        if touchDevice then
            mobileRoot = mk("Frame", { Name = rname(), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, overlay())
            local stickBase = mk("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 24, 1, -28), Size = UDim2.fromOffset(136, 136),
                BackgroundColor3 = Color3.fromRGB(14, 14, 18), BackgroundTransparency = 0.28, Active = true, ZIndex = 20,
            }, mobileRoot)
            mk("UICorner", { CornerRadius = UDim.new(1, 0) }, stickBase)
            mk("UIStroke", { Color = ACCENT, Thickness = 2, Transparency = 0.35 }, stickBase)
            local stickKnob = mk("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(54, 54),
                BackgroundColor3 = ACCENT, BackgroundTransparency = 0.08, ZIndex = 21,
            }, stickBase)
            mk("UICorner", { CornerRadius = UDim.new(1, 0) }, stickKnob)
            local stickTouch

            local function resetStick()
                stickTouch = nil
                mobileInput.throttle, mobileInput.yaw = 0, 0
                stickKnob.Position = UDim2.fromScale(0.5, 0.5)
            end

            local function updateStick(input)
                local center = stickBase.AbsolutePosition + stickBase.AbsoluteSize / 2
                local delta = Vector2.new(input.Position.X, input.Position.Y) - center
                local radius = stickBase.AbsoluteSize.X * 0.36
                if delta.Magnitude > radius then delta = delta.Unit * radius end
                mobileInput.yaw = math.clamp(delta.X / radius, -1, 1)
                mobileInput.throttle = math.clamp(-delta.Y / radius, -1, 1)
                stickKnob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
            end

            table.insert(connections2, stickBase.InputBegan:Connect(function(input)
                if not stickTouch and input.UserInputType == Enum.UserInputType.Touch then
                    stickTouch = input
                    updateStick(input)
                end
            end))
            table.insert(connections2, UIS.InputChanged:Connect(function(input)
                if input == stickTouch then updateStick(input) end
            end))
            table.insert(connections2, UIS.InputEnded:Connect(function(input)
                if input == stickTouch then resetStick() end
            end))

            local lookPad = mk("Frame", {
                Position = UDim2.fromScale(0.38, 0), Size = UDim2.new(0.62, 0, 1, -190),
                BackgroundTransparency = 1, Active = true, ZIndex = 19,
            }, mobileRoot)
            mk("TextLabel", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 18), Size = UDim2.fromOffset(130, 22),
                BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "DRAG TO AIM", TextSize = 12,
                TextColor3 = Color3.fromRGB(225, 225, 230), TextTransparency = 0.35, ZIndex = 20,
            }, lookPad)
            local lookTouch
            table.insert(connections2, lookPad.InputBegan:Connect(function(input)
                if not lookTouch and input.UserInputType == Enum.UserInputType.Touch then
                    lookTouch = input
                end
            end))
            table.insert(connections2, UIS.InputChanged:Connect(function(input)
                if input == lookTouch then
                    mobileInput.lookDelta = mobileInput.lookDelta + Vector2.new(input.Delta.X, input.Delta.Y)
                end
            end))
            table.insert(connections2, UIS.InputEnded:Connect(function(input)
                if input == lookTouch then lookTouch = nil end
            end))

            local function controlButton(label, x, y, callback, holdKey)
                local button = mk("TextButton", {
                    AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, x, 1, y), Size = UDim2.fromOffset(82, 54),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 23), BackgroundTransparency = 0.16, AutoButtonColor = false,
                    Font = Enum.Font.GothamBold, Text = label, TextSize = 12, TextColor3 = Color3.fromRGB(245, 245, 248), ZIndex = 22,
                }, mobileRoot)
                mk("UICorner", { CornerRadius = UDim.new(0, 12) }, button)
                mk("UIStroke", { Color = label == "BOOM" and Color3.fromRGB(255, 75, 60) or ACCENT, Thickness = 1.5, Transparency = 0.3 }, button)
                if holdKey then
                    local heldInput
                    table.insert(connections2, button.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            heldInput = input
                            mobileInput[holdKey] = true
                            button.BackgroundColor3 = ACCENT
                        end
                    end))
                    table.insert(connections2, UIS.InputEnded:Connect(function(input)
                        if input == heldInput then
                            heldInput = nil
                            mobileInput[holdKey] = false
                            button.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
                        end
                    end))
                else
                    table.insert(connections2, button.Activated:Connect(callback))
                end
            end

            controlButton("BOOST", -212, -92, nil, "boost")
            controlButton("UP", -122, -92, nil, "up")
            controlButton("DOWN", -32, -92, nil, "down")
            controlButton("VIEW", -212, -28, function() fpView = not fpView end)
            controlButton("BOOM", -122, -28, function()
                if os.clock() - t0 > 0.5 then detonate(pos) end
            end)
            controlButton("EXIT", -32, -28, abort)
        end

        -----------------------------------------------------------------
        -- movement: the sphere cast stops the drone at walls, the step slides along them
        -----------------------------------------------------------------
        local function castSphere(move)
            local hit2 = workspace:Spherecast(pos, 1.4, move, rp)
            for _ = 1, 8 do
                if not hit2 then break end
                local obj = hit2.Instance
                local m = obj:FindFirstAncestorOfClass("Model")
                local hitHum = m and m:FindFirstChildOfClass("Humanoid")
                if not (obj.Transparency >= 0.9 or not obj.CanCollide or hitHum) then break end
                table.insert(ignoreList, hitHum and m or obj)
                rp.FilterDescendantsInstances = ignoreList
                hit2 = workspace:Spherecast(pos, 1.4, move, rp)
            end
            return hit2
        end

        local function moveDrone(move)
            for _ = 1, 3 do
                if move.Magnitude < 0.001 then return end
                local hit2 = castSphere(move)
                if not hit2 then
                    pos = pos + move
                    return
                end
                local n = hit2.Normal
                local travel = math.max(hit2.Distance - 0.05, 0)
                pos = pos + move.Unit * travel + n * 0.02
                move = move - move.Unit * travel
                move = move - n * move:Dot(n)
                velocity = velocity - n * math.min(velocity:Dot(n), 0)
            end
        end

        -----------------------------------------------------------------
        -- pilot: runs every frame after the camera (its own render step, unbound in endFlight)
        -----------------------------------------------------------------
        RunService:BindToRenderStep(bindName, Enum.RenderPriority.Last.Value + 5, function(dt)
            if not running then
                abort()
                return
            end
            if done then return end
            dt = math.min(dt, 0.05)
            if not touchDevice then
                UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
                UIS.MouseIconEnabled = false
            end
            cam.CameraType = Enum.CameraType.Scriptable
            local mouseDelta = touchDevice and mobileInput.lookDelta or UIS:GetMouseDelta()
            mobileInput.lookDelta = Vector2.zero
            local turn2 = 0
            if UIS:IsKeyDown(Enum.KeyCode.A) then turn2 = turn2 + 1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then turn2 = turn2 - 1 end
            turn2 = turn2 - mobileInput.yaw
            local yawDelta = -mouseDelta.X * (touchDevice and 0.0045 or 0.0035) + turn2 * 1.8 * dt
            turn = turn + yawDelta
            pitch = math.clamp(pitch - mouseDelta.Y * (touchDevice and 0.0045 or 0.0035), -1.45, 1.3)
            local v = UIS:IsKeyDown(Enum.KeyCode.V)
            if v and not vWasDown then fpView = not fpView end
            vWasDown = v
            local rot = CFrame.Angles(0, turn, 0) * CFrame.Angles(pitch, 0, 0)
            local dir = rot.LookVector
            local fast = UIS:IsKeyDown(Enum.KeyCode.LeftShift)
            local speed = 0
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                speed = isFpv and (fast and 150 or 90) or (fast and 110 or 60)
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                speed = isFpv and -30 or -25
            end
            if touchDevice and math.abs(mobileInput.throttle) > 0.04 then
                if mobileInput.throttle > 0 then
                    speed = mobileInput.throttle * (isFpv and (mobileInput.boost and 150 or 90) or (mobileInput.boost and 110 or 60))
                else
                    speed = mobileInput.throttle * (isFpv and 30 or 25)
                end
            end
            local vert, vel = 0, isFpv and 40 or 28
            if UIS:IsKeyDown(Enum.KeyCode.Space) or mobileInput.up then vert = vert + vel end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) or mobileInput.down then vert = vert - vel end
            velocity = velocity:Lerp(dir * speed + Vector3.yAxis * vert, math.min(dt * (isFpv and 4.5 or 3), 1))
            bank = bank + (math.clamp(yawDelta / math.max(dt, 0.001) * 0.35, -0.9, 0.9) - bank) * math.min(dt * 5, 1)

            local targets = droneTargets(pos)
            for _, e in ipairs(targets) do
                if e.d < 6 then
                    detonate(e.hrp.Position)
                    return
                end
            end
            moveDrone(velocity * dt)
            local cf = CFrame.new(pos) * rot
            local tilt = isFpv and -math.clamp(velocity:Dot(dir) / 150, -0.4, 1) * 0.45 or 0
            local visualCf = cf * CFrame.Angles(tilt, 0, bank * (isFpv and 1.2 or 1))
            drone:PivotTo(visualCf)
            local spinAxis = isFpv and visualCf.UpVector or visualCf.LookVector
            for _, prop in ipairs(props) do
                prop.CFrame = CFrame.new(prop.Position) * CFrame.fromAxisAngle(spinAxis, dt * 45) * (prop.CFrame - prop.Position)
            end
            if engine and isFpv then
                engine.PlaybackSpeed = 0.9 + velocity.Magnitude / 170
            end
            local camGoal
            if fpView then
                camGoal = isFpv and cf * CFrame.new(0, 0.45, -0.9) * CFrame.Angles(0.1, 0, bank * 0.6) or cf * CFrame.new(0, 0.3, -3) * CFrame.Angles(0, 0, bank * 0.5)
            else
                camGoal = isFpv and cf * CFrame.new(0, 0.8, 2.8) * CFrame.Angles(-0.1, 0, 0) or cf * CFrame.new(0, 1.1, 4) * CFrame.Angles(-0.08, 0, 0)
            end
            local elapsed = os.clock() - t0
            if osdLabels then
                local g = workspace:Raycast(pos, Vector3.new(0, -400, 0), groundParams)
                osdLabels.bat.Text = ("BAT %.1fV"):format(16.8 - elapsed * 0.05)
                osdLabels.time.Text = ("%02d:%02d"):format(math.floor(elapsed / 60), math.floor(elapsed % 60))
                osdLabels.alt.Text = ("ALT %dm"):format(g and math.floor(g.Distance * 0.28) or 99)
                osdLabels.spd.Text = ("%d km/h"):format(math.floor(velocity.Magnitude * 0.28 * 3.6))
            end
            camCf = camCf:Lerp(camGoal, math.min(dt * (fpView and 25 or 12), 1))
            cam.CFrame = camCf

            -- the target cam follows the player that the drone is closing on fastest (time to impact under 3 s)
            local pipTarget, bestEta
            for _, e in ipairs(targets) do
                local delta = e.hrp.Position - pos
                local closing = delta.Magnitude > 0.1 and velocity:Dot(delta.Unit) or 0
                if closing > 4 then
                    local eta = delta.Magnitude / closing
                    if not bestEta or eta < bestEta then
                        pipTarget, bestEta = e.p, eta
                    end
                end
            end
            if pip and (pip.p ~= pipTarget or bestEta > 4.5) then closePip() end
            if not pip and pipTarget and bestEta < 3 then openPip(pipTarget) end
            if pip then recordFrame(visualCf) end
            if pip then pipFollow(pip, pos, visualCf) end

            local left = FLIGHT_SECS - elapsed
            if touchDevice then
                hint.Text = ("stick - fly  ·  drag - aim  ·  buttons - actions  ·  %ds"):format(math.max(0, math.ceil(left)))
            else
                hint.Text = ("mouse - aim  ·  W fly  ·  Shift fast  ·  S back  ·  Space/Ctrl up/down  ·  V view  ·  LMB boom  ·  X exit  ·  %ds"):format(math.max(0, math.ceil(left)))
            end
            if left <= 0 then detonate(pos) end
        end)

        flying = { abort = abort, bind = bindName, drone = drone }
    end

    -----------------------------------------------------------------
    -- launch: one flight at a time. a missing knife stops a kill launch (safe mode turns the impact off instead)
    -----------------------------------------------------------------
    local function launchFlight()
        if busy then return end
        if not droneAlive(lp) then
            notify("drone: no character", "warn")
            return
        end
        local kind = Settings.DroneKind == "FPV" and "FPV" or "Shahed"
        local impact = Settings.DroneImpact == "Kill" and "Kill" or "Fling"
        if impact == "Kill" and not Settings.SafeMode and not hasTool(lp, "Knife") then
            notify("kill impact needs the murderer knife", "warn")
            return
        end
        if Settings.SafeMode then
            notify("safe mode: the flight works, the impact is off", "info")
        end
        busy = true
        local template = loadDrone(kind)
        if not droneAlive(lp) then
            busy = false
            return
        end
        flight(kind, impact, template)
    end

    -- puts the character, the camera and the mouse back (after an error, or on unload)
    local function recover()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char then pcall(hideChar, char, false) end
        pcall(function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end)
        pcall(function()
            local cam = workspace.CurrentCamera
            handBackCamera(cam, preFlightCf, Enum.CameraType.Custom, hum)
            preFlightCf = nil
            if hum and hum.WalkSpeed == 0 then hum.WalkSpeed, hum.JumpPower = 16, 50 end
        end)
        pcall(function()
            require(lp.PlayerScripts.PlayerModule):GetControls():Enable()
        end)
    end

    local function launchSafe()
        local ok, err = xpcall(launchFlight, debug.traceback)
        if ok then return end
        warn("[MM2 Suite] drone: " .. tostring(err))
        notify("drone error", tostring(err):match("^[^\n]*"):sub(-110))
        if flying then
            pcall(flying.abort)
        else
            if overlayGui then
                pcall(function() overlayGui:Destroy() end)
                overlayGui = nil
            end
            recover()
        end
        busy = false
    end

    local function stop()
        if flying then pcall(flying.abort) end
        busy = false
        if overlayGui then
            pcall(function() overlayGui:Destroy() end)
            overlayGui = nil
        end
    end

    return {
        launch = function() task.spawn(launchSafe) end,
        stop = stop,
        busy = function() return busy end,
    }
end)()

---------------------------------------------------------------------
-- local movement (v13.13): walk speed, jump power, fly, noclip, infinite jump, bhop, ctrl + click teleport, unstuck.
-- the drone and the fling own the body while they run: speed and jump wait for the drone, the rest waits for both.
-- every value goes back when its switch goes off, on respawn and on unload. fly, noclip and click teleport are
-- high-risk: safe mode keeps them off, like the other risky switches
---------------------------------------------------------------------
local MOVE = (function()
    local GRAVITY = 196.2
    local JUMP_UNITS = 50 / 7.2          -- jump power per stud of jump height (the engine's default pair)
    local RISKY = { LmFly = true, LmNoclip = true, LmClickTp = true }

    local st = {
        char = nil,                      -- the character the changes below belong to
        walk = nil,                      -- WalkSpeed before our change (nil = untouched)
        jump = nil,                      -- { mode = "jp" | "jh", raw = value } before our change
        plat = false,                    -- PlatformStand we set for fly
        hold = nil,                      -- the BodyVelocity fly holds the root with
        cols = setmetatable({}, { __mode = "k" }),   -- part -> CanCollide before noclip
        stopped = false,
    }

    -- on, and a risky switch only with safe mode off
    local function want(key)
        if Settings[key] ~= true then return false end
        return not (RISKY[key] and Settings.SafeMode)
    end

    -- a new character starts clean: the old one's values are not ours to put back on it
    local function sameChar(char)
        if char == st.char then return end
        st.char, st.walk, st.jump, st.plat, st.hold = char, nil, nil, false, nil
        st.cols = setmetatable({}, { __mode = "k" })
    end

    local function readJump(hum)
        if hum.UseJumpPower then return "jp", hum.JumpPower end
        return "jh", hum.JumpHeight
    end

    -- the setting is jump power; a jump height game gets the same jump in studs
    local function writeJump(hum, mode, units)
        if mode == "jp" then hum.JumpPower = units else hum.JumpHeight = units / JUMP_UNITS end
    end

    local function restoreWalk(hum)
        if st.walk == nil then return end
        hum.WalkSpeed = st.walk
        st.walk = nil
    end

    local function restoreJump(hum)
        if st.jump == nil then return end
        if st.jump.mode == "jp" then hum.JumpPower = st.jump.raw else hum.JumpHeight = st.jump.raw end
        st.jump = nil
    end

    local function noclipOn(char)
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                if st.cols[p] == nil then st.cols[p] = true end
                p.CanCollide = false
            end
        end
    end

    local function noclipOff()
        for p, was in pairs(st.cols) do
            pcall(function() p.CanCollide = was end)
        end
        st.cols = setmetatable({}, { __mode = "k" })
    end

    -- fly: a BodyVelocity holds the root at the input's velocity (no input = hover)
    local function flyOn(hum, root)
        if not st.plat then
            hum.PlatformStand = true
            st.plat = true
        end
        if st.hold == nil then
            st.hold = mk("BodyVelocity", { Velocity = Vector3.zero, MaxForce = Vector3.new(9e9, 9e9, 9e9) }, root)
        end
        local md = hum.MoveDirection
        local up = (UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)
        local sp = Settings.LmFlySpeed
        st.hold.Velocity = Vector3.new(md.X * sp, up * sp, md.Z * sp)
    end

    -- root is passed only for our own exit: a drone or fling takeover keeps the velocity it set
    local function flyOff(hum, root)
        if st.hold ~= nil then
            pcall(function() st.hold:Destroy() end)
            st.hold = nil
            if root then root.AssemblyLinearVelocity = Vector3.zero end
        end
        if st.plat then
            hum.PlatformStand = false
            st.plat = false
        end
    end

    -- bhop: holding space re-jumps on landing; in the air the horizontal speed builds toward the cap
    local function bhop(hum, root, dt)
        if hum.FloorMaterial ~= Enum.Material.Air then
            if UIS:IsKeyDown(Enum.KeyCode.Space) then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            return
        end
        local md = hum.MoveDirection
        if md.Magnitude < 0.1 then return end
        local v = root.AssemblyLinearVelocity
        local hv = Vector3.new(v.X, 0, v.Z) + md * (180 * dt)
        local cap = Settings.LmBhopCap
        if hv.Magnitude > cap then hv = hv.Unit * cap end
        root.AssemblyLinearVelocity = Vector3.new(hv.X, v.Y, hv.Z)
    end

    -- infinite jump: a jump in the air sets the upward velocity to the jump's own
    local function airJump(hum, root)
        local jv = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * (workspace.Gravity or GRAVITY) * hum.JumpHeight)
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X, jv, v.Z)
    end

    local function clickTp(char, root)
        local cam = workspace.CurrentCamera
        if not cam then return end
        local mp = UIS:GetMouseLocation()
        local ray = cam:ScreenPointToRay(mp.X, mp.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }
        local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
        if not hit then return end
        root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
        root.AssemblyLinearVelocity = Vector3.zero
    end

    local function unstuck()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) or hum.Health <= 0 then return end
        root.CFrame = CFrame.new(root.Position + Vector3.new(0, 6, 0))
        root.AssemblyLinearVelocity = Vector3.zero
    end

    local function step(dt)
        if not running or st.stopped then return end
        local t = dt or 1 / 60
        local char = lp.Character
        sameChar(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) or hum.Health <= 0 then return end
        local drone = DRONE.busy()
        local body = drone or FLING.busy     -- the drone or the fling owns the body right now

        -- walk speed and jump power: the drone freezes both while it flies
        if not drone then
            if want("LmSpeedOn") then
                if st.walk == nil and hum.WalkSpeed > 0 then st.walk = hum.WalkSpeed end
                if st.walk ~= nil then hum.WalkSpeed = Settings.LmSpeed end
            else
                restoreWalk(hum)
            end
            if want("LmJumpOn") then
                if st.jump == nil then
                    local mode, raw = readJump(hum)
                    if raw > 0 then st.jump = { mode = mode, raw = raw } end
                end
                if st.jump ~= nil then writeJump(hum, st.jump.mode, Settings.LmJump) end
            else
                restoreJump(hum)
            end
        end

        if body then
            flyOff(hum)
            return
        end
        if want("LmFly") then
            flyOn(hum, root)
        elseif st.plat or st.hold ~= nil then
            flyOff(hum, root)
        end
        if want("LmNoclip") then
            noclipOn(char)
        elseif next(st.cols) ~= nil then
            noclipOff()
        end
        if want("LmBhop") and st.hold == nil then bhop(hum, root, t) end
    end

    connect(RunService.Heartbeat, step)

    connect(UIS.JumpRequest, function()
        if not running or st.stopped or not want("LmInfJump") or st.hold ~= nil then return end
        if DRONE.busy() or FLING.busy then return end
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) or hum.Health <= 0 then return end
        if hum.FloorMaterial ~= Enum.Material.Air then return end   -- on the ground the normal jump runs
        airJump(hum, root)
    end)

    connect(UIS.InputBegan, function(input, gp)
        if gp or not running or st.stopped then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not want("LmClickTp") or DRONE.busy() or FLING.busy then return end
        if not UIS:IsKeyDown(Enum.KeyCode.LeftControl) then return end
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then pcall(clickTp, char, root) end
    end)

    local function stop()
        if st.stopped then return end
        st.stopped = true
        local char = lp.Character
        local mine = char ~= nil and char == st.char
        local hum = mine and char:FindFirstChildOfClass("Humanoid") or nil
        local root = mine and char:FindFirstChild("HumanoidRootPart") or nil
        if hum then
            flyOff(hum, root)
            restoreWalk(hum)
            restoreJump(hum)
        elseif st.hold ~= nil then
            pcall(function() st.hold:Destroy() end)
            st.hold = nil
        end
        noclipOff()
    end

    return { stop = stop, unstuck = unstuck }
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
        game = "game", drone = "drone / shahed & fpv", esp = "visuals / esp", world = "visuals / world", fx = "visuals / fx", radar = "visuals / radar", lock = "player / target lock",
        perks = "player / local", vote = "Vote Duper", misc = "misc", stats = "live stats", presets = "settings",
        skins = "skins / skin changer",
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
    SilentAim.state.toast = function(text, kind) if ST.toast then ST.toast(text, kind) end end
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
        local role = SilentAim.state.role or "Innocent"
        local silent = Settings.SilentAim
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
    for _, n in ipairs({ "game", "drone", "esp", "world", "fx", "radar", "lock", "perks", "vote", "misc", "stats", "presets", "skins" }) do
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
        { name = "drone", sub = "shahed / fpv", icon = ICONS.Signal, page = "drone" },
        { name = "visuals", sub = "player visuals", icon = ICONS.Visuals, kids = {
            { name = "esp", page = "esp" }, { name = "world", page = "world" }, { name = "fx", page = "fx" }, { name = "radar", page = "radar" } } },
        { name = "player", sub = "local perks", icon = ICONS.Player, kids = {
            { name = "lock", page = "lock" }, { name = "local", page = "perks" } } },
        { name = "skins", sub = "knife & gun skins", icon = ICONS.Combat, page = "skins" },
        { name = "Vote Duper", sub = "map cards", icon = ICONS.Vote, page = "vote" },
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
    -- radar: a round 2d map of the living players around you. the circle sits in the screen gui, so it stays
    -- up with the hub closed. drag the circle to move it, drag the corner grip to resize, pin locks both.
    -- dots: role colours. the needle is where you look (rotate off = north up, the needle turns instead)
    -----------------------------------------------------------------
    local pageRadar
    do
        local GLASS = Color3.fromRGB(8, 8, 11)
        local BLACK = Color3.fromRGB(0, 0, 0)
        local ROLE_COL = {
            Murderer = Color3.fromRGB(236, 84, 84), Sheriff = Color3.fromRGB(92, 152, 255),
            Innocent = Color3.fromRGB(110, 220, 132),
        }
        local MIN_SIZE, MAX_SIZE = 120, 420
        local SPIN = 120                                   -- sweep: degrees per second
        local rd = {
            dots = {}, ringF = {}, cross = {}, applied = {}, vp = {}, fwd = Vector3.new(0, 0, -1),
            alpha = nil, pinned = nil, drag = nil, grab = nil,
        }

        local function pressed(input)
            local t = input.UserInputType
            return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
        end

        local function disc(parent, color, z)              -- filled circle: the dots and the centre
            local f = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.fromOffset(6, 6), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = z,
            }, parent)
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
            return f
        end

        rd.root = new("Frame", {
            Name = "Radar", Size = UDim2.fromOffset(200, 200), BackgroundColor3 = GLASS,
            BackgroundTransparency = 0.15, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, ZIndex = 5,
        }, gui)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, rd.root)
        rd.ring = stroke(rd.root, T.Dim, 1.5, 0)
        for i = 1, 2 do
            local f = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
            }, rd.root)
            new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
            stroke(f, T.Dim, 1, 0.5)
            rd.ringF[i] = f
        end
        rd.cross[1] = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Dim, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5,
        }, rd.root)
        rd.cross[2] = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 1, 1, 0),
            BackgroundColor3 = T.Dim, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5,
        }, rd.root)
        rd.sweep = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(2, 90),
            BackgroundColor3 = T.Text, BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 6,
        }, rd.root)
        rd.needle = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(2, 40),
            BackgroundColor3 = T.Text, BorderSizePixel = 0, ZIndex = 9,
        }, rd.root)
        rd.self = disc(rd.root, T.Text, 10)
        rd.north = txt(rd.root, "N", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 3), Size = UDim2.fromOffset(12, 10),
            TextSize = 8, TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Center, Visible = false, ZIndex = 8,
        })
        rd.pinLbl = txt(rd.root, "pinned", {
            AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5), Size = UDim2.fromOffset(60, 9),
            TextSize = 7, TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Center, Visible = false, ZIndex = 8,
        })
        -- the grip sits on the rim at 45 degrees (0.854 of the frame = the circle's edge there)
        rd.grip = new("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.854, 0, 0.854, 0),
            Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 12,
        }, rd.root)
        new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(8, 10), Size = UDim2.fromOffset(8, 1),
            Rotation = -45, BackgroundColor3 = T.Dim, BorderSizePixel = 0, ZIndex = 12,
        }, rd.grip)
        new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(4, 1),
            Rotation = -45, BackgroundColor3 = T.Dim, BorderSizePixel = 0, ZIndex = 12,
        }, rd.grip)

        -- size and place, clamped to the viewport; the stored values are clamped too (no drift off screen)
        local function place()
            local cam = workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
            local size = clamp(math.floor(Settings.RadarSize + 0.5), MIN_SIZE, MAX_SIZE)
            local x = clamp(Settings.RadarX, 0, math.max(0, vp.X - size))
            local y = clamp(Settings.RadarY, 0, math.max(0, vp.Y - size))
            Settings.RadarSize, Settings.RadarX, Settings.RadarY = size, x, y
            rd.applied = { s = size, x = x, y = y }
            rd.vp = { X = vp.X, Y = vp.Y }
            rd.root.Size = UDim2.fromOffset(size, size)
            rd.root.Position = UDim2.fromOffset(x, y)
            local dia = size - 12                          -- the dots keep 6 px inside the rim
            for i = 1, 2 do rd.ringF[i].Size = UDim2.fromOffset(dia * i / 3, dia * i / 3) end
            rd.sweep.Size = UDim2.fromOffset(2, dia / 2)
            rd.needle.Size = UDim2.fromOffset(2, dia * 0.2)
        end

        local function update()
            local on = Settings.RadarOn and true or false
            rd.root.Visible = on
            local cam = workspace.CurrentCamera
            if not on or not cam then return end
            local vp = cam.ViewportSize
            local a = rd.applied
            if Settings.RadarSize ~= a.s or Settings.RadarX ~= a.x or Settings.RadarY ~= a.y
                or vp.X ~= rd.vp.X or vp.Y ~= rd.vp.Y then
                place()
            end
            local pin = Settings.RadarPin and true or false
            if pin ~= rd.pinned then
                rd.pinned = pin
                rd.grip.Visible = not pin
                rd.pinLbl.Visible = pin
                rd.ring.Color = pin and T.Text or T.Dim
            end
            local alpha = 1 - Settings.RadarAlpha
            if alpha ~= rd.alpha then
                rd.alpha = alpha
                rd.root.BackgroundTransparency = alpha
            end
            local rings = Settings.RadarRings and true or false
            rd.ringF[1].Visible = rings
            rd.ringF[2].Visible = rings
            rd.cross[1].Visible = rings
            rd.cross[2].Visible = rings

            -- the view on the ground: fw = where the camera looks, rt = its right, both flat
            local look = cam.CFrame.LookVector
            local f = Vector3.new(look.X, 0, look.Z)
            if f.Magnitude > 0.05 then rd.fwd = f.Unit end
            local fw = rd.fwd
            local rt = Vector3.new(-fw.Z, 0, fw.X)
            local rotate = Settings.RadarRotate and true or false

            local me = isAlive(lp)
            local rad = rd.applied.s / 2 - 6                -- read again: place() above may have replaced rd.applied
            local k = rad / Settings.RadarRange
            local now = os.clock()
            local seen = {}
            if me then
                for _, plr in ipairs(Players:GetPlayers()) do
                    local hrp = plr ~= lp and inRound(plr) and isAlive(plr)
                    if hrp then
                        seen[plr] = true
                        local dot = rd.dots[plr]
                        if not dot then
                            dot = { f = disc(rd.root, T.Muted, 8), role = nil, at = 0 }
                            stroke(dot.f, BLACK, 1, 0.3)
                            rd.dots[plr] = dot
                        end
                        if now >= dot.at then                 -- the role is read 4 times a second
                            dot.at = now + 0.25
                            local r = getRole(plr)
                            if r ~= dot.role then
                                dot.role = r
                                dot.f.BackgroundColor3 = ROLE_COL[r] or T.Muted
                            end
                        end
                        local d = hrp.Position - me.Position
                        local sx, sy
                        if rotate then
                            sx, sy = d.X * rt.X + d.Z * rt.Z, d.X * fw.X + d.Z * fw.Z
                        else
                            sx, sy = d.X, -d.Z
                        end
                        local px, py = sx * k, -sy * k
                        local len = math.sqrt(px * px + py * py)
                        local edge = false
                        if len > rad and Settings.RadarEdge then
                            px, py = px * rad / len, py * rad / len
                            edge = true
                        end
                        if len > rad and not edge then
                            dot.f.Visible = false
                        else
                            dot.f.Visible = true
                            dot.f.Position = UDim2.new(0.5, px, 0.5, py)
                            dot.f.BackgroundTransparency = edge and 0.5 or 0
                        end
                    end
                end
            end
            for plr, dot in pairs(rd.dots) do
                if not seen[plr] then dot.f.Visible = false end
                if not plr.Parent then
                    dot.f:Destroy()
                    rd.dots[plr] = nil
                end
            end
            rd.self.Visible = me and true or false          -- dead or in the lobby: no centre dot, no needle
            rd.needle.Visible = me and true or false
            rd.needle.Rotation = rotate and 0 or (90 - math.deg(math.atan2(-fw.Z, fw.X)))
            rd.north.Visible = not rotate
            rd.sweep.Visible = Settings.RadarSweep and me and true or false
            rd.sweep.Rotation = (now * SPIN) % 360
        end
        connect(RunService.RenderStepped, update)

        rd.root.InputBegan:Connect(function(input)
            if not pressed(input) or Settings.RadarPin or not Settings.RadarOn then return end
            rd.drag = { start = input.Position, base = Vector2.new(Settings.RadarX, Settings.RadarY) }
        end)
        rd.grip.InputBegan:Connect(function(input)
            if not pressed(input) or Settings.RadarPin then return end
            rd.grab = { start = input.Position, size = rd.applied.s }
        end)
        connect(UIS.InputChanged, function(input)
            local t = input.UserInputType
            if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
            if rd.drag then
                -- the place comes from the press point, not from the last clamped value: no dead zone at the edge
                local d = input.Position - rd.drag.start
                Settings.RadarX = rd.drag.base.X + d.X
                Settings.RadarY = rd.drag.base.Y + d.Y
                place()
            end
            if rd.grab then
                local d = input.Position - rd.grab.start
                Settings.RadarSize = rd.grab.size + (d.X + d.Y) / 2
                place()
            end
        end)
        connect(UIS.InputEnded, function(input)
            local t = input.UserInputType
            if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
            if rd.drag or rd.grab then
                rd.drag, rd.grab = nil, nil
                markDirty()
                refreshAll()
            end
        end)

        pageRadar = function()
            curPage = "radar"
            local a = card(PG.radar, "radar", "left")
            toggleRow(a, "RadarOn", "radar", "round map of the living players around you", {
                sub = function(d)
                    sliderRow(d, "RadarRange", "range", 40, 400, 10, "%.0f st")
                    sliderRow(d, "RadarSize", "size", MIN_SIZE, MAX_SIZE, 10, "%.0f px")
                    sliderRow(d, "RadarAlpha", "opacity", 0.2, 1, 0.05, "%.2f")
                end,
            })
            toggleRow(a, "RadarPin", "pin", "locks the place and the size. off = drag the circle, drag the corner grip")
            btnRow(a, "reset place and size", function()
                Settings.RadarX, Settings.RadarY, Settings.RadarSize = 24, 220, 200
                markDirty()
                refreshAll()
            end)
            local b = card(PG.radar, "look", "right")
            toggleRow(b, "RadarRotate", "rotate with the view", "off = north up, the needle turns to where you look")
            toggleRow(b, "RadarEdge", "edge markers", "players past the range sit on the rim, dimmed")
            toggleRow(b, "RadarRings", "rings and cross", "distance rings and the centre cross")
            toggleRow(b, "RadarSweep", "sweep", "a line turns around the circle")
            infoRow(b, "dots: red murderer, blue sheriff, green innocent. only living players of the round show")
        end
    end -- radar

    -----------------------------------------------------------------
    -- game page: sheriff, murder (left) / autos, script aim (right)
    -----------------------------------------------------------------
    -- one silent at a time: the silent aim and the script aim switch each other off
    local function offSwitch(key)
        if not Settings[key] then return end
        setSetting(key, false)
        if REG[key] then pcall(REG[key].set, false) end
    end

    local function pageGame()
        curPage = "game"
        local S = card(PG.game, "sheriff", "left")
        toggleRow(S, "SilentAim", "silent", "the shot goes out on the predicted line. knife throws too", {
            onChange = function(v) if v then offSwitch("ScriptAim") end end,
            sub = function(d)
                dropRow(d, "TargetMode", "target", OPTS.TargetMode)
                dropRow(d, "AimPart", "aim part", OPTS.AimPart)
                dropRow(d, "WallCheck", "wall check", OPTS.WallCheck)
                sliderRow(d, "FOV", "fov (cursor mode)", 30, 400, 10, "%.0f px")
                sliderRow(d, "MaxDist", "max distance", 50, 500, 10, "%.0f st")
                sliderRow(d, "AimHeight", "aim height", -3, 3, 0.1, "%+.1f")
                toggleRow(d, "VisibleOnly", "visible targets only")
                toggleRow(d, "AvoidInnocents", "avoid players on the line")
                sliderRow(d, "PredStrength", "lead multiplier", 0.5, 2, 0.05, "%.2fx")
                sliderRow(d, "Interp", "interp delay", 0, 200, 5, "%.0f ms")
                sliderRow(d, "HitRadius", "hit radius", 0.8, 3, 0.1, "%.1f st")
                sliderRow(d, "Overshoot", "overshoot", 0, 8, 0.5, "%.1f st")
                sliderRow(d, "KnifeSpeed", "knife speed", 30, 400, 5, "%.0f st/s")
                btnRow(d, "reset learning", function() SilentAim.resetLearning() end)
            end,
        })
        toggleRow(S, "AutoShoot", "auto shoot", "fires by itself at the murderer when the chance to hit is high", {
            risk = "mid",
            sub = function(d)
                sliderRow(d, "AutoConf", "min confidence", 50, 95, 1, "%.0f %%")
                sliderRow(d, "AutoRange", "max range", 30, 400, 10, "%.0f st")
                sliderRow(d, "AutoCooldown", "cooldown", 1, 6, 0.1, "%.1f s")
                toggleRow(d, "AutoEquip", "equip the gun early", "takes the gun out while a shot is prepared")
            end,
        })

        local M = card(PG.game, "murder", "left")
        toggleRow(M, "KillAura", "kill aura", "stabs everyone inside the distance as the murderer", {
            sub = function(d)
                sliderRow(d, "KillDistance", "distance", 5, 60, 1, "%.0f st")
            end,
        })
        toggleRow(M, "KillAll", "kill all", "stabs every player, no distance", { risk = "high" })

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
            onChange = function(v) if v then offSwitch("SilentAim") end end,
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
        infoRow(F, "fling = locked player, else the nearest. the root goes around the target for up to 2 s; the target is launched or the window ends, then you go back to your spot. needs safe mode off.")
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

    local function pageDrone()
        curPage = "drone"
        local dc = card(PG.drone, "drone", "left")
        dropRow(dc, "DroneKind", "type", OPTS.DroneKind)
        dropRow(dc, "DroneImpact", "impact", OPTS.DroneImpact)
        btnRow(dc, "launch drone", function() DRONE.launch() end)
        infoRow(dc, "kill needs the murderer knife, fling works for every role. safe mode turns the impact off, the flight still works")
        local hc = card(PG.drone, "controls", "left")
        infoRow(hc, "mouse aims, W fly, shift fast, S back, space / ctrl up and down, V view, LMB or BOOM detonates, X exits. touch: stick, drag to aim, buttons")
        infoRow(hc, "the target cam records the last 3.2 s and replays it when the drone hits a player")
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
        -- colour: three sliders (0-255) and quick picks; the picks and the reset write the same three settings
        local function setAura(c)
            setSetting("AuraR", math.floor(c.R * 255 + 0.5))
            setSetting("AuraG", math.floor(c.G * 255 + 0.5))
            setSetting("AuraB", math.floor(c.B * 255 + 0.5))
            refreshAll()
        end
        toggleRow(au, "WorldAura", "aura", "particle aura on your own character", {
            sub = function(d)
                dropRow(d, "AuraType", "type", auras.types)
                sliderRow(d, "AuraR", "red", 0, 255, 1, "%.0f")
                sliderRow(d, "AuraG", "green", 0, 255, 1, "%.0f")
                sliderRow(d, "AuraB", "blue", 0, 255, 1, "%.0f")
                paletteRow(d, setAura)
                btnRow(d, "reset to ice", function() setAura(Color3.fromRGB(133, 220, 255)) end)
            end,
        })
        local nv = card(PG.world, "nova Aura", "right")
        toggleRow(nv, "NovaAura", "nova Aura", "orbs, trails and sparks around your character", {
            sub = function(d)
                dropRow(d, "NovaAuraStyle", "style", OPTS.NovaAuraStyle)
                dropRow(d, "NovaAuraColor", "color", OPTS.NovaAuraColor)
                sliderRow(d, "NovaAuraSize", "radius", 2, 7, 0.1, "%.1f")
                sliderRow(d, "NovaAuraSpeed", "speed", 0.3, 3, 0.1, "%.1f")
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
            if SilentAim.state.forced == plr then
                SilentAim.lock(nil)
                notify("target lock released", "info")
            else
                SilentAim.lock(plr)
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
                local locked = SilentAim.state.forced == plr
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
        local m = card(PG.perks, "local movement", "left")
        toggleRow(m, "LmSpeedOn", "speed", "walk speed, set every frame. off puts the old value back", {
            sub = function(d)
                sliderRow(d, "LmSpeed", "walk speed", 16, 300, 1, "%.0f")
            end,
        })
        toggleRow(m, "LmJumpOn", "jump power", "a higher jump, whichever the game uses (power or height)", {
            sub = function(d)
                sliderRow(d, "LmJump", "jump power", 50, 400, 1, "%.0f")
            end,
        })
        toggleRow(m, "LmFly", "fly", "wasd moves, space up, ctrl down, hovers with no input", {
            risk = "high",
            sub = function(d)
                sliderRow(d, "LmFlySpeed", "fly speed", 10, 250, 1, "%.0f")
            end,
        })
        toggleRow(m, "LmNoclip", "noclip", "walks through walls. without fly you drop through the floor", { risk = "high" })
        toggleRow(m, "LmInfJump", "infinite jump", "jump again in the air")
        toggleRow(m, "LmBhop", "bhop", "hold space to keep hopping, air speed builds up to the cap", {
            sub = function(d)
                sliderRow(d, "LmBhopCap", "air speed cap", 16, 200, 1, "%.0f")
            end,
        })
        toggleRow(m, "LmClickTp", "click teleport", "ctrl + left click: teleport to the point under the cursor", { risk = "high" })
        btnRow(m, "unstuck", function() MOVE.unstuck() end)
        infoRow(m, "fly, noclip and click teleport need safe mode off. the drone and the fling take the body while they run")
        local a = card(PG.perks, "auto tune", "right")
        toggleRow(a, "AutoProfile", "auto profile", "re-tunes aim for your role when it changes", {
            sub = function(d)
                btnRow(d, "apply gun profile", function() SilentAim.applyProfile("gun") end)
                btnRow(d, "apply knife profile", function() SilentAim.applyProfile("knife") end)
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
        -- vote duper: the lobby's pads as three cards (picture, map name, votes); the card you click is the pick
        local vd = card(PG.vote, "vote duper", "left")
        local slots, refreshCards, pickLine = {}, nil, nil
        toggleRow(vd, "VoteDuper", "vote duper", "stands on the picked map's pad while its window is open", {
            risk = "high",
            onChange = function(nv)
                if not nv then return end
                if type(Settings.VoteDuperMap) ~= "string" or Settings.VoteDuperMap == "" then
                    notify("vote duper: click a map card first", "warn")
                end
                setSetting("MapVote", false)
                if REG.MapVote then pcall(REG.MapVote.set, false) end
            end,
        })
        local grid = rowFrame(vd, 84)
        new("UIGridLayout", {
            CellSize = UDim2.new(1 / 3, -4, 1, 0), CellPadding = UDim2.fromOffset(4, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, grid)
        for i = 1, 3 do
            local b = new("TextButton", {
                Name = "VoteCard" .. i, BackgroundColor3 = T.Input, BackgroundTransparency = 0.18,
                BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = i, Visible = false,
            }, grid)
            corner(b, 4)
            local edge = acc(stroke(b, T.Accent, 1, 1), "Color")
            local icon = new("ImageLabel", {
                Name = "MapIcon", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 4),
                Size = UDim2.new(1, -10, 0, 44), BackgroundColor3 = T.Row, BackgroundTransparency = 0.15,
                BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop, Image = "",
            }, b)
            corner(icon, 3)
            local nm = txt(b, "searching...", {
                Position = UDim2.new(0, 3, 0, 52), Size = UDim2.new(1, -6, 0, 11), Font = Enum.Font.GothamMedium,
                TextSize = 8, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local vt = txt(b, "votes: --", {
                Position = UDim2.new(0, 3, 0, 65), Size = UDim2.new(1, -6, 0, 10), TextSize = 7,
                TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            slots[i] = { btn = b, edge = edge, icon = icon, name = nm, votes = vt, entry = nil }
            b.MouseButton1Click:Connect(function()
                local e = slots[i].entry
                if not e or e.name == "" then return end
                setSetting("VoteDuperMap", e.name)
                refreshCards()
                notify("vote duper: " .. e.name, "good")
            end)
        end
        pickLine = infoRow(vd, "")
        btnRow(vd, "clear pick", function()
            setSetting("VoteDuperMap", "")
            refreshCards()
            notify("vote duper: pick cleared", "info")
        end)
        sliderRow(vd, "VoteDuperDelay", "stand time", 0.1, 1.5, 0.01, "%.2f s")
        infoRow(vd, "high-risk: safe mode off first. the pick is saved by map name, so it comes back with the config.")

        refreshCards = function()
            local list = VD.list(true)
            for i = 1, 3 do
                local s, e = slots[i], list[i]
                s.entry = e
                s.btn.Visible = e ~= nil
                if e then
                    local picked = e.name ~= "" and e.name == Settings.VoteDuperMap
                    s.name.Text = e.name ~= "" and e.name or "unknown map"
                    s.votes.Text = e.votes ~= "" and e.votes or "votes: --"
                    s.icon.Image = e.image
                    s.edge.Transparency = picked and 0 or 1
                    s.edge.Thickness = picked and 2 or 1
                    s.btn.BackgroundTransparency = picked and 0.02 or 0.18
                end
            end
            local cur = Settings.VoteDuperMap
            pickLine.Text = (type(cur) == "string" and cur ~= "") and ("pick: " .. cur) or "pick: none (click a map card)"
        end
        pcall(refreshCards)
        task.spawn(function()
            while running do
                task.wait(0.35)
                if curPage == "vote" then pcall(refreshCards) end
            end
        end)

        -- map vote: as before, switching it on switches the duper off
        local mv = card(PG.vote, "map vote", "right")
        toggleRow(mv, "MapVote", "map vote", "walks you into the vote zone of your first open pick and holds you there", {
            risk = "high",
            onChange = function(nv)
                if not nv then return end
                setSetting("VoteDuper", false)
                if REG.VoteDuper then pcall(REG.VoteDuper.set, false) end
            end,
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
        btnRow(le, "reset learning", function() SilentAim.resetLearning() end)
        ACC_TXT.sys = infoRow(card(PG.stats, "system", "left"), "")
    end

    function refreshAccounts()
        local h = PING.hist
        local hist = {}
        for i = math.max(1, #h - 11), #h do hist[#hist + 1] = tostring(math.floor(h[i] * 1000 + 0.5)) end
        ACC_TXT.profile.Text = string.format("user  %s (%s)\nrole  %s\nprofile  %s\nsafe mode  %s",
            lp.Name, lp.DisplayName, string.lower(getRole(lp)), SilentAim.state.profile, Settings.SafeMode and "on" or "off")
        ACC_TXT.conn.Text = string.format("ping %d ms\njitter +-%d ms (%s)\nlead %d ms\nlast: %s",
            math.floor(PING.rtt * 1000 + 0.5), math.floor(PING.jitter * 1000 + 0.5),
            PING.stable and "stable" or "unstable", math.floor(A.lead * 1000 + 0.5), table.concat(hist, " "))
        if A.name then
            local st = A.lagging and "lagging" or (A.stable and "steady" or "strafing")
            ACC_TXT.target.Text = string.format("%s%s\n%s | %s\ncover %d%% | model %s", A.name,
                SilentAim.state.forced and " (locked)" or "", st, A.visible and "clear line" or "no clear line",
                math.floor(A.cover * 100), tostring(A.model))
        else
            ACC_TXT.target.Text = "no target"
        end
        local ranked = {}
        for n, w in pairs(A.weights) do ranked[#ranked + 1] = { n, w } end
        table.sort(ranked, function(a, b) return a[2] > b[2] end)
        local lines = {
            string.format("hits %d / %d  redirected %d  passed %d", SilentAim.stats.hits, SilentAim.stats.shots,
                SilentAim.stats.redirected, SilentAim.stats.passed),
            "auto  " .. tostring(SilentAim.auto.state),
        }
        for i = 1, math.min(4, #ranked) do
            lines[#lines + 1] = string.format("%s  %d%%", ranked[i][1], math.floor(ranked[i][2] * 100 + 0.5))
        end
        ACC_TXT.learn.Text = table.concat(lines, "\n")
        local function yn(v) return v and "yes" or "no" end
        ACC_TXT.sys.Text = string.format("hook  %s\nrole data  %s\ncheckcaller %s  touch %s\nprompt %s  files %s\nerrors  %d",
            SilentAim.hookStatus(), dataOk and "server" or "tools", yn(CAP.caller), yn(CAP.touch), yn(CAP.prompt), yn(CAP.fs), SilentAim.state.errCount)
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
            SilentAim.resetLearning()
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
    buildPage("drone", pageDrone)
    buildPage("esp", pageEsp)
    buildPage("world", pageWorld)
    buildPage("fx", pageFx)
    buildPage("radar", pageRadar)
    buildPage("lock", pageLock)
    buildPage("perks", pagePerks)
    buildPage("vote", pageVote)
    buildPage("misc", pageMisc)
    buildPage("stats", pageStats)
    buildPage("presets", pagePresets)
    buildPage("skins", function()
        curPage = "skins"
        local S = ST.skins
        local info = nil
        local function label(sig)
            local r = S.get(sig)
            return r and r.label or "none"
        end
        local function describe()
            return "knife: " .. label(Settings.SkinKnife) .. "\ngun: " .. label(Settings.SkinGun)
        end
        local function refresh()
            if info then info.Text = describe() end
            S.sync()
        end
        local ctl = card(PG.skins, "skin changer", "left")
        toggleRow(ctl, "SkinChanger", "skin changer", "wears the picked skin on the knife / gun you hold (only you see it)", {
            onChange = refresh,
        })
        toggleRow(ctl, "SkinHolster", "holster", "gun skin on the back, knife skin on the belt while that weapon is not in hand", {
            onChange = refresh,
        })
        info = infoRow(ctl, describe())
        btnRow(ctl, "clear knife skin", function() setSetting("SkinKnife", ""); refresh() end)
        btnRow(ctl, "clear gun skin", function() setSetting("SkinGun", ""); refresh() end)
        local all = card(PG.skins, "all skins", "right")
        local list = S.list()
        infoRow(all, #list .. " skins. tap one to wear it, the knife and gun slots are separate")
        for _, r in ipairs(list) do
            btnRow(all, r.label, function()
                setSetting(r.k == "Knife" and "SkinKnife" or "SkinGun", r.s)
                setSetting("SkinChanger", true)
                if REG.SkinChanger then REG.SkinChanger.set(true) end
                notify("skin: " .. r.label, "good")
                refresh()
            end)
        end
    end)
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
    pcall(VD.stop)
    pcall(function() auras.stop() end)
    pcall(function() ST.novaAura.stop() end)
    pcall(function() ST.skins.stop() end)
    pcall(function() local f = ENV.SILENT_UNLOAD if f then f() end end)
    pcall(saveConfig)
    pcall(SilentAim.unload) -- disconnects the module's loops and the hook (the hook becomes a pass-through)
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, L in pairs(life) do
        if L.conn then pcall(function() L.conn:Disconnect() end) end
    end
    pcall(espClearAll)
    pcall(function() FX.stop() end)
    pcall(function() DRONE.stop() end)
    pcall(function() MOVE.stop() end)
    pcall(function() if ESP.root then ESP.root:Destroy() end end)
    pcall(function() if ST.gui then ST.gui:Destroy() end end)
    ST.toast = nil
    if ENV.MM2SuiteUnload == unload then ENV.MM2SuiteUnload = nil end
end
ENV.MM2SuiteUnload = unload

print(string.format("[MM2 Suite %s] loaded | hook: %s | role data: %s | files: %s",
    VERSION, SilentAim.hookStatus(), dataOk and "server" or "tools", CAP.fs and "yes" or "no"))
