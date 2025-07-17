This creates the sample infra code which creates networking(VPC, subnets ane other resources) + ECS

**Testing** part

1. Unit test - You can refer the **main.tftest.hcl** file, this is executed during **terraform test**
   - **run** block with command plan, this just do the test by only planning,
   - here we can validate the variables are passed based on the expectation.
   - if any parsing, we did on our code works as expected.
  
2. Integration test - You can refer the **main.tftest.hcl** file
   - **run** block with command apply, this do apply + destroy
   - Here we can validate the complete integration, after the apply we can check the expected condition
   - check if the resource gets created successfully or not.

3. E2E test - Refer **enedtoend-validation.tf** file
   - **check** block - Once all the resources are created we can validate the final endpoint of the application 
