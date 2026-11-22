local addon = LockpickAtlas

local function isSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function isFiniteNumber(value)
    return type(value) == "number" and not isSecret(value)
        and value == value and value ~= math.huge and value ~= -math.huge
end

local function addRoundTexture(pin, layer, size, red, green, blue, alpha)
    local dot = pin:CreateTexture(nil, layer)
    dot:SetSize(size, size)
    dot:SetPoint("CENTER")
    dot:SetColorTexture(red, green, blue, alpha)

    local mask = pin:CreateMaskTexture()
    mask:SetAllPoints(dot)
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    dot:AddMaskTexture(mask)
    return dot
end

local function setUpPinArtwork(pin)
    pin:SetSize(10, 10)
    addRoundTexture(pin, "BACKGROUND", 7, 0.15, 0.10, 0.06, 0.85)
    pin.dot = addRoundTexture(pin, "ARTWORK", 5, 0.94, 0.73, 0.41, 0.9)
end

local function configurePin(pin, location)
    local isPersonal = location.personalPoint ~= nil
    pin:SetMouseClickEnabled(isPersonal)
    if isPersonal then
        pin.dot:SetColorTexture(0.55, 0.84, 1, 0.95)
    else
        pin.dot:SetColorTexture(0.94, 0.73, 0.41, 0.9)
    end
end

local function openPinMenu(pin, location)
    if not location or not location.personalPoint then return end
    if GameTooltip:IsOwned(pin) then GameTooltip:Hide() end
    MenuUtil.CreateContextMenu(pin, function(_, root)
        root:CreateButton("Remove Pin", function()
            addon.RemovePersonalPin(location)
        end)
    end)
end

LockpickAtlasMapPinMixin = CreateFromMixins(MapCanvasPinMixin)
addon.MapPinMixin = LockpickAtlasMapPinMixin

function addon.MapPinMixin:OnLoad()
    setUpPinArtwork(self)
    self:SetScalingLimits(1, 1, 1)
end

function addon.MapPinMixin:OnAcquired(data)
    self.data = data
    configurePin(self, data.location)
    self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI", data.location.personalPoint and 2 or 1)
    self:SetPosition(data.x, data.y)
    self:ApplyCurrentScale()
end

function addon.MapPinMixin:CheckMouseButtonPassthrough()
    -- MapCanvas calls this after OnAcquired, including for recycled pins.
    if self.data.location.personalPoint then
        self:SetPassThroughButtons("LeftButton", "MiddleButton")
    else
        MapCanvasPinMixin.CheckMouseButtonPassthrough(self, "RightButton")
    end
end

function addon.MapPinMixin:OnClick(button)
    if button == "RightButton" then
        openPinMenu(self, self.data and self.data.location)
    end
end

function addon.MapPinMixin:OnReleased()
    self:OnMouseLeave()
    self.data = nil
    MapCanvasPinMixin.OnReleased(self)
end

function addon.MapPinMixin:OnMouseEnter()
    local location = self.data and self.data.location
    if not location then return end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    addon.AddLocationTooltip(GameTooltip, location)
    GameTooltip:Show()
end

function addon.MapPinMixin:OnMouseLeave()
    if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
end

addon.MapDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin)

local function getXY(position)
    if not position or isSecret(position) then return nil end
    local x, y
    if type(position.GetXY) == "function" then
        x, y = position:GetXY()
    else
        x, y = position.x, position.y
    end
    return x, y
end

function addon.MapDataProviderMixin:RemoveAllData()
    local map = self:GetMap()
    if map then
        map:RemoveAllPinsByTemplate("LockpickAtlasMapPinTemplate")
    end
end

function addon.MapDataProviderMixin:RefreshAllData()
    self:RemoveAllData()

    if not addon.DB or not addon.DB.showWorldMapPins then return end

    local map = self:GetMap()
    if not map or not map:IsShown() then return end

    local mapID = map:GetMapID()
    if not isFiniteNumber(mapID) then return end

    local locations = addon.GetMapLocations(mapID)
    if not locations then return end

    for _, location in ipairs(locations) do
        map:AcquirePin("LockpickAtlasMapPinTemplate", {
            location = location,
            x = location.x,
            y = location.y,
        })
    end
end

function addon.MapDataProviderMixin:OnAdded(mapCanvas)
    MapCanvasDataProviderMixin.OnAdded(self, mapCanvas)
    self:RefreshAllData()
end

local function getPlayerFacingIfRotated()
    local rotation = C_CVar and C_CVar.GetCVar and C_CVar.GetCVar("rotateMinimap")
    if isSecret(rotation) then return nil end
    if rotation ~= "1" then return 0 end
    if C_Minimap and C_Minimap.IsRotateMinimapIgnored and C_Minimap.IsRotateMinimapIgnored() then return 0 end
    if type(GetPlayerFacing) ~= "function" then return nil end

    local facing = GetPlayerFacing()
    if not isFiniteNumber(facing) then return nil end
    return facing
end

local function addMinimapPin()
    local pin = CreateFrame("Frame", nil, Minimap)
    setUpPinArtwork(pin)
    pin:SetFrameStrata("MEDIUM")
    pin:SetMouseMotionEnabled(true)
    pin:SetPassThroughButtons("LeftButton", "MiddleButton")
    pin:Hide()

    pin:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        addon.AddLocationTooltip(GameTooltip, self.location)
        GameTooltip:Show()
    end)
    pin:SetScript("OnLeave", GameTooltip_Hide)
    pin:SetScript("OnMouseUp", function(self, button, upInside)
        if button == "RightButton" and upInside then
            openPinMenu(self, self.location)
        end
    end)
    return pin
end

local minimapPinsByMapID = {}

