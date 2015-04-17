--[[
Copyright (C) 2015
William A Adams

Based On:
/*
 * libvirt-host.h
 * Summary: APIs for management of hosts
 * Description: Provides APIs for the management of hosts
 * Author: Daniel Veillard <veillard@redhat.com>
 *
 * Copyright (C) 2006-2014 Red Hat, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
--]]

local ffi = require("ffi")

local export = {}

ffi.cdef[[
typedef void (*virFreeCallback)(void *opaque);

typedef struct _virConnect virConnect;
typedef virConnect *virConnectPtr;

typedef enum {
    VIR_NODE_SUSPEND_TARGET_MEM     = 0,
    VIR_NODE_SUSPEND_TARGET_DISK    = 1,
    VIR_NODE_SUSPEND_TARGET_HYBRID  = 2,


    VIR_NODE_SUSPEND_TARGET_LAST /* This constant is subject to change */

} virNodeSuspendTarget;


typedef struct _virStream virStream;
typedef virStream *virStreamPtr;


static const int VIR_SECURITY_LABEL_BUFLEN = (4096+1);

typedef struct _virSecurityLabel virSecurityLabel;

struct _virSecurityLabel {
    char label[VIR_SECURITY_LABEL_BUFLEN];    /* security label string */
    int enforcing;                            /* 1 if security policy is being enforced for domain */
};


typedef virSecurityLabel *virSecurityLabelPtr;


static const int VIR_SECURITY_MODEL_BUFLEN = (256 + 1);

static const int VIR_SECURITY_DOI_BUFLEN = (256 + 1);


typedef struct _virSecurityModel virSecurityModel;

struct _virSecurityModel {
    char model[VIR_SECURITY_MODEL_BUFLEN];      /* security model string */
    char doi[VIR_SECURITY_DOI_BUFLEN];          /* domain of interpretation */
};

typedef virSecurityModel *virSecurityModelPtr;


/* Common data types shared among interfaces with name/type/value lists.  */


typedef enum {
    VIR_TYPED_PARAM_INT     = 1, /* integer case */
    VIR_TYPED_PARAM_UINT    = 2, /* unsigned integer case */
    VIR_TYPED_PARAM_LLONG   = 3, /* long long case */
    VIR_TYPED_PARAM_ULLONG  = 4, /* unsigned long long case */
    VIR_TYPED_PARAM_DOUBLE  = 5, /* double case */
    VIR_TYPED_PARAM_BOOLEAN = 6, /* boolean(character) case */
    VIR_TYPED_PARAM_STRING  = 7, /* string case */

    VIR_TYPED_PARAM_LAST
} virTypedParameterType;


typedef enum {
    /* 1 << 0 is reserved for virDomainModificationImpact */
    /* 1 << 1 is reserved for virDomainModificationImpact */

    VIR_TYPED_PARAM_STRING_OKAY = 1 << 2,

} virTypedParameterFlags;


static const int VIR_TYPED_PARAM_FIELD_LENGTH = 80;


typedef struct _virTypedParameter virTypedParameter;

struct _virTypedParameter {
    char field[VIR_TYPED_PARAM_FIELD_LENGTH];  /* parameter name */
    int type;   /* parameter type, virTypedParameterType */
    union {
        int i;                      /* type is INT */
        unsigned int ui;            /* type is UINT */
        long long int l;            /* type is LLONG */
        unsigned long long int ul;  /* type is ULLONG */
        double d;                   /* type is DOUBLE */
        char b;                     /* type is BOOLEAN */
        char *s;                    /* type is STRING, may not be NULL */
    } value; /* parameter value */
};


typedef virTypedParameter *virTypedParameterPtr;


virTypedParameterPtr
virTypedParamsGet       (virTypedParameterPtr params,
                         int nparams,
                         const char *name);
int
virTypedParamsGetInt    (virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         int *value);
int
virTypedParamsGetUInt   (virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         unsigned int *value);
int
virTypedParamsGetLLong  (virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         long long *value);
int
virTypedParamsGetULLong (virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         unsigned long long *value);
int
virTypedParamsGetDouble (virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         double *value);
int
virTypedParamsGetBoolean(virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         int *value);
int
virTypedParamsGetString (virTypedParameterPtr params,
                         int nparams,
                         const char *name,
                         const char **value);
int
virTypedParamsAddInt    (virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         int value);
int
virTypedParamsAddUInt   (virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         unsigned int value);
int
virTypedParamsAddLLong  (virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         long long value);
int
virTypedParamsAddULLong (virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         unsigned long long value);
int
virTypedParamsAddDouble (virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         double value);
int
virTypedParamsAddBoolean(virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         int value);
int
virTypedParamsAddString (virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         const char *value);
int
virTypedParamsAddFromString(virTypedParameterPtr *params,
                         int *nparams,
                         int *maxparams,
                         const char *name,
                         int type,
                         const char *value);
void
virTypedParamsClear     (virTypedParameterPtr params,
                         int nparams);
void
virTypedParamsFree      (virTypedParameterPtr params,
                         int nparams);
]]

