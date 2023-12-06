#!/bin/bash

#need sudo apt-get install sshpass
#need sudo apt-get install openjdk-17-jre/openjdk-17-jdk

echo -n "Docker Server Password:"
read -s Docker_Password


#test 
#echo $Docker_Password




if [[ -f "./env.sh" ]]; then
  echo "Use env variables from file ${PWD}/env.sh"
  source ./env.sh
fi


DB_CONTAINER_NAME="spring-postgres"
workDir="${WORKING_DIRECTORY:=~/WorkSpace}"
DOCKER_SERVER=192.168.58.100



help() {
    echo "
    Usage:
      ./application init - init working directory and database
      ./application clean - clean working directory and stop database
      ./application build - run Junit test to check app health (-skipTest arg to skip tests)
      ./application up - launch application
    "
}


build() {
  cd "${workDir}" || exit
  #copy files to docker server 

  if [[  -d "spring-starter" && "sshkey" ]]; then
   sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" 'mkdir ~/WorkSpace'
   sshpass -p "${Docker_Password}" scp -r -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key "${workDir}/spring-starter/" root@${DOCKER_SERVER}:~/WorkSpace/
  fi 
  
  sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "cd ~/WorkSpace/spring-starter/" || exit

  #cd "${workDir}/spring-starter" || exit

  sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "cd ~/WorkSpace/spring-starter/ && ./gradlew clean"

  if [[ "$1" = "-skipTests" ]] || sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "cd  ~/WorkSpace/spring-starter/ && ./gradlew test"; then
     echo "Application is building..."
     sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "cd ~/WorkSpace/spring-starter/ && ./gradlew bootJar"
  else 
      echo "Test failded. see test report or send -skipTests arg"
  fi
}

up() {

   sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "cd ~/WorkSpace/spring-starter/build/libs" || exit
   sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "cd ~/WorkSpace/spring-starter/build/libs && java -jar spring-starter-*.jar " 
}


clean() {

    #stop docker container (PostgreSQL)
    if  sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" 'docker ps -a' | grep "${DB_CONTAINER_NAME}"; then 
    echo "Stoping container name ${DB_CONTAINER_NAME}..."
    sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "docker stop ${DB_CONTAINER_NAME}"
    fi

    #remove working directory
    echo 'Removing working directory ${workDir}...'
    rm -rf "${workDir}"
}

init() {



    #init working directory 
    mkdir -p "${workDir}"
    # Copy server Key
      if [[ -d "sshkey" ]]; then
       echo "Copying Server SSH KEY"
       cp -r sshkey "${workDir}"
      else
      exit
      fi
    cd "${workDir}" || exit


  #git clone 
  if [[ ! -d "spring-starter" ]]; then
  git clone git@github.com:dmdev2020/spring-starter.git
  fi 
  cd "spring-starter" || exit
  git checkout lesson-125

   #PostgreSQL 
   sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" 'systemctl start docker'
   sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" 'docker pull postgres'

   #
    if  sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" 'docker ps -a' | grep "${DB_CONTAINER_NAME}"; then
        sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "docker start ${DB_CONTAINER_NAME}"
    else
       sshpass -p "${Docker_Password}" ssh -o StrictHostKeyChecking=no -i "${workDir}"/sshkey/ssh_key root@"${DOCKER_SERVER}" "docker run --name ${DB_CONTAINER_NAME} \
         -e POSTGRES_PASSWORD=pass \
         -e POSTGRES_USER=postgres \
         -e POSTGRES_DB=postgres \
         -p 5433:5432 \
         -d postgres"
         
    fi
}   


case $1 in 
help)
   help
   ;;

build) 
   build $2
   ;;

init)
   init
   ;;

up)
   up
   ;;

clean)
  clean
  ;;

*)
   echo "s$ command is not valid"
   exit 1
   ;;

esac

