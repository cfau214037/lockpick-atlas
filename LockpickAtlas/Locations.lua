LockpickAtlas = LockpickAtlas or {}

-- Coordinates are representative points from community route data, not confirmed live spawns.
-- Points are percentages on the WoW: Forever zone maps.
LockpickAtlas.Zones = {
    {
        mapID = 1423,
        name = "Eastern Plaguelands",
        box = "Scarlet Footlocker",
        skillFrom = 250,
        skillTo = 300,
        routeCeiling = 300,
        note = "Tyr's Hand. Guards are reported as level 53-57 elites.",
        points = {
            {72.8, 72.3}, {68.7, 68.9}, {72.1, 68.7}, {68.5, 64.9}, {69.8, 74.8}, {76.4, 71.2},
            {70.8, 71.0}, {72.1, 72.3}, {73.2, 66.9}, {71.5, 72.9}, {72.7, 74.6}, {77.4, 75.1},
            {77.5, 70.2},
        },
    },
    {
        mapID = 1413,
        name = "The Barrens",
        box = "Buccaneer's Strongbox",
        skillFrom = 1,
        skillTo = 70,
        routeCeiling = 70,
        note = "Single reported practice spot on the Merchant Coast.",
        points = {{65.0, 45.4}},
    },
    {
        mapID = 1433,
        name = "Redridge Mountains",
        box = "Waterlogged Footlocker",
        skillFrom = 70,
        skillTo = 110,
        routeCeiling = 110,
        note = "Lake Everstill route; underwater.",
        points = {
            {39.2, 56.4}, {41.7, 61.0}, {36.2, 60.3},
            {32.7, 58.8}, {34.2, 64.4}, {38.3, 64.4},
        },
    },
    {
        mapID = 1440,
        name = "Ashenvale",
        box = "Waterlogged Footlocker",
        skillFrom = 70,
        skillTo = 110,
        routeCeiling = 110,
        note = "Zoram Strand route; shallow water and naga nearby.",
        points = {{13.9, 26.5}, {13.0, 30.0}, {13.9, 20.0}, {14.6, 16.7}},
    },
    {
        mapID = 1442,
        name = "Stonetalon Mountains",
        box = "Battered Footlocker",
        skillFrom = 70,
        skillTo = 150,
        routeCeiling = 150,
        note = "Windshear Crag and Mine; dry-land route. Some points are the 110 tier.",
        points = {
            {62.5, 51.1}, {70.1, 48.2}, {64.7, 45.8}, {65.0, 49.0},
            {70.0, 54.4}, {73.7, 59.6}, {72.4, 62.8},
        },
    },
    {
        mapID = 1437,
        name = "Wetlands",
        box = "Battered Footlocker",
        skillFrom = 70,
        skillTo = 150,
        routeCeiling = 150,
        note = "West-shore camps. Inner-camp skill reports differ (110/115).",
        points = {
            {13.6, 41.3}, {14.3, 32.8}, {16.5, 30.6}, {18.3, 39.5},
            {16.2, 36.0}, {20.5, 35.7}, {22.6, 31.6},
        },
    },
    {
        mapID = 1424,
        name = "Hillsbrad Foothills",
        box = "Battered Footlocker",
        skillFrom = 110,
        skillTo = 150,
        routeCeiling = 150,
        note = "Dense upper and lower yard route at Durnholde Keep.",
        points = {
            {75.7, 41.6}, {79.5, 46.2}, {82.4, 42.2}, {80.2, 41.2},
            {74.9, 38.3}, {75.8, 44.1}, {83.4, 40.3},
        },
    },
    {
        mapID = 1418,
        name = "Badlands",
        box = "Battered / Dented Footlocker",
        skillFrom = 150,
        skillTo = 200,
        routeCeiling = 200,
        note = "Angor Fortress: Battered boxes upstairs, Dented boxes downstairs; guarded by level 38-40 enemies.",
        points = {{40.9, 26.4}, {41.7, 30.0}, {42.0, 28.3}},
    },
    {
        mapID = 1443,
        name = "Desolace",
        box = "Waterlogged / Mossy Footlocker",
        skillFrom = 150,
        skillTo = 200,
        routeCeiling = 200,
        note = "Sar'theris Strand route; underwater.",
        points = {{34.8, 20.9}, {37.5, 22.3}, {34.3, 24.0}, {31.7, 22.5}, {40.0, 17.2}},
    },
    {
        mapID = 1435,
        name = "Swamp of Sorrows",
        box = "Mossy Footlocker",
        skillFrom = 175,
        skillTo = 200,
        routeCeiling = 200,
        note = "Pool of Tears route; fewer hostiles reported near the pools.",
        points = {{69.8, 45.4}, {68.7, 48.4}, {64.8, 56.2}, {68.0, 56.5}, {71.6, 57.3}, {70.1, 61.0}},
    },
    {
        mapID = 1427,
        name = "Searing Gorge",
        box = "Dented Footlocker",
        skillFrom = 200,
        skillTo = 250,
        routeCeiling = 250,
        note = "Slag Pit has both 200 and 225 tiers; level 45-48 enemies patrol the area.",
        points = {{37.5, 40.4}, {40.7, 37.8}, {35.0, 42.8}, {43.0, 31.0}, {46.1, 25.9}, {44.4, 35.3}},
    },
    {
        mapID = 1446,
        name = "Tanaris",
        box = "Dented Footlocker",
        skillFrom = 225,
        skillTo = 250,
        routeCeiling = 250,
        note = "Lost Rigger Cove route through pirate camps.",
        points = {{74.1, 47.5}, {72.2, 44.6}, {71.1, 47.9}},
    },
    {
        mapID = 1447,
        name = "Azshara",
        box = "Mossy Footlocker",
        skillFrom = 225,
        skillTo = 250,
        routeCeiling = 250,
        note = "Bay of Storms route is spread out; expect more riding between points.",
        points = {{48.2, 46.4}, {58.8, 43.0}, {60.0, 51.2}, {50.2, 64.2}, {72.8, 40.8}, {77.3, 45.0}},
    },
}