local function hideMinimapPins()
    if not addon.minimapPins then return end
    for _, pin in ipairs(addon.minimapPins) do pin:Hide() end
    addon.minimapPins = nil
end

local function getMinimapPins(mapID, locations)
    local cached = minimapPinsByMapID[mapID]
    if not cached then
        cached = { pins = {} }
        minimapPinsByMapID[mapID] = cached
    end

    local pins = cached.pins
    if cached.locations ~= locations then
        for index, location in ipairs(locations) do
            local pin = pins[index] or addMinimapPin()
            pins[index] = pin
            pin.location = location
            configurePin(pin, location)
            pin:SetFrameLevel(Minimap:GetFrameLevel() + (location.personalPoint and 5 or 4))
        end
        for index = #locations + 1, #pins do
            pins[index]:Hide()
            pins[index].location = nil
        end
        cached.locations = locations
    end
    return pins
end

function addon.UpdateMinimapPins()
    if not Minimap or not addon.DB or not addon.DB.showMinimapPins then
        hideMinimapPins()
        return
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID or isSecret(mapID) then
        hideMinimapPins()
        return
    end

    local currentZone = addon.FindZoneForMap(mapID)
    local routeMapID = currentZone and currentZone.mapID or mapID
    local locations = addon.GetMapLocations(routeMapID)
    if not locations then
        hideMinimapPins()
        return
    end

    -- Use the route's zone map for both positions. GetBestMapForUnit can return a
    -- smaller sub-area map, while the route coordinates are recorded on the zone map.
    local playerPosition = C_Map.GetPlayerMapPosition(routeMapID, "player")
    local playerX, playerY = getXY(playerPosition)
    local mapWidth, mapHeight = C_Map.GetMapWorldSize(routeMapID)
    local radius = C_Minimap and C_Minimap.GetViewRadius and C_Minimap.GetViewRadius()
    local facing = getPlayerFacingIfRotated()

    if not isFiniteNumber(playerX) or not isFiniteNumber(playerY)
        or not isFiniteNumber(mapWidth) or not isFiniteNumber(mapHeight)
        or mapWidth <= 0 or mapHeight <= 0
        or not isFiniteNumber(radius) or radius <= 0 or facing == nil then
        hideMinimapPins()
        return
    end

    local pixelsPerYardX = Minimap:GetWidth() * 0.5 / radius
    local pixelsPerYardY = Minimap:GetHeight() * 0.5 / radius
    local maxDistanceSquared = (radius * 0.96) ^ 2
    local sine, cosine = math.sin(facing), math.cos(facing)

    local pins = getMinimapPins(routeMapID, locations)
    if addon.minimapPins ~= pins then
        hideMinimapPins()
        addon.minimapPins = pins
    end

    for index, location in ipairs(locations) do
        local pin = pins[index]
        local east = (location.x - playerX) * mapWidth
        local north = (playerY - location.y) * mapHeight
        if east * east + north * north > maxDistanceSquared then
            pin:Hide()
        else
            local offsetX = (east * cosine - north * sine) * pixelsPerYardX
            local offsetY = (east * sine + north * cosine) * pixelsPerYardY
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", Minimap, "CENTER", offsetX, offsetY)
            pin:Show()
        end
    end
end

local function positionMinimapButton(button)
    if not addon.DB or not Minimap then return end

    local angle = addon.DB.minimapButtonAngle
    if not isFiniteNumber(angle) then angle = 45 end
    local radians = math.rad(angle)
    local radiusX = Minimap:GetWidth() * 0.5 + 4
    local radiusY = Minimap:GetHeight() * 0.5 + 4

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * radiusX, math.sin(radians) * radiusY)
end

local function saveMinimapButtonAngle(button)
    if not addon.DB or not Minimap then return end

    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    if not isFiniteNumber(cursorX) or not isFiniteNumber(cursorY) or not isFiniteNumber(scale) or scale <= 0 then return end

    cursorX = cursorX / scale
    cursorY = cursorY / scale
    local centerX, centerY = Minimap:GetCenter()
    if not isFiniteNumber(centerX) or not isFiniteNumber(centerY) then return end
    local deltaX, deltaY = cursorX - centerX, cursorY - centerY
    if deltaX == 0 and deltaY == 0 then return end

    addon.DB.minimapButtonAngle = math.deg(math.atan2(deltaY, deltaX))
    positionMinimapButton(button)
end

function addon.CreateMinimapButton()
    if not Minimap or addon.minimapButton then return end

    local button = CreateFrame("Button", nil, Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetMovable(true)

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(22, 22)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\LockpickAtlas\\Textures\\Logo")

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    -- The visible ring sits 17 right and 15 down from this texture's top left.
    border:SetPoint("TOPLEFT", button, "CENTER", -17, 15)
    border:SetTexture(136430) -- MiniMap-TrackingBorder

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Lockpick Atlas", 1, 0.82, 0.3)
        GameTooltip:AddLine("Left-click to open settings.", 1, 1, 1)
        GameTooltip:AddLine("Right-click for pin options.", 1, 1, 1)
        GameTooltip:AddLine("Drag to move around the minimap.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            GameTooltip:Hide()
            addon.OpenMinimapMenu(self)
        elseif addon.OpenOptions then
            addon.OpenOptions()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", function(draggingButton)
            saveMinimapButtonAngle(draggingButton)
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        saveMinimapButtonAngle(self)
    end)
    button:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    addon.minimapButton = button
    positionMinimapButton(button)
end

function addon.UpdateMinimapButton()
    local button = addon.minimapButton
    if not button then return end

    if addon.DB and addon.DB.showMinimapButton then
        positionMinimapButton(button)
        button:Show()
    else
        button:Hide()
    end
end