ffi.cdef[[
/* data types related to virNodePtr */

typedef struct _virNodeInfo virNodeInfo;

struct _virNodeInfo {
    char model[32];       /* string indicating the CPU model */
    unsigned long memory; /* memory size in kilobytes */
    unsigned int cpus;    /* the number of active CPUs */
    unsigned int mhz;     /* expected CPU frequency */
    unsigned int nodes;   /* the number of NUMA cell, 1 for unusual NUMA
                             topologies or uniform memory access; check
                             capabilities XML for the actual NUMA topology */
    unsigned int sockets; /* number of CPU sockets per node if nodes > 1,
                             1 in case of unusual NUMA topology */
    unsigned int cores;   /* number of cores per socket, total number of
                             processors in case of unusual NUMA topology*/
    unsigned int threads; /* number of threads per core, 1 in case of
                             unusual numa topology */
};


static const int VIR_NODE_CPU_STATS_FIELD_LENGTH = 80;


typedef enum {
    VIR_NODE_CPU_STATS_ALL_CPUS = -1,
} virNodeGetCPUStatsAllCPUs;
]]

export.VIR_NODE_CPU_STATS_KERNEL ="kernel";
export.VIR_NODE_CPU_STATS_USER ="user";
export.VIR_NODE_CPU_STATS_IDLE ="idle";
export.VIR_NODE_CPU_STATS_IOWAIT ="iowait";
export.VIR_NODE_CPU_STATS_INTR ="intr";
export.VIR_NODE_CPU_STATS_UTILIZATION ="utilization";

ffi.cdef[[

typedef struct _virNodeCPUStats virNodeCPUStats;

struct _virNodeCPUStats {
    char field[VIR_NODE_CPU_STATS_FIELD_LENGTH];
    unsigned long long value;
};


static const int VIR_NODE_MEMORY_STATS_FIELD_LENGTH = 80;

typedef enum {
    VIR_NODE_MEMORY_STATS_ALL_CELLS = -1,
} virNodeGetMemoryStatsAllCells;
]]

export.VIR_NODE_MEMORY_STATS_TOTAL ="total";
export.VIR_NODE_MEMORY_STATS_FREE ="free";
export.VIR_NODE_MEMORY_STATS_BUFFERS ="buffers";
export.VIR_NODE_MEMORY_STATS_CACHED ="cached";

ffi.cdef[[

typedef struct _virNodeMemoryStats virNodeMemoryStats;

struct _virNodeMemoryStats {
    char field[VIR_NODE_MEMORY_STATS_FIELD_LENGTH];
    unsigned long long value;
};
]]

export.VIR_NODE_MEMORY_SHARED_PAGES_TO_SCAN      ="shm_pages_to_scan";

export.VIR_NODE_MEMORY_SHARED_SLEEP_MILLISECS    ="shm_sleep_millisecs";

export.VIR_NODE_MEMORY_SHARED_PAGES_SHARED       ="shm_pages_shared";

export.VIR_NODE_MEMORY_SHARED_PAGES_SHARING      ="shm_pages_sharing";

export.VIR_NODE_MEMORY_SHARED_PAGES_UNSHARED     ="shm_pages_unshared";

export.VIR_NODE_MEMORY_SHARED_PAGES_VOLATILE    = "shm_pages_volatile";

export.VIR_NODE_MEMORY_SHARED_FULL_SCANS         ="shm_full_scans";

export.VIR_NODE_MEMORY_SHARED_MERGE_ACROSS_NODES ="shm_merge_across_nodes";

ffi.cdef[[
int virNodeGetMemoryParameters(virConnectPtr conn,
                               virTypedParameterPtr params,
                               int *nparams,
                               unsigned int flags);

int virNodeSetMemoryParameters(virConnectPtr conn,
                               virTypedParameterPtr params,
                               int nparams,
                               unsigned int flags);


int virNodeGetCPUMap(virConnectPtr conn,
                     unsigned char **cpumap,
                     unsigned int *online,
                     unsigned int flags);
]]


