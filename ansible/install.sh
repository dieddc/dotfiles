
source ../scripts/common.sh

USERNAME=dev
current_user=$(whoami)

if id $USERNAME >/dev/null 2>&1;
then
  log-green "Standard Development User $USERNAME exists"
  if [ "$current_user" = "$USERNAME" ]; 
  then 
    log "Running as $USERNAME, we can proceed with user install"
    ansible-playbook playbooks/deploy.yml
  else  
    echo -e $red" You are root, user $USERNAME already added"$clear
    exit 0
  fi
else
  echo -e $orange" We need to add the user $USERNAME"$clear
  if [ $UID = 0 ];
  then 
    if getent passwd 1000 >/dev/null; 
    then  
      echo -e $red" USER ID 1000 is occupied"$clear
      exit 0
    fi    
    ansible-playbook playbooks/create-user.yml
  fi
fi  

