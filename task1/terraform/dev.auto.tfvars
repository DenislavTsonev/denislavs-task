runtime = "python3.12"
handler = "dummy.lambda_handler"
lambda_policies = [
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
]
