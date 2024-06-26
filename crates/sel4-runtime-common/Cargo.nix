#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

{ mk, localCrates, versions, unwindingWith }:

mk {
  package.name = "sel4-runtime-common";
  dependencies = {
    inherit (versions) cfg-if;
    unwinding = unwindingWith [] // { optional = true; };
    inherit (localCrates) sel4-panicking-env;
    sel4 = localCrates.sel4 // { default-features = false; optional = true; };
    sel4-initialize-tls-on-stack = localCrates.sel4-initialize-tls-on-stack // { optional = true; };
  };
  features = {
    tls = [ "dep:sel4-initialize-tls-on-stack" "dep:sel4" ];
    start = [];
  };
}
