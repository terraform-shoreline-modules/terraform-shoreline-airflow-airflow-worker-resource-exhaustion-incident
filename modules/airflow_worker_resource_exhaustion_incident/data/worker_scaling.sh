

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