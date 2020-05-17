#!/bin/bash

# Copyright (c) Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Compilation of functions that can be called for most Linux distros.  Functions are commonly used when installing Linux.

function create_basic_partitions() {
    if [[ "${windows_response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Creates one partition.  Partition uses the rest of the free space avalailable to create a Linux filesystem partition.
        sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
    else
        # Creates two partitions.  First one is a 512 MB EFI partition while the second uses the rest of the free space avalailable to create a Linux filesystem partition.
        sgdisk -n 0:0:+512MiB -c "${partition_number1}":"EFI System Partition" -t "${partition_number1}":ef00 "${disk}"
        sgdisk -n 0:0:0 -c "${partition_number2}":"Linux Filesystem" -t "${partition_number2}":8300 "${disk}"
    fi
}

function create_basic_filesystems() {
    # Parameters
    local partition1=${1}
    local partition2=${2}
    local duel_boot=${3}

    mkfs.ext4 "${partition2}"
    if [[ ! "${duel_boot}" =~ ^([d][b])+$ ]]; then
        mkfs.fat -F32 "${partition1}"
    fi
}

function mount_basic_filesystems() {
    # Parameters
    local boot_partition=${1}
    local root_partition=${2}

    mount "${root_partition}" /mnt
    mkdir '/mnt/boot'
    mount "${boot_partition}" '/mnt/boot'
}

function mount_proc_and_sysfs() {
    {
        printf '%s\n' 'proc /mnt/proc proc defaults 0 0'
        printf '%s\n' 'sysfs /mnt/sys sysfs defaults 0 0'
    } >>'/etc/fstab'
    mount proc /mnt/proc -t proc
    mount sysfs /mnt/sys -t sysfs
}

function create_basic_partition_fstab() {
    {
        printf '%s\n' "UUID=${uuid} /boot/EFI vfat defaults 0 0"
        printf '%s\n' '/swapfile none swap defaults 0 0'
        printf '%s\n' "UUID=${uuid2} / ext4 defaults 0 0"
    } >>'/etc/fstab'
}

function enable_base_network_connectivity() {
    # Parameters
    local interface=${1}

    {
        printf '%s\n' 'auto lo'
        printf '%s\n' 'iface lo inet loopback'
        printf '%s\n' "auto ${interface}"
        printf '%s\n' "iface ${interface} inet dhcp"
    } >>'/etc/network/interfaces'
}

function lock_root() {
    passwd --lock root
}

function create_luks_partition() {
    # Parameters
    local disk_password=${1}
    local partition=${2}

    printf '%s\n' "${disk_password}" >'/tmp/disk_password'
    cryptsetup -q luksFormat "${partition}" <'/tmp/disk_password'
}

function create_basic_lvm() {
    # Parameters
    local partition=${1}
    local disk_password=${2}
    local lvm_name=${3}
    local root_partition_size=${4}
    local home_partition_size=${5}

    cryptsetup open "${partition}" cryptlvm <"${disk_password}"
    pvcreate '/dev/mapper/cryptlvm'
    vgcreate "${lvm_name}" '/dev/mapper/cryptlvm'
    lvcreate -L "${root_partition_size}" "${lvm_name}" -n root
    lvcreate -l "${home_partition_size}" "${lvm_name}" -n home
    rm -f "${disk_password}"
}

function create_basic_filesystems_lvm() {
    # Parameters
    local lvm_name=${1}
    local duel_boot=${2}
    local partition=${3}

    mkfs.ext4 "/dev/${lvm_name}/root"
    mkfs.ext4 "/dev/${lvm_name}/home"
    if [[ ! "${duel_boot}" =~ ^([d][b])+$ ]]; then
        mkfs.fat -F32 "${partition}"
    fi
}

function mount_basic_filesystems_lvm() {
    # Parameters
    local lvm_name=${1}
    local partition=${2}

    mount "/dev/${lvm_name}/root" /mnt
    mkdir '/mnt/home'
    mount "/dev/${lvm_name}/home" '/mnt/home'
    mkdir '/mnt/boot'
    mount "${partition}" '/mnt/boot'
}

function create_basic_lvm_fstab() {
    rm -f '/etc/fstab'
    {
        printf '%s\n' "UUID=${boot_uuid} /boot/EFI vfat defaults 0 0"
        printf '%s\n' '/swapfile none swap defaults 0 0'
        printf '%s\n' "UUID=${root_uuid} / ext4 defaults 0 0"
        printf '%s\n' "UUID=${home_uuid} / ext4 defaults 0 0"
    } >>'/etc/fstab'
}

function create_swap_file() {
    # Parameters
    local swap_file_size=${1}

    # Create swapfile
    dd if=/dev/zero of=/swapfile bs=1M count="${swap_file_size}" status=progress
    # Set file permissions
    chmod 600 /swapfile
    # Format file to swap
    mkswap /swapfile
    # Activate the swap file
    swapon /swapfile
}

function set_timezone() {
    ln -sf '/usr/share/zoneinfo/America/New_York' '/etc/localtime'
}

function set_hardware_clock() {
    hwclock --systohc
}

function enable_ntpd_client() {
    systemctl enable ntpd.service
}

function set_language() {
    rm -f '/etc/locale.conf'
    {
        printf '%s\n' '# language config'
        printf '%s\n' '# file location is /etc/locale.conf'
        printf '%s\n' ''
        printf '%s\n' 'LANG=en_US.UTF-8'
        printf '%s\n' ''
    } >>'/etc/locale.conf'
}

function set_hostname() {
    # Parameters
    local device_hostname=${1}

    rm -f '/etc/hostname'
    {
        printf '%s\n' '# hostname file'
        printf '%s\n' '# File location is /etc/hostname'
        printf '%s\n' "${device_hostname}"
        printf '%s\n' ''
    } >>'/etc/hostname'
}

function setup_hosts_file() {
    # Parameters
    local device_hostname=${1}

    rm -f '/etc/hosts'
    {
        printf '%s\n' '# host file'
        printf '%s\n' '# file location is /etc/hosts'
        printf '%s\n' ''
        printf '%s\n' '127.0.0.1 localhost'
        printf '%s\n' '::1 localhost'
        printf '%s\n' "127.0.1.1 ${device_hostname}.localdomain ${device_hostname}"
        printf '%s\n' ''
    } >>'/etc/hosts'
}

function set_root_password() {
    echo 'Set root password'
    passwd root
}

function set_systemd_boot_install_path() {
    bootctl --path=/boot install
}

function add_user_to_sudo() {
    # Parameters
    local user_name=${1}

    printf '%s\n' "${user_name} ALL=(ALL) ALL" >>'/etc/sudoers'
}

function get_base_partition_uuids() {
    # Parameters
    local partition1=${1}
    local partition2=${2}

    uuid="$(blkid -o value -s UUID "${partition1}")"
    uuid2="$(blkid -o value -s UUID "${partition2}")"
}

function get_lvm_uuids() {
    boot_uuid=uuid="$(blkid -o value -s UUID "${partition1}")"
    luks_partition_uuid="$(blkid -o value -s UUID "${partition2}")"
    root_uuid="$(blkid -o value -s UUID /dev/Archlvm/root)"
    home_uuid="$(blkid -o value -s UUID /dev/Archlvm/home)"
}

function delete_all_partitions_on_a_disk() {
    # Parameters
    local disk=${1}

    local response
    read -r -p "Are you sure you want to delete everything on ${disk}? [y/N] " response
    if [[ "${response}" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        # Deletes all partitions on disk
        sgdisk -Z "${disk}"
        sgdisk -og "${disk}"
    fi
}
