# Mauve Web Server

## Set up instructions

1. Create an ssh key to connect to the EC2 instances

    ```sh
    ssh-keygen -f ~/.ssh/temp_aws_rsa -b 4096
    ```

    - Copy the contents of the public key into `terraform/ec2.tf` for the key pair

    - Add the key to ssh agent forwarding with the following command

        ```sh
        ssh-add -K ~/.ssh/temp_aws_rsa
        ```

1. Get AWS API key and secret with the minimum permissions to administer VPC and EC2

    - I created a profile in my `~/.aws/credentials`

    - Set the profile name in `terraform/main.tf` in the AWS provider block

### Terraform (v0.13.5)

1. Run the following commands in the `terraform/` directory

    ```sh
    # first time
    terraform init

    # plan or apply
    terraform apply --var-file variables-usw2.tfvars
    ```

1. Type "yes" when prompted to apply

1. Take note of the outputs after apply

    ```txt
    bastion_public_ip    = "<some ip>"
    lb_dns_name          = "<some dns name>"
    webserver_private_ip = "<some ip>"
    ```

### Ansible (v2.9.13)

1. Update the following things to setup Ansible

    - Replace the webserver ip in the inventory file here `ansible/hosts`

    - Replace the bastion ip in the config file here `ansible/ansible.cfg`

1. Run the following command in the `ansible/` directory

    ```sh
    # test the connection with
    ANSIBLE_CONFIG=./ansible.cfg ansible all -i ./hosts -m ping

    # If successful run Ansible with the following
    ANSIBLE_CONFIG=./ansible.cfg ansible-playbook playbook.yml -i ./hosts
    ```

### Verify

1. If you have access to the AWS console check that the instance in the load balancer shows "InService". This should take around one minute after successfully running Ansible. (The health checks have an interval of 30 seconds and a healthy threshold of 2.)

1. You can try curling the load balancer DNS to see if you get a response.

    ```sh
    curl <lb_dns_name>
    {"id":"977ae381-2b9e-4d17-a5c4-bdb53dc19bbb","unix_stamp":1612043933}
    ```

### Details

The infrastructure for this code sample might be overkill, but I am hoping to demonstrate my understanding of AWS, Docker, servers, networking, infrastructure-as-code, configuration management, and then tying them all together.

Here's what will be created:

- VPC

    - Private subnet

    - Public subnet

- Security groups

    - Allow traffic between everything in VPC

    - Allow traffic (port 22) to bastion from home ip

    - Allow traffic (port 80) from anywhere to ELB

    - Allow traffic from ELB to VPC

- EC2

    - Web server (private subnet) which will run the docker container

    - Bastion (public subnet) to access instances on the private subnet through ssh

- ELB

    - Load balancer (public subnet) to route HTTP (80) traffic to web server

### Recommendations

1. Terraform

    - Remote state (S3)

    - Use "data" for ami in order to more easily stay up to date

1. Use two or more instances in multiple AZs for HA

1. SSL (ACM cert) terminate at load balancer

1. Ansible

    - dynamic inventory and use EC2 user_data together with instance tags

    - docker login for private registries

1. Dockerfile

    - multistage build (to decrease image size on disk < 885MB)

1. As far as fixing the crashing app
