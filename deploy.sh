#! /bin/sh

rake generate
rake deploy
git add .
EDITOR=vim git commit
git push origin source
