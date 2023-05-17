use core::fmt;

pub use sel4_panicking::catch_unwind;
pub use sel4_panicking_env::{abort, debug_print, debug_println};

use crate::get_ipc_buffer;
use crate::handler::{run_handler, Handler};
use crate::panicking::init_panicking;

#[cfg(target_thread_local)]
#[no_mangle]
unsafe extern "C" fn sel4_runtime_rust_entry() -> ! {
    use core::ffi::c_void;
    use core::ptr;

    unsafe extern "C" fn cont_fn(_cont_arg: *mut c_void) -> ! {
        inner_entry()
    }

    let cont_arg = ptr::null_mut();

    sel4_runtime_common::locate_tls_image()
        .unwrap()
        .reserve_on_stack_and_continue(cont_fn, cont_arg)
}

#[cfg(not(target_thread_local))]
#[no_mangle]
unsafe extern "C" fn sel4_runtime_rust_entry() -> ! {
    inner_entry()
}

unsafe extern "C" fn inner_entry() -> ! {
    #[cfg(feature = "unwinding")]
    {
        sel4_runtime_common::set_eh_frame_finder().unwrap();
    }

    init_panicking();
    sel4::set_ipc_buffer(get_ipc_buffer());
    __sel4cp_init();
    abort!("main thread returned")
}

extern "C" {
    fn __sel4cp_init();
}

#[macro_export]
macro_rules! declare_main {
    ($main:path) => {
        #[no_mangle]
        pub unsafe extern "C" fn __sel4cp_init() {
            $crate::_private::run_main($main);
        }
    };
}

#[allow(clippy::missing_safety_doc)]
pub unsafe fn run_main<T>(f: impl FnOnce() -> T)
where
    T: Handler,
    T::Error: fmt::Debug,
{
    match catch_unwind(|| run_handler(f()).into_err()) {
        Ok(err) => abort!("main thread terminated with error: {err:?}"),
        Err(_) => abort!("main thread panicked"),
    }
}
