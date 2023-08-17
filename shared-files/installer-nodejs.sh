
# lxc exec <instance_name> -- su --login <user_name>

sudo -H -u devops bash -c '
echo "--------changing to home"
cd /home/devops
echo "--------confirm current directory:"
pwd
echo "--------confirm current current user:"
whoami
echo "--------installing nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
echo "--------installing node v16.20.1"
nvm install v16.20.1'