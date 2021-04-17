fx_version "cerulean"
game "gta5"

author "AstroNaught"
version "1.0.0"

dependencies {
	"bt-polyzone",
	"np-activities"
}

client_scripts {
	"cl_vineyard.lua",
	"cl_data.lua",
	"cl_utils.lua",
	"cl_np.lua"
}

exports {
	"setActivityStatus",
	"setLocationStatus",
	"setActivityDestination",
	"removeActivityDestination",
	"startActivity"
}

server_scripts {
	"sv_vineyard.lua",
	"sv_np.lua",
	"sv_data.lua"
}
shared_scripts {
	"shared_config.lua",
	"shared_data.lua"
}
