pipeline {
    agent any

    parameters {
        string(name: 'IP_ADDRESS', description: 'Remote Server IP Address')
        string(name: 'CLIENT', defaultValue: 'client1', description: 'Client Name (no spaces)')
        string(name: 'PORT', defaultValue: '8000', description: 'App Port (e.g., 8000)')
        string(name: 'MYSQLPORT', defaultValue: '3306', description: 'MySQL Port (e.g., 3306)')
        string(name: 'PMA_PORT', defaultValue: '8080', description: 'phpMyAdmin Port (e.g., 8080)')  
        string(name: 'DB_ROOTPASSWD', description: 'Enter Root Password')
        string(name: 'DB_NAME', description: 'Enter Database Name')
        string(name: 'DB_USERNAME', description: 'Enter Database Username')
        string(name: 'DB_PASSWD', description: 'Enter Database User Password')
    }

    environment {
        REMOTE_USER = 'ec2-user'
        SSH_KEY_ID = 'jenkins_id_rsa'
        DOCKER_COMPOSE_VERSION = '1.29.2'
    }

    stages {
        stage('Deploy to Remote Server') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${params.IP_ADDRESS} << EOF
                            set -e
                            sudo -i

                            # Create user and project directory
                            useradd -m -s /bin/bash ${params.CLIENT} || true
                            mkdir -p /home/${params.CLIENT}
                            cd /home/${params.CLIENT}

                            # Install dependencies
                            yum install -y git docker libxcrypt-compat
                            systemctl enable --now docker

                            # Install Docker Compose
                            if [ ! -f /usr/local/bin/docker-compose ]; then
                                curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                                chmod +x /usr/local/bin/docker-compose
                            fi

                            # Clone and prepare project
                            if [ ! -d filamentphp ]; then
                                git clone https://github.com/Sandy120499/filamentphp
                            fi

                            cd filamentphp
                            git pull
                            cp .env.example .env

                            # Update .env file
                            sed -i '/^DB_CONNECTION=/c\\DB_CONNECTION=mysql' .env
                            sed -i '/^DB_HOST=/c\\DB_HOST=db' .env
                            sed -i '/^DB_PORT=/c\\DB_PORT=3306' .env
                            sed -i '/^DB_DATABASE=/c\\DB_DATABASE=${params.DB_NAME}' .env
                            sed -i '/^DB_USERNAME=/c\\DB_USERNAME=${params.DB_USERNAME}' .env
                            sed -i '/^DB_PASSWORD=/c\\DB_PASSWORD=${params.DB_PASSWD}' .env

                            # Replace placeholders in docker-compose.yml
                            sed -i "s/{{CLIENT}}/${params.CLIENT}/g" docker-compose.yml
                            sed -i "s/{{PORT}}/${params.PORT}/g" docker-compose.yml
                            sed -i "s/{{MYSQLPORT}}/${params.MYSQLPORT}/g" docker-compose.yml
                            sed -i "s/{{PMA_PORT}}/${params.PMA_PORT}/g" docker-compose.yml
                            sed -i "s/{{DB_ROOTPASSWD}}/${params.DB_ROOTPASSWD}/g" docker-compose.yml
                            sed -i "s/{{DB_NAME}}/${params.DB_NAME}/g" docker-compose.yml
                            sed -i "s/{{DB_USERNAME}}/${params.DB_USERNAME}/g" docker-compose.yml
                            sed -i "s/{{DB_PASSWD}}/${params.DB_PASSWD}/g" docker-compose.yml

                            docker-compose -p filament_${params.CLIENT} up -d --build
EOF
                    """
                }
            }
        }

        stage('Post-Deploy Commands') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${params.IP_ADDRESS} << EOF
                            sleep 10
                            sudo -i
                            cd /home/${params.CLIENT}/filamentphp
                            docker exec app_${params.CLIENT} bash -c "
                                composer install &&
                                php artisan key:generate &&
                                php artisan migrate:fresh --seed &&
                                chown -R www-data:www-data /var/www/html"
EOF
                    """
                }
            }
        }
    }
}
