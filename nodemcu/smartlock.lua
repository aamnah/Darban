-- wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(config.SSID, config.PASSWORD)
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function() 
  print(wifi.sta.getip())
end)

-- lock
function autolock()
  gpio.mode(config.LOCKPIN, gpio.OUTPUT)
  gpio.write(config.LOCKPIN, gpio.HIGH)
  print("UNLOCKED")
  if gpio.read(config.LOCKPIN) == 1 then
    tmr.alarm(3, 5000, tmr.ALARM_SINGLE, function() 
      gpio.write(config.LOCKPIN, gpio.LOW)
      print("Door has been automatically LOCKED after 5 seconds.")
    end)
  end
end

m = mqtt.Client(config.ID, config.KEEPALIVE, config.USER, config.PASS)
m:lwt("/lwt", "SmartLock LOST " ..wifi.sta.getmac(), config.QOS, 0)

m:on("offline", function(con) 
   print ("reconnecting...") 
   print(node.heap())
   tmr.alarm(2, 10000, 0, function()
      m:connect(config.BROKER2, config.PORT, 0) --0/false = non-secure
   end)
end)

-- on publish message receive event
m:on("message", function(conn, topic, data) 
  if data  == "autolock" then
    autolock()
  else
    print(topic .. ": " .. data)
  end
end)

tmr.alarm(1, 1000, 1, function()
  if wifi.sta.status() == 5 then -- 5: STA_GOTIP
    tmr.stop(1)
    m:connect(config.BROKER2, config.PORT, 0, function(conn) 
      print("Connected to MQTT Broker.")
      m:subscribe("home/smartlock", config.QOS, function(conn) 
        m:publish("home/smartlock", "SmartLock is ONLINE", config.QOS, 0, 
        function(conn) 
          print("ACK sent") 
        end)
      end)
    end)
  end
end)
