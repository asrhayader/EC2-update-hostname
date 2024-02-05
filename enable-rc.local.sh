sudo systemctl status rc-local

sudo systemctl enable rc-local

sudo systemctl start rc-local

sudo systemctl status rc-local

# it doesn't start because /etc/rc.d/rc.local does not exist
sudo ln -s /etc/rc.local /etc/rc.d/rc.local

sudo systemctl start rc-local

sudo systemctl status rc-local
