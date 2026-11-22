# Lockpick Atlas

A small WoW: Forever addon that marks reported lockbox route locations and warns when Lockpicking is at its current character cap in a route that can skill up farther.

## Current features

- World-map pins on each route's zone map, plus nearby minimap markers.
- Left-click the draggable minimap icon for settings. Its right-click menu shows the version, **Add Coords**, the map marker toggles, and **Settings**.
- A toggle for the capped-skill warning.
- `/lpa options` opens settings. `/lpa status` shows the version, current skill, and toggles. `/lockpickatlas` accepts the same commands.
- Route points begin at Tyr's Hand and cover the common earlier footlocker areas.
- Right-click the minimap key icon and select **Add Coords**, or open **Add Coords** in Lockpick Atlas settings. The box starts with your current coordinates. Edit them or click **Add Pin** to save a personal pin for the zone named in the dialog. Personal pins appear on both maps and are saved locally for your WoW account.
- Right-click a blue personal pin on the world map or minimap and select **Remove Pin**. Gold route pins are built in.
- Type `/lpa mark` to save your current position immediately. Type `/lpa unmark` while standing nearby to remove the closest personal pin.

The cap warning reads Lockpicking's current rank and `maxRank` from Forever's skill API. For example, at `240/240` in a route with a higher skill ceiling, it says to level up before continuing. It only warns once for each area/cap combination.

## Location data note

The catalog in `Locations.lua` combines community route points with 135 coordinates selected from QuestieDB's Forever object records, using its zone ID mapping. Eight of those coordinates are at Tyr's Hand. [Forever object records](https://github.com/Questie/QuestieDB/blob/master/data/Forever/foreverObjectDB.lua) · [Forever zone ID mapping](https://github.com/Questie/QuestieDB/blob/master/support/Forever/Zones/uiMapIdToAreaId.lua)

A pin shows a reported box location, including locations inherited from earlier game data that still need checking in Forever. The tooltip shows the box name, coordinates, and route skill range, which may cover several tiers of box.

## Install

Place the `LockpickAtlas` folder in the Forever client's `Interface/AddOns` folder, enable it at character select, then open `Options > AddOns > Lockpick Atlas`.

The addon targets Forever interface `16001`. Check the current interface number after client updates.

## Upgrade from Lockpick Assist

With WoW closed, move the old `LockpickAssist` addon folder out of `Interface/AddOns` and install `LockpickAtlas`. To carry over personal pins and settings, copy `LockpickAssist.lua` from your account's `WTF/Account/<account>/SavedVariables` folder to `LockpickAtlas.lua` in the same folder. Keep the original as a backup. If `LockpickAtlas.lua` already exists, keep it to preserve your Atlas settings.
