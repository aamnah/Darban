-- wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(config.SSID, config.PASSWORD)
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

m = mqtt.Client(config.ID, config.KEEPALIVE, config.USER, config.PASS)
m:lwt("/lwt", "LWT LOST " ..wifi.sta.getmac(), 0, 0)

m:on("offline", function(con) 
   print ("reconnecting...") 
   print(node.heap())
   tmr.alarm(1, 10000, 0, function()
      m:connect(config.BROKER2, config.PORT, 0)
   end)
end)

-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data  == "autolock" then
    autolock()
  else
    print(data)
  end
end)

tmr.alarm(0, 1000, 1, function()
 if wifi.sta.status() == 5 then
   tmr.stop(0)
   m:connect(config.BROKER2, config.PORT, 0, function(conn) 
      print("connected")
      m:subscribe("home/smartlock",0, function(conn) 
      m:publish("home/smartlock","hello form smartlock", 0, 0, function(conn) print("ack sent") end)
      end)
   end)
 end
end)
