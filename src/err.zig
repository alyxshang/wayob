// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

/// A data structure to catch
/// and handle errors in this
/// library.
pub const WayobErr = error {
    AllocErr,
    WriteErr,
    TypeError,
    EmptyStack,
    LibLoadErr, 
    FnNotFound,
    MissingValue,
    DynLibOpenErr,
    PluginExecErr,
    EnvVarReadErr,
};
