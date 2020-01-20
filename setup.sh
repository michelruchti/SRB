#!/bin/bash

# IMPORTANT
# Create a new user with sudo privileges:
# adduser username
# usermod -aG sudo username
# Copy ssh key: ssh-copy-id username@x.x.x.x
# Enable public key login 
# Disable root login and password auth in /etc/ssh/sshd_config 

sudo -v

# Variables:
GO_VERSION="go1.13.5.linux-amd64.tar.gz"

# Setup script
echo "------------------------------------------\n\n"
echo "Hello, $USER. Let's configure this system.\n\n"
echo "-------- SRB ----- setup.sh v0.3 ---------\n"

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
sudo apt install -y python3-pip
sudo apt install -y python-setuptools
sudo apt install -y jq
sudo apt install -y git
sudo apt install -y nmap
sudo apt-get install httpie -y
sudo apt install curl libcurl4-openssl-dev make zlib1g-dev gawk g++ gcc libreadline6-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config ruby ruby-bundler ruby-dev -y
echo "Done."

echo "Installing Z-Shell (Oh My Zsh) ..."
sudo apt install zsh -y
sudo apt install powerline fonts-powerline -y
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc
sed -i 's/# ENABLE_CORRECTION/ENABLE_CORRECTION/g' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
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
source ~/.zshrc
echo "Done."

# Install crtndstry
cd ~/tools/
echo "Installing crtndstry"
git clone https://github.com/nahamsec/crtndstry.git
echo "Done."

# Install sublist3r
echo "Installing sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip3 install -r requirements.txt
cd ~/tools/
echo "Done."

# Install Amass
echo "Installing Amass"
cd ~/
export GO111MODULE=on
go get -v -u github.com/OWASP/Amass/v3/...
echo "Done."

echo "installing massdns"
cd ~/tools/
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/massdns
make
sudo mv bin/massdns /bin
echo "done"

# Install Aquatone
cd ~/
echo "Installing aquatone ..."
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
unzip aquatone_linux_amd64_1.7.0.zip
sudo mv aquatone /bin
rm aquatone_linux_amd64_1.7.0.zip LICENSE.txt README.md
echo "Done."

# Install Chromium
echo "Installing chromium ..."
sudo snap install chromium
sudo cp /snap/bin/* /usr/bin
echo "Done."

# Install Dirsearch
cd ~/tools/
echo "Installing dirsearch ..."
git clone https://github.com/maurosoria/dirsearch.git
echo "Done."

# Install ffuf
cd ~/
echo "Installing ffuf ..."
go get github.com/ffuf/ffuf
echo "Done."

# Install Gobuster
cd ~/
echo "Installing Gobuster ..."
go get github.com/OJ/gobuster
echo "Done."

# Install sqlmap
echo "Installing sqlmap ..."
cd ~/tools
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
echo "Done."

# Install knock.py
# echo "Installing knock.py ..."
# cd ~/tools
# git clone https://github.com/guelfoweb/knock.git
# echo "Done."

# Install httprobe
echo "Installing httprobe ..."
cd ~/
go get -u github.com/tomnomnom/httprobe 
echo "Done."

# Install XSStrike
echo "Installing XSStrike .."
cd ~/tools/
git clone https://github.com/s0md3v/XSStrike.git
echo "Done."

# Install JSParser
# echo "Installing JSParser .."
# cd ~/tools/
# git clone https://github.com/nahamsec/JSParser.git
# cd JSParser
# python setup.py install
# echo "Done."

# Install WPScan
echo "Installing wpscan ..."
cd ~/tools/
git clone https://github.com/wpscanteam/wpscan.git
cd wpscan/
sudo gem install wpscan
wpscan --update
echo "Done."

# Get Seclists
echo "Downloading Seclists"
cd ~/tools/
git clone https://github.com/danielmiessler/SecLists.git
cd ~/tools/SecLists/Discovery/DNS/
##THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat dns-Jhaddix.txt | head -n -14 > clean-jhaddix-dns.txt
echo "Done."

# Optional: Install DNS Bind Server
# DNS configs:
# A	    ns1.domain.com  ->  157.245.24.77       1800 
# NS	    x.domain.com    ->  ns1.domain.com      1800
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
