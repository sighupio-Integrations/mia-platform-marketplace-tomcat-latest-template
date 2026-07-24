#!/bin/sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a proprietary
# license that can be found in the LICENSE file.

set -e
set -o errexit -o nounset

IGNORE_PATHS='.git/,.github/,.vscode/,.idea/'

file-cr --text --ignore "${IGNORE_PATHS}" --path .
file-crlf --text --ignore "${IGNORE_PATHS}" --path .
file-trailing-single-newline --text --ignore "${IGNORE_PATHS}" --path .
file-trailing-space --text --ignore "${IGNORE_PATHS}" --path .
file-utf8 --text --ignore "${IGNORE_PATHS}" --path .
file-utf8-bom --text --ignore "${IGNORE_PATHS}" --path .
