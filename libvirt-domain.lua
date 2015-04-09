--[[
/*
 * libvirt-domain.h
 * Summary: APIs for management of domains
 * Description: Provides APIs for the management of domains
 * Author: Daniel Veillard <veillard@redhat.com>
 *
 * Copyright (C) 2006-2015 Red Hat, Inc.
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
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot


local export = {}


ffi.cdef[[

typedef struct _virDomain virDomain;

typedef virDomain *virDomainPtr;


typedef enum {
    VIR_DOMAIN_NOSTATE = 0,     /* no state */
    VIR_DOMAIN_RUNNING = 1,     /* the domain is running */
    VIR_DOMAIN_BLOCKED = 2,     /* the domain is blocked on resource */
    VIR_DOMAIN_PAUSED  = 3,     /* the domain is paused by user */
    VIR_DOMAIN_SHUTDOWN= 4,     /* the domain is being shut down */
    VIR_DOMAIN_SHUTOFF = 5,     /* the domain is shut off */
    VIR_DOMAIN_CRASHED = 6,     /* the domain is crashed */
    VIR_DOMAIN_PMSUSPENDED = 7, /* the domain is suspended by guest
                                   power management */


    VIR_DOMAIN_LAST

} virDomainState;

typedef enum {
    VIR_DOMAIN_NOSTATE_UNKNOWN = 0,

    VIR_DOMAIN_NOSTATE_LAST

} virDomainNostateReason;

typedef enum {
    VIR_DOMAIN_RUNNING_UNKNOWN = 0,
    VIR_DOMAIN_RUNNING_BOOTED = 1,          /* normal startup from boot */
    VIR_DOMAIN_RUNNING_MIGRATED = 2,        /* migrated from another host */
    VIR_DOMAIN_RUNNING_RESTORED = 3,        /* restored from a state file */
    VIR_DOMAIN_RUNNING_FROM_SNAPSHOT = 4,   /* restored from snapshot */
    VIR_DOMAIN_RUNNING_UNPAUSED = 5,        /* returned from paused state */
    VIR_DOMAIN_RUNNING_MIGRATION_CANCELED = 6,  /* returned from migration */
    VIR_DOMAIN_RUNNING_SAVE_CANCELED = 7,   /* returned from failed save process */
    VIR_DOMAIN_RUNNING_WAKEUP = 8,          /* returned from pmsuspended due to
                                               wakeup event */
    VIR_DOMAIN_RUNNING_CRASHED = 9,         /* resumed from crashed */

    VIR_DOMAIN_RUNNING_LAST
} virDomainRunningReason;

typedef enum {
    VIR_DOMAIN_BLOCKED_UNKNOWN = 0,     /* the reason is unknown */

    VIR_DOMAIN_BLOCKED_LAST
} virDomainBlockedReason;

typedef enum {
    VIR_DOMAIN_PAUSED_UNKNOWN = 0,      /* the reason is unknown */
    VIR_DOMAIN_PAUSED_USER = 1,         /* paused on user request */
    VIR_DOMAIN_PAUSED_MIGRATION = 2,    /* paused for offline migration */
    VIR_DOMAIN_PAUSED_SAVE = 3,         /* paused for save */
    VIR_DOMAIN_PAUSED_DUMP = 4,         /* paused for offline core dump */
    VIR_DOMAIN_PAUSED_IOERROR = 5,      /* paused due to a disk I/O error */
    VIR_DOMAIN_PAUSED_WATCHDOG = 6,     /* paused due to a watchdog event */
    VIR_DOMAIN_PAUSED_FROM_SNAPSHOT = 7, /* paused after restoring from snapshot */
    VIR_DOMAIN_PAUSED_SHUTTING_DOWN = 8, /* paused during shutdown process */
    VIR_DOMAIN_PAUSED_SNAPSHOT = 9,      /* paused while creating a snapshot */
    VIR_DOMAIN_PAUSED_CRASHED = 10,     /* paused due to a guest crash */
    VIR_DOMAIN_PAUSED_STARTING_UP = 11, /* the domain is being started */

    VIR_DOMAIN_PAUSED_LAST
} virDomainPausedReason;

typedef enum {
    VIR_DOMAIN_SHUTDOWN_UNKNOWN = 0,    /* the reason is unknown */
    VIR_DOMAIN_SHUTDOWN_USER = 1,       /* shutting down on user request */

    VIR_DOMAIN_SHUTDOWN_LAST
} virDomainShutdownReason;

typedef enum {
    VIR_DOMAIN_SHUTOFF_UNKNOWN = 0,     /* the reason is unknown */
    VIR_DOMAIN_SHUTOFF_SHUTDOWN = 1,    /* normal shutdown */
    VIR_DOMAIN_SHUTOFF_DESTROYED = 2,   /* forced poweroff */
    VIR_DOMAIN_SHUTOFF_CRASHED = 3,     /* domain crashed */
    VIR_DOMAIN_SHUTOFF_MIGRATED = 4,    /* migrated to another host */
    VIR_DOMAIN_SHUTOFF_SAVED = 5,       /* saved to a file */
    VIR_DOMAIN_SHUTOFF_FAILED = 6,      /* domain failed to start */
    VIR_DOMAIN_SHUTOFF_FROM_SNAPSHOT = 7, /* restored from a snapshot which was
                                           * taken while domain was shutoff */
    VIR_DOMAIN_SHUTOFF_LAST
} virDomainShutoffReason;

typedef enum {
    VIR_DOMAIN_CRASHED_UNKNOWN = 0,     /* crashed for unknown reason */
    VIR_DOMAIN_CRASHED_PANICKED = 1,    /* domain panicked */

    VIR_DOMAIN_CRASHED_LAST
} virDomainCrashedReason;

typedef enum {
    VIR_DOMAIN_PMSUSPENDED_UNKNOWN = 0,

    VIR_DOMAIN_PMSUSPENDED_LAST
} virDomainPMSuspendedReason;

typedef enum {
    VIR_DOMAIN_PMSUSPENDED_DISK_UNKNOWN = 0,

    VIR_DOMAIN_PMSUSPENDED_DISK_LAST
} virDomainPMSuspendedDiskReason;


typedef enum {
    VIR_DOMAIN_CONTROL_OK = 0,       /* operational, ready to accept commands */
    VIR_DOMAIN_CONTROL_JOB = 1,      /* background job is running (can be
                                        monitored by virDomainGetJobInfo); only
                                        limited set of commands may be allowed */
    VIR_DOMAIN_CONTROL_OCCUPIED = 2, /* occupied by a running command */
    VIR_DOMAIN_CONTROL_ERROR = 3,    /* unusable, domain cannot be fully
                                        operated, possible reason is provided
                                        in the details field */

    VIR_DOMAIN_CONTROL_LAST
} virDomainControlState;

typedef enum {
    VIR_DOMAIN_CONTROL_ERROR_REASON_NONE = 0,     /* server didn't provide a
                                                     reason */
    VIR_DOMAIN_CONTROL_ERROR_REASON_UNKNOWN = 1,  /* unknown reason for the
                                                     error */
    VIR_DOMAIN_CONTROL_ERROR_REASON_MONITOR = 2,  /* monitor connection is
                                                     broken */
    VIR_DOMAIN_CONTROL_ERROR_REASON_INTERNAL = 3, /* error caused due to
                                                     internal failure in libvirt
                                                  */
    VIR_DOMAIN_CONTROL_ERROR_REASON_LAST
} virDomainControlErrorReason;
]]

ffi.cdef[[
typedef struct _virDomainControlInfo virDomainControlInfo;
struct _virDomainControlInfo {
    unsigned int state;     /* control state, one of virDomainControlState */
    unsigned int details;   /* state details, currently 0 except for ERROR
                               state (one of virDomainControlErrorReason) */
    unsigned long long stateTime; /* for how long (in msec) control interface
                                     has been in current state (except for OK
                                     and ERROR states) */
};


typedef virDomainControlInfo *virDomainControlInfoPtr;


typedef enum {
    VIR_DOMAIN_AFFECT_CURRENT = 0,      /* Affect current domain state.  */
    VIR_DOMAIN_AFFECT_LIVE    = 1 << 0, /* Affect running domain state.  */
    VIR_DOMAIN_AFFECT_CONFIG  = 1 << 1, /* Affect persistent domain state.  */
    /* 1 << 2 is reserved for virTypedParameterFlags */
} virDomainModificationImpact;



typedef struct _virDomainInfo virDomainInfo;

struct _virDomainInfo {
    unsigned char state;        /* the running state, one of virDomainState */
    unsigned long maxMem;       /* the maximum memory in KBytes allowed */
    unsigned long memory;       /* the memory in KBytes used by the domain */
    unsigned short nrVirtCpu;   /* the number of virtual CPUs for the domain */
    unsigned long long cpuTime; /* the CPU time used in nanoseconds */
};



typedef virDomainInfo *virDomainInfoPtr;


typedef enum {
    VIR_DOMAIN_NONE               = 0,      /* Default behavior */
    VIR_DOMAIN_START_PAUSED       = 1 << 0, /* Launch guest in paused state */
    VIR_DOMAIN_START_AUTODESTROY  = 1 << 1, /* Automatically kill guest when virConnectPtr is closed */
    VIR_DOMAIN_START_BYPASS_CACHE = 1 << 2, /* Avoid file system cache pollution */
    VIR_DOMAIN_START_FORCE_BOOT   = 1 << 3, /* Boot, discarding any managed save */
    VIR_DOMAIN_START_VALIDATE     = 1 << 4, /* Validate the XML document against schema */
} virDomainCreateFlags;
]]



export.VIR_DOMAIN_SCHEDULER_CPU_SHARES ="cpu_shares"
export.VIR_DOMAIN_SCHEDULER_VCPU_PERIOD ="vcpu_period"
export.VIR_DOMAIN_SCHEDULER_VCPU_QUOTA ="vcpu_quota"
export.VIR_DOMAIN_SCHEDULER_EMULATOR_PERIOD ="emulator_period"
export.VIR_DOMAIN_SCHEDULER_EMULATOR_QUOTA ="emulator_quota"
export.VIR_DOMAIN_SCHEDULER_WEIGHT ="weight"
export.VIR_DOMAIN_SCHEDULER_CAP ="cap"
export.VIR_DOMAIN_SCHEDULER_RESERVATION ="reservation"
export.VIR_DOMAIN_SCHEDULER_LIMIT ="limit"
export.VIR_DOMAIN_SCHEDULER_SHARES ="shares"



ffi.cdef[[
int     virDomainGetSchedulerParameters (virDomainPtr domain,
                                         virTypedParameterPtr params,
                                         int *nparams);
int     virDomainGetSchedulerParametersFlags (virDomainPtr domain,
                                              virTypedParameterPtr params,
                                              int *nparams,
                                              unsigned int flags);

/*
 * Change scheduler parameters
 */
int     virDomainSetSchedulerParameters (virDomainPtr domain,
                                         virTypedParameterPtr params,
                                         int nparams);
int     virDomainSetSchedulerParametersFlags (virDomainPtr domain,
                                              virTypedParameterPtr params,
                                              int nparams,
                                              unsigned int flags);

/**
 * virDomainBlockStats:
 *
 * Block device stats for virDomainBlockStats.
 *
 * Hypervisors may return a field set to ((long long)-1) which indicates
 * that the hypervisor does not support that statistic.
 *
 * NB. Here 'long long' means 64 bit integer.
 */
typedef struct _virDomainBlockStats virDomainBlockStatsStruct;

struct _virDomainBlockStats {
    long long rd_req; /* number of read requests */
    long long rd_bytes; /* number of read bytes */
    long long wr_req; /* number of write requests */
    long long wr_bytes; /* number of written bytes */
    long long errs;   /* In Xen this returns the mysterious 'oo_req'. */
};


typedef virDomainBlockStatsStruct *virDomainBlockStatsPtr;


static const int VIR_DOMAIN_BLOCK_STATS_FIELD_LENGTH = VIR_TYPED_PARAM_FIELD_LENGTH;
]]

export.VIR_DOMAIN_BLOCK_STATS_READ_BYTES ="rd_bytes";
export.VIR_DOMAIN_BLOCK_STATS_READ_REQ ="rd_operations";
export.VIR_DOMAIN_BLOCK_STATS_READ_TOTAL_TIMES ="rd_total_times";
export.VIR_DOMAIN_BLOCK_STATS_WRITE_BYTES ="wr_bytes";
export.VIR_DOMAIN_BLOCK_STATS_WRITE_REQ ="wr_operations";
export.VIR_DOMAIN_BLOCK_STATS_WRITE_TOTAL_TIMES ="wr_total_times";
export.VIR_DOMAIN_BLOCK_STATS_FLUSH_REQ ="flush_operations";
export.VIR_DOMAIN_BLOCK_STATS_FLUSH_TOTAL_TIMES ="flush_total_times";
export.VIR_DOMAIN_BLOCK_STATS_ERRS ="errs";



