#!/bin/bash

# IMPORTANT
# Create a new user with sudo privileges:
# adduser username
# usermod -aG sudo username
# Copy ssh key: ssh-copy-id username@x.x.x.x
# Enable public key login 
# Disable root login and password auth in /etc/ssh/sshd_config 

# Variables:
GO_VERSION="go1.13.5.linux-amd64.tar.gz"

# Setup script
echo "------------------------------------------\n\n"
echo "Hello, $USER. Let's configure this system.\n\n"
echo "-------- SRB ----- setup.sh v0.2 ---------\n"

# Setup firewall
echo "Setup firewall ..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
echo "y" | sudo ufw enable
echo "Done."

# Update system
echo "Updating System ..."
sudo apt update;
sudo apt upgrade -y
sudo apt dist-upgrade -y
echo "Done."

# Clean system
echo "Clean up System ..."
sudo apt autoremove -y
sudo apt autoclean -y
sudo updatedb
echo "Done."

# Install dependencies
echo "Installing dependencies ..."
sudo apt install -y build-essential
sudo apt install -y jq
sudo apt install -y git
sudo apt install curl libcurl4-openssl-dev make zlib1g-dev gawk g++ gcc libreadline6-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config ruby ruby-bundler ruby-dev -y
echo "Done."

echo "Installing Z-Shell (Oh My Zsh) ..."
sudo apt install zsh -y
sudo apt install powerline fonts-powerline -y
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' .zshrc
sed -i 's/# ENABLE_CORRECTION/ENABLE_CORRECTION/g' .zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' .zshrc
zsh
chsh -s $(which zsh)
echo "Done."

# Setup Aliases ~/
echo "Setup Aliases ..."
echo 'alias webserver="python3 -m http.server 443"' >> ~/.zshrc
echo "Done."

# Create tools folder in ~/
echo "Creating tools folder ..."
mkdir ~/tools
echo "Done."

# Install Go
echo "Installing Golang ..."
wget "https://dl.google.com/go/$GO_VERSION"
tar -xvf $GO_VERSION
sudo mv go /usr/local
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
echo 'export GOROOT=/usr/local/go' >> ~/.zshrc
echo 'export GOPATH=$HOME/go'   >> ~/.zshrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.zshrc
rm $GO_VERSION
source ~/.zshrc
echo "Done."

# Installing tools
cd ~/tools/

# Install crtndstry
echo "Installing crtndstry"
git clone https://github.com/nahamsec/crtndstry.git
echo "Done."

# Install Amass
#echo "Installing Amass"
#export GO111MODULE=on
#go get -v -u github.com/OWASP/Amass/v3
#echo "Done."

echo "installing massdns"
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/massdns
make
cd ~/tools/
echo "done"

# Install Aquatone
echo "Installing aquatone ..."
go get github.com/michenriksen/aquatone
echo "Done."

# Install Chromium
echo "Installing chromium ..."
sudo snap install chromium
sudo cp /snap/bin/* /usr/bin
echo "Done."

# Install Dirsearch
echo "Installing dirsearch ..."
git clone https://github.com/maurosoria/dirsearch.git
echo "Done."

# Install ffuf
echo "Installing ffuf ..."
go get github.com/ffuf/ffuf
echo "Done."

# Install Gobuster
echo "Installing Gobuster ..."
go get github.com/OJ/gobuster
echo "Done."

# Install sqlmap
echo "Installing sqlmap ..."
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
echo "Done."

# Install knock.py
echo "Installing knock.py ..."
git clone https://github.com/guelfoweb/knock.git
echo "Done."

# Install httprobe
echo "Installing httprobe ..."
go get -u github.com/tomnomnom/httprobe 
cd ~/tools/
echo "Done."

# Install XSStrike
echo "Installing XSStrike .."
git clone https://github.com/s0md3v/XSStrike.git
echo "Done."

# Install JSParser
echo "Installing JSParser .."
git clone https://github.com/nahamsec/JSParser.git
cd JSParser*
sudo python setup.py install
cd ~/tools/
echo "Done."

# Install WPScan
echo "Installing wpscan ..."
git clone https://github.com/wpscanteam/wpscan.git
cd wpscan/
sudo gem install wpscan
wpscan --update
cd ~/tools/
echo "Done."

# Get Seclists
echo "Downloading Seclists"
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
##THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
cd ~/tools/
echo "Done."

echo "Would you like to install DNS Bind Server for Out-of-Band testing?"
PS1="Please select an option : "
options=("yes" "no")
select opt in "${options[@]}"; do
        case $opt in
                yes)
                        git clone https://github.com/JuxhinDB/OOB-Server.git
                        cd OOB-Server
                        echo "Enter your hostname: "
                        read domain
                        echo "Enter your server IP: "
                        read ip
                        setup $domain $ip
                        cd ~/tools/
                        rm -rf OOB-Server/
                        sudo ufw allow 53
                        echo "OOB DNS Bind Server installed."
                        break
                        ;;
                no)
                        echo "Ok."
                        break
                        ;;
                *)      echo "invalid option $REPLY";;
        esac
done

cd ~/
rm -rf SRB/

echo -e "\n\n\nDone! All tools are set up in ~/tools\n\n\n"