#!/bin/python3

"""
Renders jinja2 templates in the context of variables loaded from yaml files.
It follows these steps:
01. Load variable files <directory>/vars/*.yml
02. Load variable files <directory>/vars/**/*.yml
03. Render templated variable files <directory>/vars/*.yml.j2
04. Render templated variable files <directory>/vars/**/*.yml.j2
05. Load just rendered variable files
06. Load variable files <directory>/data/vars.yml
07. Load variable files <directory>/data/**/vars.yml
08. Render templated variable files <directory>/data/vars.yml.j2
09. Render templated variable files <directory>/data/**/vars.yml.j2
10. Load just rendered variable files
11. Render template files <directory>/data/**/*.j2 (excluding templated variable files).
"""

LOGLEVEL_DEFAULT = 'INFO' # can be overwritten via environment variable 'LOGLEVEL'
TEMPLATE_EXTENSION = '.j2'


import difflib
import logging
import os
import shutil
import yaml
from jinja2 import Environment, FileSystemLoader
from jinja2_ansible_filters import AnsibleCoreFiltersExtension
from glob import glob
from tempfile import TemporaryDirectory


LOGGER = logging.getLogger(__name__)
logging.basicConfig(format="[%(asctime)s %(levelname)8s] %(message)s   (L%(lineno)s)")
LOGGER.setLevel(level=os.getenv('LOGLEVEL', LOGLEVEL_DEFAULT).upper())

CONFIG = None

def main(directory) -> None:
  LOGGER.info(f"Starting template renderer for directory '{os.path.abspath(directory)}'")
  environment = create_template_environment(directory)
  variables = {}

  for folder, variable_file_pattern in (
    ('vars', '*.yml'),
    ('data', 'vars.yml'),
  ):
    LOGGER.info(f"Loading simple variable files in '{folder}'.")
    files = [
      f
      for pattern in (
        f'{folder}/{variable_file_pattern}',
        f'{folder}/**/{variable_file_pattern}',
      )
      for f in glob(pattern) if not os.path.isfile(f"{f}{TEMPLATE_EXTENSION}")
    ]
    if files:
      variables = merge_dicts(
        variables,
        load_variables(files),
      )
    else:
      LOGGER.info(f"No simple variable files found in '{folder}'.")

    files = [
      f
      for pattern in (
        f'{folder}/{variable_file_pattern}{TEMPLATE_EXTENSION}',
        f'{folder}/**/{variable_file_pattern}{TEMPLATE_EXTENSION}',
      )
      for f in glob(pattern)
    ]
    if files:
      LOGGER.info(f"Rendering templated variable files in '{folder}'")
      render_templates(environment, files, variables)
      LOGGER.info(f"Loading templated variable files in '{folder}'")
      variables = merge_dicts(
        variables,
        load_variables([f[:-len(TEMPLATE_EXTENSION)] for f in files]),
      )
    else:
      LOGGER.info(f"No templated variable files found in '{folder}'.")

  LOGGER.info(f"Rendering templates")
  files = (f for f in glob(f'data/**/*{TEMPLATE_EXTENSION}') if not f.endswith(f'yml{TEMPLATE_EXTENSION}'))
  if files:
    render_templates(environment, files, variables)

def create_template_environment(directory: str) -> Environment:
  os.chdir(directory)
  env = Environment(
    autoescape=False,
    extensions=[AnsibleCoreFiltersExtension],
    loader=FileSystemLoader(
      os.path.dirname('.')
    ),
    trim_blocks=True,
  )
  return env

def load_variable_file(yaml_file: str) -> dict:
  LOGGER.debug(f"Loading variable file '{yaml_file}'")
  with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) # TODO: cache?
    if type(data) is not dict:
      msg = f"The variable file '{yaml_file}' did not load as a dictionary."
      raise RuntimeError(msg)
    return data

def load_variables(files: list[str]) -> dict:
  if type(files) is not list:
    files = list(files)
  LOGGER.info(f"Loading variables from files {files}")
  return merge_dicts(*map(load_variable_file, files))

def merge_dicts(*dicts: list[dict]) -> dict:
  if not dicts:
    return dict()
  elif len(dicts) == 1:
    return dicts[0]
  elif len(dicts) == 2:
    return dict(**dicts[0], **dicts[1])
  else:
    pivot = len(dicts) // 2
    return merge_dicts(merge_dicts(*dicts[:pivot]), merge_dicts(*dicts[pivot:]))

def render_templates(environment: Environment, files: list[str], variables: dict) -> None:
  if type(files) is not list:
    files = list(files)
  LOGGER.info(f"Rendering templates {files}")
  with TemporaryDirectory() as tmpdir:
    for f in files:
      target = f[:-len(TEMPLATE_EXTENSION)]
      target_tmp = os.path.join(tmpdir, target.replace('/', '\x1a'))
      LOGGER.debug(f"Rendering template '{f}' to '{target_tmp}'")
      environment \
        .get_template(f) \
        .stream(variables) \
        .dump(target_tmp)
      if CONFIG.diff:
        with open(target, 'r') as render_old:
          with open(target_tmp, 'r') as render_new:
            diff = difflib.context_diff(
              render_old.readlines(),
              render_new.readlines(),
              fromfile=target,
            )
            print(''.join(diff), end='')
      if not CONFIG.dry_run:
        shutil.copystat(target, target_tmp)
        shutil.move(target_tmp, target)


def parse_cli_config():
  import argparse
  parser = argparse.ArgumentParser(
    description="Renders templated files (marked with '.j2' extension)",
    epilog=__doc__,
    formatter_class=argparse.RawTextHelpFormatter,
  )
  parser.add_argument(
    'directory',
    help="Root directory to search for templates in.",
    nargs='?',
    default=os.getcwd(),
  )
  parser.add_argument(
    '--diff',
    help="Show differences between old and new rendered templates.",
    action='store_true',
  )
  parser.add_argument(
    '--dry-run',
    help="Don't actually render the templates. (Useful in combination with --diff.)",
    action='store_true',
  )
  return parser.parse_args()

if __name__ == '__main__':
  CONFIG = parse_cli_config()
  main(CONFIG.directory)

