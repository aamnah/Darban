-- WiFi
wifi.setmode(wifi.STATION)
wifi.sta.config(config.SSID, config.PASSWORD)
tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function() 
  print(wifi.sta.getip())
end)

-- LOCK
function autolock()
  gpio.mode(config.LOCKPIN, gpio.OUTPUT)
  gpio.write(config.LOCKPIN, gpio.HIGH)
  m:publish("home/smartlock", "UNLOCKED", config.QOS, 0, 
  function(conn) 
    print("UNLOCKED")
  end)  
  if gpio.read(config.LOCKPIN) == 1 then
    tmr.alarm(3, 5000, tmr.ALARM_SINGLE, function() 
      gpio.write(config.LOCKPIN, gpio.LOW)
      m:publish(config.ENDPOINT, "Door has been automatically LOCKED after 5 seconds.", config.QOS, 0, 
      function(conn) 
        print("Door has been automatically LOCKED after 5 seconds.")      
      end)
    end)
  end
end

-- MQTT
m = mqtt.Client(config.ID, config.KEEPALIVE, config.USER, config.PASS)
m:lwt("/lwt", "SmartLock LOST ", config.QOS, 0)

m:on("offline", function(con) 
   print ("MQTT OFFLINE. Reconnecting...") 
   print(node.heap())
   tmr.alarm(2, 10000, 0, function()
      m:connect(config.BROKER2, config.PORT, 0) --0/false = non-secure
   end)
end)

m:on("message", function(conn, topic, data) 
  if data == "autolock" then
    autolock()
  elseif data == "restart" then
    m:publish(config.ENDPOINT, "Restarting.. ", config.QOS, 0, function(conn) 
      node.restart()
    end)
  elseif data == "info" then
    m:publish(config.ENDPOINT, lang.payload_info, config.QOS, 0, function(conn) 
      func.info()
    end)
  elseif data == "sysinfo" then
    func.sysinfo()
  elseif data == "fsinfo" then
    func.fsinfo()
  elseif data == "chipinfo" then
    func.chipinfo()
  else
    m:publish(config.ENDPOINT, "Invalid command", config.QOS, 0, function(conn)
      print(topic .. ": " .. data)
    end)
  end
end)

tmr.alarm(1, 1000, 1, function()
  if wifi.sta.status() == 5 then -- 5: STA_GOTIP
    tmr.stop(1)
    m:connect(config.BROKER2, config.PORT, 0, function(conn) 
      print("Connected to MQTT Broker.")
      m:subscribe("home/smartlock", config.QOS, function(conn) 
        m:publish("home/smartlock", "SmartLock is ONLINE. MAC: ".. wifi.sta.getmac() .. " IP: " ..wifi.sta.getip(), config.QOS, 0, 
        function(conn) 
          print("ACK sent") 
        end)
      end)
    end)
  end
end)
