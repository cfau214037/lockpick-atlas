local addonName = ...
local addon = LockpickAtlas

local DEFAULTS = {
    showWorldMapPins = true,
    showMinimapPins = true,
    showMinimapButton = true,
    minimapButtonAngle = 45,
    warnAtSkillCap = true,
}

local MARKER_SETTINGS = {
    { key = "showWorldMapPins", label = "World map markers", tooltip = "Show lockbox markers on the world map." },
    { key = "showMinimapPins", label = "Minimap markers", tooltip = "Show nearby lockbox markers on the minimap." },
}
local registeredSettings = {}
local LOCKPICKING_SKILL_ID = 633
local warnedKeys = {}
local elapsedSinceMinimapUpdate = 0
local mergedLocations = {}
local PERSONAL_PIN_RADIUS_SQUARED = 0.0025 ^ 2

local function isSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function safeNumber(value)
    if type(value) ~= "number" or isSecret(value) or value ~= value then return nil end
    return value
end

local function readLockpickingSkill()
    if not C_SkillInfo then return nil end

    local info = C_SkillInfo.GetSkillLineInfoByID(LOCKPICKING_SKILL_ID)
    if not info then
        local count = C_SkillInfo.GetNumSkillLines()
        count = safeNumber(count)
        if not count then return nil end

        for index = 1, count do
            local candidate = C_SkillInfo.GetSkillLineInfo(index)
            if candidate and not isSecret(candidate.skillID) and candidate.skillID == LOCKPICKING_SKILL_ID then
                info = candidate
                break
            end
        end
    end

    if not info then return nil end
    local rank = safeNumber(info.rank)
    local maximum = safeNumber(info.maxRank)
    if not rank or not maximum or maximum <= 0 then return nil end
    return rank, maximum
end

local function getCurrentZone()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not mapID or isSecret(mapID) then return nil end
    return addon.FindZoneForMap(mapID), mapID
end

function addon.GetMapLocations(mapID)
    local catalog = addon.LocationsByMapID[mapID]
    local personal = addon.DB.personalPins[mapID]
    if not personal or #personal == 0 then return catalog end
    if mergedLocations[mapID] then return mergedLocations[mapID] end

    local locations = {}
    for _, location in ipairs(catalog or {}) do
        locations[#locations + 1] = location
    end
    local zone = addon.ZonesByMapID[mapID]
    for _, point in ipairs(personal) do
        locations[#locations + 1] = {
            box = "Personal Footlocker",
            skillFrom = zone and zone.skillFrom,
            skillTo = zone and zone.skillTo,
            x = point.x,
            y = point.y,
            personalPoint = point,
            mapID = mapID,
        }
    end
    mergedLocations[mapID] = locations
    return locations
end

function addon.AddLocationTooltip(tooltip, location)
    tooltip:AddLine(location.box, 1, 0.82, 0.3)
    if location.skillFrom and location.skillTo then
        tooltip:AddLine(string.format("Skill %d–%d", location.skillFrom, location.skillTo), 1, 1, 1)
    end
    tooltip:AddLine(string.format("%.2f, %.2f", location.x * 100, location.y * 100), 1, 1, 1)
    if location.personalPoint then
        tooltip:AddLine("Right-click to remove", 0.7, 0.7, 0.7)
    end
end

function addon.CheckCapWarning()
    if not addon.DB or not addon.DB.warnAtSkillCap then return end

    local zone = getCurrentZone()
    if not zone then return end

    local rank, maximum = readLockpickingSkill()
    if not rank or rank < maximum or zone.routeCeiling <= maximum then return end

    local warningKey = table.concat({zone.mapID, maximum, zone.routeCeiling}, ":")
    if warnedKeys[warningKey] then return end
    warnedKeys[warningKey] = true

    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        "|cffffcc00Lockpick Atlas: Lockpicking is capped at %d/%d here. This route can skill up to about %d; level up to raise your cap before continuing.|r",
        rank,
        maximum,
        zone.routeCeiling
    ))
