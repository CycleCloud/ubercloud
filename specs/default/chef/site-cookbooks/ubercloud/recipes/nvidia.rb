execute 'download nvidia driver' do
	command 'cd /tmp; wget https://s3.amazonaws.com/ubercloud.public.tools/NVIDIA-drivers/v352.79/NVIDIA-Linux-x86_64-352.79.run;'
	creates '/tmp/NVIDIA-Linux-x86_64-352.79.run'
end

execute 'download additional kernel files' do
	command 'cd /tmp; wget https://s3.amazonaws.com/ubercloud.public.tools/RPMs/kernel-headers-$(uname -r).rpm https://s3.amazonaws.com/ubercloud.public.tools/RPMs/kernel-devel-$(uname -r).rpm'
	creates '/tmp/kernel-headers-$(uname -r).rpm'
end

execute 'install additional kernel files' do
	command 'cd /tmp;  rpm -ivh --force kernel*rpm'
	creates '/usr/src/kernels/$(uname -r)'
end

yum_package 'dkms' do
	action :install
end

execute 'install nvidia driver' do
	command 'sh /tmp/NVIDIA-Linux-x86_64-352.79.run -a -q -s'
	creates '/bin/nvidia-smi'
end

execute 'tune nvidia drivers' do
	command '/bin/nvidia-smi -pm 1; /bin/nvidia-smi -acp 0; /bin/nvidia-smi --auto-boost-permission=0; /bin/nvidia-smi -ac 2505,875'
end
