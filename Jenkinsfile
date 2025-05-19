pipeline {
    agent any

    parameters {
        string(name: 'CLIENT', defaultValue: 'client1', description: 'Client Name (no spaces)')
        string(name: 'PORT', defaultValue: '8002', description: 'App Port (e.g., 8002)')
        string(name: 'PMA_PORT', defaultValue: '8082', description: 'phpMyAdmin Port (e.g., 8082)')
    }

    environment {
        REMOTE_USER = 'ec2-user'
        REMOTE_HOST = '16.16.98.231'
        SSH_KEY_ID = 'jenkins_id_rsa'
        DOCKER_COMPOSE_VERSION = '1.29.2'
    }

    stages {
        stage('Deploy to Remote Server') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} << EOF
                            sudo yum install -y git docker libxcrypt-compat
                            sudo systemctl start docker
                            sudo systemctl enable docker

                            if [ ! -f /usr/local/bin/docker-compose ]; then
                                sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-\\\$(uname -s)-\\\$(uname -m)" -o /usr/local/bin/docker-compose
                                sudo chmod +x /usr/local/bin/docker-compose
                            fi

                            if [ ! -d filamentphp ]; then
                                git clone https://github.com/Sandy120499/filamentphp
                            fi

                            cd filamentphp
                            git pull

                            cp docker-compose-template.yml docker-compose.yml

                            sed -i "s/{{CLIENT}}/${params.CLIENT}/g" docker-compose.yml
                            sed -i "s/{{PORT}}/${params.PORT}/g" docker-compose.yml
                            sed -i "s/{{PMA_PORT}}/${params.PMA_PORT}/g" docker-compose.yml

                            sudo docker-compose -p filament_${params.CLIENT} up -d --build
                    """
                }
            }
        }

        stage('Post-Deploy Commands') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} << EOF
                            sleep 10
                            sudo docker exec filament_${params.CLIENT}_app_${params.CLIENT}_1 bash -c "
                                composer install &&
                                chown -R www-data:www-data /var/www/html &&
                                php artisan migrate:fresh --seed
                            "
                    """
                }
            }
        }
    }
}
