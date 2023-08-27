# ~/dotfiles

My dotfiles. Please use your own.

## Prerequisite
brew.sh

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Install

```sh

git clone --depth 1 git@github.com:xslim/dotfiles.git ~/dotfiles
cd ~/dotfiles

brew bundle install -v


```

## Cheatsheet commands

### Installing ruby

```sh
brew update
brew install rbenv ruby-build

rbenv install --list
rbenv install 2.3.3
rbenv global 2.3.3

ruby -v
```

### Encryption

#### AES

```
# encrypt file.txt to file.enc using 256-bit AES in CBC mode
openssl enc -aes-256-cbc -salt -in file.txt -out file.enc

# the same, only the output is base64 encoded for, e.g., e-mail
openssl enc -aes-256-cbc -a -salt -in file.txt -out file.enc

# decrypt binary file.enc
openssl enc -d -aes-256-cbc -in file.enc -out file.txt

# decrypt base64-encoded version
openssl enc -d -aes-256-cbc -a -in file.enc -out file.txt


read -sp Password: OPENSSLPASS
OPENSSLPASS=$OPENSSLPASS openssl aes-256-cbc -a -d -in myfile.txt.enc -pass env:OPENSSLPASS | less
unset OPENSSLPASS
```

