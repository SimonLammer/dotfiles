USER := $(shell whoami)


ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif
ifndef XDG_CACHE_HOME
	XDG_CACHE_HOME := $(HOME)/.cache
endif


symlinks: templates
	data/scripts/symlink_dotfiles.sh

setup: templates git-setup-hooks symlinks


_git-hook-pre_push:
	echo Checking templates...
	make -s templates-check

git-setup-hooks:
	echo "make -s _git-hook-pre_push 2>/dev/null" > .git/hooks/pre-push
	chmod +x .git/hooks/pre-push

git-ssh:
	# Change origin to use ssh instead of https
	git remote rename origin https
	git remote get-url https | sed -E 's|.*://[^/]+/|git@github.com:|' | xargs git remote add origin 
	git push -u origin --all # TODO: set-upstream instead

