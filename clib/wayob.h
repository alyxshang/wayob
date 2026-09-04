/*
WAYOB by Alyx Shang.
Licensed under the FSL v1.
*/

#ifndef WAYOB_H
#define WAYOB_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

/* An enumeration
 * containing all
 * possible types
 * of data a `CFrame`
 * can contain.
 */
typedef enum {
    Void,
    Bool,
    String,
    Integer,
    Structure,
    FloatingPoint
} CFrameType;

/* A forward declaration
 * for the `CFrame` type.
 */
struct CFrame;

/* A structure to
 * encapsulate data
 * about user-created
 * data structures.
 */
typedef struct {
    struct CFrame* data;
    size_t arg_count;
} CStructure;

/* A union containing
 * every possible unit
 * of data that Wayob can
 * process and that can be
 * used in an FFI context.
 */
typedef union {
    bool Bool;
    int64_t Integer;
    double FloatingPoint;
    const char* String;
    CStructure Structure;
} CFramePayload;

/* A structure encapsulating
 * data about a single unit
 * of data in an FFI context.
 */
typedef struct CFrame {
    CFrameType tag;
    CFramePayload payload;
} CFrame;

#endif
