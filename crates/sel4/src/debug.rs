//
// Copyright 2023, Colias Group, LLC
// Copyright (c) 2020 Arm Limited
//
// SPDX-License-Identifier: MIT
//

use crate::{sys, InvocationContext, CapType, TCB, LocalCPtr};

/// Corresponds to `seL4_DebugPutChar`.
pub fn debug_put_char(c: u8) {
    sys::seL4_DebugPutChar(c)
}

pub fn get_clock() -> u64 {
    sys::seL4_GetClock() as u64
}

/// Corresponds to `seL4_DebugSnapshot`.
pub fn debug_snapshot() {
    sys::seL4_DebugSnapshot()
}

impl<C: InvocationContext> TCB<C> {
    /// Corresponds to `seL4_DebugNameThread`.
    pub fn debug_name(self, name: &[u8]) {
        self.invoke(|cptr, ipc_buffer| {
            sys::seL4_DebugNameThread(cptr.bits(), name, ipc_buffer.inner_mut())
        })
    }
}

impl<T: CapType> LocalCPtr<T> {
    /// Corresponds to `seL4_DebugCapIdentify`.
    pub fn debug_identify(self) -> u32 {
        sys::seL4_DebugCapIdentify(self.bits())
    }
}
