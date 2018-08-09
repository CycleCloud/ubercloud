execute 'disable nouveau' do
        command 'echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf; echo "blacklist lbm-nouveau" >> /etc/modprobe.d/blacklist.conf; reboot'
	creates '/etc/modprobe.d/blacklist.conf'
end
