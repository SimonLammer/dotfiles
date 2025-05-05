USER := $(shell whoami)
PYTHON3 := python
ifeq ($(shell test -d venv && echo $$?),0)
	PYTHON3 := . venv/bin/activate && ${PYTHON3}
endif

ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif
ifndef XDG_CACHE_HOME
	XDG_CACHE_HOME := $(HOME)/.cache
endif


templates:
	${PYTHON3} data/scripts/render_templates.py .

templates-check:
	changes=`LOGLEVEL=WARNING ${PYTHON3} data/scripts/render_templates.py . --diff --dry-run`; \
	if [ "$$changes" = "" ]; then \
		echo All templates rendered correctly. ; \
	else \
		echo Template\(s\) have not been rendered. \(Use \`make templates\` to render templates.\) ; \
		echo Changes:; \
		echo "$$changes"; \
		exit 1; \
	fi

watch-templates:
	find . \
			-name '*j2*' -o \
			-name 'vars/*.yml' -o \
			-name 'vars/**/*.yml' -o \
			-name 'data/vars.yml' -o \
			-name 'data/**/vars.yml' -o \
			-name 'render_templates.py' -o \
			-name 'Makefile' \
		| entr -c make templates

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
	git push -u origin --all

