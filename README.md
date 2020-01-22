# SRB - Super Recon Box

SRB is a script to install tools I use while looking for vulnerabilities in CTF challenges and bug bounty programs.

# Unix Shell

- Z-Shell
- Oh My Zsh
 
# Tools

- Amass
- Aquatone
- Chromium (required for Aquatone)
- crtndstry
- Dirsearch
- ffuf
- Gobuster
- httprobe
- Massdns
- nmap
- Seclists collection
- Sqlmap-dev
- Sublist3r
- WPScan
- XSStrike

Optional:
- DNS Bind Server for Out-of-Band testing (Hostname and IP required)

# IMPORTANT
Create a new user with sudo privileges:
adduser username
usermod -aG sudo username
Enable password login in /etc/ssh/sshd_config

On remote host:
Copy ssh key: ssh-copy-id username@x.x.x.x
Disable root and password login in /etc/ssh/sshd_config

# Installing
- git clone https://github.com/michelruchti/SRB
- cd SRB
- chmod +x setup.sh
- ./setup.sh
