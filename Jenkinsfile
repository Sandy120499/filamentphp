pipeline {
    agent any

    environment {
        REMOTE_USER = 'ec2-user'
        REMOTE_HOST = '13.53.198.194'
        SSH_KEY_ID = 'jenkins_id_rsa'
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
                                git pull
                            fi

                            cd filamentphp
                            sudo docker-compose pull
                            sudo docker-compose up -d --build
                    """
                }
            }
        }

        stage('Post-Deploy Commands') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
                            sleep 10
                            sudo docker exec filamentphp_app_1 bash -c "
                                composer install &&
                                chown -R www-data:www-data /var/www/html &&
                                php artisan migrate &&
                                php artisan migrate:fresh --seed
                            "
                    """
                }
            }
        }
    }
}
