#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

{ mk, localCrates, versions }:

mk {
  package.name = "sel4-microkit";
  dependencies = {
    inherit (versions) cfg-if;
    inherit (localCrates)
      sel4-panicking
      sel4-panicking-env
      sel4-immediate-sync-once-cell
      sel4-immutable-cell
      sel4-dlmalloc
      sel4-sync
      sel4-microkit-macros
      sel4-externally-shared
    ;
    sel4-runtime-common = localCrates.sel4-runtime-common // { features = [ "tls" "unwinding" "start" ]; };
    sel4 = localCrates.sel4 // { features = [ "single-threaded" ]; };
  };
  features = {
    default = [
      "unwinding"
    ];
    full = [
      "default"
      "alloc"
    ];
    unwinding = [
      "sel4-panicking/unwinding"
    ];
    alloc = [
      "sel4-panicking/alloc"
    ];
  };
}
