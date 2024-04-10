RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function info(){
    local message=$1
    echo -e "${WHITE}[I] ${message}${NC}"
}

function warn(){
    local message=$1
    echo -e "${YELLOW}[!] ${message}${NC}"
}

function success(){
    local message=$1
    echo -e "${GREEN}[I] ${message}${NC}"
}

function error(){
    local message=$1
    echo -e "${RED}[X] ${message}${NC}"
    exit 1
}

info "Elevating privileges to install requirements"
if [[ "$EUID" = 0 ]]; then
    info "(1) already root"
else
    sudo su # make sure to ask for password on next sudo ✱
    if sudo true; then
        info "(2) correct password"
    else
        error "(3) wrong password"
        exit 1
    fi
fi

info "Install libffi-dev, required by python module installation to avoid _ctypes errors"
yum install libffi-devel
if [ "$?" -ne 0 ]; then
    error "Installation of libffi-devel failed"
fi

info "Install pyenv"
curl https://pyenv.run | bash
if [ "$?" -ne 0 ]; then
    error "Installation of pyenv failed"
fi

info "Add pyenv sourcing to .bashrc"
cat << 'EOF' | tee -a "${HOME}/.bashrc"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

info "Install python 3.8.0"
pyenv install 3.8.0
if [ "$?" -ne 0 ]; then
    error "Installation of python 3.8.0 failed"
fi

info "Install python 2.7"
pyenv install 2.7
if [ "$?" -ne 0 ]; then
    error "Installation of python 2.7 failed"
fi

info "Set python 3.8 as global"
pyenv global 3.8.0
info "Upgrade pip3"
pip install --upgrade pip

info "Enter python 2.7 shell"
pyenv shell 2.7
info "Upgrade pip2"
pip install --upgrade pip
info "Deactivate python 2.7 shell"
deactivate

info "Install impacket"
if [ "$?" -ne 0 ]; then
    error "Installation of impacket failed"
fi
pip install impacket
