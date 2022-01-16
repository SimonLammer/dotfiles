ANSIBLE = ANSIBLE_COW_SELECTION=random ANSIBLE_FORCE_COLOR=true ansible-playbook

templates:
	${ANSIBLE} templates.yml -u slammer

watch-templates:
	ls */**/*.j2 | entr make templates

setup:
	ansible-galaxy install -r requirements/setup.yml
	${ANSIBLE} setup.yml -u slammer -K 2>&1 | tee log

git-ssh:
	# Change origin to use ssh instead of https
	git remote rename origin https
	git remote get-url https | sed -E 's|.*://[^/]+/|git@github.com:|' | xargs git remote add origin 
	git push -u origin --all

