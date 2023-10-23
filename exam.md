This file gives an insight of how to:


- Automate the provisioning of two Ubuntu-based servers, named "Master" and "Slave", using Vagrant.

- Write a bash script to automate the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack on the master node .

- The bash script should clone a PHP application from GitHub(laravel), install all necessary packages, and configure Apache web server and MySQL. 

- With Ansible Playbook:

    A) Execute the bash script on the Slave node

    B) Create a cron job to check the server's uptime every 12 am.


1: Automating Master and Slave machine with Vagrant.

![](<../../Master&Slave .png>)

2: Deployment of LAMP stack on the Master node

![](../../LAMP.png)

3: cloning laravel..
  To do this, i installed composer first
![](../../composer.png)

Then i cloned laravel from github, and changed the ownership of /var/www/html/laravel to www-data to enable access the files in the /var/www/html/laravel directory. Also i copied the files in .env.example file to .env file

![](../../cloning.png)


Configuring and restarting Apache web server
![](../../Apache.png)

Configuring MYSQL and creating a database

![](../../Mysql.png)

In the .env file created earlier, i edited the database name and username and also created a password for the database created above  
![](../../env.png)

N/B: To run this script on the master node, i used the command:

- bash laravel.sh chinazor nazor93
- < /dev/null makes the script non interactive


Ansible Playbook: The Ansible Playbook has d 1 directory and 3 files.

- files: This directory contains the script that will be executed on the slave node.

- ansible.cfg: This provides configuration settings for the ansible
![](../../cfg.png)

- inventory: This is where the host machine that ansible will connect to is located.
![](../../inven.png)


- script.yaml file: This file contains the play that will be executed.

I updated and upgraded the host server, then i created a cronjob to check the server's uptime every 12am
![](../../cronjob.png)

- The first task is to copy the bash script from the files directory to the root of the slave machine, and then change the permissions.
- The second task sets permission to execute the script
- The third task executes the script
![](../../ans_task.png)

N/B: To run the ansible playbook, i used the comman:

- ansible-playbook -i inventory script.yaml