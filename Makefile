ANSIBLE = ANSIBLE_COW_SELECTION=random ANSIBLE_FORCE_COLOR=true ansible-playbook
#ANSIBLE = ANSIBLE_NOCOWS=true ANSIBLE_FORCE_COLOR=true ansible-playbook

templates:
	${ANSIBLE} templates.yml -u slammer

templates-check:
	#ANSIBLE_NOCOWS=true ansible-playbook templates.yml -u slammer --check | grep -i play\ recap -A1 | tail -n 1 | sed -E 's/.*changed=([0-9]+).*/\1/'
	changes=`ANSIBLE_NOCOWS=true ansible-playbook templates.yml -u slammer --check | grep -i play\ recap -A1 | tail -n 1 | sed -E 's/.*changed=([0-9]+).*/\1/'`; \
	if [ "$$changes" -eq "0" ]; then \
		echo All templates rendered correctly. ; \
	else \
		echo $$changes template\(s\) have not been rendered. \(Use \`make templates\` to render templates.\) ; \
		exit $$changes; \
	fi

watch-templates:
	ls */**/*.j2 | entr make templates

setup:
	if ! command -v ansible-galaxy -h &>/dev/null; then\
		sudo apt-get -y install ansible;\
	fi
	ansible-galaxy collection install -r requirements/setup.yml
	ansible-galaxy install -r requirements/setup.yml
	${ANSIBLE} setup.yml -u slammer -K 2>&1 | tee log

xfce:
	${ANSIBLE} xfce.yml -u slammer


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

