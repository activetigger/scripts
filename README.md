# Deployment scripts for ActiveTigger


## OVH server

- `git clone https://github.com/activetigger/scripts.git` and `cd scripts`
- run `./deploy_phase1.sh`
- edit the `.env` and `sudo reboot`
- run `./deploy_phase2.sh dev/prod`