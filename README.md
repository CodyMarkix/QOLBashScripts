# Quality of Life bash scripts

These are just some bash scripts I wrote for myself to make my life a bit easier. I also decided to write them in bash as a challenge and to learn more about bash.

You can use the scripts as well if you want.

Perhaps I'll be adding some more here soon.

## Current list of scripts and what they do:

- toggletouchpad - Toggles the touchpad
- vpnmanager - A CLI manager for VPNs

## "Installation" process

Download this repository.

```bash
git clone https://github.com/CodyMarkix/QOLBashScripts
```

Then copy the path to the folder (including the folder!) and add it to path in your .bash/zsh/fish/whateverrc using your favorite editor.

```bash
export PATH="$PATH:/path/to/the/cloned/repo"
```

Open a terminal and verify that you have done it successfully by doing:

```bash
echo $PATH
```

If you see the path to the cloned repo, well done!

DEBs / PKGBUILDs / RPMs on my to-do list!

## To-do list

- [x] Add support for more desktop environments in `toggletouchpad`
- [ ] Create DEBs / PKGBUILDs / RPMs
- [ ] Add automatic updates (Optional updates of course!)
