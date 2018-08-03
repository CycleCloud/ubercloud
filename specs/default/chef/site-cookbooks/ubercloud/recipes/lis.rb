execute 'install lis' do
	command 'if [ $(rpm -qa microsoft-hyper-v | wc -l) -lt 1 ]; then cd /tmp; wget https://aka.ms/lis; tar xvzf lis; cd LISISO; ./install.sh; if [ $? -eq 0 ]; then reboot; fi; else touch /tmp/LISISO; fi'
	creates '/tmp/LISISO'
end
