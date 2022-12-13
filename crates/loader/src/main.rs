#![no_std]
#![no_main]
#![feature(core_intrinsics)]
#![feature(ptr_to_from_bits)]
#![feature(pointer_byte_offsets)]
#![feature(const_pointer_byte_offsets)]

use core::ops::Range;

use loader_payload::PAYLOAD;

#[no_mangle]
extern "C" fn main() -> ! {
    loader_core::main(&PAYLOAD, &get_own_footprint())
}

fn get_own_footprint() -> Range<usize> {
    unsafe { LOADER_PHYS_START..(&_end as *const i32 as usize) }
}

extern "C" {
    // TODO incompatible with -Ttext=0x...
    // static __executable_start: i32;

    static _end: i32;
}

const LOADER_PHYS_START: usize =
    include!(concat!(env!("OUT_DIR"), "/loader_phys_start.fragment.rs"));

mod translation_tables {
    include!(concat!(env!("OUT_DIR"), "/translation_tables.rs"));
}