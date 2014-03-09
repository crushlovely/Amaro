#!/bin/bash

set -ue  # Bomb on uninitialized variables and non-zero exit statuses
set -o pipefail  # Pass the first non-zero exit status through a pipe

BOOTSTRAP_REPO="git@github.com:misterfifths/CrushBootstrap.git"
BOOTSTRAP_BRANCH=master

DEFAULT_PREFIX=CRBS
DEFAULT_PROJECT_NAME=CrushBootstrap
DEFAULT_FULLNAME=$(dscl . read /Users/`whoami` RealName | sed -n 's/^[\t ]*//;2p')

die() {
    echo $1
    exit 1
}

trim() {
    echo $1 | sed 's/^[\t ]*//;s/[\t ]*$//'
}

removeAllWhitespace() {
    echo $1 | sed 's/[\t ]*//g'
}

####################
### Gathering Info
####################

echo "Bootstrapping from branch $BOOTSTRAP_BRANCH of $BOOTSTRAP_REPO"
echo -e "Allons-y!\n"


#### Project Name
read -p "New project name: " ORIG_PROJECT_NAME
PROJECT_NAME=$(trim "$ORIG_PROJECT_NAME" | tr -s ' ' | tr ' ' '-')

[[ -z "$PROJECT_NAME" ]] && die "Ya gotta enter something!"
[[ $(dirname -- "$PROJECT_NAME") != "." ]] && die "No paths in your name, silly!"
[[ "$PROJECT_NAME" != "$ORIG_PROJECT_NAME" ]] && echo "  Fixed that for you. Using '$PROJECT_NAME'"
[[ -e "$PROJECT_NAME" ]] && die "A file already exists with that name!"
[[ "$PROJECT_NAME" == "$DEFAULT_PROJECT_NAME" ]] && die "Very funny."


### Prefix
isBlacklistedPrefix() {
    # http://www.fvue.nl/wiki/Bash:_Check_if_array_element_exists
    # This is not a complete list, but certainly hits the highpoints
    BAD_PREFIXES=( AB AC AD AL AU AV CA CB CF CG CI CL CM CV EA EK GC JS MA MC MF MK NK NS PK QL SC SK SL SS TW UI UT )
    
    local needle=$1
    shift
    
    set -- ${BAD_PREFIXES[@]}
    
    for prefix; do
        [[ $prefix == $needle ]] && return 0
    done
    return 1
}

read -p "Class prefix (2 or preferably 3 characters): " ORIG_PREFIX
PREFIX=$(removeAllWhitespace "$ORIG_PREFIX")

