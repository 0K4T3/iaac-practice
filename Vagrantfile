# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ailispaw/barge"
  config.vm.box_check_update = true

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 4566, host: 4566

  config.vm.synced_folder "./web", "/opt/web"
  config.vm.synced_folder "./api", "/opt/api"
  config.vm.synced_folder "./container", "/opt/container"
  config.vm.synced_folder "./infra", "/opt/infra"
  config.vm.synced_folder "./.localstack", "/opt/.localstack", create: true

  config.vm.provider "virtualbox" do |vb|
    vb.name = "test-barge"
    vb.gui = false
    vb.memory = 4096
  end

  config.vm.provision "shell", inline: "sudo /etc/init.d/docker restart latest"
  config.vm.provision "docker" do |docker|
    docker.pull_images "localstack/localstack"
    docker.build_image "/opt/container", args: "-t react-app-starter"
  end

  config.vm.provision "shell", inline: <<-SHELL
    pkg install make && pkg install zip
    docker pull imega/jq:latest
  SHELL
  
  config.vm.provision "shell", inline: <<-SHELL
    wget -q https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m) -O /opt/bin/docker-compose
    chmod +x /opt/bin/docker-compose

    wget -q https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip -O /tmp/terraform.zip
    unzip /tmp/terraform.zip -d /opt/bin
    chmod +x /opt/bin/terraform

    docker-compose -f /opt/container/docker-compose.yaml up -d \
    && cd /opt/infra/db && terraform init && terraform apply -auto-approve \
    && docker-compose -f /opt/container/docker-compose.yaml down
  SHELL

  config.trigger.after :up do |trigger|
    trigger.run_remote = {inline: <<-SHELL
        cp -r /opt/.localstack/ /tmp/localstack/ \
        && docker run -v /opt/api:/opt/api -w /opt/api python:3.8-alpine sh -c "pip install pipenv && pipenv install && pipenv lock -r > requirements.txt && apk add make zip && make pack" \
        && cp /opt/api/function.zip /opt/infra/api \
        && docker-compose -f /opt/container/docker-compose.yaml up -d \
        && cd /opt/infra/api && terraform init && terraform apply -auto-approve

        API_ENDPOINT=$(terraform output -json -state=/opt/infra/api/terraform.tfstate | docker run --rm -i imega/jq -r .api_endpoint.value) \
        && sed -i -E "s#API_ENDPOINT=.*#API_ENDPOINT=${API_ENDPOINT}#g" /opt/container/docker-compose.yaml \
        && docker-compose -f /opt/container/docker-compose.yaml up -d
    SHELL
    }
  end

  config.trigger.before :halt do |trigger|
    trigger.run_remote = {inline: <<-SHELL
        cp -r /tmp/localstack/* /opt/.localstack/ \
        && rm -r /opt/infra/api/.terraform* \
        && rm -r /opt/infra/api/terraform*
    SHELL
    }
  end

  config.trigger.before :destroy do |trigger|
    trigger.run_remote = {inline: <<-SHELL
        rm -rf /opt/.localstack/* \
        && rm -rf /opt/infra/db/terraform* \
        && rm -rf /opt/infra/db/.terraform* \
        && rm -rf /opt/infra/api/.terraform* \
        && rm -rf /opt/infra/api/terraform*
    SHELL
    }
  end
end
