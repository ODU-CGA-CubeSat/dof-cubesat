# !/usr/bin/env bash

# create build directory for generated artifacts, if none exists
if [ ! -r ./dist/linkml ]; then
    mkdir -p dist/linkml
fi

# copy linkml schemas to build directory
cp -r ./m30ml/src/linkml ./dist
cp ./src/linkml/* ./dist/linkml

# build script for generating unified schema definition
# for docker command usage, see https://hub.docker.com/r/linkml/linkml

clitool="gen-yaml"
cmdargs="dist/linkml/dof_datastructures.yaml --mergeimports"
cmd="$clitool $cmdargs"
dockercmd="podman run --rm -v $workdir:/work -w /work docker.io/linkml/linkml:1.5.6 $cmd"
condition="$clitool --help | grep 'Validate input and produce fully resolved yaml equivalent' > /dev/null"
dest="dist/dof.yaml"

if ! eval $condition; then
    eval $(echo $dockercmd) > $dest
else
    eval $cmd > $dest
fi

# remove imports to work around issue running gen-yaml
# for docker command usage, see https://github.com/mikefarah/yq#oneshot-use

clitool="yq"
cmdargs="'del(.imports)' -i dist/dof.yaml"
cmd="$clitool $cmdargs"
dockercmd="podman run --rm --user="root" -v $PWD:/workdir docker.io/mikefarah/yq $cmdargs"
condition="$clitool --help | grep 'yq is a portable command-line YAML processor' > /dev/null"

if ! eval $condition; then
    eval $dockercmd
else
    eval $cmd
fi

# run linkml linter on merged m30ml schema
# for docker command usage, see https://hub.docker.com/r/linkml/linkml
# continue execution on error for linkml-lint, as per https://stackoverflow.com/a/11231970

#clitool="linkml-lint"
#cmdargs="--format markdown dist/m30ml.yaml"
#cmd="$clitool $cmdargs"
#dockercmd="podman run --rm -v $PWD:/work -w /work docker.io/linkml/linkml:1.4.0 $cmd || true"
#condition="$clitool --help | grep 'Show this message and exit.' > /dev/null"
#dest="dist/linter-results.md"
#
#if ! eval $condition; then
#    eval $(echo $dockercmd) > $dest
#else
#    eval $cmd > $dest
#fi
