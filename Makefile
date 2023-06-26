USER := $(shell whoami)
ANSIBLE_PLAYBOOK_ENV = ANSIBLE_COW_SELECTION=random ANSIBLE_FORCE_COLOR=true
#ANSIBLE_PLAYBOOK_ENV = ANSIBLE_NOCOWS=true ANSIBLE_FORCE_COLOR=true


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


templates: install-ansible
	$(ANSIBLE-PLAYBOOK) templates.yml -u ${USER}

templates-check: install-ansible
	#ANSIBLE_NOCOWS=true ansible-playbook templates.yml -u ${USER} --check | grep -i play\ recap -A1 | tail -n 1 | sed -E 's/.*changed=([0-9]+).*/\1/'
	changes=`ANSIBLE_NOCOWS=true ansible-playbook templates.yml -u ${USER} --check | grep -i play\ recap -A1 | tail -n 1 | sed -E 's/.*changed=([0-9]+).*/\1/'`; \
	if [ "$$changes" -eq "0" ]; then \
		echo All templates rendered correctly. ; \
	else \
		echo $$changes template\(s\) have not been rendered. \(Use \`make templates\` to render templates.\) ; \
		exit $$changes; \
	fi

watch-templates:
	ls */**/*.j2 | entr make templates

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