ffi.cdef[[
typedef struct _virDomainInterfaceStats virDomainInterfaceStatsStruct;

struct _virDomainInterfaceStats {
    long long rx_bytes;
    long long rx_packets;
    long long rx_errs;
    long long rx_drop;
    long long tx_bytes;
    long long tx_packets;
    long long tx_errs;
    long long tx_drop;
};


typedef virDomainInterfaceStatsStruct *virDomainInterfaceStatsPtr;


typedef enum {
    /* The total amount of data read from swap space (in kB). */
    VIR_DOMAIN_MEMORY_STAT_SWAP_IN         = 0,
    /* The total amount of memory written out to swap space (in kB). */
    VIR_DOMAIN_MEMORY_STAT_SWAP_OUT        = 1,

    /*
     * Page faults occur when a process makes a valid access to virtual memory
     * that is not available.  When servicing the page fault, if disk IO is
     * required, it is considered a major fault.  If not, it is a minor fault.
     * These are expressed as the number of faults that have occurred.
     */
    VIR_DOMAIN_MEMORY_STAT_MAJOR_FAULT     = 2,
    VIR_DOMAIN_MEMORY_STAT_MINOR_FAULT     = 3,

    /*
     * The amount of memory left completely unused by the system.  Memory that
     * is available but used for reclaimable caches should NOT be reported as
     * free.  This value is expressed in kB.
     */
    VIR_DOMAIN_MEMORY_STAT_UNUSED          = 4,

    /*
     * The total amount of usable memory as seen by the domain.  This value
     * may be less than the amount of memory assigned to the domain if a
     * balloon driver is in use or if the guest OS does not initialize all
     * assigned pages.  This value is expressed in kB.
     */
    VIR_DOMAIN_MEMORY_STAT_AVAILABLE       = 5,

    /* Current balloon value (in KB). */
    VIR_DOMAIN_MEMORY_STAT_ACTUAL_BALLOON  = 6,

    /* Resident Set Size of the process running the domain. This value
     * is in kB */
    VIR_DOMAIN_MEMORY_STAT_RSS             = 7,

    /*
     * The number of statistics supported by this version of the interface.
     * To add new statistics, add them to the enum and increase this value.
     */
    VIR_DOMAIN_MEMORY_STAT_NR              = 8,

    VIR_DOMAIN_MEMORY_STAT_LAST = VIR_DOMAIN_MEMORY_STAT_NR
} virDomainMemoryStatTags;

typedef struct _virDomainMemoryStat virDomainMemoryStatStruct;

struct _virDomainMemoryStat {
    int tag;
    unsigned long long val;
};

typedef virDomainMemoryStatStruct *virDomainMemoryStatPtr;


/* Domain core dump flags. */
typedef enum {
    VIR_DUMP_CRASH        = (1 << 0), /* crash after dump */
    VIR_DUMP_LIVE         = (1 << 1), /* live dump */
    VIR_DUMP_BYPASS_CACHE = (1 << 2), /* avoid file system cache pollution */
    VIR_DUMP_RESET        = (1 << 3), /* reset domain after dump finishes */
    VIR_DUMP_MEMORY_ONLY  = (1 << 4), /* use dump-guest-memory */
} virDomainCoreDumpFlags;


typedef enum {
    VIR_DOMAIN_CORE_DUMP_FORMAT_RAW,          /* dump guest memory in raw format */
    VIR_DOMAIN_CORE_DUMP_FORMAT_KDUMP_ZLIB,   /* kdump-compressed format, with
                                               * zlib compression */
    VIR_DOMAIN_CORE_DUMP_FORMAT_KDUMP_LZO,    /* kdump-compressed format, with
                                               * lzo compression */
    VIR_DOMAIN_CORE_DUMP_FORMAT_KDUMP_SNAPPY, /* kdump-compressed format, with
                                               * snappy compression */
    VIR_DOMAIN_CORE_DUMP_FORMAT_LAST
} virDomainCoreDumpFormat;

/* Domain migration flags. */
typedef enum {
    VIR_MIGRATE_LIVE              = (1 << 0), /* live migration */
    VIR_MIGRATE_PEER2PEER         = (1 << 1), /* direct source -> dest host control channel */
    /* Note the less-common spelling that we're stuck with:
       VIR_MIGRATE_TUNNELLED should be VIR_MIGRATE_TUNNELED */
    VIR_MIGRATE_TUNNELLED         = (1 << 2), /* tunnel migration data over libvirtd connection */
    VIR_MIGRATE_PERSIST_DEST      = (1 << 3), /* persist the VM on the destination */
    VIR_MIGRATE_UNDEFINE_SOURCE   = (1 << 4), /* undefine the VM on the source */
    VIR_MIGRATE_PAUSED            = (1 << 5), /* pause on remote side */
    VIR_MIGRATE_NON_SHARED_DISK   = (1 << 6), /* migration with non-shared storage with full disk copy */
    VIR_MIGRATE_NON_SHARED_INC    = (1 << 7), /* migration with non-shared storage with incremental copy */
                                              /* (same base image shared between source and destination) */
    VIR_MIGRATE_CHANGE_PROTECTION = (1 << 8), /* protect for changing domain configuration through the
                                               * whole migration process; this will be used automatically
                                               * when supported */
    VIR_MIGRATE_UNSAFE            = (1 << 9), /* force migration even if it is considered unsafe */
    VIR_MIGRATE_OFFLINE           = (1 << 10), /* offline migrate */
    VIR_MIGRATE_COMPRESSED        = (1 << 11), /* compress data during migration */
    VIR_MIGRATE_ABORT_ON_ERROR    = (1 << 12), /* abort migration on I/O errors happened during migration */
    VIR_MIGRATE_AUTO_CONVERGE     = (1 << 13), /* force convergence */
    VIR_MIGRATE_RDMA_PIN_ALL      = (1 << 14), /* RDMA memory pinning */
} virDomainMigrateFlags;
]]


export.VIR_MIGRATE_PARAM_URI              = "migrate_uri";
export.VIR_MIGRATE_PARAM_DEST_NAME        = "destination_name";
export.VIR_MIGRATE_PARAM_DEST_XML         = "destination_xml";
export.VIR_MIGRATE_PARAM_BANDWIDTH        = "bandwidth";
export.VIR_MIGRATE_PARAM_GRAPHICS_URI     = "graphics_uri";
export.VIR_MIGRATE_PARAM_LISTEN_ADDRESS   = "listen_address";

ffi.cdef[[
/* Domain migration. */
virDomainPtr virDomainMigrate (virDomainPtr domain, virConnectPtr dconn,
                               unsigned long flags, const char *dname,
                               const char *uri, unsigned long bandwidth);
virDomainPtr virDomainMigrate2(virDomainPtr domain, virConnectPtr dconn,
                               const char *dxml,
                               unsigned long flags, const char *dname,
                               const char *uri, unsigned long bandwidth);
virDomainPtr virDomainMigrate3(virDomainPtr domain,
                               virConnectPtr dconn,
                               virTypedParameterPtr params,
                               unsigned int nparams,
                               unsigned int flags);

int virDomainMigrateToURI (virDomainPtr domain, const char *duri,
                           unsigned long flags, const char *dname,
                           unsigned long bandwidth);

int virDomainMigrateToURI2(virDomainPtr domain,
                           const char *dconnuri,
                           const char *miguri,
                           const char *dxml,
                           unsigned long flags,
                           const char *dname,
                           unsigned long bandwidth);
int virDomainMigrateToURI3(virDomainPtr domain,
                           const char *dconnuri,
                           virTypedParameterPtr params,
                           unsigned int nparams,
                           unsigned int flags);

int virDomainMigrateSetMaxDowntime (virDomainPtr domain,
                                    unsigned long long downtime,
                                    unsigned int flags);

int virDomainMigrateGetCompressionCache(virDomainPtr domain,
                                        unsigned long long *cacheSize,
                                        unsigned int flags);
int virDomainMigrateSetCompressionCache(virDomainPtr domain,
                                        unsigned long long cacheSize,
                                        unsigned int flags);

int virDomainMigrateSetMaxSpeed(virDomainPtr domain,
                                unsigned long bandwidth,
                                unsigned int flags);

int virDomainMigrateGetMaxSpeed(virDomainPtr domain,
                                unsigned long *bandwidth,
                                unsigned int flags);

char * virConnectGetDomainCapabilities(virConnectPtr conn,
                                       const char *emulatorbin,
                                       const char *arch,
                                       const char *machine,
                                       const char *virttype,
                                       unsigned int flags);
]]

ffi.cdef[[

int                     virConnectListDomains   (virConnectPtr conn,
                                                 int *ids,
                                                 int maxids);


int                     virConnectNumOfDomains  (virConnectPtr conn);



virConnectPtr           virDomainGetConnect     (virDomainPtr domain);



virDomainPtr            virDomainCreateXML      (virConnectPtr conn,
                                                 const char *xmlDesc,
                                                 unsigned int flags);
virDomainPtr            virDomainCreateXMLWithFiles(virConnectPtr conn,
                                                    const char *xmlDesc,
                                                    unsigned int nfiles,
                                                    int *files,
                                                    unsigned int flags);
virDomainPtr            virDomainLookupByName   (virConnectPtr conn,
                                                 const char *name);
virDomainPtr            virDomainLookupByID     (virConnectPtr conn,
                                                 int id);
virDomainPtr            virDomainLookupByUUID   (virConnectPtr conn,
                                                 const unsigned char *uuid);
virDomainPtr            virDomainLookupByUUIDString     (virConnectPtr conn,
                                                         const char *uuid);

typedef enum {
    VIR_DOMAIN_SHUTDOWN_DEFAULT        = 0,        /* hypervisor choice */
    VIR_DOMAIN_SHUTDOWN_ACPI_POWER_BTN = (1 << 0), /* Send ACPI event */
    VIR_DOMAIN_SHUTDOWN_GUEST_AGENT    = (1 << 1), /* Use guest agent */
    VIR_DOMAIN_SHUTDOWN_INITCTL        = (1 << 2), /* Use initctl */
    VIR_DOMAIN_SHUTDOWN_SIGNAL         = (1 << 3), /* Send a signal */
    VIR_DOMAIN_SHUTDOWN_PARAVIRT       = (1 << 4), /* Use paravirt guest control */
} virDomainShutdownFlagValues;

int                     virDomainShutdown       (virDomainPtr domain);
int                     virDomainShutdownFlags  (virDomainPtr domain,
                                                 unsigned int flags);

typedef enum {
    VIR_DOMAIN_REBOOT_DEFAULT        = 0,        /* hypervisor choice */
    VIR_DOMAIN_REBOOT_ACPI_POWER_BTN = (1 << 0), /* Send ACPI event */
    VIR_DOMAIN_REBOOT_GUEST_AGENT    = (1 << 1), /* Use guest agent */
    VIR_DOMAIN_REBOOT_INITCTL        = (1 << 2), /* Use initctl */
    VIR_DOMAIN_REBOOT_SIGNAL         = (1 << 3), /* Send a signal */
    VIR_DOMAIN_REBOOT_PARAVIRT       = (1 << 4), /* Use paravirt guest control */
} virDomainRebootFlagValues;

int                     virDomainReboot         (virDomainPtr domain,
                                                 unsigned int flags);
int                     virDomainReset          (virDomainPtr domain,
                                                 unsigned int flags);

int                     virDomainDestroy        (virDomainPtr domain);


typedef enum {
    VIR_DOMAIN_DESTROY_DEFAULT   = 0,      /* Default behavior - could lead to data loss!! */
    VIR_DOMAIN_DESTROY_GRACEFUL  = 1 << 0, /* only SIGTERM, no SIGKILL */
} virDomainDestroyFlagsValues;

int                     virDomainDestroyFlags   (virDomainPtr domain,
                                                 unsigned int flags);
int                     virDomainRef            (virDomainPtr domain);
int                     virDomainFree           (virDomainPtr domain);
]]

