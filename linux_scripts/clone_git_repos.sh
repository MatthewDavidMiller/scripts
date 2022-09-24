#!/bin/bash

source git_repos.sh

for i in "${git_repos[@]}"; do
    git clone "${url}/${i}.git"
done
