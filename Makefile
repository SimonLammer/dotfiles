USER := $(shell whoami)
ANSIBLE_PLAYBOOK_ENV = ANSIBLE_COW_SELECTION=random ANSIBLE_FORCE_COLOR=true
#ANSIBLE_PLAYBOOK_ENV = ANSIBLE_NOCOWS=true ANSIBLE_FORCE_COLOR=true

PYTHON3 = python


ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif
ifndef XDG_CACHE_HOME
	XDG_CACHE_HOME := $(HOME)/.cache
endif

# https://wiki.archlinux.org/title/XDG_Base_Directory
ANSIBLE_XDG_ENV := ANSIBLE_HOME="$(XDG_CONFIG_HOME)/ansible" ANSIBLE_CONFIG="$(XDG_CONFIG_HOME)/ansible.cfg" ANSIBLE_GALAXY_CACHE_DIR="$(XDG_CACHE_HOME)/ansible/galaxy_cache"
#ANSIBLE_LOCAL_TEMP="$(XDG_CACHE_HOME)/ansible/tmp"
ANSIBLE-PLAYBOOK = env $(ANSIBLE_XDG_ENV) $(ANSIBLE_PLAYBOOK_ENV) ansible-playbook
ANSIBLE-GALAXY = env $(ANSIBLE_XDG_ENV) $(ANSIBLE_PLAYBOOK_ENV) ansible-galaxy


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

setup: install-ansible
	$(ANSIBLE-GALAXY) collection install -r requirements/setup.yml
	$(ANSIBLE-GALAXY) install -r requirements/setup.yml
	$(ANSIBLE-PLAYBOOK) setup.yml -u ${USER} --ask-become-pass 2>&1 | tee log

test: install-ansible
	$(ANSIBLE-PLAYBOOK) test.yml -u ${USER}

xfce: install-ansible
	${ANSIBLE-PLAYBOOK} xfce.yml -u ${USER}

install-ansible:
	if [ -z "`command -v ansible`" ]; then \
		if [ -x "`command -v apt-get`" ]; then \
			sudo apt-get -y install ansible; \
		elif [ -x "`command -v dnf`" ]; then \
			sudo dnf install -y ansible; \
		elif [ -x "`command -v zypper`" ]; then \
			sudo zypper install -y ansible; \
		else \
			exit 1; \
		fi \
	fi


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

