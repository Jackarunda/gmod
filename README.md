# The Garry's Mod Additions Pack!

Ha-HA, the fun has been DOUBLED!

# Contributing

If you think you can help, let Jackarunda know in the gmod Discord.

# Setup for Contribution

You must have a github account, first. You can make one for free.

Ask Jackarunda in the Discord to be added as a collaborator (tell him your github name), and he will find your github account and add you. Then you go back to github into your profile and accept the collaboration invite. Being a collaborator is important because it will allow you to push/pull without needing to fork (which is more complicated). Note that being a collaborator is a trusted position, because you will have the ability to mess up the repo (though if you do, Jackarunda will revoke your permissions and revert the changes).

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

`git clone https://github.com/Jackarunda/gmod.git jmod`

This will create the addon in your gmod. It'll take a while to download. Once this is done, you can literally play in gmod with the addon from right there. You can then make any changes you wish in that local folder, renaming things, adding things, editing files, etc. You only need to clone the repo once, ever, unless yours gets really badly messed up and you need to delete and re-clone. But that should never happen.

Before you make any changes, always make sure to do the command: `git pull origin master`, because this will pull down the latest version of the repo into your local folder. You always want to be up-to-date.

When you've made changes you want to commit, do the following, in order:

1. make a new branch with 
`git checkout -b my_new_unique_branch_name`
usually you make a branch name that contains your name and something relating to the work you did

2. stage all the changes you've made with 
`git add .`

3. commit the changes to your new local branch you just made, with a comment, by entering 
`git commit -m "fixing some bugs and adding more hookers"`

4. push your branch up to the repo with 
`git push origin my_new_unique_branch_name`

5. go to your browser, to the github repo page, and click the pull request button for the branch you just made

6. tell jackarunda about it in discord. We'll look at it, maybe fix a few things, and merge it into the master branch. All done.

7. then you should go back locally and `git checkout master` and then `git pull origin master` to get the latest content right from master. Then you can make more changes and start from step 1.

For more complicated operations regarding git, you can consult the wealth of information on the internet and/or ask jackarunda.

# ToDo:

There's a lot more EZ content to be made. Details are typically found in discussions in the discord server.

# Bugs

If you find a bug, put it in the bugs.txt file here or tell Jackarunda about it in the gmod discord channel.
