# 3scale-JDG-Demo
The idea of this demo is setup an example of how to use RH DataGrid to cache API requests in 3scale API Manager.

![Demo Architecture](images/3scale+JDG_Demo.png)
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
	* Run a performance test (with caching enabled)
		* `ab -n 1000 -c 20 https://products-apicast-production.gateway.<`*`replace with your domain`*`>:443/rest/services/products?user_key=<`*`replace with a user_key for this API`*`>`
	* Take note of the results
	* Disable caching in Apicast
		* ```foo@bar:~$ oc set env dc/apicast-production APICAST_MODULE=cors.apicast_cors -n 3scale```
	* Run a second performance test (without caching)
		* `ab -n 1000 -c 20 https://products-apicast-production.gateway.<`*`replace with your domain`*`>:443/rest/services/products?user_key=<`*`replace with a user_key for this API`*`>`
	* Compare results with/without caching.

4. You can test the performance improvements on a remote backend API by executing:
	* Run a performance test (without caching)
		* `ab -n 1000 -c 20 https://api-3scale-apicast-production.<`*`replace with your domain`*`>:443?user_key=<`*`replace with a user_key for this API`*`>`
	* Take note of the results
	* Enable caching again
		* ```foo@bar:~$ oc set env dc/apicast-production APICAST_MODULE=jdg.apicast_jdg -n 3scale```
	* Run a seconf performance test (with caching enabled)
		* `ab -n 1000 -c 20 https://api-3scale-apicast-production.<`*`replace with your domain`*`>:443?user_key=<`*`replace with a user_key for this API`*`>`
	* Compare results with/without caching.

### Notes
 * JDG expiration for objects is hardcoded to 60sec (this could be made configurable)
 * You can easily check the existing cached objects at http://datagrid.<replace with your domain>/rest/default
 * 3scale admin console:
 * URL: https://3scale-admin.< *replace with your domain* >
	* User: admin
	* Password: admin
