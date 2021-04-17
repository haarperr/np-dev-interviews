-- This is designed to be compatible with the np-polyzone
-- method of creating tracked enterable zones as demonstrated in
-- DW's 4/12 farmer's market
exports["bt-polyzone"]:AddCircleZone(
	"Vineyard.JobPed",
	VineyardJobPosVector,
	2.5,
	{
		name = "Vineyard.JobPed",
		minZ = 138.0,
		maxZ = 141.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesCloseLeft",
	{
		vector2(-1871.6700439453, 2094.2268066406),
		vector2(-1915.4471435547, 2097.6984863281),
		vector2(-1909.4754638672, 2156.9411621094),
		vector2(-1887.0437011719, 2168.7700195313),
		vector2(-1854.0191650391, 2165.5778808594),
		vector2(-1838.1499023438, 2151.6684570313),
		vector2(-1843.384765625, 2131.6936035156)
	},
	{
		name = "Vineyard.VinesCloseLeft",
		minZ = 111.0,
		maxZ = 141.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesCloseCenter",
	{
		vector2(-1865.6380615234, 2094.0859375),
		vector2(-1828.4647216797, 2148.3154296875),
		vector2(-1753.142578125, 2153.9724121094),
		vector2(-1806.0235595703, 2114.65625)
	},
	{
		name = "Vineyard.VinesCloseCenter",
		minZ = 115.0,
		maxZ = 141.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesCloseRight",
	{
		vector2(-1857.7094726563, 2088.1228027344),
		vector2(-1830.115234375, 2103.2443847656),
		vector2(-1744.8278808594, 2146.9497070313),
		vector2(-1684.8671875, 2160.8898925781),
		vector2(-1683.7412109375, 2157.2700195313),
		vector2(-1728.517578125, 2127.9978027344),
		vector2(-1786.9273681641, 2072.6623535156),
		vector2(-1804.6019287109, 2061.7844238281),
		vector2(-1838.5964355469, 2059.6560058594)
	},
	{
		name = "Vineyard.VinesCloseRight",
		minZ = 106.0,
		maxZ = 141.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesCenterLeft",
	{
		vector2(-1836.4489746094, 2162.3776855469),
		vector2(-1901.0759277344, 2181.7421875),
		vector2(-1902.484375, 2225.1003417969),
		vector2(-1884.0187988281, 2232.2177734375),
		vector2(-1856.7941894531, 2227.2653808594),
		vector2(-1835.5148925781, 2213.03125),
		vector2(-1822.7163085938, 2184.9189453125)
	},
	{
		name = "Vineyard.VinesCenterLeft",
		minZ = 82.0,
		maxZ = 115.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesCenterRight",
	{
		vector2(-1827.3034667969, 2155.8369140625),
		vector2(-1773.6218261719, 2156.4555664063),
		vector2(-1706.5614013672, 2160.7937011719),
		vector2(-1674.4757080078, 2173.6772460938),
		vector2(-1668.0871582031, 2190.5732421875),
		vector2(-1697.2836914063, 2201.1867675781),
		vector2(-1758.5179443359, 2223.5864257813),
		vector2(-1797.8542480469, 2224.2165527344),
		vector2(-1821.1751708984, 2209.9663085938),
		vector2(-1815.7193603516, 2185.3139648438)
	},
	{
		name = "Vineyard.VinesCenterRight",
		minZ = 88.0,
		maxZ = 122.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesTopRight",
	{
		vector2(-1827.6240234375, 2220.2866210938),
		vector2(-1810.3227539063, 2224.1118164063),
		vector2(-1789.2321777344, 2230.6462402344),
		vector2(-1741.1141357422, 2230.5151367188),
		vector2(-1741.3869628906, 2262.7006835938),
		vector2(-1763.0675048828, 2276.0505371094),
		vector2(-1799.1470947266, 2276.8876953125),
		vector2(-1822.5753173828, 2259.5544433594)
	},
	{
		name = "Vineyard.VinesTopRight",
		minZ = 70.0,
		maxZ = 93.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesTopLeft",
	{
		vector2(-1828.9976806641, 2269.5900878906),
		vector2(-1844.931640625, 2280.0158691406),
		vector2(-1871.4866943359, 2285.1647949219),
		vector2(-1901.6925048828, 2276.5888671875),
		vector2(-1904.5676269531, 2237.3859863281),
		vector2(-1873.7473144531, 2238.2661132813),
		vector2(-1849.4697265625, 2230.7648925781),
		vector2(-1833.7154541016, 2227.9116210938)
	},
	{
		name = "Vineyard.VinesTopLeft",
		minZ = 64.0,
		maxZ = 89.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesBottomClose",
	{
		vector2(-1859.8314208984, 1933.6130371094),
		vector2(-1892.9918212891, 1966.6336669922),
		vector2(-1904.7911376953, 1969.7687988281),
		vector2(-1972.4197998047, 1965.7004394531),
		vector2(-1986.478515625, 1946.1413574219),
		vector2(-1942.5546875, 1917.3806152344),
		vector2(-1935.4114990234, 1903.5251464844),
		vector2(-1924.6502685547, 1896.9698486328),
		vector2(-1881.5111083984, 1911.4453125)
	},
	{
		name = "Vineyard.VinesBottomClose",
		minZ = 144.0,
		maxZ = 178.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesBottomFar",
	{
		vector2(-1849.1885986328, 1923.6634521484),
		vector2(-1890.2839355469, 1902.1146240234),
		vector2(-1914.8685302734, 1894.0222167969),
		vector2(-1937.5219726563, 1877.4598388672),
		vector2(-1952.9626464844, 1837.1628417969),
		vector2(-1945.8289794922, 1822.8001708984),
		vector2(-1897.5483398438, 1855.6809082031),
		vector2(-1839.984375, 1897.1947021484)
	},
	{
		name = "Vineyard.VinesBottomFar",
		minZ = 144.0,
		maxZ = 181.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesEastTop",
	{
		vector2(-1700.3826904297, 2041.3415527344),
		vector2(-1690.5655517578, 2037.0928955078),
		vector2(-1687.0235595703, 2015.1739501953),
		vector2(-1687.9310302734, 1980.1751708984),
		vector2(-1682.1813964844, 1967.4788818359),
		vector2(-1683.8492431641, 1948.0803222656),
		vector2(-1692.1478271484, 1937.2127685547),
		vector2(-1699.2677001953, 1918.8297119141),
		vector2(-1704.8021240234, 1921.1806640625),
		vector2(-1723.1236572266, 1954.6317138672),
		vector2(-1739.6040039063, 1974.1072998047),
		vector2(-1737.5628662109, 1997.7252197266),
		vector2(-1724.0986328125, 2016.0480957031),
		vector2(-1718.5864257813, 2031.2052001953),
		vector2(-1710.6052246094, 2042.068359375)
	},
	{
		name = "Vineyard.VinesEastTop",
		minZ = 109.0,
		maxZ = 149.0
	}
)

exports["bt-polyzone"]:AddPolyzone(
	"Vineyard.VinesEastBottom",
	{
		vector2(-1751.5093994141, 1980.3056640625),
		vector2(-1727.6673583984, 1948.8680419922),
		vector2(-1724.5870361328, 1931.2255859375),
		vector2(-1703.8479003906, 1905.2755126953),
		vector2(-1704.6041259766, 1894.3028564453),
		vector2(-1710.6760253906, 1885.7833251953),
		vector2(-1765.9254150391, 1886.0334472656),
		vector2(-1779.6680908203, 1894.7612304688),
		vector2(-1788.8342285156, 1928.1927490234),
		vector2(-1771.0660400391, 1958.6015625)
	},
	{
		name = "Vineyard.VinesEastBottom",
		minZ = 117.0,
		maxZ = 162.0
	}
)
