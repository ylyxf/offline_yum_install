#!/bin/bash
#chmod +x /var/oyi/offline_yum_install.sh
#docker run -d --privileged=true  -d -v /var/oyi:/var/oyi centos:7.2.1511 /var/oyi/offline_yum_install.sh installName
if [ "$#" -eq "0" ];
then
    echo "offline_yum_install need a package name as paramter"
else
  echo "packing ${1}"
	volume_dir=/var/oyi
	timestamp=`date +%Y%m%d%H%M%S`
	work_base_dir=$(cd `dirname $0`; pwd)/offline_yum_install_${1}_${timestamp}
	mkdir ${work_base_dir}
  work_dir=${work_base_dir}/${1}
  mkdir ${work_dir} 
  mkdir ${work_dir}/cache
  cp /etc/yum.conf ${work_dir}/yum.conf
	cp -r ${volume_dir}/repos ${work_dir}/repos
  sed -i "/^cachedir=/ c cachedir=${work_dir}/cache"  ${work_dir}/yum.conf
	sed -i "/\[main\]/ a reposdir=${work_dir}/repos"  ${work_dir}/yum.conf
  sed -i "/^keepcache=/ c keepcache=1"  ${work_dir}/yum.conf 
  yum install ${1} --downloadonly --config=${work_dir}/yum.conf
	

  install_script=${work_dir}/install_${1}.sh
  echo "#!/bin/bash" >> ${install_script}
  echo "echo 'installing ${1}'" >> ${install_script}
  echo 'work_dir=$(cd `dirname $0`; pwd)' >> ${install_script}
	echo 'sed -i "/^cachedir=/ c cachedir=${work_dir}/cache"  ${work_dir}/yum.conf' >> ${install_script}
  echo 'sed -i "/^reposdir=/ c reposdir=${work_dir}/repos"  ${work_dir}/yum.conf' >> ${install_script}
	echo -e "yum install $* --cacheonly \c" >> ${install_script} 
	echo '--config=${work_dir}/yum.conf' >> ${install_script} 
	
  chmod +x ${install_script}
	tar -czvf ${volume_dir}/${1}_${timestamp}.tgz -C ${work_base_dir} ${1}
	rm -rf ${work_base_dir}
fi