ffi.cdef[[

int                     virDomainSuspend        (virDomainPtr domain);
int                     virDomainResume         (virDomainPtr domain);
int                     virDomainPMSuspendForDuration (virDomainPtr domain,
                                                       unsigned int target,
                                                       unsigned long long duration,
                                                       unsigned int flags);
int                     virDomainPMWakeup       (virDomainPtr domain,
                                                 unsigned int flags);



typedef enum {
    VIR_DOMAIN_SAVE_BYPASS_CACHE = 1 << 0, /* Avoid file system cache pollution */
    VIR_DOMAIN_SAVE_RUNNING      = 1 << 1, /* Favor running over paused */
    VIR_DOMAIN_SAVE_PAUSED       = 1 << 2, /* Favor paused over running */
} virDomainSaveRestoreFlags;

int                     virDomainSave           (virDomainPtr domain,
                                                 const char *to);
int                     virDomainSaveFlags      (virDomainPtr domain,
                                                 const char *to,
                                                 const char *dxml,
                                                 unsigned int flags);
int                     virDomainRestore        (virConnectPtr conn,
                                                 const char *from);
int                     virDomainRestoreFlags   (virConnectPtr conn,
                                                 const char *from,
                                                 const char *dxml,
                                                 unsigned int flags);

char *          virDomainSaveImageGetXMLDesc    (virConnectPtr conn,
                                                 const char *file,
                                                 unsigned int flags);
int             virDomainSaveImageDefineXML     (virConnectPtr conn,
                                                 const char *file,
                                                 const char *dxml,
                                                 unsigned int flags);
]]

ffi.cdef[[

int                    virDomainManagedSave     (virDomainPtr dom,
                                                 unsigned int flags);
int                    virDomainHasManagedSaveImage(virDomainPtr dom,
                                                    unsigned int flags);
int                    virDomainManagedSaveRemove(virDomainPtr dom,
                                                  unsigned int flags);
]]

ffi.cdef[[

int                     virDomainCoreDump       (virDomainPtr domain,
                                                 const char *to,
                                                 unsigned int flags);


int                 virDomainCoreDumpWithFormat (virDomainPtr domain,
                                                 const char *to,
                                                 unsigned int dumpformat,
                                                 unsigned int flags);
]]

ffi.cdef[[

char *                  virDomainScreenshot     (virDomainPtr domain,
                                                 virStreamPtr stream,
                                                 unsigned int screen,
                                                 unsigned int flags);
]]

ffi.cdef[[


int                     virDomainGetInfo        (virDomainPtr domain,
                                                 virDomainInfoPtr info);
int                     virDomainGetState       (virDomainPtr domain,
                                                 int *state,
                                                 int *reason,
                                                 unsigned int flags);
]]

export.VIR_DOMAIN_CPU_STATS_CPUTIME ="cpu_time";
export.VIR_DOMAIN_CPU_STATS_USERTIME ="user_time";
export.VIR_DOMAIN_CPU_STATS_SYSTEMTIME ="system_time";
export.VIR_DOMAIN_CPU_STATS_VCPUTIME ="vcpu_time";

ffi.cdef[[
int virDomainGetCPUStats(virDomainPtr domain,
                         virTypedParameterPtr params,
                         unsigned int nparams,
                         int start_cpu,
                         unsigned int ncpus,
                         unsigned int flags);

int                     virDomainGetControlInfo (virDomainPtr domain,
                                                 virDomainControlInfoPtr info,
                                                 unsigned int flags);


char *                  virDomainGetSchedulerType(virDomainPtr domain,
                                                  int *nparams);
]]



-- Manage blkio parameters.

export.VIR_DOMAIN_BLKIO_WEIGHT ="weight";
export.VIR_DOMAIN_BLKIO_DEVICE_WEIGHT ="device_weight";
export.VIR_DOMAIN_BLKIO_DEVICE_READ_IOPS ="device_read_iops_sec";
export.VIR_DOMAIN_BLKIO_DEVICE_WRITE_IOPS ="device_write_iops_sec";
export.VIR_DOMAIN_BLKIO_DEVICE_READ_BPS ="device_read_bytes_sec";
export.VIR_DOMAIN_BLKIO_DEVICE_WRITE_BPS ="device_write_bytes_sec";

ffi.cdef[[
/* Set Blkio tunables for the domain*/
int     virDomainSetBlkioParameters(virDomainPtr domain,
                                    virTypedParameterPtr params,
                                    int nparams, unsigned int flags);
int     virDomainGetBlkioParameters(virDomainPtr domain,
                                    virTypedParameterPtr params,
                                    int *nparams, unsigned int flags);
]]

-- Manage memory parameters.


export.VIR_DOMAIN_MEMORY_PARAM_UNLIMITED = 9007199254740991LL; -- = INT64_MAX >> 10 


export.VIR_DOMAIN_MEMORY_HARD_LIMIT ="hard_limit";
export.VIR_DOMAIN_MEMORY_SOFT_LIMIT ="soft_limit";
export.VIR_DOMAIN_MEMORY_MIN_GUARANTEE ="min_guarantee";
export.VIR_DOMAIN_MEMORY_SWAP_HARD_LIMIT ="swap_hard_limit";

ffi.cdef[[
/* Set memory tunables for the domain*/
int     virDomainSetMemoryParameters(virDomainPtr domain,
                                     virTypedParameterPtr params,
                                     int nparams, unsigned int flags);
int     virDomainGetMemoryParameters(virDomainPtr domain,
                                     virTypedParameterPtr params,
                                     int *nparams, unsigned int flags);

/* Memory size modification flags. */
typedef enum {
    /* See virDomainModificationImpact for these flags.  */
    VIR_DOMAIN_MEM_CURRENT = VIR_DOMAIN_AFFECT_CURRENT,
    VIR_DOMAIN_MEM_LIVE    = VIR_DOMAIN_AFFECT_LIVE,
    VIR_DOMAIN_MEM_CONFIG  = VIR_DOMAIN_AFFECT_CONFIG,

    /* Additionally, these flags may be bitwise-OR'd in.  */
    VIR_DOMAIN_MEM_MAXIMUM = (1 << 2), /* affect Max rather than current */
} virDomainMemoryModFlags;
]]

ffi.cdef[[
/* Manage numa parameters */

typedef enum {
    VIR_DOMAIN_NUMATUNE_MEM_STRICT      = 0,
    VIR_DOMAIN_NUMATUNE_MEM_PREFERRED   = 1,
    VIR_DOMAIN_NUMATUNE_MEM_INTERLEAVE  = 2,

    VIR_DOMAIN_NUMATUNE_MEM_LAST /* This constant is subject to change */
} virDomainNumatuneMemMode;
]]

export.VIR_DOMAIN_NUMA_NODESET = "numa_nodeset"
export.VIR_DOMAIN_NUMA_MODE = "numa_mode"

ffi.cdef[[
int     virDomainSetNumaParameters(virDomainPtr domain,
                                   virTypedParameterPtr params,
                                   int nparams, unsigned int flags);
int     virDomainGetNumaParameters(virDomainPtr domain,
                                   virTypedParameterPtr params,
                                   int *nparams, unsigned int flags);


const char *            virDomainGetName        (virDomainPtr domain);
unsigned int            virDomainGetID          (virDomainPtr domain);
int                     virDomainGetUUID        (virDomainPtr domain,
                                                 unsigned char *uuid);
int                     virDomainGetUUIDString  (virDomainPtr domain,
                                                 char *buf);
char *                  virDomainGetOSType      (virDomainPtr domain);
unsigned long           virDomainGetMaxMemory   (virDomainPtr domain);
int                     virDomainSetMaxMemory   (virDomainPtr domain,
                                                 unsigned long memory);
int                     virDomainSetMemory      (virDomainPtr domain,
                                                 unsigned long memory);
int                     virDomainSetMemoryFlags (virDomainPtr domain,
                                                 unsigned long memory,
                                                 unsigned int flags);
int                     virDomainSetMemoryStatsPeriod (virDomainPtr domain,
                                                       int period,
                                                       unsigned int flags);
int                     virDomainGetMaxVcpus    (virDomainPtr domain);
int                     virDomainGetSecurityLabel (virDomainPtr domain,
                                                   virSecurityLabelPtr seclabel);
char *                  virDomainGetHostname    (virDomainPtr domain,
                                                 unsigned int flags);
int                     virDomainGetSecurityLabelList (virDomainPtr domain,
                                                       virSecurityLabelPtr* seclabels);

typedef enum {
    VIR_DOMAIN_METADATA_DESCRIPTION = 0, /* Operate on <description> */
    VIR_DOMAIN_METADATA_TITLE       = 1, /* Operate on <title> */
    VIR_DOMAIN_METADATA_ELEMENT     = 2, /* Operate on <metadata> */

    VIR_DOMAIN_METADATA_LAST
} virDomainMetadataType;

int
virDomainSetMetadata(virDomainPtr domain,
                     int type,
                     const char *metadata,
                     const char *key,
                     const char *uri,
                     unsigned int flags);

char *
virDomainGetMetadata(virDomainPtr domain,
                     int type,
                     const char *uri,
                     unsigned int flags);
]]

ffi.cdef[[
/*
 * XML domain description
 */

typedef enum {
    VIR_DOMAIN_XML_SECURE       = (1 << 0), /* dump security sensitive information too */
    VIR_DOMAIN_XML_INACTIVE     = (1 << 1), /* dump inactive domain information */
    VIR_DOMAIN_XML_UPDATE_CPU   = (1 << 2), /* update guest CPU requirements according to host CPU */
    VIR_DOMAIN_XML_MIGRATABLE   = (1 << 3), /* dump XML suitable for migration */
} virDomainXMLFlags;

char *                  virDomainGetXMLDesc     (virDomainPtr domain,
                                                 unsigned int flags);


char *                  virConnectDomainXMLFromNative(virConnectPtr conn,
                                                      const char *nativeFormat,
                                                      const char *nativeConfig,
                                                      unsigned int flags);
char *                  virConnectDomainXMLToNative(virConnectPtr conn,
                                                    const char *nativeFormat,
                                                    const char *domainXml,
                                                    unsigned int flags);

int                     virDomainBlockStats     (virDomainPtr dom,
                                                 const char *disk,
                                                 virDomainBlockStatsPtr stats,
                                                 size_t size);
int                     virDomainBlockStatsFlags (virDomainPtr dom,
                                                  const char *disk,
                                                  virTypedParameterPtr params,
                                                  int *nparams,
                                                  unsigned int flags);
int                     virDomainInterfaceStats (virDomainPtr dom,
                                                 const char *path,
                                                 virDomainInterfaceStatsPtr stats,
                                                 size_t size);
]]

-- Management of interface parameters 


export.VIR_DOMAIN_BANDWIDTH_IN_AVERAGE ="inbound.average";
export.VIR_DOMAIN_BANDWIDTH_IN_PEAK ="inbound.peak";
export.VIR_DOMAIN_BANDWIDTH_IN_BURST ="inbound.burst";
export.VIR_DOMAIN_BANDWIDTH_OUT_AVERAGE ="outbound.average";
export.VIR_DOMAIN_BANDWIDTH_OUT_PEAK ="outbound.peak";
export.VIR_DOMAIN_BANDWIDTH_OUT_BURST ="outbound.burst";

ffi.cdef[[
int                     virDomainSetInterfaceParameters (virDomainPtr dom,
                                                         const char *device,
                                                         virTypedParameterPtr params,
                                                         int nparams, unsigned int flags);
int                     virDomainGetInterfaceParameters (virDomainPtr dom,
                                                         const char *device,
                                                         virTypedParameterPtr params,
                                                         int *nparams, unsigned int flags);
]]

ffi.cdef[[
/* Management of domain block devices */

int                     virDomainBlockPeek (virDomainPtr dom,
                                            const char *disk,
                                            unsigned long long offset,
                                            size_t size,
                                            void *buffer,
                                            unsigned int flags);


typedef enum {
    VIR_DOMAIN_BLOCK_RESIZE_BYTES = 1 << 0, /* size in bytes instead of KiB */
} virDomainBlockResizeFlags;

int                     virDomainBlockResize (virDomainPtr dom,
                                              const char *disk,
                                              unsigned long long size,
                                              unsigned int flags);


typedef struct _virDomainBlockInfo virDomainBlockInfo;
typedef virDomainBlockInfo *virDomainBlockInfoPtr;
struct _virDomainBlockInfo {
    unsigned long long capacity;   /* logical size in bytes of the
                                    * image (how much storage the
                                    * guest will see) */
    unsigned long long allocation; /* host storage in bytes occupied
                                    * by the image (such as highest
                                    * allocated extent if there are no
                                    * holes, similar to 'du') */
    unsigned long long physical;   /* host physical size in bytes of
                                    * the image container (last
                                    * offset, similar to 'ls')*/
};

int                     virDomainGetBlockInfo(virDomainPtr dom,
                                              const char *disk,
                                              virDomainBlockInfoPtr info,
                                              unsigned int flags);
]]

