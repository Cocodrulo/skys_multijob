fx_version "cerulean"
game "gta5"

author "Cocodrulo"
version '1.1.0'
description "A multi-job script for any framework"

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

files {
    "common/config/shared.lua",
    "common/frameworks/framework.lua",
    "common/frameworks/**/client.lua",
    "common/frameworks/**/server.lua",
    "locales/*.json"
}
