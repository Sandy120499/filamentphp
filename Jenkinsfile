pipeline {
    agent any

    parameters {
        string(name: 'IP_ADDRESS', description: 'Remote Server IP Address')
        string(name: 'CLIENT', defaultValue: 'client1', description: 'Client Name (no spaces)')
        string(name: 'PORT', defaultValue: '8000', description: 'App Port (e.g., 8000)')
        string(name: 'MYSQLPORT', defaultValue: '3306', description: 'MySql Port (e.g., 3306)')
        string(name: 'PMA_PORT', defaultValue: '8080', description: 'phpMyAdmin Port (e.g., 8080)')  
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
                            sudo -i
                            useradd ${params.CLIENT}
                            cd /home/${params.CLIENT}
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


                            sed -i "s/{{CLIENT}}/${params.CLIENT}/g" docker-compose.yml
                            sed -i "s/{{PORT}}/${params.PORT}/g" docker-compose.yml
                            sed -i "s/{{MYSQLPORT}}/${params.MYSQLPORT}/g" docker-compose.yml
                            sed -i "s/{{PMA_PORT}}/${params.PMA_PORT}/g" docker-compose.yml

                            sudo docker-compose -p filament up -d --build
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
                            docker exec filament_app_${params.CLIENT}_1 bash -c "
                                composer install &&
                                chown -R www-data:www-data /var/www/html &&
                                php artisan migrate:fresh --seed"
                    """
                }
            }
        }
    }
}