ffi.cdef[[
/* Management of domain memory */

int                     virDomainMemoryStats (virDomainPtr dom,
                                              virDomainMemoryStatPtr stats,
                                              unsigned int nr_stats,
                                              unsigned int flags);

/* Memory peeking flags. */

typedef enum {
    VIR_MEMORY_VIRTUAL            = 1 << 0, /* addresses are virtual addresses */
    VIR_MEMORY_PHYSICAL           = 1 << 1, /* addresses are physical addresses */
} virDomainMemoryFlags;

int                     virDomainMemoryPeek (virDomainPtr dom,
                                             unsigned long long start,
                                             size_t size,
                                             void *buffer,
                                             unsigned int flags);

typedef enum {
    VIR_DOMAIN_DEFINE_VALIDATE = (1 << 0), /* Validate the XML document against schema */
} virDomainDefineFlags;


virDomainPtr            virDomainDefineXML      (virConnectPtr conn,
                                                 const char *xml);

virDomainPtr            virDomainDefineXMLFlags (virConnectPtr conn,
                                                 const char *xml,
                                                 unsigned int flags);
int                     virDomainUndefine       (virDomainPtr domain);

typedef enum {
    VIR_DOMAIN_UNDEFINE_MANAGED_SAVE       = (1 << 0), /* Also remove any
                                                          managed save */
    VIR_DOMAIN_UNDEFINE_SNAPSHOTS_METADATA = (1 << 1), /* If last use of domain,
                                                          then also remove any
                                                          snapshot metadata */
    VIR_DOMAIN_UNDEFINE_NVRAM              = (1 << 2), /* Also remove any
                                                          nvram file */

    /* Future undefine control flags should come here. */
} virDomainUndefineFlagsValues;


int                     virDomainUndefineFlags   (virDomainPtr domain,
                                                  unsigned int flags);
int                     virConnectNumOfDefinedDomains  (virConnectPtr conn);
int                     virConnectListDefinedDomains (virConnectPtr conn,
                                                      char **const names,
                                                      int maxnames);
]]

ffi.cdef[[

typedef enum {
    VIR_CONNECT_LIST_DOMAINS_ACTIVE         = 1 << 0,
    VIR_CONNECT_LIST_DOMAINS_INACTIVE       = 1 << 1,

    VIR_CONNECT_LIST_DOMAINS_PERSISTENT     = 1 << 2,
    VIR_CONNECT_LIST_DOMAINS_TRANSIENT      = 1 << 3,

    VIR_CONNECT_LIST_DOMAINS_RUNNING        = 1 << 4,
    VIR_CONNECT_LIST_DOMAINS_PAUSED         = 1 << 5,
    VIR_CONNECT_LIST_DOMAINS_SHUTOFF        = 1 << 6,
    VIR_CONNECT_LIST_DOMAINS_OTHER          = 1 << 7,

    VIR_CONNECT_LIST_DOMAINS_MANAGEDSAVE    = 1 << 8,
    VIR_CONNECT_LIST_DOMAINS_NO_MANAGEDSAVE = 1 << 9,

    VIR_CONNECT_LIST_DOMAINS_AUTOSTART      = 1 << 10,
    VIR_CONNECT_LIST_DOMAINS_NO_AUTOSTART   = 1 << 11,

    VIR_CONNECT_LIST_DOMAINS_HAS_SNAPSHOT   = 1 << 12,
    VIR_CONNECT_LIST_DOMAINS_NO_SNAPSHOT    = 1 << 13,
} virConnectListAllDomainsFlags;

int                     virConnectListAllDomains (virConnectPtr conn,
                                                  virDomainPtr **domains,
                                                  unsigned int flags);
int                     virDomainCreate         (virDomainPtr domain);
int                     virDomainCreateWithFlags (virDomainPtr domain,
                                                  unsigned int flags);

int                     virDomainCreateWithFiles (virDomainPtr domain,
                                                  unsigned int nfiles,
                                                  int *files,
                                                  unsigned int flags);

int                     virDomainGetAutostart   (virDomainPtr domain,
                                                 int *autostart);
int                     virDomainSetAutostart   (virDomainPtr domain,
                                                 int autostart);



typedef enum {
    VIR_VCPU_OFFLINE    = 0,    /* the virtual CPU is offline */
    VIR_VCPU_RUNNING    = 1,    /* the virtual CPU is running */
    VIR_VCPU_BLOCKED    = 2,    /* the virtual CPU is blocked on resource */

    VIR_VCPU_LAST
} virVcpuState;

typedef struct _virVcpuInfo virVcpuInfo;
struct _virVcpuInfo {
    unsigned int number;        /* virtual CPU number */
    int state;                  /* value from virVcpuState */
    unsigned long long cpuTime; /* CPU time used, in nanoseconds */
    int cpu;                    /* real CPU number, or -1 if offline */
};
typedef virVcpuInfo *virVcpuInfoPtr;

/* Flags for controlling virtual CPU hot-plugging.  */
typedef enum {
    /* See virDomainModificationImpact for these flags.  */
    VIR_DOMAIN_VCPU_CURRENT = VIR_DOMAIN_AFFECT_CURRENT,
    VIR_DOMAIN_VCPU_LIVE    = VIR_DOMAIN_AFFECT_LIVE,
    VIR_DOMAIN_VCPU_CONFIG  = VIR_DOMAIN_AFFECT_CONFIG,

    /* Additionally, these flags may be bitwise-OR'd in.  */
    VIR_DOMAIN_VCPU_MAXIMUM = (1 << 2), /* Max rather than current count */
    VIR_DOMAIN_VCPU_GUEST   = (1 << 3), /* Modify state of the cpu in the guest */
} virDomainVcpuFlags;
]]

ffi.cdef[[
int                     virDomainSetVcpus       (virDomainPtr domain,
                                                 unsigned int nvcpus);
int                     virDomainSetVcpusFlags  (virDomainPtr domain,
                                                 unsigned int nvcpus,
                                                 unsigned int flags);
int                     virDomainGetVcpusFlags  (virDomainPtr domain,
                                                 unsigned int flags);

int                     virDomainPinVcpu        (virDomainPtr domain,
                                                 unsigned int vcpu,
                                                 unsigned char *cpumap,
                                                 int maplen);
int                     virDomainPinVcpuFlags   (virDomainPtr domain,
                                                 unsigned int vcpu,
                                                 unsigned char *cpumap,
                                                 int maplen,
                                                 unsigned int flags);

int                     virDomainGetVcpuPinInfo (virDomainPtr domain,
                                                 int ncpumaps,
                                                 unsigned char *cpumaps,
                                                 int maplen,
                                                 unsigned int flags);

int                     virDomainPinEmulator   (virDomainPtr domain,
                                                unsigned char *cpumap,
                                                int maplen,
                                                unsigned int flags);

int                     virDomainGetEmulatorPinInfo (virDomainPtr domain,
                                                     unsigned char *cpumaps,
                                                     int maplen,
                                                     unsigned int flags);
]]

ffi.cdef[[

typedef struct _virDomainIOThreadInfo virDomainIOThreadInfo;
typedef virDomainIOThreadInfo *virDomainIOThreadInfoPtr;
struct _virDomainIOThreadInfo {
    unsigned int iothread_id;          /* IOThread ID */
    unsigned char *cpumap;             /* CPU map for thread. A pointer to an */
                                       /* array of real CPUs (in 8-bit bytes) */
    int cpumaplen;                     /* cpumap size */
};

void                 virDomainIOThreadInfoFree(virDomainIOThreadInfoPtr info);

int                  virDomainGetIOThreadInfo(virDomainPtr domain,
                                               virDomainIOThreadInfoPtr **info,
                                               unsigned int flags);
int                  virDomainPinIOThread(virDomainPtr domain,
                                          unsigned int iothread_id,
                                          unsigned char *cpumap,
                                          int maplen,
                                          unsigned int flags);
]]


export.VIR_USE_CPU = function(cpumap, cpu) 
  cpumap[cpu / 8] = bor(cpumap[cpu / 8], lshift((cpu % 8),1))
end

export.VIR_UNUSE_CPU = function(cpumap, cpu) 
  cpumap[cpu / 8] = band(cpumap[cpu / 8], bnot(lshift((cpu % 8), 1)));
end

export.VIR_CPU_USED = function(cpumap, cpu) 
  return band(cpumap[cpu / 8], lshift((cpu % 8),1))
end

export.VIR_CPU_MAPLEN = function(cpu) 
  return ((cpu + 7) / 8)
end


ffi.cdef[[
int                     virDomainGetVcpus       (virDomainPtr domain,
                                                 virVcpuInfoPtr info,
                                                 int maxinfo,
                                                 unsigned char *cpumaps,
                                                 int maplen);
]]


export.VIR_CPU_USABLE = function(cpumaps, maplen, vcpu, cpu)
    return VIR_CPU_USED(export.VIR_GET_CPUMAP(cpumaps, maplen, vcpu), cpu)
end

export.VIR_COPY_CPUMAP = function(cpumaps, maplen, vcpu, cpumap)
    memcpy(cpumap, VIR_GET_CPUMAP(cpumaps, maplen, vcpu), maplen)
end

--[[
-- TODO, get the address of a field
export.VIR_GET_CPUMAP(cpumaps, maplen, vcpu) 
  return (&((cpumaps)[(vcpu) * (maplen)]))
end
--]]

ffi.cdef[[
typedef enum {
    /* See virDomainModificationImpact for these flags.  */
    VIR_DOMAIN_DEVICE_MODIFY_CURRENT = VIR_DOMAIN_AFFECT_CURRENT,
    VIR_DOMAIN_DEVICE_MODIFY_LIVE    = VIR_DOMAIN_AFFECT_LIVE,
    VIR_DOMAIN_DEVICE_MODIFY_CONFIG  = VIR_DOMAIN_AFFECT_CONFIG,

    /* Additionally, these flags may be bitwise-OR'd in.  */
    VIR_DOMAIN_DEVICE_MODIFY_FORCE = (1 << 2), /* Forcibly modify device
                                                  (ex. force eject a cdrom) */
} virDomainDeviceModifyFlags;

int virDomainAttachDevice(virDomainPtr domain, const char *xml);
int virDomainDetachDevice(virDomainPtr domain, const char *xml);

int virDomainAttachDeviceFlags(virDomainPtr domain,
                               const char *xml, unsigned int flags);
int virDomainDetachDeviceFlags(virDomainPtr domain,
                               const char *xml, unsigned int flags);
int virDomainUpdateDeviceFlags(virDomainPtr domain,
                               const char *xml, unsigned int flags);

typedef struct _virDomainStatsRecord virDomainStatsRecord;
typedef virDomainStatsRecord *virDomainStatsRecordPtr;
struct _virDomainStatsRecord {
    virDomainPtr dom;
    virTypedParameterPtr params;
    int nparams;
};

typedef enum {
    VIR_DOMAIN_STATS_STATE = (1 << 0), /* return domain state */
    VIR_DOMAIN_STATS_CPU_TOTAL = (1 << 1), /* return domain CPU info */
    VIR_DOMAIN_STATS_BALLOON = (1 << 2), /* return domain balloon info */
    VIR_DOMAIN_STATS_VCPU = (1 << 3), /* return domain virtual CPU info */
    VIR_DOMAIN_STATS_INTERFACE = (1 << 4), /* return domain interfaces info */
    VIR_DOMAIN_STATS_BLOCK = (1 << 5), /* return domain block info */
} virDomainStatsTypes;

typedef enum {
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_ACTIVE = VIR_CONNECT_LIST_DOMAINS_ACTIVE,
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_INACTIVE = VIR_CONNECT_LIST_DOMAINS_INACTIVE,

    VIR_CONNECT_GET_ALL_DOMAINS_STATS_PERSISTENT = VIR_CONNECT_LIST_DOMAINS_PERSISTENT,
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_TRANSIENT = VIR_CONNECT_LIST_DOMAINS_TRANSIENT,

    VIR_CONNECT_GET_ALL_DOMAINS_STATS_RUNNING = VIR_CONNECT_LIST_DOMAINS_RUNNING,
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_PAUSED = VIR_CONNECT_LIST_DOMAINS_PAUSED,
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_SHUTOFF = VIR_CONNECT_LIST_DOMAINS_SHUTOFF,
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_OTHER = VIR_CONNECT_LIST_DOMAINS_OTHER,

    VIR_CONNECT_GET_ALL_DOMAINS_STATS_BACKING = 1 << 30, /* include backing chain for block stats */
    VIR_CONNECT_GET_ALL_DOMAINS_STATS_ENFORCE_STATS = 1 << 31, /* enforce requested stats */
} virConnectGetAllDomainStatsFlags;

int virConnectGetAllDomainStats(virConnectPtr conn,
                                unsigned int stats,
                                virDomainStatsRecordPtr **retStats,
                                unsigned int flags);

int virDomainListGetStats(virDomainPtr *doms,
                          unsigned int stats,
                          virDomainStatsRecordPtr **retStats,
                          unsigned int flags);

void virDomainStatsRecordListFree(virDomainStatsRecordPtr *stats);
]]

