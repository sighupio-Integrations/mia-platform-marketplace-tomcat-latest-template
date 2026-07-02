#!/bin/sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a proprietary
# license that can be found in the LICENSE file.

set -e
set -o errexit -o nounset

find . \( -name '*.yaml' -o -name '*.yml' \) -type f -exec yq eval -P -I 2 -M -i {} \;
