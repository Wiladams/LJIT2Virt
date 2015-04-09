local ffi = require("ffi")

local export = {}

ffi.cdef[[
typedef enum {
    VIR_NETWORK_XML_INACTIVE = (1 << 0), /* dump inactive network information */
} virNetworkXMLFlags;


typedef struct _virNetwork virNetwork;


typedef virNetwork *virNetworkPtr;


virConnectPtr           virNetworkGetConnect    (virNetworkPtr network);


int                     virConnectNumOfNetworks (virConnectPtr conn);
int                     virConnectListNetworks  (virConnectPtr conn,
                                                 char **const names,
                                                 int maxnames);


int                     virConnectNumOfDefinedNetworks  (virConnectPtr conn);
int                     virConnectListDefinedNetworks   (virConnectPtr conn,
                                                         char **const names,
                                                         int maxnames);

typedef enum {
    VIR_CONNECT_LIST_NETWORKS_INACTIVE      = 1 << 0,
    VIR_CONNECT_LIST_NETWORKS_ACTIVE        = 1 << 1,

    VIR_CONNECT_LIST_NETWORKS_PERSISTENT    = 1 << 2,
    VIR_CONNECT_LIST_NETWORKS_TRANSIENT     = 1 << 3,

    VIR_CONNECT_LIST_NETWORKS_AUTOSTART     = 1 << 4,
    VIR_CONNECT_LIST_NETWORKS_NO_AUTOSTART  = 1 << 5,
} virConnectListAllNetworksFlags;

int                     virConnectListAllNetworks       (virConnectPtr conn,
                                                         virNetworkPtr **nets,
                                                         unsigned int flags);


virNetworkPtr           virNetworkLookupByName          (virConnectPtr conn,
                                                         const char *name);
virNetworkPtr           virNetworkLookupByUUID          (virConnectPtr conn,
                                                         const unsigned char *uuid);
virNetworkPtr           virNetworkLookupByUUIDString    (virConnectPtr conn,
                                                         const char *uuid);


virNetworkPtr           virNetworkCreateXML     (virConnectPtr conn,
                                                 const char *xmlDesc);


virNetworkPtr           virNetworkDefineXML     (virConnectPtr conn,
                                                 const char *xmlDesc);


int                     virNetworkUndefine      (virNetworkPtr network);


typedef enum {
    VIR_NETWORK_UPDATE_COMMAND_NONE      = 0, /* (invalid) */
    VIR_NETWORK_UPDATE_COMMAND_MODIFY    = 1, /* modify an existing element */
    VIR_NETWORK_UPDATE_COMMAND_DELETE    = 2, /* delete an existing element */
    VIR_NETWORK_UPDATE_COMMAND_ADD_LAST  = 3, /* add an element at end of list */
    VIR_NETWORK_UPDATE_COMMAND_ADD_FIRST = 4, /* add an element at start of list */
    VIR_NETWORK_UPDATE_COMMAND_LAST

} virNetworkUpdateCommand;


typedef enum {
    VIR_NETWORK_SECTION_NONE              =  0, /* (invalid) */
    VIR_NETWORK_SECTION_BRIDGE            =  1, /* <bridge> */
    VIR_NETWORK_SECTION_DOMAIN            =  2, /* <domain> */
    VIR_NETWORK_SECTION_IP                =  3, /* <ip> */
    VIR_NETWORK_SECTION_IP_DHCP_HOST      =  4, /* <ip>/<dhcp>/<host> */
    VIR_NETWORK_SECTION_IP_DHCP_RANGE     =  5, /* <ip>/<dhcp>/<range> */
    VIR_NETWORK_SECTION_FORWARD           =  6, /* <forward> */
    VIR_NETWORK_SECTION_FORWARD_INTERFACE =  7, /* <forward>/<interface> */
    VIR_NETWORK_SECTION_FORWARD_PF        =  8, /* <forward>/<pf> */
    VIR_NETWORK_SECTION_PORTGROUP         =  9, /* <portgroup> */
    VIR_NETWORK_SECTION_DNS_HOST          = 10, /* <dns>/<host> */
    VIR_NETWORK_SECTION_DNS_TXT           = 11, /* <dns>/<txt> */
    VIR_NETWORK_SECTION_DNS_SRV           = 12, /* <dns>/<srv> */
    VIR_NETWORK_SECTION_LAST

} virNetworkUpdateSection;


typedef enum {
    VIR_NETWORK_UPDATE_AFFECT_CURRENT = 0,      /* affect live if network is active,
                                                   config if it's not active */
    VIR_NETWORK_UPDATE_AFFECT_LIVE    = 1 << 0, /* affect live state of network only */
    VIR_NETWORK_UPDATE_AFFECT_CONFIG  = 1 << 1, /* affect persistent config only */
} virNetworkUpdateFlags;


int                     virNetworkUpdate(virNetworkPtr network,
                                         unsigned int command, /* virNetworkUpdateCommand */
                                         unsigned int section, /* virNetworkUpdateSection */
                                         int parentIndex,
                                         const char *xml,
                                         unsigned int flags);


int                     virNetworkCreate        (virNetworkPtr network);


int                     virNetworkDestroy       (virNetworkPtr network);
int                     virNetworkRef           (virNetworkPtr network);
int                     virNetworkFree          (virNetworkPtr network);


const char*             virNetworkGetName       (virNetworkPtr network);
int                     virNetworkGetUUID       (virNetworkPtr network,
                                                 unsigned char *uuid);
int                     virNetworkGetUUIDString (virNetworkPtr network,
                                                 char *buf);
char *                  virNetworkGetXMLDesc    (virNetworkPtr network,
                                                 unsigned int flags);
char *                  virNetworkGetBridgeName (virNetworkPtr network);

int                     virNetworkGetAutostart  (virNetworkPtr network,
                                                 int *autostart);
int                     virNetworkSetAutostart  (virNetworkPtr network,
                                                 int autostart);

int virNetworkIsActive(virNetworkPtr net);
int virNetworkIsPersistent(virNetworkPtr net);


typedef enum {
    VIR_NETWORK_EVENT_DEFINED = 0,
    VIR_NETWORK_EVENT_UNDEFINED = 1,
    VIR_NETWORK_EVENT_STARTED = 2,
    VIR_NETWORK_EVENT_STOPPED = 3,

    VIR_NETWORK_EVENT_LAST

} virNetworkEventLifecycleType;


typedef void (*virConnectNetworkEventLifecycleCallback)(virConnectPtr conn,
                                                        virNetworkPtr net,
                                                        int event,
                                                        int detail,
                                                        void *opaque);
]]

