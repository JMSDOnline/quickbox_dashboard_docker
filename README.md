# quickbox_dashboard_docker [wip]

Install docker setup with the following:
```
git clone https://github.com/JMSDOnline/quickbox_dashboard_docker.git /etc/quickbox
cd /etc/quickbox && bash install.sh
```

Now pull the image
```
docker pull quickboxio/quickbox-dashboard:development
```

Next, run it
```
docker run -i -t -d -p 80:80 quickboxio/quickbox-dashboard:development /bin/bash
```

You can enter the image with `docker exec -it [container-id] bash`

Containers can be seen with `docker ps` - Images can be seen with `docker images`
