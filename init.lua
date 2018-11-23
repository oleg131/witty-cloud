----------------------
-- Global Variables --
----------------------

-- WiFi Variables
SSID = "wifi_ssid"
PASS = "wifi_password"

-- GPIO Pins
-- Default for Witty Cloud
LED_PIN_1 = 6
LED_PIN_2 = 7
LED_PIN_3 = 8
ADC_PIN = 0

-- Restart every N hours
-- Prevents hanging
RESTART_DELAY = 4 * (1000 * 60 * 60)

function restart()
  node.restart()
end

-- Configure Wireless Internet
wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ', wifi.sta.getmac())
print('Chip ID: ', node.chipid())
print('Heap Size: ', node.heap(), '\n')

-- Configure WiFi
wifi.sta.config(ssid, pass)

----------------------------------
-- WiFi Connection Verification --
----------------------------------
tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      print("Connecting to AP...\n")
   else
      ip, nm, gw = wifi.sta.getip()
      print("IP Info: \nIP Address: ", ip)
      print("Netmask: ", nm)
      print("Gateway Addr: ", gw, '\n')
      tmr.stop(0)
   end
end)

----------------
-- GPIO Setup --
----------------
print("Setting Up GPIO...")

-- Turn off LED
gpio.mode(LED_PIN_1, gpio.OUTPUT)
gpio.write(LED_PIN_1, gpio.LOW)
gpio.mode(LED_PIN_2, gpio.OUTPUT)
gpio.write(LED_PIN_2, gpio.LOW)
gpio.mode(LED_PIN_3, gpio.OUTPUT)
gpio.write(LED_PIN_3, gpio.LOW)

----------------
-- Web Server --
----------------
print("Starting Web Server...")

-- Create a server object with 30 second timeout
srv = net.createServer(net.TCP, 10)

srv:listen(80, function(conn)
	conn:on("receive", function(conn, payload)
    conn:send(adc.read(adc_id))
    conn:on("sent", function(conn) conn:close() end)
	end)
end)

tmr.alarm(1, RESTART_DELAY, 1, restart)
