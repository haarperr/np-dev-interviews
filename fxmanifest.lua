fx_version "cerulean"
game "gta5"

author "AstroNaught"
version "1.0.0"

client_scripts {
	"@bt-polyzone/main.lua", -- Replace with np-polyzone
	"cl_vineyard.lua",
	"cl_data.lua",
	"cl_np.lua"
}
server_scripts {
	"sv_vineyard.lua",
	"sv_np.lua",
	"sv_data.lua"
}
shared_script "shared_data.lua"