ffi.cdef[[
/*
 * BlockJob API
 */


typedef enum {
    VIR_DOMAIN_BLOCK_JOB_TYPE_UNKNOWN = 0, /* Placeholder */

    VIR_DOMAIN_BLOCK_JOB_TYPE_PULL = 1,
    /* Block Pull (virDomainBlockPull, or virDomainBlockRebase without
     * flags), job ends on completion */

    VIR_DOMAIN_BLOCK_JOB_TYPE_COPY = 2,
    /* Block Copy (virDomainBlockCopy, or virDomainBlockRebase with
     * flags), job exists as long as mirroring is active */

    VIR_DOMAIN_BLOCK_JOB_TYPE_COMMIT = 3,
    /* Block Commit (virDomainBlockCommit without flags), job ends on
     * completion */

    VIR_DOMAIN_BLOCK_JOB_TYPE_ACTIVE_COMMIT = 4,
    /* Active Block Commit (virDomainBlockCommit with flags), job
     * exists as long as sync is active */

    VIR_DOMAIN_BLOCK_JOB_TYPE_LAST

} virDomainBlockJobType;


typedef enum {
    VIR_DOMAIN_BLOCK_JOB_ABORT_ASYNC = 1 << 0,
    VIR_DOMAIN_BLOCK_JOB_ABORT_PIVOT = 1 << 1,
} virDomainBlockJobAbortFlags;

int virDomainBlockJobAbort(virDomainPtr dom, const char *disk,
                           unsigned int flags);

/* Flags for use with virDomainGetBlockJobInfo */
typedef enum {
    VIR_DOMAIN_BLOCK_JOB_INFO_BANDWIDTH_BYTES = 1 << 0, /* bandwidth in bytes/s
                                                           instead of MiB/s */
} virDomainBlockJobInfoFlags;

/* An iterator for monitoring block job operations */
typedef unsigned long long virDomainBlockJobCursor;

typedef struct _virDomainBlockJobInfo virDomainBlockJobInfo;
struct _virDomainBlockJobInfo {
    int type; /* virDomainBlockJobType */
    unsigned long bandwidth; /* either bytes/s or MiB/s, according to flags */

    /*
     * The following fields provide an indication of block job progress.  @cur
     * indicates the current position and will be between 0 and @end.  @end is
     * the final cursor position for this operation and represents completion.
     * To approximate progress, divide @cur by @end.
     */
    virDomainBlockJobCursor cur;
    virDomainBlockJobCursor end;
};
typedef virDomainBlockJobInfo *virDomainBlockJobInfoPtr;

int virDomainGetBlockJobInfo(virDomainPtr dom, const char *disk,
                             virDomainBlockJobInfoPtr info,
                             unsigned int flags);

/* Flags for use with virDomainBlockJobSetSpeed */
typedef enum {
    VIR_DOMAIN_BLOCK_JOB_SPEED_BANDWIDTH_BYTES = 1 << 0, /* bandwidth in bytes/s
                                                            instead of MiB/s */
} virDomainBlockJobSetSpeedFlags;

int virDomainBlockJobSetSpeed(virDomainPtr dom, const char *disk,
                              unsigned long bandwidth, unsigned int flags);

/* Flags for use with virDomainBlockPull (values chosen to be a subset
 * of the flags for virDomainBlockRebase) */
typedef enum {
    VIR_DOMAIN_BLOCK_PULL_BANDWIDTH_BYTES = 1 << 6, /* bandwidth in bytes/s
                                                       instead of MiB/s */
} virDomainBlockPullFlags;

int virDomainBlockPull(virDomainPtr dom, const char *disk,
                       unsigned long bandwidth, unsigned int flags);

/**
 * virDomainBlockRebaseFlags:
 *
 * Flags available for virDomainBlockRebase().
 */
typedef enum {
    VIR_DOMAIN_BLOCK_REBASE_SHALLOW   = 1 << 0, /* Limit copy to top of source
                                                   backing chain */
    VIR_DOMAIN_BLOCK_REBASE_REUSE_EXT = 1 << 1, /* Reuse existing external
                                                   file for a copy */
    VIR_DOMAIN_BLOCK_REBASE_COPY_RAW  = 1 << 2, /* Make destination file raw */
    VIR_DOMAIN_BLOCK_REBASE_COPY      = 1 << 3, /* Start a copy job */
    VIR_DOMAIN_BLOCK_REBASE_RELATIVE  = 1 << 4, /* Keep backing chain
                                                   referenced using relative
                                                   names */
    VIR_DOMAIN_BLOCK_REBASE_COPY_DEV  = 1 << 5, /* Treat destination as block
                                                   device instead of file */
    VIR_DOMAIN_BLOCK_REBASE_BANDWIDTH_BYTES = 1 << 6, /* bandwidth in bytes/s
                                                         instead of MiB/s */
} virDomainBlockRebaseFlags;

int virDomainBlockRebase(virDomainPtr dom, const char *disk,
                         const char *base, unsigned long bandwidth,
                         unsigned int flags);


typedef enum {
    VIR_DOMAIN_BLOCK_COPY_SHALLOW   = 1 << 0, /* Limit copy to top of source
                                                 backing chain */
    VIR_DOMAIN_BLOCK_COPY_REUSE_EXT = 1 << 1, /* Reuse existing external
                                                 file for a copy */
} virDomainBlockCopyFlags;
]]


export.VIR_DOMAIN_BLOCK_COPY_BANDWIDTH ="bandwidth";
export.VIR_DOMAIN_BLOCK_COPY_GRANULARITY ="granularity";
export.VIR_DOMAIN_BLOCK_COPY_BUF_SIZE ="buf-size";


ffi.cdef[[
int virDomainBlockCopy(virDomainPtr dom, const char *disk,
                       const char *destxml,
                       virTypedParameterPtr params,
                       int nparams,
                       unsigned int flags);


typedef enum {
    VIR_DOMAIN_BLOCK_COMMIT_SHALLOW = 1 << 0, /* NULL base means next backing
                                                 file, not whole chain */
    VIR_DOMAIN_BLOCK_COMMIT_DELETE  = 1 << 1, /* Delete any files that are now
                                                 invalid after their contents
                                                 have been committed */
    VIR_DOMAIN_BLOCK_COMMIT_ACTIVE  = 1 << 2, /* Allow a two-phase commit when
                                                 top is the active layer */
    VIR_DOMAIN_BLOCK_COMMIT_RELATIVE = 1 << 3, /* keep the backing chain
                                                  referenced using relative
                                                  names */
    VIR_DOMAIN_BLOCK_COMMIT_BANDWIDTH_BYTES = 1 << 4, /* bandwidth in bytes/s
                                                         instead of MiB/s */
} virDomainBlockCommitFlags;

int virDomainBlockCommit(virDomainPtr dom, const char *disk, const char *base,
                         const char *top, unsigned long bandwidth,
                         unsigned int flags);
]]



-- Block I/O throttling support 


export.VIR_DOMAIN_BLOCK_IOTUNE_TOTAL_BYTES_SEC ="total_bytes_sec"

export.VIR_DOMAIN_BLOCK_IOTUNE_READ_BYTES_SEC ="read_bytes_sec"

export.VIR_DOMAIN_BLOCK_IOTUNE_WRITE_BYTES_SEC ="write_bytes_sec"

export.VIR_DOMAIN_BLOCK_IOTUNE_TOTAL_IOPS_SEC ="total_iops_sec"

export.VIR_DOMAIN_BLOCK_IOTUNE_READ_IOPS_SEC ="read_iops_sec"

export.VIR_DOMAIN_BLOCK_IOTUNE_WRITE_IOPS_SEC ="write_iops_sec"

export.VIR_DOMAIN_BLOCK_IOTUNE_TOTAL_BYTES_SEC_MAX ="total_bytes_sec_max"

export.VIR_DOMAIN_BLOCK_IOTUNE_READ_BYTES_SEC_MAX ="read_bytes_sec_max"

export.VIR_DOMAIN_BLOCK_IOTUNE_WRITE_BYTES_SEC_MAX ="write_bytes_sec_max"

export.VIR_DOMAIN_BLOCK_IOTUNE_TOTAL_IOPS_SEC_MAX ="total_iops_sec_max"

export.VIR_DOMAIN_BLOCK_IOTUNE_READ_IOPS_SEC_MAX ="read_iops_sec_max"

export.VIR_DOMAIN_BLOCK_IOTUNE_WRITE_IOPS_SEC_MAX ="write_iops_sec_max"

export.VIR_DOMAIN_BLOCK_IOTUNE_SIZE_IOPS_SEC ="size_iops_sec"

ffi.cdef[[
int
virDomainSetBlockIoTune(virDomainPtr dom,
                        const char *disk,
                        virTypedParameterPtr params,
                        int nparams,
                        unsigned int flags);
int
virDomainGetBlockIoTune(virDomainPtr dom,
                        const char *disk,
                        virTypedParameterPtr params,
                        int *nparams,
                        unsigned int flags);
]]

ffi.cdef[[

typedef enum {
    VIR_DOMAIN_DISK_ERROR_NONE      = 0, /* no error */
    VIR_DOMAIN_DISK_ERROR_UNSPEC    = 1, /* unspecified I/O error */
    VIR_DOMAIN_DISK_ERROR_NO_SPACE  = 2, /* no space left on the device */

    VIR_DOMAIN_DISK_ERROR_LAST

} virDomainDiskErrorCode;


typedef struct _virDomainDiskError virDomainDiskError;
typedef virDomainDiskError *virDomainDiskErrorPtr;

struct _virDomainDiskError {
    char *disk; /* disk target */
    int error;  /* virDomainDiskErrorCode */
};

int virDomainGetDiskErrors(virDomainPtr dom,
                           virDomainDiskErrorPtr errors,
                           unsigned int maxerrors,
                           unsigned int flags);
]]

ffi.cdef[[

typedef enum {
    VIR_KEYCODE_SET_LINUX          = 0,
    VIR_KEYCODE_SET_XT             = 1,
    VIR_KEYCODE_SET_ATSET1         = 2,
    VIR_KEYCODE_SET_ATSET2         = 3,
    VIR_KEYCODE_SET_ATSET3         = 4,
    VIR_KEYCODE_SET_OSX            = 5,
    VIR_KEYCODE_SET_XT_KBD         = 6,
    VIR_KEYCODE_SET_USB            = 7,
    VIR_KEYCODE_SET_WIN32          = 8,
    VIR_KEYCODE_SET_RFB            = 9,

    VIR_KEYCODE_SET_LAST

} virKeycodeSet;
]]

export.VIR_DOMAIN_SEND_KEY_MAX_KEYS  = 16;

ffi.cdef[[
int virDomainSendKey(virDomainPtr domain,
                     unsigned int codeset,
                     unsigned int holdtime,
                     unsigned int *keycodes,
                     int nkeycodes,
                     unsigned int flags);
]]

