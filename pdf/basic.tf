resource "local_file" "terraform_file" {
  filename = "hello.pdf"
  content  = var.file_content
}

resource "local_file" "hello" {
    filename = "hello-backup.pdf"
    content = local_file.terraform_file.content
}