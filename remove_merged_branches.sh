#!/bin/bash
current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
if [ "$current_branch" != "master" ]; then
  echo "WARNING: You are on branch $current_branch, NOT master. If you continue you can delete branches not merged in master branch"
fi
echo "Fetching merged branches..."
git remote prune origin
remote_branches=$(git branch -r --merged | grep -v '/master$' | grep -v "/$current_branch$")
local_branches=$(git branch --merged | grep -v 'master$' | grep -v "$current_branch$")
if [ -z "$remote_branches" ] && [ -z "$local_branches" ]; then
  echo "No existing branches have been merged into $current_branch."
else
  echo "The following branches have been merged into $current_branch and could be removed:"
  if [ -n "$remote_branches" ]; then
    echo "Remote_branches:"
    echo "$remote_branches"
  fi
  if [ -n "$local_branches" ]; then
    echo "Local branches:"
    echo "$local_branches"
  fi
  echo "###################"
  echo "pre and development will not be deleted"
  read -p "Select branches to remove (upperCase)? ((L)ocal branches | (R)emote branches | (A)ll branches | (C)ancel ): " choice
  echo $choice
  if [ "$choice" == "A" ]; then
    git branch -d `git branch --merged | grep -v 'master$' | grep -v "development" | grep -v "pre" | grep -v "$current_branch$" | sed 's/origin\///g' | tr -d '\n'`
    git push origin `git branch -r --merged | grep -v '/master$' | grep -v "/$current_branch$" | grep -v "development" | grep -v "pre" | sed 's/origin\//:/g' | tr -d '\n'`
    echo "Origin and Local branches removed."
  elif [ "$choice" == "L" ]; then
     git branch -d `git branch --merged | grep -v 'master$' | grep -v "development" | grep -v "pre" | grep -v "$current_branch$" | sed 's/origin\///g' | tr -d '\n'`
     echo "Local branches removed."
  elif [ "$choice" == "R" ]; then
       git push origin `git branch -r --merged | grep -v '/master$' | grep -v "/$current_branch$" | grep -v "development" | grep -v "pre" | sed 's/origin\//:/g' | tr -d '\n'`
       echo "Remote branches removed."
  else
    echo "No branches removed."
  fi

fi

   
