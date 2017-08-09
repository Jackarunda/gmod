# The Plan

We're taking all of Jackarunda's past addons and resurrecting them into a single big community project to re-upload to the workshop.

Once most of the content is copied, converted and working, Jackarunda will split the content of this repo up and upload mutliple Workshop items so that everyone can enjoy this content once again and use it on their servers bug-free. Maintenance and additions will continue from there and Jackarunda will handle the workshop aspect of things. If you help as a playtester, you will be mentioned in the credits for the packs if you wish. If you help as a coder or file-folder organizer/converter in any way, you will be added as a co-publisher to the workshop items if you wish. This is a community project.

# Contributing

We don't really need hardcore functional programming to make this work. If we do, jackarunda will do it. What we really need right now is:

> move all of these files from X folder to Y folder

> combine the content of these files into one file and put it in Z folder

> take the content of this file and put it in a section of another file and delete this file

> see what resources are needed from these files and copy the resources into the new folder

> rename this file and then rename all usages of it in all the other files

> rename this sound file and then replace any usages of it in these files

> look through this folder for any large texture files, and if you find them, downsize them in GIMP or something and replace

> look throgh this folder for large sound files and if you find them, then convert them to MP3 in Audacity or something and replace

If you think you can help, let Jackarunda know in the gmod Discord.

# Setup

clone this repo into your gmod/addons directory. It will work just fine in gmod right from there. You can make changes directly. Simple

All the old addons can be found for download here:

FunGuns: https://www.dropbox.com/s/kxxbex74acct06r/FunGuns.7z?dl=0
Homicide: https://www.dropbox.com/s/qoegratt6amsxdl/Homicide.7z?dl=0
Defense Solutions: https://www.dropbox.com/s/ac8xg6tibl1gxfr/JIDS.7z?dl=0
OpSquads: https://www.dropbox.com/s/2k54kb7lq8ikw5o/OpSquads.7z?dl=0
Explosives: https://www.dropbox.com/s/8inhop8y3panltc/JIEX.7z?dl=0
SENTs: https://www.dropbox.com/s/7yc1gz3yw8oe88r/SENTs.7z?dl=0
BFS 2114: https://www.dropbox.com/s/qrpwohdcwypmbvr/JIBFS2114.7z?dl=0
Old BFS 2114 Wiki: http://jibfs.wikia.com/wiki/JIBFS_Wiki 

# ToDo:

Include content from all the previous addons.

OpSquads has been included already. Next on the list is JI Defense Solutions.

- download JIDS source from dropbox
- copy whatever entities/weapons you like from JIDS into this repo, along with all dependent other entities and effects
- convert all entities/weapons to single-file format if not already
- take the sounds from JIDS and copy them into this repo's sound folder (sound/snds_jack_gmod), then replace all instances of their use in the entity/weapon files
- copy all needed materials and textures from JIDS into respective folders in this repo, keeping the organization scheme the same and renaming if necessary (and replacing usage calls in code if necessary)
- do the same for models and particle effects

- test in gmod

Jackarunda will handle most of the fixing/optimizing of the code.

# Custom Additions

If you're a glua coder and want to add new features or items to the pack, let Jackarunda know and make a PR. Custom contributions to the pack are welcome if they are of a quality and style similar to or surpassing that of existing content.

# Bugs

If you find a bug, put it in the bugs.txt file here or tell Jackarunda about it in the gmod channel.
