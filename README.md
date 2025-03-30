# AWS Load Balancer with Terraform  
Premise of this project is to deploy a secure web server behind an HTTPS ALB in AWS.

# Architecture 
  VPC with public/private subnets
  ALB terminating SSL with self-signed cert
  EC2 instance in private subnet running Apache

## **Prerequisites**  
- Terraform v1.5+  
- AWS CLI configured on local machine
- Key pair (`ubuntu.pem`) in project directory 

## **Usage**  Please run commands in order
1. Initialize:  
   terraform init

2. Deploy:  
   terraform plan
   terraform apply 

3. Access:
   Website: https://$(terraform output -raw load_balancer_dns_name)
   SSH (via SSM): aws ssm start-session --target $(terraform output -raw instance_id) 

4. Troubleshooting:
   Validate ALB HTTPS (Copy code in between curly brackets and paste on terminal command line, when command is ran it should return HTML w/ hostname){
       ```bash 
    curl -vk https://$(terraform output -raw load_balancer_dns_name)  
   }

   Check Instance Health (Copy code in between curly brackets and paste on terminal command line, when the command is ran targets SHOULD say healthy){
       aws elbv2 describe-target-health \
       --target-group-arn $(aws elbv2 describe-target-groups --query "TargetGroups[0].TargetGroupArn" --output text)
   }

   Test end to end (Copy code in between curly brackets and paste on terminal command line, FOR THIS COMMAND RUN ON LOCAL MACHINE!!){
       ALB_URL=$(terraform output -raw load_balancer_dns_name)
       echo "https://$ALB_URL" 
   }

   Cost Estimation: Option#1 Using Infracost 
   Service      	Configuration	        Cost/Month
   EC2 t2.micro	    730 hours(always-on)       $9.52
   ALB	            1 LCU average	           $19.71
   NAT Gateway	    1 + data processing	       $34.56
   EIP	            1 attached to NAT	       $3.60
                                         Total:$67.39
                            
   Cost Estimation: Option#2 via AWS cli (Copy code in between curly brackets and paste on terminal command line,){

   
   aws pricing get-products --service-code AmazonEC2 \
  --filters "Type=TERM_MATCH,Field=instanceType,Value=t2.micro" \
  --query "PriceList[0]" --output text | jq .

   } **if using Mac OS please install jq (brew install jq)

5. Additional Troubleshooting   
   Symptom	                            Solution
   ALB 403 errors	                    Check /var/www/html permissions
   Health check failures	            Test curl http://localhost/health.html on instance
   SSH timeouts	                        Verify NAT gateway routes