#!/bin/python3

import logging
import os
import yaml
from jinja2 import Environment, FileSystemLoader
from jinja2_ansible_filters import AnsibleCoreFiltersExtension
from glob import glob

from pdb import set_trace as st


LOGLEVEL_DEFAULT = 'INFO' # can be overwritten via environment variable 'LOGLEVEL'
TEMPLATE_EXTENSION = '.j2'


LOGGER = logging.getLogger(__name__)
logging.basicConfig(format="[%(asctime)s %(levelname)8s] %(message)s   (%(funcName)s@%(filename)s:%(lineno)s)")
LOGGER.setLevel(level=os.getenv('LOGLEVEL', LOGLEVEL_DEFAULT).upper())

# TODO:
# - Cache file hashsums / modification timestamps & don't process unless changed

def main(directory: str) -> None:
  LOGGER.info(f"Starting template renderer for directory {directory}")
  environment = create_template_environment(directory)
  variables = {}

  for folder, variable_file_pattern in (
    ('vars', '*.yml'),
    ('data', 'vars.yml'),
  ):
    LOGGER.info(f"Loading simple variables in '{folder}'")

    files = (
      f
      for pattern in (
        f'{folder}/{variable_file_pattern}',
        f'{folder}/**/{variable_file_pattern}',
      )
      for f in glob(pattern) if not os.path.isfile(f"{f}{TEMPLATE_EXTENSION}")
    )
    if files:
      variables = merge_dicts(
        variables,
        load_variables(files),
      )

    LOGGER.info(f"Rendering templated variables in '{folder}'")
    files = (
      f
      for pattern in (
        f'{folder}/{variable_file_pattern}{TEMPLATE_EXTENSION}',
        f'{folder}/**/{variable_file_pattern}{TEMPLATE_EXTENSION}',
      )
      for f in glob(pattern)
    )
    if files:
      render_templates(environment, files, variables)
      LOGGER.info(f"Loading templated variables in '{folder}'")
      variables = merge_dicts(
        variables,
        load_variables(f[:-len(TEMPLATE_EXTENSION)] for f in files),
      )

  exit(1)
  LOGGER.info(f"Rendering templates")
  files = (f for f in glob(f'data/**/*{TEMPLATE_EXTENSION}') if not f.endswith(f'yml{TEMPLATE_EXTENSION}'))
  if files:
    render_templates(environment, files, variables)

def create_template_environment(directory: str) -> Environment:
  return Environment(
    #autoescape=False,
    extensions=[AnsibleCoreFiltersExtension],
    loader=FileSystemLoader(directory),
    trim_blocks=True,
  )

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
  for f in files:
    environment \
      .get_template(f) \
      .stream(variables) \
      .dump(f[:-len(TEMPLATE_EXTENSION)])


if __name__ == '__main__':
  directory = os.path.dirname(os.path.abspath(__file__))
  main(directory)

