-- config.lua

local module = {}

-- vars
module.LOCKPIN = 5

-- WiFi
module.SSID=""
module.PASSWORD=""

-- MQTT
module.BROKER1="192.168.0.112"
module.BROKER2="192.168.0.200"
module.PORT=1883
module.ID="SmartLock: " .. wifi.sta.getmac()
module.USER=""
module.PASS=""
module.KEEPALIVE=18000
module.QOS=2 --exactly once
module.ENDPOINT="smartlock/"

return module