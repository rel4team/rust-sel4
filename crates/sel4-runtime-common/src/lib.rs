//
// Copyright 2023, Colias Group, LLC
//
// SPDX-License-Identifier: BSD-2-Clause
//

#![no_std]
#![feature(cfg_target_thread_local)]

mod ctors;

pub use ctors::run_ctors;

#[cfg(feature = "start")]
mod start;

#[cfg(any(
    all(feature = "tls", target_thread_local),
    all(feature = "unwinding", panic = "unwind")
))]
mod phdrs;

#[cfg(any(
    all(feature = "tls", target_thread_local),
    all(feature = "unwinding", panic = "unwind")
))]
pub use phdrs::*;

#[doc(hidden)]
pub mod _private {
    #[cfg(feature = "start")]
    pub use crate::start::_private as start;
}