end

local function refreshPins()
    if addon.MapDataProvider then addon.MapDataProvider:RefreshAllData() end
    addon.UpdateMinimapPins()
    addon.UpdateMinimapButton()
end

local function finishPersonalPinChange(mapID, pins, action, point)
    addon.DB.personalPins[mapID] = #pins > 0 and pins or nil
    mergedLocations[mapID] = nil
    refreshPins()
    DEFAULT_CHAT_FRAME:AddMessage(string.format("Lockpick Atlas: %s personal pin at %.2f, %.2f.",
        action, point.x * 100, point.y * 100))
end

local function removePersonalPin(mapID, pins, index)
    local point = table.remove(pins, index)
    finishPersonalPinChange(mapID, pins, "Removed", point)
end

function addon.RemovePersonalPin(location)
    local pins = addon.DB.personalPins[location.mapID]
    for index, point in ipairs(pins or {}) do
        if point == location.personalPoint then
            removePersonalPin(location.mapID, pins, index)
            return
        end
    end
end

local function getPlayerCoordinates(mapID)
    local position = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not position or isSecret(position) then return nil end
    local x, y = position:GetXY()
    x, y = safeNumber(x), safeNumber(y)
    if not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    return x, y
end

local function changePersonalPin(mapID, x, y, remove)
    local personal = addon.DB.personalPins[mapID] or {}
    local closest, bestDistance = nil, PERSONAL_PIN_RADIUS_SQUARED
    for index, point in ipairs(personal) do
        local distance = (point.x - x) ^ 2 + (point.y - y) ^ 2
        if distance <= bestDistance then
            closest, bestDistance = index, distance
        end
    end

    if remove then
        if not closest then
            DEFAULT_CHAT_FRAME:AddMessage("Lockpick Atlas: No nearby personal pin. Move closer to it and try again.")
            return
        end
        removePersonalPin(mapID, personal, closest)
        return
    end
    if closest then
        DEFAULT_CHAT_FRAME:AddMessage("Lockpick Atlas: You already have a personal pin nearby.")
        return
    end
    local point = { x = x, y = y }
    personal[#personal + 1] = point
    finishPersonalPinChange(mapID, personal, "Saved", point)
end

local function changePinAtPlayer(remove)
    local zone, playerMapID = getCurrentZone()
    local mapID = zone and zone.mapID or playerMapID
    local x, y = getPlayerCoordinates(mapID)
    if not x then
        DEFAULT_CHAT_FRAME:AddMessage("Lockpick Atlas: Your map position is unavailable here.")
        return
    end
    changePersonalPin(mapID, x, y, remove)
end

local ADD_COORDS_POPUP = "LOCKPICKATLAS_ADD_COORDS"

local function parseCoordinates(text)
    local x, y = text:match("^%s*(%d+%.?%d*)%s*,%s*(%d+%.?%d*)%s*$")
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x > 100 or y > 100 then return nil end
    return x / 100, y / 100
end

local function acceptCoordinates(editBox, data)
    local x, y = parseCoordinates(editBox:GetText())
    if x then changePersonalPin(data.mapID, x, y, false) end
end

StaticPopupDialogs[ADD_COORDS_POPUP] = {
    text = "Add Coords — %s\nEnter X, Y (0–100).",
    button1 = "Add Pin",
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(dialog, data)
        local editBox = dialog:GetEditBox()
        editBox:SetText(data.prefill)
        dialog:GetButton1():SetEnabled(parseCoordinates(data.prefill) ~= nil)
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    OnAccept = function(dialog, data)
        acceptCoordinates(dialog:GetEditBox(), data)
    end,
    EditBoxOnTextChanged = function(editBox)
        editBox:GetParent():GetButton1():SetEnabled(parseCoordinates(editBox:GetText()) ~= nil)
    end,
    EditBoxOnEnterPressed = function(editBox, data)
        local dialog = editBox:GetParent()
        if dialog:GetButton1():IsEnabled() then
            acceptCoordinates(editBox, data)
            dialog:Hide()
        end
    end,
    EditBoxOnEscapePressed = function(editBox)
        editBox:GetParent():Hide()
    end,
}

function addon.OpenAddCoords()
    local zone, playerMapID = getCurrentZone()
    local mapID = zone and zone.mapID or playerMapID
    local map = mapID and C_Map.GetMapInfo(mapID)
    local name = map and map.name
    if not name or isSecret(name) then
        DEFAULT_CHAT_FRAME:AddMessage("Lockpick Atlas: Your current map is unavailable.")
        return
    end
    local x, y = getPlayerCoordinates(mapID)
    StaticPopup_Show(ADD_COORDS_POPUP, name, nil, {
        mapID = mapID,
        prefill = x and string.format("%.2f, %.2f", x * 100, y * 100) or "",
    })
end

local function onSettingChanged(setting)
    if setting == "warnAtSkillCap" then warnedKeys = {} end
    refreshPins()
    addon.CheckCapWarning()
end

local function setSetting(key, value)
    addon.DB[key] = value
    onSettingChanged(key)
end

local function toggleMarkerSetting(key)
    local value = not addon.DB[key]
    local setting = registeredSettings[key]
    if setting then
        setting:SetValue(value, true)
    else
        setSetting(key, value)
    end
end

local function getVersion()
    return C_AddOns.GetAddOnMetadata(addonName, "Version") or "unknown"
end

function addon.OpenMinimapMenu(owner)
    MenuUtil.CreateContextMenu(owner, function(_, root)
        root:CreateTitle("Lockpick Atlas v" .. getVersion())
        root:CreateButton("Add Coords", addon.OpenAddCoords)
        for _, entry in ipairs(MARKER_SETTINGS) do
            root:CreateCheckbox(entry.label, function(key)
                return addon.DB[key]
            end, toggleMarkerSetting, entry.key)
        end
        root:CreateButton("Settings", addon.OpenOptions)
    end)
end

function addon.MarkCurrentLocation()
    changePinAtPlayer(false)
end

local function addCheckbox(category, key, label, tooltip)
    local variable = "LockpickAtlas_" .. key
    local setting = Settings.RegisterProxySetting(
        category,
        variable,
        Settings.VarType.Boolean,
        label,
        DEFAULTS[key],
        function() return addon.DB[key] end,
        function(value) setSetting(key, value) end
    )
    registeredSettings[key] = setting
    Settings.CreateCheckbox(category, setting, tooltip)
end

local function createOptions()
    if not Settings then return end

    local category = Settings.RegisterVerticalLayoutCategory("Lockpick Atlas")
    addon.OptionsCategory = category
    for _, entry in ipairs(MARKER_SETTINGS) do
        addCheckbox(category, entry.key, entry.label, entry.tooltip)
    end
    addCheckbox(category, "showMinimapButton", "Minimap button", "Show the draggable Lockpick Atlas button beside the minimap.")
    addCheckbox(category, "warnAtSkillCap", "Skill cap warning", "Warn once per area and cap when the route can skill up beyond your current cap.")
    local layout = SettingsPanel and SettingsPanel:GetLayout(category)
    if layout and CreateSettingsButtonInitializer then
        layout:AddInitializer(CreateSettingsButtonInitializer(
            "Personal pins",
            "Add Coords",
            addon.OpenAddCoords,
            "Enter coordinates for a personal pin on your current zone's map.",
            true
        ))
    end
    Settings.RegisterAddOnCategory(category)
end

local function openOptions()
    if addon.OptionsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addon.OptionsCategory:GetID())
    else
        DEFAULT_CHAT_FRAME:AddMessage("Lockpick Atlas: Open Options > AddOns > Lockpick Atlas.")
    end
