-- Track currently working players
VineyardCurrentlyWorkingPlayers = {}

-- Track the stats of a currently working group.
-- Includes current players associated with a group, the number of current picks
-- on a field, and field information.
-- Example [0] = {
-- 	Players = [22, 42, 43],
-- 	JobCompleted = false,
-- 	CurrentField = 2
-- 	NextField = 4,
-- 	CurrentPicks = 0
-- }
VineyardCurrentlyWorkingGroups = {}

-- Track the current status of fields being worked by group.
-- This includes areas that have been or are in the progress of being
-- picked by a player.
-- Example:
-- [1] (Group Id) = {
--	[1] (Pick Id) = {
-- 		Completed = false,
--		InProgress = true,
--		PosX = 2.0,
--		PosY = 3.0
--	}
-- }
VineyardWorkingFieldsStatus = {}

for i = 1, #VineyardFieldLocations do
	VineyardWorkingFieldsStatus[i] = {
		["LastChanged"] = nil,
		["PickedAreas"] = {}
	}
end
