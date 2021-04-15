-- Basic configuration of vineyard job task
VineyardRequiredPicksPerField = 5
VineyardLocationPickDistance = 5.0
VineyardLocationPickRequiredTimeMs = 5000

-- Item reward statistics
VineyardMinWineReward = 10
VineyardMaxWineReward = 20

-- Define the field locations which will be randomly chosen to be sent to the client
VineyardFieldLocations = {
	[1] = {
		["FieldName"] = "Center Northern Field #1",
		["FieldZone"] = "Vineyard.VinesCloseCenter",
		["FieldCenterX"] = -1819.0,
		["FieldCenterY"] = 2128.4,
		["FieldCenterZ"] = 127.0
	},
	[2] = {
		["FieldName"] = "Right Northern Field #1 ",
		["FieldZone"] = "Vineyard.VinesCloseRight",
		["FieldCenterX"] = -1807.1,
		["FieldCenterY"] = 2089.6,
		["FieldCenterZ"] = 127.0
	},
	[3] = {
		["FieldName"] = "Left Northern Field #1",
		["FieldZone"] = "Vineyard.VinesCloseLeft",
		["FieldCenterX"] = -1878.1,
		["FieldCenterY"] = 2132.6,
		["FieldCenterZ"] = 127.0
	},
	[4] = {
		["FieldName"] = "Left Northern Field #2",
		["FieldZone"] = "Vineyard.VinesCenterLeft",
		["FieldCenterX"] = -1870.3,
		["FieldCenterY"] = 2202.5,
		["FieldCenterZ"] = 102.0
	},
	[5] = {
		["FieldName"] = "Right Northern Field #2",
		["FieldZone"] = "Vineyard.VinesCenterRight",
		["FieldCenterX"] = -1773.0,
		["FieldCenterY"] = 2190.9,
		["FieldCenterZ"] = 110.0
	},
	[6] = {
		["FieldName"] = "Left Northern Field #3",
		["FieldZone"] = "Vineyard.VinesTopLeft",
		["FieldCenterX"] = -1866.6,
		["FieldCenterY"] = 2258.4,
		["FieldCenterZ"] = 79.0
	},
	[7] = {
		["FieldName"] = "Right Northern Field #3",
		["FieldZone"] = "Vineyard.VinesTopRight",
		["FieldCenterX"] = -1779.0,
		["FieldCenterY"] = 2254.1,
		["FieldCenterZ"] = 85.0
	},
	[8] = {
		["FieldName"] = "Southern Field #1",
		["FieldZone"] = "Vineyard.VinesBottomClose",
		["FieldCenterX"] = -1915.1,
		["FieldCenterY"] = 1937.8,
		["FieldCenterZ"] = 160.4
	},
	[9] = {
		["FieldName"] = "Southern Field #2",
		["FieldZone"] = "Vineyard.VinesBottomFar",
		["FieldCenterX"] = -1893.4,
		["FieldCenterY"] = 1884.8,
		["FieldCenterZ"] = 163.7
	},
	[10] = {
		["FieldName"] = "East Field #2",
		["FieldZone"] = "Vineyard.VinesEastBottom",
		["FieldCenterX"] = -1749.2,
		["FieldCenterY"] = 1921.3,
		["FieldCenterZ"] = 141.9
	},
	[11] = {
		["FieldName"] = "East Field #1",
		["FieldZone"] = "Vineyard.VinesEastTop",
		["FieldCenterX"] = -1710.8,
		["FieldCenterY"] = 1984.2,
		["FieldCenterZ"] = 123.3
	}
}