ffi.cdef[[

typedef enum {
    VIR_DOMAIN_PROCESS_SIGNAL_NOP        =  0, /* No constant in POSIX/Linux */
    VIR_DOMAIN_PROCESS_SIGNAL_HUP        =  1, /* SIGHUP */
    VIR_DOMAIN_PROCESS_SIGNAL_INT        =  2, /* SIGINT */
    VIR_DOMAIN_PROCESS_SIGNAL_QUIT       =  3, /* SIGQUIT */
    VIR_DOMAIN_PROCESS_SIGNAL_ILL        =  4, /* SIGILL */
    VIR_DOMAIN_PROCESS_SIGNAL_TRAP       =  5, /* SIGTRAP */
    VIR_DOMAIN_PROCESS_SIGNAL_ABRT       =  6, /* SIGABRT */
    VIR_DOMAIN_PROCESS_SIGNAL_BUS        =  7, /* SIGBUS */
    VIR_DOMAIN_PROCESS_SIGNAL_FPE        =  8, /* SIGFPE */
    VIR_DOMAIN_PROCESS_SIGNAL_KILL       =  9, /* SIGKILL */

    VIR_DOMAIN_PROCESS_SIGNAL_USR1       = 10, /* SIGUSR1 */
    VIR_DOMAIN_PROCESS_SIGNAL_SEGV       = 11, /* SIGSEGV */
    VIR_DOMAIN_PROCESS_SIGNAL_USR2       = 12, /* SIGUSR2 */
    VIR_DOMAIN_PROCESS_SIGNAL_PIPE       = 13, /* SIGPIPE */
    VIR_DOMAIN_PROCESS_SIGNAL_ALRM       = 14, /* SIGALRM */
    VIR_DOMAIN_PROCESS_SIGNAL_TERM       = 15, /* SIGTERM */
    VIR_DOMAIN_PROCESS_SIGNAL_STKFLT     = 16, /* Not in POSIX (SIGSTKFLT on Linux )*/
    VIR_DOMAIN_PROCESS_SIGNAL_CHLD       = 17, /* SIGCHLD */
    VIR_DOMAIN_PROCESS_SIGNAL_CONT       = 18, /* SIGCONT */
    VIR_DOMAIN_PROCESS_SIGNAL_STOP       = 19, /* SIGSTOP */

    VIR_DOMAIN_PROCESS_SIGNAL_TSTP       = 20, /* SIGTSTP */
    VIR_DOMAIN_PROCESS_SIGNAL_TTIN       = 21, /* SIGTTIN */
    VIR_DOMAIN_PROCESS_SIGNAL_TTOU       = 22, /* SIGTTOU */
    VIR_DOMAIN_PROCESS_SIGNAL_URG        = 23, /* SIGURG */
    VIR_DOMAIN_PROCESS_SIGNAL_XCPU       = 24, /* SIGXCPU */
    VIR_DOMAIN_PROCESS_SIGNAL_XFSZ       = 25, /* SIGXFSZ */
    VIR_DOMAIN_PROCESS_SIGNAL_VTALRM     = 26, /* SIGVTALRM */
    VIR_DOMAIN_PROCESS_SIGNAL_PROF       = 27, /* SIGPROF */
    VIR_DOMAIN_PROCESS_SIGNAL_WINCH      = 28, /* Not in POSIX (SIGWINCH on Linux) */
    VIR_DOMAIN_PROCESS_SIGNAL_POLL       = 29, /* SIGPOLL (also known as SIGIO on Linux) */

    VIR_DOMAIN_PROCESS_SIGNAL_PWR        = 30, /* Not in POSIX (SIGPWR on Linux) */
    VIR_DOMAIN_PROCESS_SIGNAL_SYS        = 31, /* SIGSYS (also known as SIGUNUSED on Linux) */
    VIR_DOMAIN_PROCESS_SIGNAL_RT0        = 32, /* SIGRTMIN */
    VIR_DOMAIN_PROCESS_SIGNAL_RT1        = 33, /* SIGRTMIN + 1 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT2        = 34, /* SIGRTMIN + 2 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT3        = 35, /* SIGRTMIN + 3 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT4        = 36, /* SIGRTMIN + 4 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT5        = 37, /* SIGRTMIN + 5 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT6        = 38, /* SIGRTMIN + 6 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT7        = 39, /* SIGRTMIN + 7 */

    VIR_DOMAIN_PROCESS_SIGNAL_RT8        = 40, /* SIGRTMIN + 8 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT9        = 41, /* SIGRTMIN + 9 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT10       = 42, /* SIGRTMIN + 10 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT11       = 43, /* SIGRTMIN + 11 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT12       = 44, /* SIGRTMIN + 12 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT13       = 45, /* SIGRTMIN + 13 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT14       = 46, /* SIGRTMIN + 14 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT15       = 47, /* SIGRTMIN + 15 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT16       = 48, /* SIGRTMIN + 16 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT17       = 49, /* SIGRTMIN + 17 */

    VIR_DOMAIN_PROCESS_SIGNAL_RT18       = 50, /* SIGRTMIN + 18 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT19       = 51, /* SIGRTMIN + 19 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT20       = 52, /* SIGRTMIN + 20 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT21       = 53, /* SIGRTMIN + 21 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT22       = 54, /* SIGRTMIN + 22 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT23       = 55, /* SIGRTMIN + 23 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT24       = 56, /* SIGRTMIN + 24 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT25       = 57, /* SIGRTMIN + 25 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT26       = 58, /* SIGRTMIN + 26 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT27       = 59, /* SIGRTMIN + 27 */

    VIR_DOMAIN_PROCESS_SIGNAL_RT28       = 60, /* SIGRTMIN + 28 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT29       = 61, /* SIGRTMIN + 29 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT30       = 62, /* SIGRTMIN + 30 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT31       = 63, /* SIGRTMIN + 31 */
    VIR_DOMAIN_PROCESS_SIGNAL_RT32       = 64, /* SIGRTMIN + 32 / SIGRTMAX */

    VIR_DOMAIN_PROCESS_SIGNAL_LAST
} virDomainProcessSignal;

int virDomainSendProcessSignal(virDomainPtr domain,
                               long long pid_value,
                               unsigned int signum,
                               unsigned int flags);
]]


ffi.cdef[[
/*
 * Domain Event Notification
 */


typedef enum {
    VIR_DOMAIN_EVENT_DEFINED = 0,
    VIR_DOMAIN_EVENT_UNDEFINED = 1,
    VIR_DOMAIN_EVENT_STARTED = 2,
    VIR_DOMAIN_EVENT_SUSPENDED = 3,
    VIR_DOMAIN_EVENT_RESUMED = 4,
    VIR_DOMAIN_EVENT_STOPPED = 5,
    VIR_DOMAIN_EVENT_SHUTDOWN = 6,
    VIR_DOMAIN_EVENT_PMSUSPENDED = 7,
    VIR_DOMAIN_EVENT_CRASHED = 8,

    VIR_DOMAIN_EVENT_LAST
} virDomainEventType;


typedef enum {
    VIR_DOMAIN_EVENT_DEFINED_ADDED = 0,     /* Newly created config file */
    VIR_DOMAIN_EVENT_DEFINED_UPDATED = 1,   /* Changed config file */

    VIR_DOMAIN_EVENT_DEFINED_LAST
} virDomainEventDefinedDetailType;


typedef enum {
    VIR_DOMAIN_EVENT_UNDEFINED_REMOVED = 0, /* Deleted the config file */

    VIR_DOMAIN_EVENT_UNDEFINED_LAST

} virDomainEventUndefinedDetailType;


typedef enum {
    VIR_DOMAIN_EVENT_STARTED_BOOTED = 0,   /* Normal startup from boot */
    VIR_DOMAIN_EVENT_STARTED_MIGRATED = 1, /* Incoming migration from another host */
    VIR_DOMAIN_EVENT_STARTED_RESTORED = 2, /* Restored from a state file */
    VIR_DOMAIN_EVENT_STARTED_FROM_SNAPSHOT = 3, /* Restored from snapshot */
    VIR_DOMAIN_EVENT_STARTED_WAKEUP = 4,   /* Started due to wakeup event */

    VIR_DOMAIN_EVENT_STARTED_LAST

} virDomainEventStartedDetailType;


typedef enum {
    VIR_DOMAIN_EVENT_SUSPENDED_PAUSED = 0,   /* Normal suspend due to admin pause */
    VIR_DOMAIN_EVENT_SUSPENDED_MIGRATED = 1, /* Suspended for offline migration */
    VIR_DOMAIN_EVENT_SUSPENDED_IOERROR = 2,  /* Suspended due to a disk I/O error */
    VIR_DOMAIN_EVENT_SUSPENDED_WATCHDOG = 3,  /* Suspended due to a watchdog firing */
    VIR_DOMAIN_EVENT_SUSPENDED_RESTORED = 4,  /* Restored from paused state file */
    VIR_DOMAIN_EVENT_SUSPENDED_FROM_SNAPSHOT = 5, /* Restored from paused snapshot */
    VIR_DOMAIN_EVENT_SUSPENDED_API_ERROR = 6, /* suspended after failure during libvirt API call */

    VIR_DOMAIN_EVENT_SUSPENDED_LAST

} virDomainEventSuspendedDetailType;


typedef enum {
    VIR_DOMAIN_EVENT_RESUMED_UNPAUSED = 0,   /* Normal resume due to admin unpause */
    VIR_DOMAIN_EVENT_RESUMED_MIGRATED = 1,   /* Resumed for completion of migration */
    VIR_DOMAIN_EVENT_RESUMED_FROM_SNAPSHOT = 2, /* Resumed from snapshot */

    VIR_DOMAIN_EVENT_RESUMED_LAST
} virDomainEventResumedDetailType;


typedef enum {
    VIR_DOMAIN_EVENT_STOPPED_SHUTDOWN = 0,  /* Normal shutdown */
    VIR_DOMAIN_EVENT_STOPPED_DESTROYED = 1, /* Forced poweroff from host */
    VIR_DOMAIN_EVENT_STOPPED_CRASHED = 2,   /* Guest crashed */
    VIR_DOMAIN_EVENT_STOPPED_MIGRATED = 3,  /* Migrated off to another host */
    VIR_DOMAIN_EVENT_STOPPED_SAVED = 4,     /* Saved to a state file */
    VIR_DOMAIN_EVENT_STOPPED_FAILED = 5,    /* Host emulator/mgmt failed */
    VIR_DOMAIN_EVENT_STOPPED_FROM_SNAPSHOT = 6, /* offline snapshot loaded */

    VIR_DOMAIN_EVENT_STOPPED_LAST
} virDomainEventStoppedDetailType;



typedef enum {
    VIR_DOMAIN_EVENT_SHUTDOWN_FINISHED = 0, /* Guest finished shutdown sequence */

    VIR_DOMAIN_EVENT_SHUTDOWN_LAST
} virDomainEventShutdownDetailType;

typedef enum {
    VIR_DOMAIN_EVENT_PMSUSPENDED_MEMORY = 0, /* Guest was PM suspended to memory */
    VIR_DOMAIN_EVENT_PMSUSPENDED_DISK = 1, /* Guest was PM suspended to disk */

    VIR_DOMAIN_EVENT_PMSUSPENDED_LAST
} virDomainEventPMSuspendedDetailType;


typedef enum {
    VIR_DOMAIN_EVENT_CRASHED_PANICKED = 0, /* Guest was panicked */

    VIR_DOMAIN_EVENT_CRASHED_LAST
} virDomainEventCrashedDetailType;
]]

ffi.cdef[[

typedef int (*virConnectDomainEventCallback)(virConnectPtr conn,
                                             virDomainPtr dom,
                                             int event,
                                             int detail,
                                             void *opaque);

int virConnectDomainEventRegister(virConnectPtr conn,
                                  virConnectDomainEventCallback cb,
                                  void *opaque,
                                  virFreeCallback freecb);

int virConnectDomainEventDeregister(virConnectPtr conn,
                                    virConnectDomainEventCallback cb);


int virDomainIsActive(virDomainPtr dom);
int virDomainIsPersistent(virDomainPtr dom);
int virDomainIsUpdated(virDomainPtr dom);

typedef enum {
    VIR_DOMAIN_JOB_NONE      = 0, /* No job is active */
    VIR_DOMAIN_JOB_BOUNDED   = 1, /* Job with a finite completion time */
    VIR_DOMAIN_JOB_UNBOUNDED = 2, /* Job without a finite completion time */
    VIR_DOMAIN_JOB_COMPLETED = 3, /* Job has finished, but isn't cleaned up */
    VIR_DOMAIN_JOB_FAILED    = 4, /* Job hit error, but isn't cleaned up */
    VIR_DOMAIN_JOB_CANCELLED = 5, /* Job was aborted, but isn't cleaned up */

    VIR_DOMAIN_JOB_LAST
} virDomainJobType;

typedef struct _virDomainJobInfo virDomainJobInfo;
typedef virDomainJobInfo *virDomainJobInfoPtr;
struct _virDomainJobInfo {
    /* One of virDomainJobType */
    int type;

    /* Time is measured in milliseconds */
    unsigned long long timeElapsed;    /* Always set */
    unsigned long long timeRemaining;  /* Only for VIR_DOMAIN_JOB_BOUNDED */


    unsigned long long dataTotal;
    unsigned long long dataProcessed;
    unsigned long long dataRemaining;

    /* As above, but only tracking guest memory progress */
    unsigned long long memTotal;
    unsigned long long memProcessed;
    unsigned long long memRemaining;

    /* As above, but only tracking guest disk file progress */
    unsigned long long fileTotal;
    unsigned long long fileProcessed;
    unsigned long long fileRemaining;
};


typedef enum {
    VIR_DOMAIN_JOB_STATS_COMPLETED = 1 << 0, /* return stats of a recently
                                              * completed job */
} virDomainGetJobStatsFlags;

int virDomainGetJobInfo(virDomainPtr dom,
                        virDomainJobInfoPtr info);
int virDomainGetJobStats(virDomainPtr domain,
                         int *type,
                         virTypedParameterPtr *params,
                         int *nparams,
                         unsigned int flags);
int virDomainAbortJob(virDomainPtr dom);
]]

export.VIR_DOMAIN_JOB_TIME_ELAPSED            = "time_elapsed"

export.VIR_DOMAIN_JOB_TIME_REMAINING           ="time_remaining"

export.VIR_DOMAIN_JOB_DOWNTIME                = "downtime"

export.VIR_DOMAIN_JOB_SETUP_TIME              = "setup_time"

export.VIR_DOMAIN_JOB_DATA_TOTAL              = "data_total"

export.VIR_DOMAIN_JOB_DATA_PROCESSED          = "data_processed"

export.VIR_DOMAIN_JOB_DATA_REMAINING          = "data_remaining"

export.VIR_DOMAIN_JOB_MEMORY_TOTAL            = "memory_total"

export.VIR_DOMAIN_JOB_MEMORY_PROCESSED        = "memory_processed"