-- Additional object records, screened against the existing route pins. See the README for sources.
-- Points are map percentages. Records include inherited spawns and need a live check.
local databaseRoutes = {
    [1423] = {
        { -- Object 179498
            box = "Scarlet Footlocker",
            points = {
                {68.07, 68.37}, {69.43, 69.14}, {70.86, 72.25}, {72.93, 71.43},
                {74.14, 69.23}, {74.55, 67.97}, {76.72, 69.44}, {77.38, 74.41},
            },
        },
    },
    [1418] = {
        { -- Object 179490
            box = "Battered Footlocker",
            points = {
                {40.50, 28.00}, {41.30, 29.29}, {41.38, 26.16}, {42.15, 31.01},
                {43.79, 29.74},
            },
        },
        { -- Object 179492
            box = "Dented Footlocker",
            points = {
                {40.72, 28.07}, {40.81, 28.67}, {41.07, 27.40},
            },
        },
    },
    [1424] = {
        { -- Object 179486
            box = "Battered Footlocker",
            points = {
                {75.80, 39.87}, {77.49, 44.32}, {78.97, 44.53}, {78.98, 45.95},
                {80.70, 44.11}, {81.90, 41.71}, {82.60, 41.04}, {82.87, 42.56},
            },
        },
        { -- Object 179488
            box = "Battered Footlocker",
            points = {
                {75.09, 37.73}, {77.48, 39.04}, {77.87, 39.10}, {78.30, 43.55},
                {79.35, 41.15}, {80.54, 40.53}, {82.92, 44.01},
            },
        },
    },
    [1427] = {
        { -- Object 179494
            box = "Dented Footlocker",
            points = {
                {35.91, 45.23}, {36.90, 39.89}, {38.00, 45.86}, {38.43, 50.83},
                {39.07, 24.43}, {40.61, 52.84}, {40.73, 31.17}, {42.28, 29.48},
                {42.30, 54.08}, {42.36, 44.09}, {44.58, 54.15},
            },
        },
        { -- Object 179496
            box = "Dented Footlocker",
            points = {
                {43.93, 30.88}, {45.75, 28.33}, {46.85, 43.84}, {46.89, 25.69},
            },
        },
    },
    [1433] = {
        { -- Object 178244
            box = "Practice Lockbox",
            skillFrom = 1,
            skillTo = 70,
            points = {
                {46.65, 44.92}, {46.78, 45.09}, {46.86, 45.35},
            },
        },
        { -- Object 178246
            box = "Practice Lockbox",
            skillFrom = 1,
            skillTo = 70,
            points = {
                {47.01, 45.49}, {47.16, 45.43},
            },
        },
        { -- Object 179487
            box = "Waterlogged Footlocker",
            points = {
                {34.28, 61.92}, {39.63, 55.99}, {39.78, 59.05}, {42.82, 54.28},
                {45.16, 55.12}, {47.08, 61.30},
            },
        },
    },
    [1435] = {
        { -- Object 179493
            box = "Mossy Footlocker",
            points = {
                {65.39, 51.74}, {66.26, 58.37}, {71.70, 48.23}, {71.81, 61.59},
                {74.20, 58.51},
            },
        },
    },
    [1437] = {
        { -- Object 179486
            box = "Battered Footlocker",
            points = {
                {12.55, 41.71}, {14.32, 35.95}, {15.31, 36.68}, {17.04, 40.38},
                {17.21, 36.16}, {19.03, 37.71}, {21.44, 34.27}, {21.96, 31.16},
                {23.18, 31.91},
            },
        },
        { -- Object 179488
            box = "Battered Footlocker",
            points = {
                {13.35, 38.10}, {15.26, 38.95}, {15.32, 38.50},
            },
        },
    },
    [1440] = {
        { -- Object 179487
            box = "Waterlogged Footlocker",
            points = {
                {7.14, 14.18}, {11.18, 13.38}, {12.05, 15.73}, {13.39, 27.08},
                {13.45, 14.97}, {13.63, 30.95}, {14.15, 16.22}, {14.44, 23.07},
                {14.77, 20.18}, {15.08, 17.11}, {15.61, 18.96},
            },
        },
        { -- Object 179489
            box = "Waterlogged Footlocker",
            points = {
                {10.69, 17.25},
            },
        },
    },
    [1442] = {
        { -- Object 179486
            box = "Battered Footlocker",
            points = {
                {59.73, 53.51}, {61.36, 55.56}, {61.90, 51.51}, {62.91, 53.18},
                {63.30, 51.21}, {66.09, 50.89}, {67.84, 56.58}, {70.18, 48.74},
                {71.37, 52.63}, {71.50, 56.79}, {71.86, 49.53},
            },
        },
        { -- Object 179488
            box = "Battered Footlocker",
            points = {
                {72.15, 61.04}, {74.15, 59.15}, {74.24, 59.54},
            },
        },
    },
    [1443] = {
        { -- Object 179491
            box = "Waterlogged Footlocker",
            points = {
                {34.05, 20.70}, {35.44, 20.78}, {36.56, 22.11}, {37.47, 21.30},
                {37.63, 22.90},
            },
        },
        { -- Object 179493
            box = "Mossy Footlocker",
            points = {
                {34.36, 16.95}, {34.71, 12.61}, {35.54, 13.95},
            },
        },
    },
    [1446] = {
        { -- Object 179496
            box = "Dented Footlocker",
            points = {
                {70.86, 47.39}, {71.28, 48.37}, {72.87, 45.86}, {74.20, 46.96},
                {74.64, 47.31}, {74.81, 47.07}, {74.82, 45.51}, {75.63, 45.10},
            },
        },
    },
    [1447] = {
        { -- Object 179497
            box = "Mossy Footlocker",
            points = {
                {46.44, 42.43}, {47.44, 46.21}, {49.55, 41.67}, {49.87, 63.53},
                {50.51, 64.82}, {52.62, 59.51}, {55.13, 48.29}, {56.38, 58.24},
                {57.90, 56.65}, {58.25, 42.93}, {60.64, 50.75}, {61.25, 71.14},
                {66.04, 32.67}, {71.29, 74.35}, {77.50, 45.59}, {77.96, 44.90},
                {78.52, 85.69}, {78.64, 39.09}, {82.53, 30.71},
            },
        },
    },
}

