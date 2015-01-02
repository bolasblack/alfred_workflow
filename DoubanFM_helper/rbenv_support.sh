
export PATH=/usr/local/bin:$HOME/.rbenv/bin:$PATH
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

if hash rbenv 2>/dev/null; then
  eval "$(rbenv init -)"
fi
