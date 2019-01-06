#! /bin/sh

## Default variables to use
export INTERACTIVE=${INTERACTIVE:="true"}
export OSTYPE=${OSTYPE:="RedHat_64"}
export VMNAME=${VMNAME:="CentOS_7"}
export BASEFOLDER=${BASEFOLDER:="/var/vbox"}
export CPUS=${CPUS:="2"}
export MEMORY_SIZE=${MEMORY_SIZE:="4096"}
export HDD_SIZE=${HDD_SIZE:="20480"}
export BRIDGE_ADAPTER=${BRIDGE_ADAPTER:="eno1"}
export INSTALL_IMAGE=${INSTALL_IMAGE:="./CentOS-7-x86_64-DVD-1810.iso"}

## Make the script interactive to set the variables
if [ "$INTERACTIVE" = "true" ]; then
  read -rp "Name of VM to be created: ($VMNAME): " choice;
  if [ "$choice" != "" ] ; then
          export VMNAME="$choice";
  fi

  read -rp "Base folder of created vms: ($BASEFOLDER): " choice;
  if [ "$choice" != "" ] ; then
          export BASEFOLDER="$choice";
  fi

  read -rp "Number of CPUs: ($CPUS): " choice;
  if [ "$choice" != "" ] ; then
          export CPUS="$choice";
  fi

  read -rp "Size of memory in MB: ($MEMORY_SIZE): " choice;
  if [ "$choice" != "" ] ; then
          export MEMORY_SIZE="$choice";
  fi
  read -rp "Size of main disk in MB: ($HDD_SIZE): " choice;
  if [ "$choice" != "" ] ; then
          export HDD_SIZE="$choice";
  fi

  read -rp "Network adapter used for bridging: ($BRIDGE_ADAPTER): " choice;
  if [ "$choice" != "" ] ; then
          export BRIDGE_ADAPTER="$choice";
  fi

  read -rp "OS type of the machine (RedHat_64 - CentOS, RHEL | Ubuntu_64 - Ubuntu): ($OSTYPE): " choice;
  if [ "$choice" != "" ] ; then
          export OSTYPE="$choice";
  fi

  ls *.iso
  read -rp "Image to attach for installation: ($INSTALL_IMAGE): " choice;
  if [ "$choice" != "" ] ; then
          export INSTALL_IMAGE="$choice";
  fi

  echo
fi

echo "******"
echo "* The VM name is $VMNAME "
echo "* The folder where VMs are being created is $BASEFOLDER "
echo "* The number of CPUs is $CPUS "
echo "* The available memory will be $MEMORY_SIZE "
echo "* The primary disk size is $HDD_SIZE "
echo "* The network adapter used for bridging is $BRIDGE_ADAPTER "
echo "* Tho os type is $OSTYPE "
echo "* The image mounted for installation is $INSTALL_IMAGE "
echo "* Remote Desktop is enabled and available on port 5001 of this host "
echo "******"

export SATA_NAME="${VMNAME}_SATA"
export HD_FILENAME="/var/vbox/${VMNAME}/${VMNAME}.vdi"

mkdir -p ${BASEFOLDER}

vboxmanage createvm --name ${VMNAME} \
                    --ostype ${OSTYPE} \
                    --register \
                    --basefolder ${BASEFOLDER}

vboxmanage modifyvm ${VMNAME}   --cpus ${CPUS} \
                                --memory ${MEMORY_SIZE} \
                                --nic1 bridged \
                                --bridgeadapter1 ${BRIDGE_ADAPTER} \
                                --boot1 dvd \
                                --boot2 disk \
                                --boot3 none \
                                --boot4 none

vboxmanage modifyvm ${VMNAME}   --vrde on --vrdeport 5001

vboxmanage storagectl ${VMNAME} --name "$SATA_NAME" --add sata

vboxmanage createhd --filename $HD_FILENAME --size ${HDD_SIZE} --format VDI --variant Standard

vboxmanage storageattach ${VMNAME} --storagectl $SATA_NAME --port 1 --type hdd --medium $HD_FILENAME
vboxmanage storageattach ${VMNAME} --storagectl $SATA_NAME --port 0 --type dvddrive --medium $INSTALL_IMAGE

vboxmanage showvminfo ${VMNAME}

echo
echo "Your virtual machine has been created successfully."
echo
echo "Use the following command to start the vm:"
echo "  vboxmanage startvm ${VMNAME} --type headless"
echo
echo "To disable remote desktop access execute:"
echo "  vboxmanage modifyvm ${VMNAME} --vrde off"
