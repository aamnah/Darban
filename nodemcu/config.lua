-- config.lua

local module = {}

module.SSID=""
module.PASSWORD=""
module.BROKER1="192.168.0.112"
module.BROKER2="192.168.0.200"
module.ENDPOINT="smartlock/"
module.PORT=1883
module.ID="SmartLock: " .. wifi.sta.getmac()
module.KEEPALIVE=18000
module.QOS=2 --exactly once
module.USER=""
module.PASS=""

return module
