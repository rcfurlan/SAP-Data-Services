#!/bin/sh

# Seta variaveis de ambiente do DataServices
. /opt/sap/dataservices/bin/al_env.sh

# Stop no subversion
echo "Stopping subversion..."
/opt/sap/sap_bobj/svn_shutdown.sh

sleep 60

# Stop nos servicos do Information Platform Services (IPS)
/opt/sap/sap_bobj/stopservers

sleep 60

# Stop no Tomcat
echo "Stopping tomcat..."
/opt/sap/sap_bobj/tomcatshutdown.sh

sleep 60

echo "Servicos do BO Data Services - Stop completado !!!"







