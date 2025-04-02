# Backup Docker Files

This directory contains backup copies of various Docker files that were used during development and testing.
These files are kept for reference only and are not actively used in the production deployment.

## Production Docker Files

The active Docker files used for production deployment are:
- `/Dockerfile.web`: For the web component
- `/Dockerfile.worker`: For the worker component

## Deployment

The application is now deployed using Terraform with the configurations in `/terraform/modules/kubernetes`.
