#!/bin/bash
#
# usage: rails_models_to_ecto_models app/models outdir

rm -rf $2
mkdir -p $2
cp -r $1 $2
cd $2/models

for src in $(find . -name '*.rb') ; do
    dest=$(echo $src | sed -e 's/\.rb$/.ex/')
    mv $src $dest
done

for src in $(find . -name '*.ex') ; do
    cat $src | ruby -p -e 'gsub(/^(class|module)(.*)/) {"defmodule#{$1} do"}' > $src.bak
    mv $src.bak $src
done
