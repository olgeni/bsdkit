# -*- mode: sh -*-

BSDKIT_ZFS_INCLUDED="yes"

# Drop ZFS read-only properties from `zfs get` output, leaving only
# settable properties on stdout.
filter-properties() {
    awk '
BEGIN {
  read_only["available"] = 1;
  read_only["casesensitivity"] = 1;
  read_only["compressratio"] = 1;
  read_only["createtxg"] = 1;
  read_only["creation"] = 1;
  read_only["encryption"] = 1;
  read_only["filesystem_count"] = 1;
  read_only["guid"] = 1;
  read_only["keyformat"] = 1;
  read_only["keylocation"] = 1;
  read_only["logicalreferenced"] = 1;
  read_only["logicalused"] = 1;
  read_only["mlslabel"] = 1;
  read_only["mounted"] = 1;
  read_only["normalization"] = 1;
  read_only["objsetid"] = 1;
  read_only["origin"] = 1;
  read_only["pbkdf2iters"] = 1;
  read_only["refcompressratio"] = 1;
  read_only["referenced"] = 1;
  read_only["snapshot_count"] = 1;
  read_only["type"] = 1;
  read_only["used"] = 1;
  read_only["usedbychildren"] = 1;
  read_only["usedbydataset"] = 1;
  read_only["usedbyrefreservation"] = 1;
  read_only["usedbysnapshots"] = 1;
  read_only["utf8only"] = 1;
  read_only["version"] = 1;
  read_only["written"] = 1;
}

{
  if (!read_only[$2]) {
    print;
  }
}
'
}