--# define VIR_NETWORK_EVENT_CALLBACK(cb) ((virConnectNetworkEventGenericCallback)(cb))

ffi.cdef[[

typedef enum {
    VIR_NETWORK_EVENT_ID_LIFECYCLE = 0,       /* virConnectNetworkEventLifecycleCallback */

    VIR_NETWORK_EVENT_ID_LAST

} virNetworkEventID;

typedef enum {
    VIR_IP_ADDR_TYPE_IPV4,
    VIR_IP_ADDR_TYPE_IPV6,

    VIR_IP_ADDR_TYPE_LAST
} virIPAddrType;

typedef struct _virNetworkDHCPLease virNetworkDHCPLease;
typedef virNetworkDHCPLease *virNetworkDHCPLeasePtr;
struct _virNetworkDHCPLease {
    char *iface;                /* Network interface name */
    long long expirytime;       /* Seconds since epoch */
    int type;                   /* virIPAddrType */
    char *mac;                  /* MAC address */
    char *iaid;                 /* IAID */
    char *ipaddr;               /* IP address */
    unsigned int prefix;        /* IP address prefix */
    char *hostname;             /* Hostname */
    char *clientid;             /* Client ID or DUID */
};

void virNetworkDHCPLeaseFree(virNetworkDHCPLeasePtr lease);

int virNetworkGetDHCPLeases(virNetworkPtr network,
                            const char *mac,
                            virNetworkDHCPLeasePtr **leases,
                            unsigned int flags);


typedef void (*virConnectNetworkEventGenericCallback)(virConnectPtr conn,
                                                      virNetworkPtr net,
                                                      void *opaque);

/* Use VIR_NETWORK_EVENT_CALLBACK() to cast the 'cb' parameter  */
int virConnectNetworkEventRegisterAny(virConnectPtr conn,
                                      virNetworkPtr net, /* Optional, to filter */
                                      int eventID,
                                      virConnectNetworkEventGenericCallback cb,
                                      void *opaque,
                                      virFreeCallback freecb);

int virConnectNetworkEventDeregisterAny(virConnectPtr conn,
                                        int callbackID);

]]

return export
