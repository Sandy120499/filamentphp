pipeline {
    agent any

    environment {
        REMOTE_USER = 'ec2-user'                 // Change to your remote server user
        REMOTE_HOST = '13.50.233.103'              // Change to your remote server IP
        SSH_KEY_ID = 'jenkins_id_rsa'            // Jenkins credential ID
        DOCKER_COMPOSE_VERSION = '1.29.2'
    }

    stages {
        stage('Deploy to Remote Server') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
                            sudo yum install -y git docker libxcrypt-compat
                            sudo systemctl start docker
                            sudo systemctl enable docker

                            if [ ! -f /usr/local/bin/docker-compose ]; then
                                sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                                sudo chmod +x /usr/local/bin/docker-compose
                            fi

                            if [ ! -d filamentphp ]; then
                                git clone https://github.com/Sandy120499/filamentphp
                            else
                                cd filamentphp && git pull
                            fi

                            cd filamentphp
                            sudo docker-compose pull
                            sudo docker-compose up -d --build
                    """
                }
            }
        }
    }
}
