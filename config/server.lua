-- protected: never listed in fxmanifest files(), server-only

local resource = GetCurrentResourceName()

load(LoadResourceFile(resource, "config/server/recipes.lua"))()

Config = { Restaurants = {} }

local restaurantFiles = {
	"avast_arcade",
	"aztecas",
	"bahama",
	"bakery",
	"ballers",
	"beanmachine",
	"bowling",
	"burgershot",
	"casino",
	"lasttrain",
	"mba",
	"noodle",
	"pizza_this",
	"prego",
	"rockford_records",
	"rustybrowns",
	"smokeonthewater",
	"tequila",
	"triad",
	"unicorn",
	"uwu_cafe",
	"vagos",
	"woods_saloon",
}

for _, name in ipairs(restaurantFiles) do
	load(LoadResourceFile(resource, string.format("config/server/restaurants/%s.lua", name)))()
end

return Config
