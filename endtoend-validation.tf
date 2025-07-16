# Create VPC
# E2E test here - Check if the final/ public facing endpoint URL is accessible 
# Even the authorisation fails, we can cehck different status code.
# For this example - I hardcoded the URL, still we can pass the reference from difference resource and 
# it will be validated after the resource got created.
check "health_check" {
  data "http" "terraform_io" {
    url = "https://www.terraform.io"
  }

  assert {
    condition = data.http.terraform_io.status_code == 200
    error_message = "${data.http.terraform_io.url} returned an unhealthy status code"
  }
}
