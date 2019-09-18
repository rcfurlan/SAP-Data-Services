#!/bin/sh

# Seta variaveis de ambiente do DataServices
. /opt/sap/dataservices/bin/al_env.sh

# Start no subversion
echo "Starting subversion..."
/opt/sap/sap_bobj/svn_startup.sh

sleep 60

# Start nos servicos do Information Platform Services (IPS)
/opt/sap/sap_bobj/startservers

sleep 60

# Start no Tomcat
echo "Starting tomcat..."
/opt/sap/sap_bobj/tomcatstartup.sh

sleep 60

echo "Servicos do BO Data Services - Start completado !!!"