PREFIX=$(echo "$PREFIX" | tr '[:lower:]' '[:upper:]')
[[ "$PREFIX" != "$ORIG_PREFIX" ]] && echo "  Fixed that for you. Using '$PREFIX'"
[[ ${#PREFIX} < 2 ]] && die "Prefix is too short"
[[ ${#PREFIX} > 3 ]] && die "Prefix is too long. Ain't nobody got time to type that."
[[ $PREFIX =~ ^[A-Z][A-Z0-9]+$ ]] || die "Prefix is an invalid identifier"
isBlacklistedPrefix "$PREFIX" && die "That prefix is already used by Apple"
[[ "$PREFIX" == "$DEFAULT_PREFIX" ]] && die "Very funny."


### Full name
read -p "Your name (blank for $DEFAULT_FULLNAME): " FULLNAME
FULLNAME=$(trim "$FULLNAME")
if [[ -z "$FULLNAME" ]]; then
    FULLNAME=$DEFAULT_FULLNAME
    echo "  Using name $FULLNAME"
fi


echo -e "\nThus ends the interrogation."
echo -e "Pausing for 3 seconds in case you change your mind. Ctrl+C to abort."
sleep 3
echo -e "\n"



####################
### Down to business
####################

### Make the directory and bring in the repo

mkdir -- "$PROJECT_NAME"
cd -- "$PROJECT_NAME"

git init -q

# It's a shame we have to do this, really, but you can't do a squashed merge into an empty repo
touch README.md
git add README.md
git commit -q -m "[CrushBootstrap] Initial commit"

# Re: the nasty grep pipes below...
# grep returns 1 if it matched something, which set -x thinks is an error code.
# We could just pipe the whole shebang into true, but we want to know if the
# original git commands fail. So we have pipefail set globally, and we pipe
# into a shell where it's off, so we can have true eat grep's return. Ugh...

echo -n "Fetching repository... "
git remote add bootstrap "$BOOTSTRAP_REPO"
git fetch -q bootstrap "$BOOTSTRAP_BRANCH" 2>&1 | (set +o pipefail; grep -v 'warning: no common commits' | true)
echo "Done"

echo -n "Merging... "
git merge -q --squash "remotes/bootstrap/$BOOTSTRAP_BRANCH" 2>&1 | (set +o pipefail; grep -v 'Squash commit -- not updating HEAD|Automatic merge went well' | true)
git commit -q -m "[CrushBootstrap] Bootstrapping..."
echo "Done"


### File renames

renameProjectFile() {
    OLD_NAME="$1"
    NEW_NAME=$(echo "$1" | sed "s/$DEFAULT_PROJECT_NAME/$PROJECT_NAME/")
    git mv "$OLD_NAME" "$NEW_NAME"
}

renamePrefixedFile() {
    OLD_NAME="$1"
    NEW_NAME=$(echo "$1" | sed "s/^$DEFAULT_PREFIX/$PREFIX/")
    git mv "$OLD_NAME" "$NEW_NAME"
}

# Make these variables and functions available to our find -execs below
export -f renameProjectFile
export -f renamePrefixedFile
export DEFAULT_PROJECT_NAME PROJECT_NAME DEFAULT_PREFIX PREFIX FULLNAME

echo -n "Renaming files... "

# The -d is for a depth-first search, which ensures that files get renamed before their parent
# directories, which would break things, obviously.
# Re: the bash -c and $0 craziness, see http://stackoverflow.com/questions/4321456/find-exec-a-shell-function
find . -d -name "*$DEFAULT_PROJECT_NAME*" \( -type f -o -type d \)  -not \( -path './.git/*' -prune \) -execdir bash -c 'renameProjectFile "$0"' {} \;

if [[ "$PREFIX" != "$DEFAULT_PREFIX" ]]; then
    find . -type f -name "$DEFAULT_PREFIX*" -not \( -path './.git/*' -prune \) -execdir bash -c 'renamePrefixedFile "$0"' {} \;
fi

echo "Done"


### Content Changes

echo -n "Updating file contents... "

# Any reference to the project name or the prefix in all files:
find . -type f -not \( -path './.git/*' -prune \) -not -name Podfile -exec sed -i '' "s/$DEFAULT_PROJECT_NAME/$PROJECT_NAME/g;s/$DEFAULT_PREFIX/$PREFIX/g" {} +

# The 'Created by' line in the headers of code files
TODAY=$(date "+%m/%d/%y" | sed 's/^0//g;s/\/0/\//')  # sed nastiness is to remove leading zeroes from the date format
find . -type f \( -name "*.m" -o -name "*.h" \) -not \( -path './.git/*' -prune \) -exec sed -i '' "s#Created by .* on [0-9].*#Created by $FULLNAME on $TODAY#g" {} +

echo "Done"


### And commit!

echo -n "Committing... "
git add --all
git commit -q -m "[CrushBootstrap] Bootstrapped"
echo "Done"


####################
### Get Usable
####################

echo -n "Initializing submodules and CocoaPods... "

git submodule -q update --init --recursive
pod install --silent

git add Podfile.lock
git rm -q tiramisu.sh
git commit -q -m "[CrushBootstrap] Add Podfile.lock and remove init script"

echo "Done"


####################
### All Done
####################

echo -e "\nYou're all set!"
echo "Open $PROJECT_NAME/$PROJECT_NAME.xcworkspace to get started"
echo "And don't forget to add some prose to $PROJECT_NAME/README.md"
echo -e "\nXOXO -C&L"
