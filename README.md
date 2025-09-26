#

## Setup
* Clone this repository
* Install a font (TODO specify which fonts work)
`brew install --cask font-hack-nerd-font`
Choose the font in iterm settings

### Tmux
```
cd ~/.config
ln -s /path/to/cloned/repository/tmux tmux
```

Run `tmux`
`ctrl-b[prefix] I`

### nvim
Install nvim

```
cd ~/.config
ln -s /path/to/cloned/repository/nvim nvim
```

#### Install lua-5.1 and luarocks:
1. Remove existing lua installation
2. Install lua-5.1 from source (download and extract archive,`make` `sudo make install`)
3. Install luarocks from source (download and extract archive, `./configure --with-lua-include=/usr/local/include --with-lua-version=5.1`, `make`, `sudo make install` )

Run `:checkhealth` in nvim - ensure luarocks and lua are okay!


Run `:UpdateRemotePlugins`
