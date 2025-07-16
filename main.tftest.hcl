
# Unit test to validate the variable. 
# This will not apply/ create the resource, just do terraform plan
run "check_subnet_overlap" {
  command = plan
 
  assert {
    condition     = var.subnet_cidr_1 != var.subnet_cidr_2
    error_message = "Subnet CIDr's are overlapping"
  }
}

# Integration test to validate the resource get created or not
# This will do terraform apply/ try to create actual resource 
# Note - This will create all the re sources in main.tf, 
# If you want ot check only specifc resources then creation of other resources should be based on a flag.
run "check_subnet" {
#   variables {
#     subnet_cidr_2 = "10.0.1.0/24"
#   }
 
  command = apply
 
  assert {
    condition     = can(length(output.subnet_id)) && output.subnet_id != ""
    error_message = "Subnet was not created or subnet_id output is empty."
  }
 
}