export.VIR_DOMAIN_JOB_MEMORY_REMAINING        = "memory_remaining"

export.VIR_DOMAIN_JOB_MEMORY_CONSTANT         = "memory_constant"

export.VIR_DOMAIN_JOB_MEMORY_NORMAL           = "memory_normal"

export.VIR_DOMAIN_JOB_MEMORY_NORMAL_BYTES     = "memory_normal_bytes"

export.VIR_DOMAIN_JOB_MEMORY_BPS              = "memory_bps"

export.VIR_DOMAIN_JOB_DISK_TOTAL              = "disk_total"

export.VIR_DOMAIN_JOB_DISK_PROCESSED          = "disk_processed"

export.VIR_DOMAIN_JOB_DISK_REMAINING          = "disk_remaining"

export.VIR_DOMAIN_JOB_DISK_BPS                = "disk_bps"

export.VIR_DOMAIN_JOB_COMPRESSION_CACHE       = "compression_cache"

export.VIR_DOMAIN_JOB_COMPRESSION_BYTES       = "compression_bytes"

export.VIR_DOMAIN_JOB_COMPRESSION_PAGES       = "compression_pages"

export.VIR_DOMAIN_JOB_COMPRESSION_CACHE_MISSES= "compression_cache_misses"

export.VIR_DOMAIN_JOB_COMPRESSION_OVERFLOW    = "compression_overflow"


ffi.cdef[[

typedef void (*virConnectDomainEventGenericCallback)(virConnectPtr conn,
                                                     virDomainPtr dom,
                                                     void *opaque);


typedef void (*virConnectDomainEventRTCChangeCallback)(virConnectPtr conn,
                                                       virDomainPtr dom,
                                                       long long utcoffset,
                                                       void *opaque);


typedef enum {
    VIR_DOMAIN_EVENT_WATCHDOG_NONE = 0, /* No action, watchdog ignored */
    VIR_DOMAIN_EVENT_WATCHDOG_PAUSE,    /* Guest CPUs are paused */
    VIR_DOMAIN_EVENT_WATCHDOG_RESET,    /* Guest CPUs are reset */
    VIR_DOMAIN_EVENT_WATCHDOG_POWEROFF, /* Guest is forcibly powered off */
    VIR_DOMAIN_EVENT_WATCHDOG_SHUTDOWN, /* Guest is requested to gracefully shutdown */
    VIR_DOMAIN_EVENT_WATCHDOG_DEBUG,    /* No action, a debug message logged */

    VIR_DOMAIN_EVENT_WATCHDOG_LAST

} virDomainEventWatchdogAction;


typedef void (*virConnectDomainEventWatchdogCallback)(virConnectPtr conn,
                                                      virDomainPtr dom,
                                                      int action,
                                                      void *opaque);


typedef enum {
    VIR_DOMAIN_EVENT_IO_ERROR_NONE = 0,  /* No action, IO error ignored */
    VIR_DOMAIN_EVENT_IO_ERROR_PAUSE,     /* Guest CPUs are paused */
    VIR_DOMAIN_EVENT_IO_ERROR_REPORT,    /* IO error reported to guest OS */

    VIR_DOMAIN_EVENT_IO_ERROR_LAST

} virDomainEventIOErrorAction;



typedef void (*virConnectDomainEventIOErrorCallback)(virConnectPtr conn,
                                                     virDomainPtr dom,
                                                     const char *srcPath,
                                                     const char *devAlias,
                                                     int action,
                                                     void *opaque);


typedef void (*virConnectDomainEventIOErrorReasonCallback)(virConnectPtr conn,
                                                           virDomainPtr dom,
                                                           const char *srcPath,
                                                           const char *devAlias,
                                                           int action,
                                                           const char *reason,
                                                           void *opaque);


typedef enum {
    VIR_DOMAIN_EVENT_GRAPHICS_CONNECT = 0,  /* Initial socket connection established */
    VIR_DOMAIN_EVENT_GRAPHICS_INITIALIZE,   /* Authentication & setup completed */
    VIR_DOMAIN_EVENT_GRAPHICS_DISCONNECT,   /* Final socket disconnection */

    VIR_DOMAIN_EVENT_GRAPHICS_LAST

} virDomainEventGraphicsPhase;


typedef enum {
    VIR_DOMAIN_EVENT_GRAPHICS_ADDRESS_IPV4,  /* IPv4 address */
    VIR_DOMAIN_EVENT_GRAPHICS_ADDRESS_IPV6,  /* IPv6 address */
    VIR_DOMAIN_EVENT_GRAPHICS_ADDRESS_UNIX,  /* UNIX socket path */

    VIR_DOMAIN_EVENT_GRAPHICS_ADDRESS_LAST
} virDomainEventGraphicsAddressType;



struct _virDomainEventGraphicsAddress {
    int family;               /* Address family, virDomainEventGraphicsAddressType */
    char *node;               /* Address of node (eg IP address, or UNIX path) */
    char *service;            /* Service name/number (eg TCP port, or NULL) */
};
typedef struct _virDomainEventGraphicsAddress virDomainEventGraphicsAddress;
typedef virDomainEventGraphicsAddress *virDomainEventGraphicsAddressPtr;
]]

ffi.cdef[[
struct _virDomainEventGraphicsSubjectIdentity {
    char *type;     /* Type of identity */
    char *name;     /* Identity value */
};
typedef struct _virDomainEventGraphicsSubjectIdentity virDomainEventGraphicsSubjectIdentity;
typedef virDomainEventGraphicsSubjectIdentity *virDomainEventGraphicsSubjectIdentityPtr;



struct _virDomainEventGraphicsSubject {
    int nidentity;                                /* Number of identities in array*/
    virDomainEventGraphicsSubjectIdentityPtr identities; /* Array of identities for subject */
};
typedef struct _virDomainEventGraphicsSubject virDomainEventGraphicsSubject;
typedef virDomainEventGraphicsSubject *virDomainEventGraphicsSubjectPtr;
]]

ffi.cdef[[

typedef void (*virConnectDomainEventGraphicsCallback)(virConnectPtr conn,
                                                      virDomainPtr dom,
                                                      int phase,
                                                      const virDomainEventGraphicsAddress *local,
                                                      const virDomainEventGraphicsAddress *remote,
                                                      const char *authScheme,
                                                      const virDomainEventGraphicsSubject *subject,
                                                      void *opaque);


typedef enum {
    VIR_DOMAIN_BLOCK_JOB_COMPLETED = 0,
    VIR_DOMAIN_BLOCK_JOB_FAILED = 1,
    VIR_DOMAIN_BLOCK_JOB_CANCELED = 2,
    VIR_DOMAIN_BLOCK_JOB_READY = 3,

    VIR_DOMAIN_BLOCK_JOB_LAST

} virConnectDomainEventBlockJobStatus;


typedef void (*virConnectDomainEventBlockJobCallback)(virConnectPtr conn,
                                                      virDomainPtr dom,
                                                      const char *disk,
                                                      int type,
                                                      int status,
                                                      void *opaque);


typedef enum {
    VIR_DOMAIN_EVENT_DISK_CHANGE_MISSING_ON_START = 0, /* oldSrcPath is set */
    VIR_DOMAIN_EVENT_DISK_DROP_MISSING_ON_START = 1,

    VIR_DOMAIN_EVENT_DISK_CHANGE_LAST
} virConnectDomainEventDiskChangeReason;


typedef void (*virConnectDomainEventDiskChangeCallback)(virConnectPtr conn,
                                                        virDomainPtr dom,
                                                        const char *oldSrcPath,
                                                        const char *newSrcPath,
                                                        const char *devAlias,
                                                        int reason,
                                                        void *opaque);


typedef enum {
    VIR_DOMAIN_EVENT_TRAY_CHANGE_OPEN = 0,
    VIR_DOMAIN_EVENT_TRAY_CHANGE_CLOSE,

    VIR_DOMAIN_EVENT_TRAY_CHANGE_LAST
} virDomainEventTrayChangeReason;


typedef void (*virConnectDomainEventTrayChangeCallback)(virConnectPtr conn,
                                                        virDomainPtr dom,
                                                        const char *devAlias,
                                                        int reason,
                                                        void *opaque);


typedef void (*virConnectDomainEventPMWakeupCallback)(virConnectPtr conn,
                                                      virDomainPtr dom,
                                                      int reason,
                                                      void *opaque);


typedef void (*virConnectDomainEventPMSuspendCallback)(virConnectPtr conn,
                                                       virDomainPtr dom,
                                                       int reason,
                                                       void *opaque);



typedef void (*virConnectDomainEventBalloonChangeCallback)(virConnectPtr conn,
                                                           virDomainPtr dom,
                                                           unsigned long long actual,
                                                           void *opaque);


typedef void (*virConnectDomainEventPMSuspendDiskCallback)(virConnectPtr conn,
                                                           virDomainPtr dom,
                                                           int reason,
                                                           void *opaque);


typedef void (*virConnectDomainEventDeviceRemovedCallback)(virConnectPtr conn,
                                                           virDomainPtr dom,
                                                           const char *devAlias,
                                                           void *opaque);
]]

export.VIR_DOMAIN_TUNABLE_CPU_VCPUPIN ="cputune.vcpupin%u";


export.VIR_DOMAIN_TUNABLE_CPU_EMULATORPIN ="cputune.emulatorpin";


export.VIR_DOMAIN_TUNABLE_CPU_IOTHREADSPIN ="cputune.iothreadpin%u";


export.VIR_DOMAIN_TUNABLE_CPU_CPU_SHARES ="cputune.cpu_shares";


export.VIR_DOMAIN_TUNABLE_CPU_VCPU_PERIOD ="cputune.vcpu_period";


export.VIR_DOMAIN_TUNABLE_CPU_VCPU_QUOTA ="cputune.vcpu_quota";


export.VIR_DOMAIN_TUNABLE_CPU_EMULATOR_PERIOD ="cputune.emulator_period";


export.VIR_DOMAIN_TUNABLE_CPU_EMULATOR_QUOTA ="cputune.emulator_quota";


export.VIR_DOMAIN_TUNABLE_BLKDEV_DISK ="blkdeviotune.disk";


export.VIR_DOMAIN_TUNABLE_BLKDEV_TOTAL_BYTES_SEC ="blkdeviotune.total_bytes_sec";


export.VIR_DOMAIN_TUNABLE_BLKDEV_READ_BYTES_SEC ="blkdeviotune.read_bytes_sec";


export.VIR_DOMAIN_TUNABLE_BLKDEV_WRITE_BYTES_SEC ="blkdeviotune.write_bytes_sec";


export.VIR_DOMAIN_TUNABLE_BLKDEV_TOTAL_IOPS_SEC ="blkdeviotune.total_iops_sec";


export.VIR_DOMAIN_TUNABLE_BLKDEV_READ_IOPS_SEC ="blkdeviotune.read_iops_sec";


export.VIR_DOMAIN_TUNABLE_BLKDEV_WRITE_IOPS_SEC ="blkdeviotune.write_iops_sec";


export.VIR_DOMAIN_TUNABLE_BLKDEV_TOTAL_BYTES_SEC_MAX ="blkdeviotune.total_bytes_sec_max";


export.VIR_DOMAIN_TUNABLE_BLKDEV_READ_BYTES_SEC_MAX ="blkdeviotune.read_bytes_sec_max";


export.VIR_DOMAIN_TUNABLE_BLKDEV_WRITE_BYTES_SEC_MAX ="blkdeviotune.write_bytes_sec_max";


export.VIR_DOMAIN_TUNABLE_BLKDEV_TOTAL_IOPS_SEC_MAX ="blkdeviotune.total_iops_sec_max";


export.VIR_DOMAIN_TUNABLE_BLKDEV_READ_IOPS_SEC_MAX ="blkdeviotune.read_iops_sec_max";


export.VIR_DOMAIN_TUNABLE_BLKDEV_WRITE_IOPS_SEC_MAX ="blkdeviotune.write_iops_sec_max";


export.VIR_DOMAIN_TUNABLE_BLKDEV_SIZE_IOPS_SEC ="blkdeviotune.size_iops_sec";

ffi.cdef[[

typedef void (*virConnectDomainEventTunableCallback)(virConnectPtr conn,
                                                     virDomainPtr dom,
                                                     virTypedParameterPtr params,
                                                     int nparams,
                                                     void *opaque);


typedef enum {
    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_STATE_CONNECTED = 1, /* agent connected */
    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_STATE_DISCONNECTED = 2, /* agent disconnected */

    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_STATE_LAST
} virConnectDomainEventAgentLifecycleState;

typedef enum {
    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_REASON_UNKNOWN = 0, /* unknown state change reason */
    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_REASON_DOMAIN_STARTED = 1, /* state changed due to domain start */
    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_REASON_CHANNEL = 2, /* channel state changed */

    VIR_CONNECT_DOMAIN_EVENT_AGENT_LIFECYCLE_REASON_LAST
} virConnectDomainEventAgentLifecycleReason;


typedef void (*virConnectDomainEventAgentLifecycleCallback)(virConnectPtr conn,
                                                            virDomainPtr dom,
                                                            int state,
                                                            int reason,
                                                            void *opaque);
]]


