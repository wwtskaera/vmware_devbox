packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

source "vmware-iso" "devbox" {
  iso_url = "assets/archlinux-2024.03.01-x86_64.iso"
  iso_checksum = "sha256:0062e39e57d492672712467fdb14371fca4e3a5c57fed06791be95da8d4a60e3"
  vmx_data = {
    "firmware" = "efi"
  }
  boot_wait = "5s"
  boot_command = [
    "<enter><wait40s>",
    # 1.10 Format the partitions
    "fdisk /dev/sda<enter>",
    "g<enter>",
    "n<enter><enter><enter>",
    "+1G<enter>",
    "t<enter>1<enter>",
    "n<enter><enter><enter>",
    "+4G<enter>",
    "t<enter><enter>19<enter>",
    "n<enter><enter><enter>",
    "<enter>",
    "t<enter><enter>23<enter>",
    "w<enter>",
    "mkfs.ext4 /dev/sda3<enter>",
    "mkswap /dev/sda2<enter>",
    "mkfs.fat -F 32 /dev/sda1<enter>",
    # 1.11 Mount the Filesystem
    "mount /dev/sda3 /mnt<enter>",
    "mount --mkdir /dev/sda1 /mnt/boot<enter>",
    "swapon /dev/sda2<enter>",
    # 2 Installation
    ## 2.1 Select the mirrors
    #"curl -s \"https://archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4&use_mirror_status=on\" | sed -e '/Server/s/^#*//g' > /etc/pacman.d/mirrorlist<enter><wait5>",
    ## 2.2 Install essential packages
    "pacstrap -K /mnt base base-devel linux linux-firmware dhcpcd sudo git openssh vim<enter><wait3m30s>",
    # 3 Configure the system
    ## 3.1 Fstab
    "genfstab -U /mnt >> /mnt/etc/fstab<enter>",
    ## 3.2 Chroot
    "arch-chroot /mnt<enter>",
    ## 3.3 Time
    "ln -sf /usr/share/zoneinfo/US/Central /etc/localtime<enter>",
    "hwclock --systohc<enter><wait5>",
    ## 3.4 Localization
    "sed -e '/en_US.UTF-8/s/^#*//g' -i /etc/locale.gen<enter>",
    "locale-gen<enter><wait5>",
    "echo 'LANG=en_US.UTF-8' > /etc/locale.conf<enter>",
    ## 3.5 Network configuration
    "echo 'archbase' > /etc/hostname<enter>",
    "systemctl enable dhcpcd<enter>",
    ## 3.7 Root password
    "echo -e 'root\\nroot' | passwd<enter>",
    ## 3.8 Bootloader Install
    "pacman -S grub efibootmgr --noconfirm<enter><wait10>",
    "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB<enter>",
    "grub-mkconfig -o /boot/grub/grub.cfg<enter>",
    # adduser and enable ssh
    "exit<enter>",
    "useradd packer<enter>",
    "echo -e 'packer\\npacker' | passwd packer<enter>",
    "echo 'packer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_packer<enter>",
    "chmod 440 /etc/sudoers.d/10_packer<enter>",
    "systemctl start sshd<enter>",
    # 4 Reboot(exit chroot)
    #"reboot<enter>"
  ]
  cpus = 2
  memory = 4096
  disk_size = 20480
  ssh_username = "packer"
  ssh_password= "packer"
  shutdown_command = "systemctl poweroff -i"
}

build {
  sources = ["sources.vmware-iso.devbox"]
}
