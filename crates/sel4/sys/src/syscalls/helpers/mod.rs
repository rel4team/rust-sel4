use sel4_bitfield_types::Bitfield;

use crate::{seL4_MessageInfo, seL4_Word};

mod arch;

pub use arch::*;

impl seL4_MessageInfo {
    pub(crate) fn from_word(word: seL4_Word) -> Self {
        Self(Bitfield::from_arr([word]))
    }

    pub(crate) fn into_word(self) -> seL4_Word {
        self.0.into_arr()[0]
    }

    pub(crate) fn msg_helper(&self, msg: Option<seL4_Word>, i: u64) -> seL4_Word {
        if let Some(msg) = msg && i < self.get_length() {
            msg
        } else {
            0
        }
    }
}