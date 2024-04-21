# Introduction
I like programming languages -- they are fun to learn and you become a better 
programmer as a result of that learning.  This docker image is built so you 
can enjoy several different programming languages inside of Jupyter notebooks.

The image is also built to be installed in Unraid.  Eventually, when it feels a 
bit more complete, I'll publish it to the Unraid community apps store.

# Warning
Be forewarned, this is a very large image, it's about 2GB in size as I write this
and I still plan on adding a few more languages.

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

# Installing In Unraid

1. `mkdir -p /boot/config/plugins/community.applications/private/mega_jupyter`
2. Copy MegaJupyter.xml into the directory created in step 1
3. In community apps, look for MegaJupyter in the left sidebar.