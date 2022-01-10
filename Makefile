templates:
	ANSIBLE_FORCE_COLOR=true ansible-playbook templates.yml -u slammer

setup:
	ansible-galaxy install -r requirements/setup.yml
	ANSIBLE_FORCE_COLOR=true ansible-playbook setup.yml -u slammer -K 2>&1 | tee log

