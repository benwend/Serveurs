# Partitionnement

## Aides

- https://blog.stephane-robert.info/docs/admin-serveurs/linux/stockage/ext4/#pour-quels-usages
- https://blog.stephane-robert.info/docs/admin-serveurs/linux/references-complementaires/btrfs/#pour-quels-usages
- https://docs.ogb4n.fr/fr/guides/debian-lvm-luks/
- https://wiki.debian.org/LVM
- https://www.shpv.fr/blog/partitionnement-disque-linux-2026/
- https://www.shpv.fr/blog/montage-filesystems-linux-2026/

## PC

### Disques

/dev/sda : SDD
/dev/sdb : HDD

### Aménagement

```
||--------------------------------------------------OS-----------------------------------------------------------------||
||-Non-LVM-||-----------------------------------------------LVM--------------------------------------------------------||
||  [BOOT] ||  [ROOT]   | [VAR-LIB]        ||  [DATA]       | [HOME]       | [VAR]       | [VIRT]       | [SWAP]       || Label Partition(LP)
||  /boot  ||  LV-1 (/) | LV-2 (/var/lib)  ||  LV-3 (/data) | LV-4 (/home) | LV-5 (/var) | LV-6 (/virt) | LV-7 (swap)  || Logical Volumes(LV)
||         ||------------------------------||---------------|--------------|-------------|--------------|--------------||
||         ||              VG 1            ||                                    VG 2                                  || Volume Groups(VG)
||         ||------------------------------||---------------|--------------|-------------|--------------|--------------||
||/dev/sda1|| /dev/sda2  | /dev/sda3       || /dev/sdb1     | /dev/sdb2    | /dev/sdb3   | /dev/sdb4    | /dev/sdb5    || Physical Volumes(PV)
||---------||------------------------------||--------------------------------------------------------------------------||
```
