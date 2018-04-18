# 3scale-JDG-Demo
The idea of this demo is setup an example of how to use RH DataGrid to cache API requests in 3scale API Manager.

## Pre-Requisites
You need to have:
	* Openshift cluster up & running (you can use *oc cluster up* or *minishift*)
	* OC binary installed
	* Admin access to the Openshift cluster
	* Ansible

## Demo Instructions
1. Edit the playbook (*3scale-config.yml*) and change the *hostname* var to match your Openshift cluster's hostname (ie: example.com)
2. Execute the playbook (```console foo@bar:~$ ansible-playbook 3scale-config.yml```)
3. You can test performance improvements on a local backend API by executing:
	* ab -n 1000 -c 20 https://products-apicast-production.gateway.[hostname]:443/rest/services/products?user_key=[user_key]
	* Take note of the results
	* ```console foo@bar:~$ oc set env dc/apicast-production APICAST_MODULE=cors.apicast_cors -n 3scale```
	* ab -n 1000 -c 20 https://products-apicast-production.gateway.[hostname]:443/rest/services/products?user_key=[user_key]
	* Compare results (without caching) with the previuos ones
4. You can test the performance improvements on a remote backend API by executing:
	* ab -n 1000 -c 20 https://api-3scale-apicast-production.[hostname]:443?user_key=[user_key]
        * Take note of the results
        * ```console foo@bar:~$ oc set env dc/apicast-production APICAST_MODULE=cors.apicast_cors -n 3scale```
        * ab -n 1000 -c 20 https://api-3scale-apicast-production.[hostname]:443?user_key=[user_key]
	* Compare results (without caching) with the previuos ones