export.VIR_NODEINFO_MAXCPUS = function(nodeinfo) 
    return nodeinfo.nodes*nodeinfo.sockets*nodeinfo.cores*nodeinfo.threads;
end

ffi.cdef[[

typedef virNodeInfo *virNodeInfoPtr;

typedef virNodeCPUStats *virNodeCPUStatsPtr;

typedef virNodeMemoryStats *virNodeMemoryStatsPtr;


typedef enum {
    VIR_CONNECT_RO         = (1 << 0),  /* A readonly connection */
    VIR_CONNECT_NO_ALIASES = (1 << 1),  /* Don't try to resolve URI aliases */
} virConnectFlags;


typedef enum {
    VIR_CRED_USERNAME = 1,     /* Identity to act as */
    VIR_CRED_AUTHNAME = 2,     /* Identify to authorize as */
    VIR_CRED_LANGUAGE = 3,     /* RFC 1766 languages, comma separated */
    VIR_CRED_CNONCE = 4,       /* client supplies a nonce */
    VIR_CRED_PASSPHRASE = 5,   /* Passphrase secret */
    VIR_CRED_ECHOPROMPT = 6,   /* Challenge response */
    VIR_CRED_NOECHOPROMPT = 7, /* Challenge response */
    VIR_CRED_REALM = 8,        /* Authentication realm */
    VIR_CRED_EXTERNAL = 9,     /* Externally managed credential */

    VIR_CRED_LAST              /* More may be added - expect the unexpected */

} virConnectCredentialType;

struct _virConnectCredential {
    int type; /* One of virConnectCredentialType constants */
    const char *prompt; /* Prompt to show to user */
    const char *challenge; /* Additional challenge to show */
    const char *defresult; /* Optional default result */
    char *result; /* Result to be filled with user response (or defresult) */
    unsigned int resultlen; /* Length of the result */
};

typedef struct _virConnectCredential virConnectCredential;
typedef virConnectCredential *virConnectCredentialPtr;



typedef int (*virConnectAuthCallbackPtr)(virConnectCredentialPtr cred,
                                         unsigned int ncred,
                                         void *cbdata);

struct _virConnectAuth {
    int *credtype; /* List of supported virConnectCredentialType values */
    unsigned int ncredtype;

    virConnectAuthCallbackPtr cb; /* Callback used to collect credentials */
    void *cbdata;
};


typedef struct _virConnectAuth virConnectAuth;
typedef virConnectAuth *virConnectAuthPtr;

 virConnectAuthPtr virConnectAuthPtrDefault;
]]


export.VIR_UUID_BUFLEN = (16);
export.VIR_UUID_STRING_BUFLEN = (36+1);

ffi.cdef[[
int                     virGetVersion           (unsigned long *libVer,
                                                 const char *type,
                                                 unsigned long *typeVer);

/*
 * Connection and disconnections to the Hypervisor
 */
int                     virInitialize           (void);

virConnectPtr           virConnectOpen          (const char *name);
virConnectPtr           virConnectOpenReadOnly  (const char *name);
virConnectPtr           virConnectOpenAuth      (const char *name,
                                                 virConnectAuthPtr auth,
                                                 unsigned int flags);
int                     virConnectRef           (virConnectPtr conn);
int                     virConnectClose         (virConnectPtr conn);
const char *            virConnectGetType       (virConnectPtr conn);
int                     virConnectGetVersion    (virConnectPtr conn,
                                                 unsigned long *hvVer);
int                     virConnectGetLibVersion (virConnectPtr conn,
                                                 unsigned long *libVer);
char *                  virConnectGetHostname   (virConnectPtr conn);
char *                  virConnectGetURI        (virConnectPtr conn);
char *                  virConnectGetSysinfo    (virConnectPtr conn,
                                                 unsigned int flags);

int virConnectSetKeepAlive(virConnectPtr conn,
                           int interval,
                           unsigned int count);

typedef enum {
    VIR_CONNECT_CLOSE_REASON_ERROR     = 0, /* Misc I/O error */
    VIR_CONNECT_CLOSE_REASON_EOF       = 1, /* End-of-file from server */
    VIR_CONNECT_CLOSE_REASON_KEEPALIVE = 2, /* Keepalive timer triggered */
    VIR_CONNECT_CLOSE_REASON_CLIENT    = 3, /* Client requested it */

    VIR_CONNECT_CLOSE_REASON_LAST
} virConnectCloseReason;


typedef void (*virConnectCloseFunc)(virConnectPtr conn,
                                    int reason,
                                    void *opaque);

int virConnectRegisterCloseCallback(virConnectPtr conn,
                                    virConnectCloseFunc cb,
                                    void *opaque,
                                    virFreeCallback freecb);
int virConnectUnregisterCloseCallback(virConnectPtr conn,
                                      virConnectCloseFunc cb);
]]

