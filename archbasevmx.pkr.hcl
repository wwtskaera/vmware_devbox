packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    ansible = {
        version = "~> 1"
        source = "github.com/hashicorp/ansible"
    }
  }
}

source "vmware-vmx" "archi3-1" {
  vm_name = "archi3"
  source_path = "../../Documents/Virtual Machines/archbase/archbase.vmx"
  ssh_username = "root"
  ssh_password = "root"
  shutdown_command = "systemctl poweroff -i"
  disk_additional_size = [20480]
}

build {
  sources = ["sources.vmware-vmx.archi3-1"]
  provisioner "ansible" {
    playbook_file = "ansible/i3.yml"
  }
}