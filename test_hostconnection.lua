-- test_hostconnection.lua
local Connection = require("hostconnection")


local function printAttributes(conn)
-- print some connection attributes
	print("Host Name: ", conn:getHostName());
	print("Encrypted: ", conn:isEncrypted());
	print("   Secure: ", conn:isSecure());
	print("     Live: ", conn:isAlive());
end

local function printCPUModelNames(conn)
-- try out the model names iterator
	print("printCPUModelNames")
	for name in conn:cpuModelNames() do
		print("MODEL: ", name);
	end
end

local function printCapabilities(conn)
	print("==== printCapabilities ====");
	print(conn:getCapabilities())
end

local hosturi = "qemu:///system"
local conn = Connection(hosturi);
if not conn then 
	print("No connection established to: ", hosturi)
	return 
end

printAttributes(conn)
--printCPUModelNames(conn)
--printCapabilities(conn)

