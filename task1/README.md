# Solution description

I'm going to use the community public terraform modules to provision the VPC, RDS and S3 because they are well-known services and I think are well-written.

I'm going to create a lambda as a simple resource/s, because I think the community module is very complicated and there are a few functionalities that should be outside of the module (at least in my opinion).

For AppRunner services I will write my module because I never used that service and it's interesting to get to know all the components.

> Components like Lambda, Apprunner (outgoing traffic) are using VPC configuration in order to keep traffic under our control.

## AppRunner
In order to keep the outgoing traffic in control and to be able to access services not publicly available in our VPC, we should create VPC connector. The ingress traffic is still from public internet, but the outgoing traffic is in the VPC.

There is a simple app in the [app](./task1/app/) folder just for illustrative purposes. The app will create a table with few "usernames" (see dummy_records.csv) just to get them via url endpoint (again, it's not the right think, but just for quick check if everything is working). The other endpoint will return a list of files on s3
    - /postges
    - /s3

Also the apprunner module needs improvements, adding a few more configuration in the apprunner service, also how the apprunner connection is made (in the current case is done manually).


## The RDS
Maybe is good to configure IAM authentication for the user not using the user/pass. - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html 


## The lambda function
I'm using a code from the module (slightly modified) in order to not have all the resources in the task deployed via public modules. Also, I think the public module is too complicated.
I've added a RDS read only policy to the role attached to the lambda (not sure what Telemetry analyzer means, maybe is just quering the DB as SQL queries or maybe is RDS AWS api calls).