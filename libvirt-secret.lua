local ffi = require("ffi")

local export = {}

ffi.cdef[[

typedef struct _virSecret virSecret;
typedef virSecret *virSecretPtr;

typedef enum {
    VIR_SECRET_USAGE_TYPE_NONE = 0,
    VIR_SECRET_USAGE_TYPE_VOLUME = 1,
    VIR_SECRET_USAGE_TYPE_CEPH = 2,
    VIR_SECRET_USAGE_TYPE_ISCSI = 3,

    VIR_SECRET_USAGE_TYPE_LAST
} virSecretUsageType;

virConnectPtr           virSecretGetConnect     (virSecretPtr secret);
int                     virConnectNumOfSecrets  (virConnectPtr conn);
int                     virConnectListSecrets   (virConnectPtr conn,
                                                 char **uuids,
                                                 int maxuuids);

typedef enum {
    VIR_CONNECT_LIST_SECRETS_EPHEMERAL    = 1 << 0, /* kept in memory, never
                                                       stored persistently */
    VIR_CONNECT_LIST_SECRETS_NO_EPHEMERAL = 1 << 1,

    VIR_CONNECT_LIST_SECRETS_PRIVATE      = 1 << 2, /* not revealed to any caller
                                                       of libvirt, nor to any other
                                                       node */
    VIR_CONNECT_LIST_SECRETS_NO_PRIVATE   = 1 << 3,
} virConnectListAllSecretsFlags;

int                     virConnectListAllSecrets(virConnectPtr conn,
                                                 virSecretPtr **secrets,
                                                 unsigned int flags);
virSecretPtr            virSecretLookupByUUID(virConnectPtr conn,
                                              const unsigned char *uuid);
virSecretPtr            virSecretLookupByUUIDString(virConnectPtr conn,
                                                    const char *uuid);
virSecretPtr            virSecretLookupByUsage(virConnectPtr conn,
                                               int usageType,
                                               const char *usageID);
virSecretPtr            virSecretDefineXML      (virConnectPtr conn,
                                                 const char *xml,
                                                 unsigned int flags);
int                     virSecretGetUUID        (virSecretPtr secret,
                                                 unsigned char *buf);
int                     virSecretGetUUIDString  (virSecretPtr secret,
                                                 char *buf);
int                     virSecretGetUsageType   (virSecretPtr secret);
const char *            virSecretGetUsageID     (virSecretPtr secret);
char *                  virSecretGetXMLDesc     (virSecretPtr secret,
                                                 unsigned int flags);
int                     virSecretSetValue       (virSecretPtr secret,
                                                 const unsigned char *value,
                                                 size_t value_size,
                                                 unsigned int flags);
unsigned char *         virSecretGetValue       (virSecretPtr secret,
                                                 size_t *value_size,
                                                 unsigned int flags);
int                     virSecretUndefine       (virSecretPtr secret);
int                     virSecretRef            (virSecretPtr secret);
int                     virSecretFree           (virSecretPtr secret);


]]

return export
