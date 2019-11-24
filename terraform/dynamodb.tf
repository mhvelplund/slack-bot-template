resource "aws_dynamodb_table" "teams" {
  count = var.create_dynamodb_for_oauth ? 1 : 0

  name           = var.dynamodb_table_name
  hash_key       = "team_id"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "team_id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}

data aws_iam_policy_document dynamodb {
  count = var.create_dynamodb_for_oauth ? 1 : 0

  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]

    resources = [aws_dynamodb_table.teams[0].arn]
  }
}

resource aws_iam_policy dynamodb {
  count = var.create_dynamodb_for_oauth ? 1 : 0

  name   = "AccessTeamsDynamoDBTable"
  policy = data.aws_iam_policy_document.dynamodb[0].json
}

resource aws_iam_role_policy_attachment dynamodb {
  count = var.create_dynamodb_for_oauth ? 1 : 0

  role       = module.apigateway.lambda_role_name
  policy_arn = aws_iam_policy.dynamodb[0].arn
}