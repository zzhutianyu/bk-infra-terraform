data "local_file" "key" {
    count = try(length(var.keys, 0))
    filename = "${path.module}/ssh_key/${var.keys[count.index]}"
}

output "keys_content" {
    value = try(length(data.local_file.key) == 0, true) ? "" : join("\n", data.local_file.key.*.content)
}