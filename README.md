# dotfiles

![with-bash](resources/bash.png)

---

My dotfiles, based on [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) ([LICENSE](LICENSE-MIT.txt)).

## Installation

> Warning: If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. **Use at your own risk!**

### Using Git and the `bootstrap.sh` script

You can clone the repository wherever you want. (I like to keep it in `~/Code/projects/shell/dotfiles`.) The `bootstrap.sh` will pull in the latest version and copy the files to your home folder.

```bash
git clone https://github.com/rayyh/dotfiles.git && cd dotfiles && source bootstrap.sh
```

To update, `cd` into your local dotfiles repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

### Git-free install

```bash
cd; curl -#L https://github.com/rayyh/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh,LICENSE,LICENSE_MIT.txt,licenses,brew.sh,resources,.zshrc}
```

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing takes place.

```bash
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
```

### Add custom commands without creating a new fork

f `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
GIT_AUTHOR_NAME="rayyh"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="rayyounghong@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

### Default mirrors - for developers living in china's mainland

```bash
# set mirrors
set_brew_mirror
set_composer_mirror
set_npm_mirror
set_yarn_mirror
# reset mirrors
reset_brew_mirror
reset_composer_mirror
reset_npm_mirror
reset_yarn_mirror
```

> NOTE: `pypi` mirror was configured in `.pip/pip.conf` file, if you want to reset `pypi` mirror, just delete the whole `.pip` folder.

### `.vimrc` ?

I strongly suggest using [amix/vimrc](https://github.com/amix/vimrc). You can use `updateVimrc` to update this repo.

To solve the lacking of `requests` package problem, try below commands.

```bash
# python2
sudo easy_install pip
pip install --user requests

# python3
pip3 install --user requests
```

## Special Thanks

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - [LICENSE](licenses/mathiasbynens_dotfiles_mit)
- [natelandau/.bash_profile](https://gist.github.com/natelandau/10654137)

## License

This project is open-source software licensed under the [MIT LICENSE](LICENSE).
