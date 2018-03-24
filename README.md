# offline_yum_install
install rpm win depends off line using yum.

the "offline yum install" sometimes abbreviated to "oyi".

sometimes , we need install software in offline environment.
we can download the rpm install package and copy it to the dist environment. 
but when we install it using rpm command, the package's depend packages which is not intalled before will stop the install process.
then we download the depend packages and install it , then we find we need more depend packages which is depended by the packages we download just now.

yum can resolve this problem , in online and offline ways. but in the offline way , you need special the local repo file path.you can mount the iso file to the repo path,but unfortunately , the iso file is usually out-of-date and half-baked(just like nginx not in the office base yum repo).

there is a method : yum install package in an online enviroment which is similar with the dist offline enviroment using downloadonly and keepcache option. then you can get the rpms organized by yum repos formate.

then copy the cache directory to the dist environment , run yum install with the cacheonly option.all things is done in theory.but the details is :
1. where is the rpms cached in the online enviroment?
2. which directory I should copy the cached rpms?
3. the yum find packages using the /ect/yum.repos.d/*.repo files , should I copy them from online env to dist offline env ?
4. how can I do if I can't find similar enough online env? if the online env has installed some depended packages before ?

all the question answer is offine_yum_install.sh(oyi),for example,if you want a offline package like nginx:
run the `./offline_yum_install.sh nginx -y`, the oyi will init a workdir, sepcial the yum `cachedir` to the ${workdir}/cache,special the yum `reposdir` to the ${workdir}/repos. 

the cachedir will filled by yum intall command with `keepcache` option.the reposdir should be prepared before by the user who can copy `/etc/yum.repos.d` files to the repos dir which in the same directory of offline_yum_install.sh.(please run the command in the offline_yum_install.sh scirpt's directory for relative path reasones.)

the  offline_yum_install.sh will not copy `/etc/yum.repos.d` to `{workdir}/repos` automatically, you should copy them manually.this is because oyi want you keep your online env all stay the same,you need not modify /etc/yum.repos.d/*.repo for oyi, just modify the `repos/*.repo` files for oyi where is in  the same directoy of  offline_yum_install.sh.whih the same reason ,oyi will not modify the /etc/yum.conf , it will copy /etc/yum.conf to it's ${workdir} and call yum with `--config=${workdir}/yum.conf`.

the command `offline_yum_install.sh nginx -y` will be translated to `yum install -y --downloadonly --config=${work_dir}/yum.conf`. the {work_dir}/yum.conf is copy from `/ect/yum.conf`,and modified:
1. cachedir=${work_dir}/cache
2. reposdir=${work_dir}/repos (${work_dir}/repos is copy from the same directory of offline_yum_install.sh)
3. keepcache=1

then oyi will generate an install script for dist env:`yum install -y --cacheonly --config=${work_dir}/yum.conf`
it will use the same yum.conf just now.

then oyi tar all resource to a nginx_${timestamp}.tgz in the same directory of offline_yum_install.sh, clear the ${work_dir}.

<strong>usage:</strong>


copy `offline_yum_install.sh` to `/var/oyi,run` and run `chmod +x /var/oyi/offline_yum_install.sh`.

run `cp -r /etc/yum.repos.d /var/oyi/repos`,modify /var/oyi/repos/*.repo is needed.

run `cd//var/oyi` then `./offline_yum_install.sh nginx -y`.you will receive a tgz file in the `/var/oyi`folder,copy it to the dist offline env , unpack it ,run `./install_nginx.sh` in the folder.

the best practice is using oyi in docker , because the basic os images is more clean then mini iso , yum will download as more depends as possiable.`docker run -it --privileged=true --workdir=/var/oyi -v /var/oyi:/var/oyi centos:7.2.1511 /var/oyi/offline_yum_install.sh nginx -y `  

>the question 4 is not answered perfectly, `maybe` oyi can copy the rpm database from the dist env and let yum use it when runing in the online env,it will be a perfectly plan,but i am not familiar with these configs now.


