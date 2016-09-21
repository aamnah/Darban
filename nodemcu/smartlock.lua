SSID="Makeistan"
PASSWORD="arduinonight"
BROKER1="192.168.0.112"
BROKER2="192.168.0.200"
ENDPOINT="smartlock/"
PORT=1883
ID="SmartLock: " .. wifi.sta.getmac()
KEEPALIVE=18000
USER=""
PASS=""

print(ID)

-- wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, PASSWORD)
tmr.alarm(1, 5000, tmr.ALARM_SINGLE, function() 
  print(wifi.sta.getip())
end)

-- lock
lockPin = 5
gpio.mode(lockPin, gpio.OUTPUT)

function autolock()
  gpio.write(lockPin, gpio.HIGH)
  print("UNLOCKED")
  if gpio.read(lockPin) == 1 then
    tmr.alarm(1, 5000, tmr.ALARM_SINGLE, function() 
      gpio.write(lockPin, gpio.LOW)
      print("Door has been automatically LOCKED after 5 seconds.")
    end)
  end
end

m = mqtt.Client(ID, KEEPALIVE, USER, PASS)
m:lwt("/lwt", "LWT LOST " ..wifi.sta.getmac(), 0, 0)

m:on("offline", function(con) 
   print ("reconnecting...") 
   print(node.heap())
   tmr.alarm(1, 10000, 0, function()
      m:connect(BROKER2, PORT, 0)
   end)
end)

-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)

tmr.alarm(0, 1000, 1, function()
 if wifi.sta.status() == 5 then
   tmr.stop(0)
   m:connect(BROKER2, PORT, 0, function(conn) 
      print("connected")
      m:subscribe("home/smartlock",0, function(conn) 
      m:publish("home/smartlock","hello form smartlock",0,0, function(conn) print("ack sent") end)
      end)
   end)
 end
end)