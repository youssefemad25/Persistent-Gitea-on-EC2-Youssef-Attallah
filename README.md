# Persistent-Gitea-on-EC2-Youssef-Attallah

# Architecture summary
This project deploys Gitea inside a Docker container running on an AWS EC2 Ubuntu instance. A 10GB EBS volume is attached to the instance mounted at /home/ubuntu/data. The Docker container uses a bind mount to ensure persistent storage outside the container. Backups of the Gitea data directory are created as compressed archives and uploaded to an Amazon S3 bucket for durable off-instance storage. The system supports full restoration of repositories from S3 backups.

#Deployment instructions
Attach and Mount EBS Volume:
lsblk
sudo mkfs.ext4 /dev/nvme1n1
sudo mkdir -p /home/ubuntu/data
sudo mount /dev/nvme1n1 /home/ubuntu/data
df -h

Make the Mount Persistent:
sudo blkid
sudo blkid
echo $HOME
sudo nano /etc/fstab: 
  LABEL=cloudimg-rootfs   /        ext4   discard,commit=30,errors=remount-ro     0 1
  LABEL=BOOT      /boot   ext4    defaults        0 2
  LABEL=UEFI      /boot/efi       vfat    umask=0077      0 1
  UUID=403cdd67-d0f2-4f43-8e2b-5e341de3f9ea /home/ubuntu/data ext4 defaults,nofail 0 2
sudo mount -a
df -h

Deploying Docker:
docker run -d \
  --name gitea \
  --restart always \
  -p 3000:3000 \
  -p 222:22 \
  -v /home/ubuntu/data:/data \
  gitea/gitea:latest

# Backup and Restore Instructions:
#!/bin/bash
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
ARCHIVE="/tmp/gitea-backup-${TIMESTAMP}.tar.gz"
BUCKET="s3://youssef-gitea-backups-2026/backups"
tar -czf ${ARCHIVE} -C /home/ubuntu/data .
aws s3 cp "${ARCHIVE}" "${BUCKET}/"
echo "Backup completed and uploaded."

./backup.sh
aws s3 ls s3://youssef-gitea-backups-2026/backups/

Restore Procedure:
docker stop gitea
sudo rm -rf /home/ubuntu/data/*
sudo aws s3 cp s3://youssef-gitea-backups-2026/backups/<backup-file>.tar.gz /tmp/
sudo tar -xzf /tmp/<backup-file>.tar.gz -C /home/ubuntu/data
docker start gitea
