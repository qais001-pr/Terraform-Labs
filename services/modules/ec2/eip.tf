resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-eip"
  }
}
