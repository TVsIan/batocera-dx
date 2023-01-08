################################################################################
#
# python-i3ipc
#
################################################################################

PYTHON_I3IPC_VERSION = v2.2.1
PYTHON_I3IPC_SITE = $(call github,altdesktop,i3ipc-python,$(PYTHON_I3IPC_VERSION))
PYTHON_I3IPC_SETUP_TYPE = setuptools
PYTHON_I3IPC_LICENSE = BSD-3-Clause
PYTHON_I3IPC_LICENSE_FILES = LICENSE

$(eval $(python-package))