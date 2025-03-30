# print the webserver public ip
output "webserver_public_ip" {
  value = aws_instance.web-server.public_ip
}

# print the url of the load balancer
output "load_balancer_dns_name" {
  value = aws_lb.application-lb.dns_name
}

# print the private IP of the web server
output "webserver_private_ip" {
  value = aws_instance.web-server.private_ip
}

# print the HTTPS URL
output "https_url" {
  value = "https://${aws_lb.application-lb.dns_name}"
}
#print the instance id url
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web-server.id
}