end

addon.OpenOptions = openOptions

local function showStatus()
    local rank, maximum = readLockpickingSkill()
    local skill = rank and string.format("%d/%d", rank, maximum) or "unavailable"
    local map = addon.MapDataProvider and addon.MapDataProvider:GetMap()
    local mapID = map and map:GetMapID()
    local worldPins = map and map:GetNumActivePinsByTemplate("LockpickAtlasMapPinTemplate") or 0
    local nearbyPins = 0
    for _, pin in ipairs(addon.minimapPins or {}) do
        if pin:IsShown() then nearbyPins = nearbyPins + 1 end
    end

    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        "Lockpick Atlas %s: Lockpicking %s, world map %s (%d pins, map %s), minimap %s (%d nearby), button %s, cap warning %s.",
        getVersion(), skill,
        addon.DB.showWorldMapPins and "on" or "off", worldPins,
        safeNumber(mapID) or "unavailable",
        addon.DB.showMinimapPins and "on" or "off", nearbyPins,
        addon.DB.showMinimapButton and "on" or "off",
        addon.DB.warnAtSkillCap and "on" or "off"
    ))
end

local function registerSlashCommand()
    SLASH_LOCKPICKATLAS1 = "/lockpickatlas"
    SLASH_LOCKPICKATLAS2 = "/lpa"
    SlashCmdList.LOCKPICKATLAS = function(message)
        message = string.lower((message or ""):match("^%s*(.-)%s*$"))
        if message == "options" then
            openOptions()
        elseif message == "status" then
            showStatus()
        elseif message == "mark" then
            addon.MarkCurrentLocation()
        elseif message == "unmark" then
            changePinAtPlayer(true)
        else
            DEFAULT_CHAT_FRAME:AddMessage("Lockpick Atlas: /lpa mark saves your position, /lpa unmark removes a nearby personal pin, /lpa options opens settings, and /lpa status shows current skill and pins.")
        end
    end
