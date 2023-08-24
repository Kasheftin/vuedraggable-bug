#!/bin/bash
echo "Vue Build Started"
npm i
npm run build
echo "Vue Build Completed"

git checkout --orphan gh-pages
git --work-tree dist add --all
git --work-tree dist commit -m gh-pages
git push origin HEAD:gh-pages --force

rm -rf dist
git checkout -f master
git branch -D gh-pages
