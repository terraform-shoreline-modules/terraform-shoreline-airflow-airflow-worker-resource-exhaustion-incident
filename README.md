
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Airflow worker resource exhaustion incident.
---

This incident type refers to situations where Apache Airflow workers have exhausted their resources. Apache Airflow is an open-source platform to programmatically author, schedule, and monitor workflows. Workers in Apache Airflow are responsible for executing tasks and are essential to the platform's functionality. Resource exhaustion in workers can cause a significant impact on the performance of the platform and can result in workflow failures. This incident type requires immediate attention to ensure the workers have sufficient resources to execute tasks, and the platform is functioning correctly.

### Parameters
```shell
export DESIRED_NUMBER_OF_WORKERS="PLACEHOLDER"

export AIRFLOW_LOG_FILE="PLACEHOLDER"

export WORKER_PID="PLACEHOLDER"

export WORKER_CONFIG_FILE="PLACEHOLDER"
```

## Debug

### Check the CPU usage of the affected worker node
```shell
top
```

### Check the disk usage of the affected worker node
```shell
df -h
```

### Check the memory usage of the affected worker node
```shell
free -m
```

### Check the currently running processes on the affected worker node
```shell
ps aux
```

### Identify any specific Airflow tasks that may be causing the resource exhaustion
```shell
grep "airflow" /var/log/syslog
```

### Check the Airflow logs for any errors or warnings that may be related to the resource exhaustion
```shell
tail -f /var/log/airflow/worker.log
```

### Restart the Airflow worker process on the affected node
```shell
sudo systemctl restart airflow-worker.service
```

### The worker may not have been configured with enough resources to handle the workload it was given.
```shell
bash

#!/bin/bash



# Displaying a message to inform the user that the script is starting.

echo "Starting diagnosis..."



# Checking the worker's resource usage.

# Replace ${WORKER_PID} with the PID of the worker process.

worker_pid=${WORKER_PID}

ps aux | grep $worker_pid | awk '{print "Worker CPU usage: " $3 "%, Memory usage: " $4 "%"}'



# Checking the worker's configuration.

# Replace ${WORKER_CONFIG_FILE} with the path to the worker's configuration file.

worker_config_file=${WORKER_CONFIG_FILE}

cat $worker_config_file



# Checking the workload being given to the worker.

# Replace ${AIRFLOW_LOG_FILE} with the path to the Apache Airflow log file.

airflow_log_file=${AIRFLOW_LOG_FILE}

grep "Task instance" $airflow_log_file | tail -n 10



# Displaying a message to inform the user that the diagnosis is complete.

echo "Diagnosis complete."


```

## Repair

### Scale up the number of airflow workers to ensure sufficient resources are available to handle the workload.
```shell


#!/bin/bash



# Get the desired number of workers from a configuration file or environment variable

NUM_WORKERS=${DESIRED_NUMBER_OF_WORKERS}



# Get the current number of workers

CURRENT_WORKERS=$(sudo systemctl status airflow-worker | grep "Active:" | grep -o "[0-9]*")



# If the current number of workers is less than the desired number, scale up

if [ "$CURRENT_WORKERS" -lt "$NUM_WORKERS" ]; then

    sudo systemctl stop airflow-worker

    sudo sed -i "s/num_processes=[0-9]*/num_processes=$NUM_WORKERS/" /etc/airflow/airflow.cfg

    sudo systemctl start airflow-worker

    echo "Scaled up the number of airflow workers to $NUM_WORKERS."

else

    echo "The current number of airflow workers is already sufficient."

fi


```