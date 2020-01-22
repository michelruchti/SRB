#!/bin/bash

sudo -v

# Variables:
COLOR="\e[95m" 
GO_VERSION="go1.13.5.linux-amd64.tar.gz"
AQUATONE_VERSION="aquatone_linux_amd64_1.7.0.zip"

# Setup script
echo -e "${COLOR}\n\n----------------------------------------------\n"
echo -e "${COLOR}--- Hello, $USER. Let's setup this system. ----\n"
echo -e "${COLOR}----------------------------------------------\n\n"
sleep 3

# Setup firewall
echo -e "${COLOR}[*] Setting up ufw firewall"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
echo "y" | sudo ufw enable

# Update system
echo -e "${COLOR}[*] Updating system"
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Install dependencies
echo -e "${COLOR}[*] Installing Essentials"
sudo apt install -y build-essential
sudo apt install -y python3-pip
sudo apt install -y python-setuptools
sudo apt install -y jq
sudo apt install -y git
sudo apt install -y httpie

# ZSH & Oh My Zsh
echo -e "${COLOR}[*] Installing Z-Shell (Oh My Zsh)"
sudo apt install -y zsh
sudo apt install -y powerline fonts-powerline
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc
sed -i 's/# ENABLE_CORRECTION/ENABLE_CORRECTION/g' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
zsh
sudo chsh -s $(which zsh)

# Setup Aliases ~/
echo -e "${COLOR}[*] Setup Aliases"
echo 'alias webserver="python3 -m http.server 443"' >> ~/.zshrc

# Create tools folder in ~/
echo -e "${COLOR}[*] Creating tools folder"
mkdir ~/tools

# Install Go
echo -e "${COLOR}[*] Installing Golang"
cd ~/
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
zsh

# Nmap
echo -e "${COLOR}[*] Installing Nmap"
sudo apt install -y nmap

# awscli
echo -e "${COLOR}[*] Installing awscli"
sudo apt install -y awscli

# Install crtndstry
echo -e "${COLOR}[*] Installing crtndstry"
cd ~/tools/
git clone https://github.com/nahamsec/crtndstry.git

# Install sublist3r
echo -e "${COLOR}[*] Installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip3 install -r requirements.txt

# Install Amass
echo -e "${COLOR}[*] Installing Amass"
cd ~/
export GO111MODULE=on
go get -v -u github.com/OWASP/Amass/v3/...

echo -e "${COLOR}[*] Installing massdns"
cd ~/tools/
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/massdns
make
#sudo mv bin/massdns /bin
ln -sf ~/tools/massdns/bin/massdns /usr/local/bin/massdns

# Install Aquatone
echo -e "${COLOR}[*] Installing Aquatone"
sudo apt install -y chromium-browser
cd ~/
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/${AQUATONE_VERSION}
unzip ${AQUATONE_VERSION}
ln -sf ~/tools/aqutone /usr/local/bin/aqutone
rm ${AQUATONE_VERSION} LICENSE.txt README.md

# Install Dirsearch
echo -e "${COLOR}[*] Installing Dirsearch"
cd ~/tools/
git clone https://github.com/maurosoria/dirsearch.git

# Install ffuf
echo -e "${COLOR}[*] Installing ffuf"
cd ~/
go get github.com/ffuf/ffuf

# Install Gobuster
echo -e "${COLOR}[*] Installing Gobuster"
cd ~/
go get github.com/OJ/gobuster

# Install sqlmap
echo -e "${COLOR}[*] Installing sqlmap"
sudo apt install -y sqlmap

# Install knock.py
# echo "Installing knock.py ..."
# cd ~/tools
# git clone https://github.com/guelfoweb/knock.git

# Install httprobe
echo -e "${COLOR}[*] Installing httprobe"
cd ~/
go get -u github.com/tomnomnom/httprobe 

# Install XSStrike
echo -e "${COLOR}[*] Installing XSStrike"
cd ~/tools/
git clone https://github.com/s0md3v/XSStrike.git

# Install JSParser
# echo "Installing JSParser .."
# cd ~/tools/
# git clone https://github.com/nahamsec/JSParser.git
# cd JSParser
# python setup.py install

# Install WPScan
echo -e "${COLOR}[*] Installing WPScan"
sudo apt install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev libgmp-dev zlib1g-dev 
cd ~/tools/
git clone https://github.com/wpscanteam/wpscan.git 
cd wpscan/ 
gem install bundler && bundle install --without test 
gem install wpscan

# Get Seclists
echo -e "${COLOR}[*] Downloading SecLists"
cd ~/tools/
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
##THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt

# Optional: Install DNS Bind Server
# DNS configs:
# A	    ns1.domain.com  ->  157.245.24.77       1800 
# NS	    x.domain.com    ->  ns1.domain.com      1800
read -p "${COLOR}Would you like to install DNS Bind Server for Out-of-Band testing? y/n"  -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
then
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
fi

# Cleaning up system
echo -e "${COLOR}[*] Cleaning up system"
cd ~/
rm -rf SRB/
sudo apt autoremove -y
sudo apt autoclean -y
sudo updatedb

echo -e "${COLOR}\n\n\nInstalation complete!\n"
echo -e "${COLOR}Your tools have been installed in: ${HOME}/tools\n\n\n"
