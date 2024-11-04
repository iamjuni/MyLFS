# MyLFS
It's a giant bash script that builds Linux From Scratch.

Pronounce it in whatever way seems best to you.

If you don't know what this is, or haven't built Linux From Scratch on your own before, you should go through the LFS [book](https://linuxfromscratch.org) before using this script.

# Roadmap
* Add support for the lfs 12.2 book (In progress)
* Clean up the source code and move critical directory making functions out of mylfs.sh into a new folder (started on branch called major-rewrite)
* Ask user for the systemd or sysvinit book before installation (not started yet)
* Create a python script which asks user for http/https Linux from scratch book , extracts commands and self sustains bash scripts, build orders, packages, patches and static files. (Started but development is stale, dont expect an ETA)

## Warning ##

It is not recommended to run this script on your daily machine (although, in essence, all it does is mount a .IMG file and build the LFS system in it). By ignoring this, you agree that some commands in this shell file can completely destroy your system with no chance of recovery! 
BE WARNED

## How to install
```
git clone https://github.com/TheKingKerellos/MyLFS.git
```
If ./mylfs.sh (or any other .sh file) returns;
```
root@root-debian:~/MyLFS$ sudo ./mylfs.sh 
sudo: ./mylfs.sh: command not found
```
Run:
```
cd MyLFS/
chmod +x mylfs.sh runqemu.sh
```


## How To Use
Basically, just run `sudo ./mylfs.sh --build-all` and then stare at your terminal for several hours. Maybe meditate on life or something while you wait. Or maybe clean your room or do your dishes finally. I don't know. Do whatever you want. Maybe by the end of the script, you'll realize why you love linux so much: you love it because it is *hard*. Just like going to the moon, god dammit.

```
$ sudo ./mylfs.sh --help

Welcome to MyLFS.

    WARNING: Most of the functionality in this script requires root privilages,
and involves the partitioning, mounting and unmounting of device files. Use at
your own risk.

    If you would like to build Linux From Scratch from beginning to end, just
run the script with the '--build-all' command. Otherwise, you can build LFS one step
at a time by using the various commands outlined below. Before building anything
however, you should be sure to run the script with '--check' to verify the
dependencies on your system. If you want to install the IMG file that this
script produces onto a storage device, you can specify '--install /dev/<devname>'
on the commandline. Be careful with that last one - it WILL destroy all partitions
on the device you specify.

    options:
        -v|--version            Print the LFS version this build is based on, then exit.

        -V|--verbose            The script will output more information where applicable
                                (careful what you wish for).

        -e|--check              Output LFS dependency version information, then exit.
                                It is recommended that you run this before proceeding
                                with the rest of the build.

        -b|--build-all          Run the entire script from beginning to end.

        -x|--extend             Pass in the path to a custom build extension. See the
                                'example_extension' directory for reference.

        -d|--download-packages  Download all packages into the 'packages' directory, then
                                exit.

        -i|--init               Create the .img file, partition it, setup basic directory
                                structure, then exit.

        -p|--start-phase
        -a|--start-package      Select a phase and optionally a package
                                within that phase to start building from.
                                These options are only available if the preceeding
                                phases have been completed. They should really only
                                be used when something broke during a build, and you
                                don't want to start from the beginning again.

        -o|--one-off            Only build the specified phase/package.

        -k|--kernel-config      Optional path to kernel config file to use during linux
                                build.

        -m|--mount
        -u|--umount             These options will mount or unmount the disk image to the
                                filesystem, and then exit the script immediately.
                                You should be sure to unmount prior to running any part of
                                the build, since the image will be automatically mounted
                                and then unmounted at the end.

        -n|--install            Specify the path to a block device on which to install the
                                fully built img file.

        -c|--clean              This will unmount and delete the image, and clear the
                                logs.

        -h|--help               Show this message.
```

## How It Works

The script builds LFS by completing the following steps:


1. Download package source code and save to the `./packages/` directory.


2. Create a 10 gigabyte IMG file called `lfs.img`. This will serve as a virtual hard drive on which to build LFS.


3. "Attach" the IMG file as a loop device using `losetup`. This way, the host machine can operate on the IMG file as if it were a physical storage device.


4. Partition the IMG file via the loop device we've created, put an ext4 filesystem on it, then add a basic directory structure and some config files (such as /boot/grub/grub.cfg etc).


5. Build initial cross compilation tools. This corresponds to chapter 5 in the LFS book.


6. Begin to build tools required for minimal chroot environment. (chapter 6)


7. Enter chroot environment, and build remaing tools needed to build the entire LFS system. (chapter 7)


8. Build the entire LFS system from within chroot envirnment, including the kernel, GRUB, and others. (chapter 8)


That's it.


## Examples
If something breaks over the course of the build, you can examine the build logs in the aptly named `logs` directory. If you discover the source of the breakage and manage to fix it, you can start the script up again from where you left off using the `--start-phase <phase-number>` and `--start-package <package-name>` commands.


For example, say the GRUB build in phase 4 broke:
```sh
sudo ./mylfs.sh --start-phase 4 --start-package grub
```
This will start the script up again at the phase 4 GRUB build, and continue on to the remaining packages.


Another example. Say you just changed your kernel config file a bit and need to recompile:
```sh
sudo ./mylfs.sh --start-phase 4 --start-package linux --one-off
```
The `--one-off` flag tells the script to exit once the starting package has been completed.


The real magic of MyLFS is that you can apply "extensions" to the script in order to automatically customize your LFS system.
```sh
sudo ./mylfs.sh --build-all --extend ./example_extension
```
Details on how extensions work can be found in `example_extension/README`.


If you want to poke around inside the image file without booting into it, you can simply use the `--mount` command like so:
```sh
sudo ./mylfs.sh --mount
```
This will mount the root partition of the IMG file under `./mnt/lfs` (i.e. not `/mnt` under the root directory). When you're done, you can unmount with the following:
```sh
sudo ./mylfs.sh --umount
```  

If you want to install the LFS IMG file onto a drive of some kind, use:
```sh
sudo ./mylfs.sh --install /dev/<devname>
```


Finally, to clean your workspace:
```sh
sudo ./mylfs.sh --clean
```
This will unmount the IMG file (if it is mounted), delete it, and delete the logs under `./logs/`. It will not delete the cached package archives under `./packages/`, but if you really want to do that you can easily `rm -f ./packages/*`.  


## Issues Booting
So far, the image is bootable using QEMU (see the [runqemu.sh](runqemu.sh) script) or on bare metal using a flash drive. I have not been able to boot it up on a VM yet.
The reason why it isn't bootable through a VM is due to the PARTUUID (run `blkid` on any linux system to see what it looks like) not being substituted to [boot/grub/grub.cfg](templates/boot__grub__grub.cfg) onto the newly installed drive. This is, I assume, due to the kernel not recognising the newly wiped and created drive so substituting the PARTUUID fails (as it is empty) and you are left with the "Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)" error. The only real solution for you is to pass on the --install flag and run install your fully built lfs as usual, but when you boot into the new GRUB bootloader, pass set root=(hdx,y) and root=/dev/<xxx> like below,
```
setparams "GNU/Linux, Linux 6.10.4-lfs-12.2" {
  set root=(hd0,msdos1)
  search --no-floppy --label LFSROOT --set=root
  linux   /boot/vmlinuz-6.10.4-lfs-12.2 rootwait root=/dev/sda1 ro
}
```
You should be able to go to the command line in grub and write `ls` to find out what your drive is, and for your partition, whatever you pass onto --install, e.g /dev/sda , /dev/sdb , write 1 directly after it just like the example and you should be good to go.
The reason why this script uses PARTUUID is because they have the advantage that they don't change if your reformat the partition with another filesystem versus /dev/sda and UUIDs, but I am experimenting with substituting hdx,y and /dev/<xxx> for the sake of booting. If you have the skills, I am asking for some help the install_image function to work with PARTUUIDs and make booting LFS efortless.

## Special thanks
* @[krglaws](https://github.com/krglaws) For creating the parent repository which allowed for this fork!
* @[Techlm77](https://github.com/Techlm77) Gave me permission, and most importantly, in mylfs.sh he had a really nice --chroot function which is usefull
