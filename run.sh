#!/bin/sh

# Initialise DB && start apache
/opt/scripts/init-db;/opt/scripts/update-db && apache2-foreground
