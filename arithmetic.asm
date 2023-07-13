addi x5, zero, 15
addi x6, zero, -5
add x31, x5, x6

addi x5, zero, 5
addi x6, zero, 15
sub x30, x5, x6

addi x6, zero, -15
add x29, x5, x6


lui x10, 0x7ffff
addi x9, x10, 0x7ff
addi x8, x9, 0x7ff
add x5, zero, x8


addi x6, zero, 3
add x28, x5, x6


addi x5, zero, -1
addi x6, zero, 1

slt x27, x5, x6

auipc x11, 0x7ffff

addi x15, zero, 4
addi x12, zero, -1
addi x13, zero, -1
addi x14, zero -1

sll x12, x12, x15
srl x13, x13, x15
sra x14, x14, x15

