
run "check_subnet_overlap" {
  command = plan
 
  assert {
    condition     = var.subnet_cidr_1 != var.subnet_cidr_2
    error_message = "Subnet CIDr's are overlapping"
  }
}