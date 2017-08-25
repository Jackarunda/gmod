# The Garry's Mod Additions Pack!

Huzzah!

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

You must have a github account, first. You can make one for free.

Ask Jackarunda in the Discord to be added as a collaborator (tell him your github name), and he will find your github account and add you. Then you go back to github into your profile and accept the collaboration invite. Being a collaborator is important because it will allow you to push/pull without needing to fork (which is more complicated). Note that being a collaborator is a trusted position, because you will have the ability to fuck up the repo (though if you do, Jackarunda will revoke your permissions and revert the changes).

If you're just edting the wiki file or the bugs file, you can just click the little edit buttons here on the github website to edit the files in-browser. Simple.

If, however, you're going to be moving/organizing content, then you need to have Git and know how to use it.
If you don't know anything about Git, then skip down and read the Git Noob section before continuing.

Clone this repo into your local gmod/addons directory. It will work just fine in gmod right from there, because this repo is orgnized exactly like a Gmod Legacy Addon. You can make changes directly right there, test them in gmod automatically (lua auto-reload ftw), and then push them up into git. Simple.

All the old addons can be found for download here:

FunGuns: https://www.dropbox.com/s/kxxbex74acct06r/FunGuns.7z?dl=0

Homicide: https://www.dropbox.com/s/qoegratt6amsxdl/Homicide.7z?dl=0

Defense Solutions: https://www.dropbox.com/s/ac8xg6tibl1gxfr/JIDS.7z?dl=0

OpSquads: https://www.dropbox.com/s/2k54kb7lq8ikw5o/OpSquads.7z?dl=0

Explosives: https://www.dropbox.com/s/8inhop8y3panltc/JIEX.7z?dl=0

SENTs: https://www.dropbox.com/s/7yc1gz3yw8oe88r/SENTs.7z?dl=0

BFS 2114: https://www.dropbox.com/s/qrpwohdcwypmbvr/JIBFS2114.7z?dl=0

Old BFS 2114 Wiki: http://jibfs.wikia.com/wiki/JIBFS_Wiki 

# Git Noob?

Git is a source control system, which is a system that allows multiple people to work together on a software project and not step on eachother's toes. Mostly. Github.com is a website, one of many, that hosts Git Repositories, which are like living containers for projects (contain all the files and assets and records etc).

Note that Git is a tech industry standard across the whole entire world and there are hundreds of thousands of millions of billions of blogs, tutorials, guides, documents, questions, answers, etc. etc. etc all over the internet that can help you with Git.

To work on git projects and do more than just edit text files in-browser, you need to have Git and Git Bash installed on your machine.
https://git-scm.com/downloads download and install all this from here

Note that Github recently made a GUI program for doing git operations, but IMO it's kinda pointless since the moment anything goes wrong you have to use the git bash command-line anyways, so might as well not bother. But you can use it if you wish.

Once git and git bash are installed on your machine, start a git bash window (probably from the start menu). Then you need to move the window's operating location into your gmod addons folder, so enter a command that looks something like this:

`cd "C:/Users/DickBagMcGee/Program Files (x86)/Steam/steamapps/common/garrysmod/garrysmod/addons"`

But obviously the path is unique for you. Note that when git installs they usually add shell extensions so you can right click or shift+right click and open a new git bash window anywhere in your Explorer, which is easier than CDing every time. Now clone this repo into a new folder into your addons folder by using the command:

`git clone https://github.com/Jackarunda/gmod.git gmod-additions-pack`

This will create the addon in your gmod. It'll take a while to download. Once this is done, you can literally play in gmod with the addon from right there. You can then make any changes you wish in that local folder, renaming things, adding things, editing files, etc. You only need to clone the repo once, ever, unless yours gets really badly fucked up and you need to delete and re-clone. But that should never happen.

Before you make any changes, always make sure to do the command: `git pull origin master`, because this will pull down the latest version of the repo into your local folder. You always want to be up-to-date.

When you've made changes you want to commit, do the following, in order:

1. make a new branch
`git checkout -b my_new_unique_branch_name`
usually you make a branch name that contains your name and something relating to the work you did

2. stage all the changes you've made
`git add .`

3. commit the changes to your new local branch you just made, with a comment
`git commit -m "fixing some bugs and adding more hookers"`

4. push your branch branch up to the repo
`git push origin my_new_unique_branch_name`

5. go to your browser, to the github repo page, and click the pull request button for the branch you just made

6. tell jackarunda about it in discord. We'll look at it, maybe fix a few things, and merge it into the master branch. All done.

7. then you should go back locally and `git checkout master` and then `git pull origin master` to get the latest content right from master. Then you can make more changes and start from step 1.

For more complicated operations regarding git, you can consult the wealth of information on the internet and/or ask jackarunda.

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