--# define VIR_DOMAIN_EVENT_CALLBACK(cb) ((virConnectDomainEventGenericCallback)(cb))

ffi.cdef[[

typedef enum {
    VIR_DOMAIN_EVENT_ID_LIFECYCLE = 0,       /* virConnectDomainEventCallback */
    VIR_DOMAIN_EVENT_ID_REBOOT = 1,          /* virConnectDomainEventGenericCallback */
    VIR_DOMAIN_EVENT_ID_RTC_CHANGE = 2,      /* virConnectDomainEventRTCChangeCallback */
    VIR_DOMAIN_EVENT_ID_WATCHDOG = 3,        /* virConnectDomainEventWatchdogCallback */
    VIR_DOMAIN_EVENT_ID_IO_ERROR = 4,        /* virConnectDomainEventIOErrorCallback */
    VIR_DOMAIN_EVENT_ID_GRAPHICS = 5,        /* virConnectDomainEventGraphicsCallback */
    VIR_DOMAIN_EVENT_ID_IO_ERROR_REASON = 6, /* virConnectDomainEventIOErrorReasonCallback */
    VIR_DOMAIN_EVENT_ID_CONTROL_ERROR = 7,   /* virConnectDomainEventGenericCallback */
    VIR_DOMAIN_EVENT_ID_BLOCK_JOB = 8,       /* virConnectDomainEventBlockJobCallback */
    VIR_DOMAIN_EVENT_ID_DISK_CHANGE = 9,     /* virConnectDomainEventDiskChangeCallback */
    VIR_DOMAIN_EVENT_ID_TRAY_CHANGE = 10,    /* virConnectDomainEventTrayChangeCallback */
    VIR_DOMAIN_EVENT_ID_PMWAKEUP = 11,       /* virConnectDomainEventPMWakeupCallback */
    VIR_DOMAIN_EVENT_ID_PMSUSPEND = 12,      /* virConnectDomainEventPMSuspendCallback */
    VIR_DOMAIN_EVENT_ID_BALLOON_CHANGE = 13, /* virConnectDomainEventBalloonChangeCallback */
    VIR_DOMAIN_EVENT_ID_PMSUSPEND_DISK = 14, /* virConnectDomainEventPMSuspendDiskCallback */
    VIR_DOMAIN_EVENT_ID_DEVICE_REMOVED = 15, /* virConnectDomainEventDeviceRemovedCallback */
    VIR_DOMAIN_EVENT_ID_BLOCK_JOB_2 = 16,    /* virConnectDomainEventBlockJobCallback */
    VIR_DOMAIN_EVENT_ID_TUNABLE = 17,        /* virConnectDomainEventTunableCallback */
    VIR_DOMAIN_EVENT_ID_AGENT_LIFECYCLE = 18,/* virConnectDomainEventAgentLifecycleCallback */

    VIR_DOMAIN_EVENT_ID_LAST

} virDomainEventID;


/* Use VIR_DOMAIN_EVENT_CALLBACK() to cast the 'cb' parameter  */
int virConnectDomainEventRegisterAny(virConnectPtr conn,
                                     virDomainPtr dom, /* Optional, to filter */
                                     int eventID,
                                     virConnectDomainEventGenericCallback cb,
                                     void *opaque,
                                     virFreeCallback freecb);

int virConnectDomainEventDeregisterAny(virConnectPtr conn,
                                       int callbackID);


typedef enum {

    VIR_DOMAIN_CONSOLE_FORCE = (1 << 0), /* abort a (possibly) active console
                                            connection to force a new
                                            connection */
    VIR_DOMAIN_CONSOLE_SAFE = (1 << 1), /* check if the console driver supports
                                           safe console operations */
} virDomainConsoleFlags;

int virDomainOpenConsole(virDomainPtr dom,
                         const char *dev_name,
                         virStreamPtr st,
                         unsigned int flags);


typedef enum {
    VIR_DOMAIN_CHANNEL_FORCE = (1 << 0), /* abort a (possibly) active channel
                                            connection to force a new
                                            connection */
} virDomainChannelFlags;

int virDomainOpenChannel(virDomainPtr dom,
                         const char *name,
                         virStreamPtr st,
                         unsigned int flags);

typedef enum {
    VIR_DOMAIN_OPEN_GRAPHICS_SKIPAUTH = (1 << 0),
} virDomainOpenGraphicsFlags;

int virDomainOpenGraphics(virDomainPtr dom,
                          unsigned int idx,
                          int fd,
                          unsigned int flags);

int virDomainOpenGraphicsFD(virDomainPtr dom,
                            unsigned int idx,
                            unsigned int flags);

int virDomainInjectNMI(virDomainPtr domain, unsigned int flags);

int virDomainFSTrim(virDomainPtr dom,
                    const char *mountPoint,
                    unsigned long long minimum,
                    unsigned int flags);

int virDomainFSFreeze(virDomainPtr dom,
                      const char **mountpoints,
                      unsigned int nmountpoints,
                      unsigned int flags);

int virDomainFSThaw(virDomainPtr dom,
                    const char **mountpoints,
                    unsigned int nmountpoints,
                    unsigned int flags);
]]

ffi.cdef[[
typedef struct _virDomainFSInfo virDomainFSInfo;
typedef virDomainFSInfo *virDomainFSInfoPtr;
struct _virDomainFSInfo {
    char *mountpoint; /* path to mount point */
    char *name;       /* device name in the guest (e.g. "sda1") */
    char *fstype;     /* filesystem type */
    size_t ndevAlias; /* number of elements in devAlias */
    char **devAlias;  /* array of disk device aliases */
};

void virDomainFSInfoFree(virDomainFSInfoPtr info);

int virDomainGetFSInfo(virDomainPtr dom,
                       virDomainFSInfoPtr **info,
                       unsigned int flags);

int virDomainGetTime(virDomainPtr dom,
                     long long *seconds,
                     unsigned int *nseconds,
                     unsigned int flags);

typedef enum {
    VIR_DOMAIN_TIME_SYNC = (1 << 0), /* Re-sync domain time from domain's RTC */
} virDomainSetTimeFlags;

int virDomainSetTime(virDomainPtr dom,
                     long long seconds,
                     unsigned int nseconds,
                     unsigned int flags);
]]

--[[
/**
 * virSchedParameterType:
 *
 * A scheduler parameter field type.  Provided for backwards
 * compatibility; virTypedParameterType is the preferred enum since
 * 0.9.2.
 */
typedef enum {
    VIR_DOMAIN_SCHED_FIELD_INT     = VIR_TYPED_PARAM_INT,
    VIR_DOMAIN_SCHED_FIELD_UINT    = VIR_TYPED_PARAM_UINT,
    VIR_DOMAIN_SCHED_FIELD_LLONG   = VIR_TYPED_PARAM_LLONG,
    VIR_DOMAIN_SCHED_FIELD_ULLONG  = VIR_TYPED_PARAM_ULLONG,
    VIR_DOMAIN_SCHED_FIELD_DOUBLE  = VIR_TYPED_PARAM_DOUBLE,
    VIR_DOMAIN_SCHED_FIELD_BOOLEAN = VIR_TYPED_PARAM_BOOLEAN,
} virSchedParameterType;
--]]

ffi.cdef[[
static const int VIR_DOMAIN_SCHED_FIELD_LENGTH = VIR_TYPED_PARAM_FIELD_LENGTH;

/**
 * virSchedParameter:
 *
 * a virSchedParameter is the set of scheduler parameters.
 * Provided for backwards compatibility; virTypedParameter is the
 * preferred alias since 0.9.2.
 */
//# define _virSchedParameter _virTypedParameter
typedef struct _virTypedParameter virSchedParameter;

/**
 * virSchedParameterPtr:
 *
 * a virSchedParameterPtr is a pointer to a virSchedParameter structure.
 * Provided for backwards compatibility; virTypedParameterPtr is the
 * preferred alias since 0.9.2.
 */
typedef virSchedParameter *virSchedParameterPtr;
]]

--[[
/**
 * virBlkioParameterType:
 *
 * A blkio parameter field type.  Provided for backwards
 * compatibility; virTypedParameterType is the preferred enum since
 * 0.9.2.
 */
typedef enum {
    VIR_DOMAIN_BLKIO_PARAM_INT     = VIR_TYPED_PARAM_INT,
    VIR_DOMAIN_BLKIO_PARAM_UINT    = VIR_TYPED_PARAM_UINT,
    VIR_DOMAIN_BLKIO_PARAM_LLONG   = VIR_TYPED_PARAM_LLONG,
    VIR_DOMAIN_BLKIO_PARAM_ULLONG  = VIR_TYPED_PARAM_ULLONG,
    VIR_DOMAIN_BLKIO_PARAM_DOUBLE  = VIR_TYPED_PARAM_DOUBLE,
    VIR_DOMAIN_BLKIO_PARAM_BOOLEAN = VIR_TYPED_PARAM_BOOLEAN,
} virBlkioParameterType;
--]]

--[[
/**
 * VIR_DOMAIN_BLKIO_FIELD_LENGTH:
 *
 * Macro providing the field length of virBlkioParameter.  Provided
 * for backwards compatibility; VIR_TYPED_PARAM_FIELD_LENGTH is the
 * preferred value since 0.9.2.
 */
# define VIR_DOMAIN_BLKIO_FIELD_LENGTH VIR_TYPED_PARAM_FIELD_LENGTH
--]]

--[[
/**
 * virBlkioParameter:
 *
 * a virBlkioParameter is the set of blkio parameters.
 * Provided for backwards compatibility; virTypedParameter is the
 * preferred alias since 0.9.2.
 */
# define _virBlkioParameter _virTypedParameter
typedef struct _virTypedParameter virBlkioParameter;
--]]

--[[
/**
 * virBlkioParameterPtr:
 *
 * a virBlkioParameterPtr is a pointer to a virBlkioParameter structure.
 * Provided for backwards compatibility; virTypedParameterPtr is the
 * preferred alias since 0.9.2.
 */
typedef virBlkioParameter *virBlkioParameterPtr;

/**
 * virMemoryParameterType:
 *
 * A memory parameter field type.  Provided for backwards
 * compatibility; virTypedParameterType is the preferred enum since
 * 0.9.2.
 */
typedef enum {
    VIR_DOMAIN_MEMORY_PARAM_INT     = VIR_TYPED_PARAM_INT,
    VIR_DOMAIN_MEMORY_PARAM_UINT    = VIR_TYPED_PARAM_UINT,
    VIR_DOMAIN_MEMORY_PARAM_LLONG   = VIR_TYPED_PARAM_LLONG,
    VIR_DOMAIN_MEMORY_PARAM_ULLONG  = VIR_TYPED_PARAM_ULLONG,
    VIR_DOMAIN_MEMORY_PARAM_DOUBLE  = VIR_TYPED_PARAM_DOUBLE,
    VIR_DOMAIN_MEMORY_PARAM_BOOLEAN = VIR_TYPED_PARAM_BOOLEAN,
} virMemoryParameterType;
--]]

--[[
static const int VIR_DOMAIN_MEMORY_FIELD_LENGTH = VIR_TYPED_PARAM_FIELD_LENGTH;


//# define _virMemoryParameter _virTypedParameter
typedef struct _virTypedParameter virMemoryParameter;


typedef virMemoryParameter *virMemoryParameterPtr;
--]]

ffi.cdef[[
typedef enum {
    VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_LEASE = 0, /* Parse DHCP lease file */
    VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT = 1, /* Query qemu guest agent */

    VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_LAST
} virDomainInterfaceAddressesSource;

typedef struct _virDomainInterfaceIPAddress virDomainIPAddress;
typedef virDomainIPAddress *virDomainIPAddressPtr;
struct _virDomainInterfaceIPAddress {
    int type;                /* virIPAddrType */
    char *addr;              /* IP address */
    unsigned int prefix;     /* IP address prefix */
};

typedef struct _virDomainInterface virDomainInterface;
typedef virDomainInterface *virDomainInterfacePtr;
struct _virDomainInterface {
    char *name;                     /* interface name */
    char *hwaddr;                   /* hardware address, may be NULL */
    unsigned int naddrs;            /* number of items in @addrs */
    virDomainIPAddressPtr addrs;    /* array of IP addresses */
};

int virDomainInterfaceAddresses(virDomainPtr dom,
                                virDomainInterfacePtr **ifaces,
                                unsigned int source,
                                unsigned int flags);

void virDomainInterfaceFree(virDomainInterfacePtr iface);
]]


return export
