# gmod
repo for the gmod addon that adds lots of fun standalone stuff to gmod

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
