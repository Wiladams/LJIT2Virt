local ffi = require("ffi")

local export = {}

ffi.cdef[[

typedef struct _virNodeDevice virNodeDevice;


typedef virNodeDevice *virNodeDevicePtr;


int                     virNodeNumOfDevices     (virConnectPtr conn,
                                                 const char *cap,
                                                 unsigned int flags);

int                     virNodeListDevices      (virConnectPtr conn,
                                                 const char *cap,
                                                 char **const names,
                                                 int maxnames,
                                                 unsigned int flags);

typedef enum {
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_SYSTEM        = 1 << 0,  /* System capability */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_PCI_DEV       = 1 << 1,  /* PCI device */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_USB_DEV       = 1 << 2,  /* USB device */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_USB_INTERFACE = 1 << 3,  /* USB interface */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_NET           = 1 << 4,  /* Network device */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_SCSI_HOST     = 1 << 5,  /* SCSI Host Bus Adapter */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_SCSI_TARGET   = 1 << 6,  /* SCSI Target */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_SCSI          = 1 << 7,  /* SCSI device */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_STORAGE       = 1 << 8,  /* Storage device */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_FC_HOST       = 1 << 9,  /* FC Host Bus Adapter */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_VPORTS        = 1 << 10, /* Capable of vport */
    VIR_CONNECT_LIST_NODE_DEVICES_CAP_SCSI_GENERIC  = 1 << 11, /* Capable of scsi_generic */
} virConnectListAllNodeDeviceFlags;

int                     virConnectListAllNodeDevices (virConnectPtr conn,
                                                      virNodeDevicePtr **devices,
                                                      unsigned int flags);

virNodeDevicePtr        virNodeDeviceLookupByName (virConnectPtr conn,
                                                   const char *name);

virNodeDevicePtr        virNodeDeviceLookupSCSIHostByWWN (virConnectPtr conn,
                                                          const char *wwnn,
                                                          const char *wwpn,
                                                          unsigned int flags);

const char *            virNodeDeviceGetName     (virNodeDevicePtr dev);

const char *            virNodeDeviceGetParent   (virNodeDevicePtr dev);

int                     virNodeDeviceNumOfCaps   (virNodeDevicePtr dev);

int                     virNodeDeviceListCaps    (virNodeDevicePtr dev,
                                                  char **const names,
                                                  int maxnames);

char *                  virNodeDeviceGetXMLDesc (virNodeDevicePtr dev,
                                                 unsigned int flags);

int                     virNodeDeviceRef        (virNodeDevicePtr dev);
int                     virNodeDeviceFree       (virNodeDevicePtr dev);

int                     virNodeDeviceDettach    (virNodeDevicePtr dev);
int                     virNodeDeviceDetachFlags(virNodeDevicePtr dev,
                                                 const char *driverName,
                                                 unsigned int flags);
int                     virNodeDeviceReAttach   (virNodeDevicePtr dev);
int                     virNodeDeviceReset      (virNodeDevicePtr dev);

virNodeDevicePtr        virNodeDeviceCreateXML  (virConnectPtr conn,
                                                 const char *xmlDesc,
                                                 unsigned int flags);

int                     virNodeDeviceDestroy    (virNodeDevicePtr dev);
]]

return export