LockpickAtlas.ZonesByMapID = {}
LockpickAtlas.LocationsByMapID = {}

local function appendLocations(locations, zone, route, source)
    for _, point in ipairs(route.points) do
        locations[#locations + 1] = {
            box = route.box,
            skillFrom = route.skillFrom or zone.skillFrom,
            skillTo = route.skillTo or zone.skillTo,
            x = point[1] / 100,
            y = point[2] / 100,
            source = source,
        }
    end
end

for _, zone in ipairs(LockpickAtlas.Zones) do
    LockpickAtlas.ZonesByMapID[zone.mapID] = zone

    local locations = {}
    LockpickAtlas.LocationsByMapID[zone.mapID] = locations
    appendLocations(locations, zone, zone, "Reported")
    for _, route in ipairs(databaseRoutes[zone.mapID] or {}) do
        appendLocations(locations, zone, route, "Database report")
    end
end

function LockpickAtlas.FindZoneForMap(mapID)
    local currentMapID = mapID
    for _ = 1, 8 do
        if type(currentMapID) ~= "number"
            or (issecretvalue and issecretvalue(currentMapID))
            or currentMapID <= 0 then return nil end

        local zone = LockpickAtlas.ZonesByMapID[currentMapID]
        if zone then return zone end

        local mapInfo = C_Map.GetMapInfo(currentMapID)
        currentMapID = mapInfo and mapInfo.parentMapID
    end
end
