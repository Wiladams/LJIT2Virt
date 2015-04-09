__VIR_LIBVIRT_H_INCLUDES__ = true;

local export = {}

require "libvirt-host"
require "libvirt-domain"
require "libvirt-domain-snapshot"
require "libvirt-event"
require "libvirt-interface"
require "libvirt-network"
require "libvirt-nodedev"
require "libvirt-nwfilter"
require "libvirt-secret"
require "libvirt-storage"
require "libvirt-stream"


-- load the library
-- retain a reference in a table
return export
