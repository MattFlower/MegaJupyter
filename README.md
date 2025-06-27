# Introduction
I like programming languages -- they are fun to learn and you become a better 
programmer as a result of that learning.  This docker image is built so you 
can enjoy several different programming languages inside of Jupyter notebooks.

The image is also built to be installed in Unraid.  Eventually, when it feels a 
bit more complete, I'll publish it to the Unraid community apps store.

# Security Warning
I have made only minimal attempts to secure this image:

  1. It doesn't run as root.
  2. It runs the operating system upgrades at the point the container is created.

There are many downsides though:

  1. The password is 'password'.  Of course, you are meant to change it.
  2. If you are installing this in Unraid, the default configuration sets up docker-in-docker so the Docker kernel
     is supported.  This allows people pretty free reign in installing things in your system.  If you are concerned 
     about this, don't map /var/run/docker.sock to the container.
  3. While I do system updates when I build the container, there are no regular system updates.  This means there
     are likely security vulnerabilities at most times.
  4. I have made no attempts to check signatures of things I install.  If anything is compromised, it could be used to
     compromise your system.

This isn't counting the dozens of other security vulnerabilities that I haven't noticed or don't know to look for.

# Languages Supported
- Bash
- C
- Javascript/Typescript (Deno)
- Golang
- Groovy (Ganymede)
- Java (Ganymede)
- Kotlin
- OCaml
- Python
- Rust
- Dockerfiles

# Installing In Unraid

1. `mkdir -p /boot/config/plugins/community.applications/private/mega_jupyter`
2. Copy MegaJupyter.xml into the directory created in step 1
3. In community apps, look for "Private Apps" in the left sidebar.

# Logging in
The default password is 'password'.  You should really change this.

# Changing the Password
Open a console to the container and run:

```bash
jupyter lab password
```

