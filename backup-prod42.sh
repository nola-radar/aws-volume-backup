#!/bin/bash

# Put the volume-ids you want backed up in the VOLUME_A & VOLUME_B variables.  
# Change "prod42" to whatever hostname you'd like.  Adjust filesystem name to
# what you're using (/dev/sda and /dev/sdb in this case). 

# Dude, where's my var?
VOLUME_A="vol-0xxxxxxxxxxxxxxxx"
VOLUME_B="vol-0yyyyyyyyyyyyyyyy"
DAY_A=$(aws ec2 describe-snapshots --filters Name=volume-id,Values=$VOLUME_A \
--output text | grep `date +"%Y-%m-%d" --date="7 day ago"` | awk '{print $8}')
DAY_B=$(aws ec2 describe-snapshots --filters Name=volume-id,Values=$VOLUME_B \
--output text | grep `date +"%Y-%m-%d" --date="7 day ago"` | awk '{print $8}')

# Delete older snapshots
aws ec2 delete-snapshot --snapshot-id `echo "${DAY_A}"| head -1`
aws ec2 delete-snapshot --snapshot-id `echo "${DAY_B}"| head -1`

# Create snapshot of / volume on prod42
aws ec2 create-snapshot --volume-id $VOLUME_A \
--description "`date +"%Y-%m-%d"` /dev/sda" \
--tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=prod42-sda}]'

# Create snapshot of /srv volume on prod42
aws ec2 create-snapshot --volume-id $VOLUME_B \
--description "`date +"%Y-%m-%d"` /dev/sdb" \
--tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=prod42-sdb}]'