ffi.cdef[[
/*
 * Capabilities of the connection / driver.
 */

int                     virConnectGetMaxVcpus   (virConnectPtr conn,
                                                 const char *type);
int                     virNodeGetInfo          (virConnectPtr conn,
                                                 virNodeInfoPtr info);
char *                  virConnectGetCapabilities (virConnectPtr conn);

int                     virNodeGetCPUStats (virConnectPtr conn,
                                            int cpuNum,
                                            virNodeCPUStatsPtr params,
                                            int *nparams,
                                            unsigned int flags);

int                     virNodeGetMemoryStats (virConnectPtr conn,
                                               int cellNum,
                                               virNodeMemoryStatsPtr params,
                                               int *nparams,
                                               unsigned int flags);

unsigned long long      virNodeGetFreeMemory    (virConnectPtr conn);

int                     virNodeGetSecurityModel (virConnectPtr conn,
                                                 virSecurityModelPtr secmodel);

int                     virNodeSuspendForDuration (virConnectPtr conn,
                                                   unsigned int target,
                                                   unsigned long long duration,
                                                   unsigned int flags);
]]

ffi.cdef[[
/*
 * NUMA support
 */

int                      virNodeGetCellsFreeMemory(virConnectPtr conn,
                                                   unsigned long long *freeMems,
                                                   int startCell,
                                                   int maxCells);


int virConnectIsEncrypted(virConnectPtr conn);
int virConnectIsSecure(virConnectPtr conn);
int virConnectIsAlive(virConnectPtr conn);
]]


ffi.cdef[[
/*
 * CPU specification API
 */

typedef enum {
    VIR_CPU_COMPARE_ERROR           = -1,
    VIR_CPU_COMPARE_INCOMPATIBLE    = 0,
    VIR_CPU_COMPARE_IDENTICAL       = 1,
    VIR_CPU_COMPARE_SUPERSET        = 2,

    VIR_CPU_COMPARE_LAST

} virCPUCompareResult;

typedef enum {
    VIR_CONNECT_COMPARE_CPU_FAIL_INCOMPATIBLE = (1 << 0), /* treat incompatible
                                                             CPUs as failure */
} virConnectCompareCPUFlags;

int virConnectCompareCPU(virConnectPtr conn,
                         const char *xmlDesc,
                         unsigned int flags);

int virConnectGetCPUModelNames(virConnectPtr conn,
                               const char *arch,
                               void *,
//                               char ***models,
                               unsigned int flags);


typedef enum {
    VIR_CONNECT_BASELINE_CPU_EXPAND_FEATURES  = (1 << 0),  /* show all features */
    VIR_CONNECT_BASELINE_CPU_MIGRATABLE = (1 << 1),  /* filter out non-migratable features */
} virConnectBaselineCPUFlags;

char *virConnectBaselineCPU(virConnectPtr conn,
                            const char **xmlCPUs,
                            unsigned int ncpus,
                            unsigned int flags);


int virNodeGetFreePages(virConnectPtr conn,
                        unsigned int npages,
                        unsigned int *pages,
                        int startcell,
                        unsigned int cellcount,
                        unsigned long long *counts,
                        unsigned int flags);

typedef enum {
    VIR_NODE_ALLOC_PAGES_ADD = 0, /* Add @pageCounts to the pages pool. This
                                     can be used only to size up the pool. */
    VIR_NODE_ALLOC_PAGES_SET = (1 << 0), /* Don't add @pageCounts, instead set
                                            passed number of pages. This can be
                                            used to free allocated pages. */
} virNodeAllocPagesFlags;

int virNodeAllocPages(virConnectPtr conn,
                      unsigned int npages,
                      unsigned int *pageSizes,
                      unsigned long long *pageCounts,
                      int startCell,
                      unsigned int cellCount,
                      unsigned int flags);


]]



return export;
