// Set base feature level.
#define MICROPY_CONFIG_ROM_LEVEL (MICROPY_CONFIG_ROM_LEVEL_EXTRA_FEATURES)

// Enable extra Unix features.
#include "../lib/micropython/ports/unix/variants/mpconfigvariant_common.h"

#define MICROPY_MODULE_BUILTIN_INIT (1)

#undef MICROPY_MALLOC_USES_ALLOCATED_SIZE
#define MICROPY_MALLOC_USES_ALLOCATED_SIZE (0)

#undef MICROPY_MEM_STATS
#define MICROPY_MEM_STATS           (0)

#define LINUX_FRAME_BUFFER 1
#define MICROPY_PY_SYS_SETTRACE                 (0)

