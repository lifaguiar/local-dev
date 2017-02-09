#!/bin/bash

if [ ! -f boxindex ]; then
   echo 'Box index not yet defined.'
   exit 1
fi

if [ -f protected ]; then
   echo 'Box already protected.'
   exit 0 
fi

vm="node$(cat index)"

uuid=$(vboxmanage showvminfo $vm | grep vmdk | awk '{print $NF}' | cut -d')' -f1)

vboxmanage encryptmedium $uuid --newpassword - --newpasswordid $vm --cipher "AES-XTS256-PLAIN64"

echo "Proceed to call vagrant up and type the given password. There is no password recovery, if you loose the password, the VM will be lost."

touch protected
