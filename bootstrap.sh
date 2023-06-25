#!/bin/bash

localmode=false
repo="macos-setup"

# is repo? 
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # if repo, what is repo?
    getrepo=$(basename "$(git rev-parse --show-toplevel)")

    # is our repo???? :o
    if [ "$getrepo" = "$repo" ]; then
        localmode=true
        echo "[debug] Running in local mode, will not pull git repo."
    fi
fi

# for later idk
#if [ "$localmode" = false ]; then
#    echo "weewoo not local mode adjsfnljd"
#fi


# l33t titlezzz (let me have a little fun please)
ascii_title="                                              
                        __                               
                       /\_\/ ()                          
  _  _  _    __,   __ |    | /\    ,   _ _|_          _  
 / |/ |/ |  /  |  /   |    |/  \  / \_|/  |  |   |  |/ \_
   |  |  |_/\_/|_/\___/\__//(__/   \/ |__/|_/ \_/|_/|__/ 
                                                   /|    
                                                   \|
"

title() {
    local pink="\033[95m"
    local resetc="\033[0m"
    echo -e "${pink}$ascii_title${resetc}"
}

title

echo "Running Locally?: $localmode"
echo "Welcome to macos-setup"
echo "Please note this is only required on new installations, if you've ran this script once, you don't need to run it again."
echo "Running this script will install macOS CLI tools, as well as Rosetta, and it will assume you have read and agreed to the terms of use."
read -p "Run setup? (y/n): " choice

if [[ $choice != "y" ]]; then
    echo "Exiting..."
    exit 0
fi

echo "Installing macOS CLI tools - You may be prompted for your password/fingerprint, and to agree to the terms and conditions."
xcode-select --install

echo "Installing Rosetta - You may be prompted for your password/fingerprint."
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

# setup pip temporially
# this can be improved in the future by somehow detecting 
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
sudo pip3 install --upgrade pip
pip3 install ansible

# pull down the playbook if not running in "localmode" == from the git repo already
if [ "$localmode" = true ]; then
    echo "[debug] Running in local mode, will not pull git repo."
else
    mkdir -p ~/.macossetuptemp
    cd ~/.macossetuptemp
    git clone https://github.com/rainyskye/macos-setup.git
    cd macos-setup
fi

# grab ansible-galaxy requirements and run ansible playbooks
ansible-galaxy install -r requirements.yml
ansible-playbook main.yml --ask-become-pass

echo "Complete!"
exit 0
