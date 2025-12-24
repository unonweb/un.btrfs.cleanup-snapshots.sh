NOTES
=====

This is a script to clean up a timeline of btrfs snapshots in a directory provided with ${1}.
If there are more than ${SNAPSHOTS_MAX_NUM} snapshots found in this directory, delete the oldest ones.

Arguments
---------

```sh
un.btrfs.cleanup-snapshots /path/to/snapshots/ snapshots_max_num
```

Requirements
------------

This script relies on a strict naming pattern: `2025-12-17-154540`
All snapshots in the given directory will be checked against that pattern. If one fails that check, the scripts exits.

TO DO
=====

- How store different SNAPSHOTS_MAX_NUM per snapshot directory