templates:
	ANSIBLE_FORCE_COLOR=true ansible-playbook templates.yml -u slammer

setup:
	ANSIBLE_FORCE_COLOR=true ansible-playbook setup.yml -u slammer -K | tee log
