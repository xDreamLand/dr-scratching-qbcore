fx_version 'cerulean'
game 'gta5'

description 'Start scratching! Odds Are Meant To Be Beaten'
author 'Dream Resources' -- https://forum.cfx.re/u/xDreamLand/summary
version '3.2.0'
repository 'https://github.com/xDreamLand/dr-scratching-qbcore'

lua54 'yes'

server_scripts {
    'config.lua',

    'shared/utils.lua',
    'server/s_main.lua',
    'server/s_webhooks.lua',
    'server/s_version.lua'
}

client_scripts {
    'config.lua',

    'client/c_main.lua',
    'client/c_nui.lua',
}

ui_page "html/index.html"

files {
    'html/index.html',
    'html/js/*.js',
    'html/css/*.css',
    'html/img/*.png',
    'html/img/*.jpg'
}
