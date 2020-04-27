#!/usr/bin/env python3

'''
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
'''
import os
import sys
import glob
import re

usb_dev_pattern = ['sd.*']
usb_part_pattern = ['sd.[1-9]*']
sd_dev_pattern = ['mmcblk*']
sd_part_pattern = ['mmcblk.p[1-9]*']

def dev_size(device):
    path = '/sys/block/'
    num_sectors = open(path + device + '/size').read().rstrip('\n')
    sector_size = open(path + device + '/queue/hw_sector_size').read().rstrip('\n')
    return (int(num_sectors)*int(sector_size))

def usb_devs():
    devices = []
    for device in glob.glob('/sys/block/*'):
        for pattern in usb_dev_pattern:
            if re.compile(pattern).match(os.path.basename(device)):
                devices.append(os.path.basename(device))
    return devices

def usb_partitions():
    partitions = []
    for device in usb_devs():
        for partition in glob.glob('/sys/block/' + str(device) + '/*'):
            for pattern in usb_part_pattern:
                if re.compile(pattern).match(os.path.basename(partition)):
                    partitions.append(os.path.basename(partition))
    return partitions

def usb_part_size(partition):
    try:
        path = '/sys/block/'
        device = partition[:-1]
        num_sectors = open(path + device + '/' + partition + '/size').read().rstrip('\n')
        sector_size = open(path + device + '/queue/hw_sector_size').read().rstrip('\n')
    except TypeError:
        print("Not enough USB devices available")
        sys.exit(1)
    else:
        return (int(num_sectors)*int(sector_size))

def uuid_table():
    device_table = os.popen('blkid').read().splitlines()
    devices = {}
    for device in device_table:
        dev = device.split(":")[0].split("/")[2]
        uuid = device.split('"')[1]
        devices[dev] = uuid
    return devices

def get_uuid(device):
    uuids = uuid_table()
    return str(uuids[device])

def usb_partition_table():
    table = {}
    for partition in usb_partitions():
        table[partition] = int(usb_part_size(partition))
    return table

def main():
    print('USB Configuration')
    if len(usb_devs()) == 1:
        first_part = dev_size('sda') / (1000*1000)
        print('Size: ' + str(first_part))
        prune_setting = int(first_part / 2)
        partitions = usb_partitions()
        if first_part < 512000:
            print("Pruning the config")
            os.system('/bin/sed -i "s/prune=550/prune=' + str(prune_setting) + '/g;" bitcoin/bitcoin.conf')
        else:
            print("Switching off pruning")
            os.system('/bin/sed -i "s/prune=550/#prune=550/g;" bitcoin/bitcoin.conf')
            os.system('/bin/sed -i "s/#txindex=1/txindex=1/g;" bitcoin/bitcoin.conf')

        os.system('mkdir -p /home/lncm/tempmount1')
        print('Initializing filesystem')
        os.system('/sbin/mkfs.ext4 -F /dev/sda1')
        first_partition_uuid = get_uuid('sda1')
        os.system('/bin/mount -t ext4 /dev/sda1 /home/lncm/tempmount1')
        print('Setup bitcoin conf')
        os.system('/bin/cp /home/lncm/bitcoin/bitcoin.conf /home/lncm/tempmount1')
        print('Setup filesystem permissions')
        os.system('/bin/chown -R 1000.1000 /home/lncm/tempmount1')
        os.system('/bin/umount /home/lncm/tempmount1')
        print('Remove bitcoin.conf')
        os.system('/bin/rm -fr /home/lncm/bitcoin/bitcoin.conf')
        print('Remount new directory')
        os.system('mount -t ext4 /dev/sda1 /home/lncm/bitcoin')
        print('Update /etc/fstab')
        os.system('echo "UUID=' + first_partition_uuid + ' /home/lncm/bitcoin ext4 defaults,noatime 0 0" > /etc/fstab')
        os.system('/bin/rm -fr /home/lncm/tempmount1')
    else:
        print('No drives or unexpected number of drives detected!')
if __name__ == '__main__':
    if os.geteuid() == 0:
        main()
    else:
        print("Must run as root")

