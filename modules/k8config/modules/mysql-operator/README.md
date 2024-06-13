# mysql-operator module

# Documentation
* https://dev.mysql.com/doc/mysql-operator/en/

Helm Package Location: https://artifacthub.io/packages/helm/mysql-operator/mysql-operator
Repository: https://github.com/mysql/mysql-operator

# CRD Location
Upgrade instructions: https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-upgrading.html

Note! There is a deployment files already setup that will handle the upgrades if you want to do them live! See https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-upgrading.html

The CRDs are located within the helm folder of the github repository. Check the Helm package version to see which application version it has to find the source code from the "release" page. Then you can install the CRDs from that.


There does seem to be a version mapping in the mysql-operator github tags

8.4.0-2.1.3 <- First number is the application number, then dash, then second number is the helm version number