end

local function registerMapPins()
    if addon.MapDataProvider then return true end
    if not WorldMapFrame or not WorldMapFrame.AddDataProvider or not MapCanvasDataProviderMixin then return false end

    local provider = CreateFromMixins(addon.MapDataProviderMixin)
    WorldMapFrame:AddDataProvider(provider)
    addon.MapDataProvider = provider
    return true
end

local function initialize()
    if type(LockpickAtlasDB) ~= "table" then
        LockpickAtlasDB = LockpickAssistDB
    end
    LockpickAssistDB = nil
    LockpickAtlasDB = type(LockpickAtlasDB) == "table" and LockpickAtlasDB or {}
    for key, default in pairs(DEFAULTS) do
        if LockpickAtlasDB[key] == nil then LockpickAtlasDB[key] = default end
    end
    addon.DB = LockpickAtlasDB
    if type(addon.DB.personalPins) ~= "table" then addon.DB.personalPins = {} end

    createOptions()
    registerSlashCommand()
    registerMapPins()
    addon.CreateMinimapButton()
    addon.UpdateMinimapPins()
    addon.UpdateMinimapButton()
    addon.CheckCapWarning()
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        initialize()
        for _, name in ipairs({
            "PLAYER_ENTERING_WORLD",
            "ZONE_CHANGED",
            "ZONE_CHANGED_NEW_AREA",
            "ZONE_CHANGED_INDOORS",
            "PLAYER_LEVEL_UP",
            "SKILL_LINES_CHANGED",
            "PLAYER_REGEN_ENABLED",
        }) do
            self:RegisterEvent(name)
        end
        if addon.MapDataProvider then
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "ADDON_LOADED" then
        if addon.DB and arg1 == "Blizzard_WorldMap" and registerMapPins() then
            self:UnregisterEvent("ADDON_LOADED")
        end
    else
        addon.CheckCapWarning()
        addon.UpdateMinimapPins()
    end
end)

events:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceMinimapUpdate = elapsedSinceMinimapUpdate + elapsed
    if elapsedSinceMinimapUpdate >= 0.2 then
        elapsedSinceMinimapUpdate = 0
        addon.UpdateMinimapPins()
    end
end)
