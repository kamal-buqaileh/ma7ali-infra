# routes module outputs

output "route_table_ids" {
  description = "List of route table IDs"
  value       = aws_route_table.this[*].id
}

output "route_table_arns" {
  description = "List of route table ARNs"
  value       = aws_route_table.this[*].arn
}

output "route_tables_by_name" {
  description = "Map of route table IDs by name"
  value = {
    for i, route_table in aws_route_table.this :
    var.route_tables[i].name => route_table.id
  }
}
