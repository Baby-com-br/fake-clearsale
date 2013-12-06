#!/bin/bash

__project_dir=${1:-"$(cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd)"}
__rpm_specfile=${2:-"${__project_dir}/clerasale/scripts/build/clearsale.spec"}
__rpm_version=${3:-$(git for-each-ref refs/tags/* --format='%(tag)' --sort='taggerdate' | grep -v jenkins | tail -n1)}
__rpm_dist=${4:-"1"}
__rpmbuild_bin=$(which rpmbuild)

$__rpmbuild_bin -ba $__rpm_specfile --define "version $__rpm_version" --define "__project_dir $__project_dir" --define "dist $__rpm_dist"

