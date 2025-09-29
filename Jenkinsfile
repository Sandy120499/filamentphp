pipeline {
    agent any

    parameters {
        string(name: 'CLIENT', defaultValue: 'client1', description: 'Client Name (no spaces)')
        string(name: 'URL', description: 'Enter application URL (e.g., yourdomain.com)')
        string(name: 'PMAURL', description: 'Enter PMA application URL')
        string(name: 'PORT', defaultValue: '8000', description: 'App Port (e.g., 8000)')
        string(name: 'MYSQLPORT', defaultValue: '3306', description: 'MySQL Port (e.g., 3306)')
        string(name: 'PMA_PORT', defaultValue: '8080', description: 'phpMyAdmin Port (e.g., 8080)')
        string(name: 'DB_ROOTPASSWD', description: 'Enter Root Password')
        string(name: 'DB_NAME', description: 'Enter Database Name')
        string(name: 'DB_USERNAME', description: 'Enter Database Username')
        string(name: 'DB_PASSWD', description: 'Enter Database User Password')
    }

    environment {
        // Use env.IP_ADDRESS in SSH commands for consistency
        IP_ADDRESS = '54.242.132.148' 
        REMOTE_USER = 'ec2-user'
        SSH_KEY_ID = 'jenkins_rsa'
        DOCKER_COMPOSE_VERSION = '1.29.2'
    }

    stages {

        stage('Deploy to Remote Server') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        # CORRECTED: Using env.REMOTE_USER and env.IP_ADDRESS
                        ssh -o StrictHostKeyChecking=no ${env.REMOTE_USER}@${env.IP_ADDRESS} << EOF
                            set -e
                            sudo -i

                            # 1. Setup User and Directory
                            useradd -m -s /bin/bash ${params.CLIENT} || true
                            mkdir -p /home/${params.CLIENT}
                            cd /home/${params.CLIENT}

                            # 2. Install Dependencies (Git, Docker)
                            yum install -y git docker libxcrypt-compat
                            systemctl enable --now docker

                            # 3. Install Nginx if not present
                            if ! command -v nginx > /dev/null 2>&1; then
                                echo "Installing nginx..."
                                yum install -y nginx
                                systemctl enable nginx
                                systemctl start nginx
                            else
                                echo "Nginx already installed."
                            fi

                            # 4. Install Docker Compose
                            if [ ! -f /usr/local/bin/docker-compose ]; then
                                curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                                chmod +x /usr/local/bin/docker-compose
                            fi

                            # 5. Clone/Pull Repository
                            if [ ! -d filamentphp ]; then
                                # NOTE: Using a hardcoded GHP token is a security risk. Use Jenkins credentials binding instead.
                                git clone https://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@github.com/Sandy120499/filamentphp
                            fi

                            cd filamentphp
                            git pull

                            # 6. Configure Environment and Nginx Files
                            cp .env.example .env
                            cp sample.conf /etc/nginx/conf.d/${params.CLIENT}.conf
                            cp sample.conf /etc/nginx/conf.d/pma${params.CLIENT}.conf
                            mkdir -p /etc/nginx/ssl || true
                            
                            # Move SSL/TLS certificates (assuming these files exist in the cloned repo)
                            mv certificate.crt ca_bundle.crt private.key /etc/nginx/ssl/ || true 

                            # 7. Update Laravel .env with credentials
                            sed -i '/^DB_CONNECTION=/c\\DB_CONNECTION=mysql' .env
                            sed -i '/^DB_HOST=/c\\DB_HOST=db' .env
                            sed -i '/^DB_PORT=/c\\DB_PORT=3306' .env
                            sed -i '/^DB_DATABASE=/c\\DB_DATABASE=${params.DB_NAME}' .env
                            sed -i '/^DB_USERNAME=/c\\DB_USERNAME=${params.DB_USERNAME}' .env
                            sed -i '/^DB_PASSWORD=/c\\DB_PASSWORD=${params.DB_PASSWD}' .env
                            sed -i '/^APP_NAME=/c\\APP_NAME="${params.CLIENT}"' .env
                            echo "ASSET_URL=https://${params.URL}" >> .env

                            # 8. Update docker-compose.yml with dynamic ports/credentials
                            sed -i "s/{{CLIENT}}/${params.CLIENT}/g" docker-compose.yml
                            sed -i "s/{{PORT}}/${params.PORT}/g" docker-compose.yml
                            sed -i "s/{{MYSQLPORT}}/${params.MYSQLPORT}/g" docker-compose.yml
                            sed -i "s/{{PMA_PORT}}/${params.PMA_PORT}/g" docker-compose.yml
                            # CRITICAL: These must map to MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD in the MySQL service of docker-compose.yml
                            sed -i "s/{{DB_ROOTPASSWD}}/${params.DB_ROOTPASSWD}/g" docker-compose.yml
                            sed -i "s/{{DB_NAME}}/${params.DB_NAME}/g" docker-compose.yml
                            sed -i "s/{{DB_USERNAME}}/${params.DB_USERNAME}/g" docker-compose.yml
                            sed -i "s/{{DB_PASSWD}}/${params.DB_PASSWD}/g" docker-compose.yml

                            # 9. Start Containers
                            docker-compose -p filament_${params.CLIENT} up -d --build
EOF
                    """
                }
            }
        }

        stage('Configure Nginx') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${env.REMOTE_USER}@${env.IP_ADDRESS} << EOF
                            set -e
                            sudo -i

                            echo "Creating nginx config..."
                            sed -i 's/server_name app_url;/server_name ${params.URL};/' /etc/nginx/conf.d/${params.CLIENT}.conf
                            sed -i 's|proxy_pass http://localhost:3000;|proxy_pass http://localhost:${params.PORT};|' /etc/nginx/conf.d/${params.CLIENT}.conf
                            sed -i 's/server_name app_url;/server_name ${params.PMAURL};/' /etc/nginx/conf.d/pma${params.CLIENT}.conf
                            sed -i 's|proxy_pass http://localhost:3000;|proxy_pass http://localhost:${params.PMA_PORT};|' /etc/nginx/conf.d/pma${params.CLIENT}.conf
                            nginx -t && systemctl reload nginx
EOF
                    """
                }
            }
        }

        stage('Post-Deploy Commands') {
            steps {
                sshagent([env.SSH_KEY_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${env.REMOTE_USER}@${env.IP_ADDRESS} << EOF
                            # IMPORTANT: Wait longer to ensure MySQL is fully ready and user is created
                            echo "Waiting 20 seconds for database service to initialize..."
                            sleep 20
                            
                            sudo -i
                            cd /home/${params.CLIENT}/filamentphp
                            
                            echo "Running post-deploy commands inside the app container..."
                            # NOTE: Added 'php artisan optimize:clear' to fix potential stale config cache
                            docker exec app_${params.CLIENT} bash -c "
                                composer install &&
                                php artisan down &&
                                chown -R www-data:www-data /var/www/html &&
                                php artisan key:generate &&
                                php artisan optimize:clear && 
                                php artisan migrate:fresh --seed &&
                                php artisan up"
EOF
                    """
                }
            }
        }
    }
}
