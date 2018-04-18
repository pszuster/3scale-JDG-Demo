# 3scale-JDG-Demo
The idea of this demo is setup an example of how to use RH DataGrid to cache API requests in 3scale API Manager.

## Pre-Requisites
You need to have:
	* Openshift cluster up & running (you can use *oc cluster up* or *minishift*)
	* OC binary installed
	* Admin access to the Openshift cluster
	* Ansible

## Demo Instructions
1. Edit the playbook (*3scale-config.yml*) and change the *domain* var to match your Openshift cluster's domain (ie: example.com)
2. Execute the playbook (```foo@bar:~$ ansible-playbook 3scale-config.yml```)
3. You can test performance improvements on a local backend API by executing:
	* ab -n 1000 -c 20 https://products-apicast-production.gateway.[*replace with your domain*]:443/rest/services/products?user_key=[*replace with a user_key for this API*]
	* Take note of the results
	* ```foo@bar:~$ oc set env dc/apicast-production APICAST_MODULE=cors.apicast_cors -n 3scale```
	* ab -n 1000 -c 20 https://products-apicast-production.gateway.[*replace with your domain*]:443/rest/services/products?user_key=[*replace with a user_key for this API*]
	* Compare results with/without caching.
4. You can test the performance improvements on a remote backend API by executing:
	* ab -n 1000 -c 20 https://api-3scale-apicast-production.[*replace with your domain*]:443?user_key=[*replace with a user_key for this API*]
	* Take note of the results
	* ```foo@bar:~$ oc set env dc/apicast-production APICAST_MODULE=jdg.apicast_jdg -n 3scale```
	* ab -n 1000 -c 20 https://api-3scale-apicast-production.[*replace with your domain*]:443?user_key=[*replace with a user_key for this API*]
	* Compare results with/without caching.


Example results:

| Backend API | With JDG Caching | Without Caching |
| :---------- | ---------------: | --------------: |
| Local	Cluster|min: 15, mean: 58, max: 126 |min: 6, mean: 64, max: 150   |
| Remote Echo |min: 11, mean: 51, max: 86 |min: 171, mean: 278, max: 917 |	
