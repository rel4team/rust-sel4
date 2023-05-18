use unwinding::custom_eh_frame_finder::{
    set_custom_eh_frame_finder, EhFrameFinder, FrameInfo, FrameInfoKind,
    SetCustomEhFrameFinderError,
};

use crate::phdrs::{
    elf::{PT_GNU_EH_FRAME, PT_LOAD},
    locate_phdrs,
};

struct ThisEhFrameFinder;

unsafe impl EhFrameFinder for ThisEhFrameFinder {
    fn find(&self, pc: usize) -> Option<FrameInfo> {
        let phdrs = locate_phdrs();

        let text_base = phdrs.iter().find_map(|phdr| {
            if phdr.p_type == PT_LOAD {
                let vaddr_range = phdr.vaddr_range();
                if vaddr_range.contains(&pc) {
                    return Some(vaddr_range.start);
                }
            }
            None
        })?;

        let eh_frame_hdr = phdrs.iter().find_map(|phdr| {
            if phdr.p_type == PT_GNU_EH_FRAME {
                let eh_frame_hdr = phdr.p_vaddr.try_into().unwrap();
                return Some(eh_frame_hdr);
            }
            None
        })?;

        Some(FrameInfo {
            text_base,
            kind: FrameInfoKind::EhFrameHdr(eh_frame_hdr),
        })
    }
}

pub fn set_eh_frame_finder() -> Result<(), SetCustomEhFrameFinderError> {
    static EH_FRAME_FINDER: &(dyn EhFrameFinder + Sync) = &ThisEhFrameFinder;
    set_custom_eh_frame_finder(EH_FRAME_FINDER)
}